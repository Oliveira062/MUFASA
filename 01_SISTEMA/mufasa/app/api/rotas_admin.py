"""
Administracao tecnica, parametros versionados e pedidos ao encarregado.

Administracao (Anexo E): configura, carrega dados, gerencia contas e le os
registros tecnicos. Nao le o conteudo dos dados pela interface: nenhuma
rota daqui devolve nota, renda ou score de aluno.

Parametros (Anexo B, tabela C.2; RN22): a administracao edita; nota e
cortes de risco so mudam com aprovacao da coordenacao; intervalo entre
atendimentos e teto de alertas sao da coordenacao. Toda mudanca gera uma
versao nova com autor, aprovador, justificativa e a fotografia dos valores.
"""

import hashlib
import json
from collections import defaultdict
from enum import Enum
from typing import Annotated

from fastapi import APIRouter, Depends, File, Form, Path, Query, Request, UploadFile
from pydantic import Field
from sqlalchemy.engine import Connection
from sqlalchemy.exc import IntegrityError

from app.api import auditoria, consultas_painel as sqlp
from app.api.auth import Usuario, exigir_perfis, gerar_hash_senha
from app.api.banco import obter_conexao
from app.api.erros import erro_http
from app.api.esquemas import PADRAO_MATRICULA, Fechado, Perfil
from app.api.notificar import notificar, usuarios_do_perfil
from app.api.permissoes import ADMIN, ALUNO, COORDENACAO, DOCENTE, ENCARREGADO_DADOS, NUCLEO_APOIO
from app.api.senhas import gerar_senha_provisoria
from app.api.util import agora, como_datetime, numero, valor_json
from app.api.validacao_carga import TAMANHO_MAXIMO, ArquivoInvalido, ler_csv, validar
from app.calculo.parametros import CATALOGO, problemas_de_coerencia

router_admin = APIRouter(prefix="/api/v1", tags=["administracao"])

SINAL_MAXIMO_S = 60

# Anexo B, coluna "Quem altera".
PRECISA_APROVACAO_COORDENACAO = {"NOTA_MINIMA", "NOTA_CONFORTAVEL", "NOTA_CRITICA",
                                 "CORTE_BAIXO", "CORTE_MODERADO", "CORTE_ALTO"}
ALTERADOS_PELA_COORDENACAO = {"INTERVALO_ATENDIMENTOS", "TETO_ALERTAS_RESPONSAVEL"}


def quem_altera(chave: str, editavel: bool) -> str:
    if not editavel:
        return "Somente por recalibração formal (Anexo A.9)"
    if chave in ALTERADOS_PELA_COORDENACAO:
        return "Coordenação"
    if chave in PRECISA_APROVACAO_COORDENACAO:
        return "Administração, com aprovação da coordenação"
    return "Administração"


# ---------------------------------------------------------------------------
# Usuarios
# ---------------------------------------------------------------------------

class PedidoUsuario(Fechado):
    login: str = Field(min_length=3, max_length=64, pattern=r"^[A-Za-z0-9._@-]+$")
    nome: str = Field(min_length=3, max_length=120)
    email: str | None = Field(default=None, max_length=160, pattern=r"^[^@\s]+@[^@\s]+\.[^@\s]+$")
    perfil: Perfil
    id_curso: str | None = Field(default=None, pattern=r"^[A-Z0-9]{2,12}$")
    id_professor: str | None = Field(default=None, pattern=r"^[A-Za-z0-9_-]{2,40}$")
    id_aluno: str | None = Field(default=None, pattern=PADRAO_MATRICULA)


class PedidoMudancaUsuario(Fechado):
    ativo: bool | None = None
    redefinir_senha: bool = False
    desbloquear: bool = False


@router_admin.get("/admin/usuarios")
def listar_usuarios(request: Request, perfil: Perfil | None = None,
                    busca: Annotated[str | None, Query(max_length=60, pattern=r"^[\w .@-]*$")] = None,
                    limite: Annotated[int, Query(ge=1, le=200)] = 50,
                    pagina: Annotated[int, Query(ge=1, le=10_000)] = 1,
                    usuario: Usuario = Depends(exigir_perfis(ADMIN)), conexao: Connection = Depends(obter_conexao)):
    linhas = conexao.execute(sqlp.LISTAR_USUARIOS, {
        "perfil": perfil.value if perfil else None, "busca": f"%{busca.lower()}%" if busca else None,
        "agora": agora(), "limite": limite, "deslocamento": (pagina - 1) * limite}).mappings().all()
    resumo = conexao.execute(sqlp.CONTAR_USUARIOS).mappings().all()
    auditoria.registrar(request, "LISTAR_USUARIOS", "PERMITIDO", usuario=usuario)
    return {"resumo": [dict(r) for r in resumo],
            "itens": [{k: valor_json(v) for k, v in l.items()} for l in linhas]}


@router_admin.post("/admin/usuarios", status_code=201)
def criar_usuario(pedido: PedidoUsuario, request: Request, usuario: Usuario = Depends(exigir_perfis(ADMIN)),
                  conexao: Connection = Depends(obter_conexao)):
    """Cria a conta com senha provisoria, mostrada uma unica vez; troca obrigatoria no primeiro acesso."""
    perfil = pedido.perfil.value
    if conexao.execute(sqlp.LOGIN_EXISTE, {"login": pedido.login}).first():
        raise erro_http(409, "Já existe uma conta com este login.")
    if perfil == ALUNO and (not pedido.id_aluno or not conexao.execute(sqlp.ALUNO_EXISTE,
                                                                        {"id_aluno": pedido.id_aluno}).first()):
        raise erro_http(422, "Conta de aluno precisa de uma matrícula cadastrada.")
    if perfil == DOCENTE and (not pedido.id_professor or not conexao.execute(
            sqlp.PROFESSOR_EXISTE, {"id_professor": pedido.id_professor}).first()):
        raise erro_http(422, "Conta de docente precisa de um professor cadastrado.")
    if perfil in (COORDENACAO, NUCLEO_APOIO) and (not pedido.id_curso or not conexao.execute(
            sqlp.CURSO_EXISTE, {"id_curso": pedido.id_curso}).first()):
        raise erro_http(422, "Coordenação e núcleo de apoio precisam de um curso cadastrado.")
    senha = gerar_senha_provisoria()
    try:
        novo = conexao.execute(sqlp.CRIAR_USUARIO, {
            "login": pedido.login, "senha_hash": gerar_hash_senha(senha), "perfil": perfil,
            "id_aluno": pedido.id_aluno if perfil == ALUNO else None,
            "id_professor": pedido.id_professor if perfil == DOCENTE else None,
            "id_curso": pedido.id_curso, "nome": pedido.nome, "email": pedido.email}).scalar()
        conexao.commit()
    except IntegrityError:
        conexao.rollback()
        raise erro_http(409, "Conta já existente para este aluno ou login.")
    auditoria.registrar(request, "CRIAR_USUARIO", "PERMITIDO", usuario=usuario)
    return {"id_usuario": novo, "login": pedido.login, "senha_provisoria": senha,
            "aviso": "Entregue a senha por canal institucional. Ela não será mostrada de novo."}


@router_admin.patch("/admin/usuarios/{id_usuario}")
def mudar_usuario(id_usuario: Annotated[int, Path(ge=1)], pedido: PedidoMudancaUsuario, request: Request,
                  usuario: Usuario = Depends(exigir_perfis(ADMIN)), conexao: Connection = Depends(obter_conexao)):
    alvo = conexao.execute(sqlp.USUARIO_PARA_ADMIN, {"id_usuario": id_usuario}).mappings().first()
    if alvo is None:
        raise erro_http(404, "Usuário não encontrado.")
    if alvo["id_usuario"] == usuario.id_usuario and pedido.ativo is False:
        raise erro_http(409, "Você não pode desativar a própria conta.")
    resposta = {"atualizado": True}
    if pedido.ativo is not None:
        conexao.execute(sqlp.ATIVAR_USUARIO, {"ativo": pedido.ativo, "id_usuario": id_usuario})
    if pedido.desbloquear:
        conexao.execute(sqlp.DESBLOQUEAR, {"id_usuario": id_usuario})
    if pedido.redefinir_senha:
        senha = gerar_senha_provisoria()
        conexao.execute(sqlp.REDEFINIR_SENHA, {"senha_hash": gerar_hash_senha(senha), "id_usuario": id_usuario})
        resposta["senha_provisoria"] = senha
    conexao.commit()
    auditoria.registrar(request, "MUDAR_USUARIO", "PERMITIDO", usuario=usuario)
    return resposta


# ---------------------------------------------------------------------------
# Cargas de CSV (RN08, RF06; endpoint /importacoes do Anexo D.1)
# ---------------------------------------------------------------------------

class TipoCarga(str, Enum):
    NOTAS = "NOTAS"
    INDICADORES = "INDICADORES"


async def _ler_ate_o_limite(arquivo: UploadFile) -> bytes:
    conteudo = await arquivo.read(TAMANHO_MAXIMO + 1)
    if len(conteudo) > TAMANHO_MAXIMO:
        raise erro_http(413, "Arquivo acima de 20 MB.")
    return conteudo


@router_admin.post("/importacoes", status_code=201)
async def enviar_carga(request: Request, tipo: Annotated[TipoCarga, Form()], arquivo: UploadFile = File(...),
                       usuario: Usuario = Depends(exigir_perfis(ADMIN)), conexao: Connection = Depends(obter_conexao)):
    """
    Recebe e valida. Nada vai para as tabelas de dados aqui: carga valida fica
    VALIDADA e espera confirmacao; com qualquer erro, fica COM_ERROS e nenhuma
    linha e aplicada (sem carga parcial).
    """
    conteudo = await _ler_ate_o_limite(arquivo)
    resumo = hashlib.sha256(conteudo).hexdigest()
    nome = (arquivo.filename or "arquivo.csv").replace("\\", "/").split("/")[-1][:120]
    repetida = conexao.execute(sqlp.CARGA_COM_HASH, {"hash": resumo}).mappings().first()
    if repetida:
        raise erro_http(409, f"Este mesmo arquivo já está na carga {repetida['id_carga']} "
                             f"({repetida['situacao'].lower()}).")
    try:
        linhas = ler_csv(conteudo, tipo.value)
    except ArquivoInvalido as exc:
        auditoria.registrar(request, "CARGA_RECUSADA", "NEGADO", usuario=usuario)
        raise erro_http(422, str(exc))

    alunos = set(conexao.execute(sqlp.IDS_ALUNOS).scalars())
    matriculas = {(m["id_aluno"], m["id_turma"]): m["id_matricula"]
                  for m in conexao.execute(sqlp.TURMAS_E_MATRICULAS).mappings()}
    resultado = validar(linhas, tipo.value, alunos, matriculas)
    situacao = "COM_ERROS" if resultado.erros else "VALIDADA"
    id_carga = conexao.execute(sqlp.CRIAR_CARGA, {
        "tipo": tipo.value, "nome_arquivo": nome, "tamanho_bytes": len(conteudo), "hash": resumo,
        "enviado_por": usuario.id_usuario, "agora": agora(), "situacao": situacao,
        "linhas_total": resultado.total, "linhas_validas": len(resultado.validas)}).scalar()

    if resultado.erros:
        por_linha = defaultdict(list)
        for numero_linha, erro in resultado.erros:
            por_linha[numero_linha].append(erro)
        for numero_linha, erros in por_linha.items():
            conexao.execute(sqlp.CRIAR_LINHA_CARGA, {"id_carga": id_carga, "numero": numero_linha, "dados": None,
                                                     "erro": json.dumps(erros, ensure_ascii=False)[:300]})
    else:
        for numero_linha, dados in resultado.validas:
            conexao.execute(sqlp.CRIAR_LINHA_CARGA, {"id_carga": id_carga, "numero": numero_linha,
                                                     "dados": json.dumps(dados), "erro": None})
    conexao.commit()
    auditoria.registrar(request, "CARGA_ENVIADA", "PERMITIDO", usuario=usuario)
    return {"id_carga": id_carga, "situacao": situacao, "linhas_total": resultado.total,
            "linhas_validas": len(resultado.validas), "linhas_com_erro": len({n for n, _ in resultado.erros}),
            "hash_sha256": resumo,
            "rejeicoes": [{"linha": n, **e} for n, e in resultado.erros[:500]],
            "proximo_passo": "Confirme a carga para aplicar." if situacao == "VALIDADA" else
            "Corrija as linhas e envie o arquivo de novo. Nenhuma linha foi aplicada."}


@router_admin.get("/importacoes")
def listar_cargas(limite: Annotated[int, Query(ge=1, le=200)] = 30, pagina: Annotated[int, Query(ge=1)] = 1,
                  usuario: Usuario = Depends(exigir_perfis(ADMIN)), conexao: Connection = Depends(obter_conexao)):
    linhas = conexao.execute(sqlp.LISTAR_CARGAS, {"limite": limite, "deslocamento": (pagina - 1) * limite}).mappings()
    return [{k: valor_json(v) for k, v in l.items()} for l in linhas]


@router_admin.get("/importacoes/{id_carga}")
def situacao_da_carga(id_carga: Annotated[int, Path(ge=1)], usuario: Usuario = Depends(exigir_perfis(ADMIN)),
                      conexao: Connection = Depends(obter_conexao)):
    carga = conexao.execute(sqlp.CARGA_POR_ID, {"id_carga": id_carga}).mappings().first()
    if carga is None:
        raise erro_http(404, "Carga não encontrada.")
    rejeicoes = []
    for l in conexao.execute(sqlp.REJEICOES_DA_CARGA, {"id_carga": id_carga}).mappings():
        try:
            rejeicoes.extend({"linha": l["numero"], **e} for e in json.loads(l["erro"]))
        except ValueError:  # relatorio cortado em 300 caracteres
            rejeicoes.append({"linha": l["numero"], "campo": "-", "valor": "", "motivo": "vários erros nesta linha"})
    return {**{k: valor_json(v) for k, v in carga.items() if k != "enviado_por"}, "rejeicoes": rejeicoes}


class AcaoCarga(str, Enum):
    confirmacao = "confirmacao"
    cancelamento = "cancelamento"


@router_admin.post("/importacoes/{id_carga}/{acao}")
def decidir_carga(id_carga: Annotated[int, Path(ge=1)], acao: AcaoCarga, request: Request,
                  usuario: Usuario = Depends(exigir_perfis(ADMIN)), conexao: Connection = Depends(obter_conexao)):
    nova = "CONFIRMADA" if acao == AcaoCarga.confirmacao else "CANCELADA"
    alterada = conexao.execute(sqlp.MUDAR_CARGA, {"nova": nova, "id_usuario": usuario.id_usuario, "agora": agora(),
                                                  "id_carga": id_carga}).rowcount
    if not alterada:
        conexao.rollback()
        raise erro_http(409, "Só carga validada e ainda não confirmada pode ser confirmada ou cancelada.")
    if nova == "CONFIRMADA":
        conexao.execute(sqlp.ACORDAR_CALCULO)
    conexao.commit()
    auditoria.registrar(request, "CARGA_" + nova, "PERMITIDO", usuario=usuario)
    return {"situacao": nova, "observacao": "O serviço de cálculo aplica a carga e recalcula os alunos afetados."
            if nova == "CONFIRMADA" else None}


# ---------------------------------------------------------------------------
# Operacao: servicos, registros tecnicos e recalculo
# ---------------------------------------------------------------------------

class Servico(str, Enum):
    api = "api"
    chat = "chat"
    calculo = "calculo"
    painel = "painel"


class NivelLog(str, Enum):
    INFO = "INFO"
    AVISO = "AVISO"
    ERRO = "ERRO"


@router_admin.get("/admin/servicos")
def situacao_dos_servicos(usuario: Usuario = Depends(exigir_perfis(ADMIN)),
                          conexao: Connection = Depends(obter_conexao)):
    momento = agora()
    servicos = []
    for l in conexao.execute(sqlp.SERVICOS).mappings():
        idade = (momento - como_datetime(l["ultimo_sinal"])).total_seconds()
        servicos.append({"servico": l["servico"], "ultimo_sinal": valor_json(l["ultimo_sinal"]),
                         "segundos_desde_sinal": int(idade), "no_ar": idade <= SINAL_MAXIMO_S, "detalhe": l["detalhe"]})
    return {"servicos": servicos, "alunos_na_fila_de_calculo": int(conexao.execute(sqlp.TAMANHO_FILA).scalar() or 0)}


@router_admin.get("/admin/registros")
def registros_tecnicos(servico: Servico | None = None, nivel: NivelLog | None = None,
                       limite: Annotated[int, Query(ge=1, le=500)] = 100, pagina: Annotated[int, Query(ge=1)] = 1,
                       usuario: Usuario = Depends(exigir_perfis(ADMIN)), conexao: Connection = Depends(obter_conexao)):
    linhas = conexao.execute(sqlp.REGISTROS_TECNICOS, {
        "servico": servico.value if servico else None, "nivel": nivel.value if nivel else None,
        "limite": limite, "deslocamento": (pagina - 1) * limite}).mappings()
    return [{k: valor_json(v) for k, v in l.items()} for l in linhas]


class PedidoCalculo(Fechado):
    curso: str | None = Field(default=None, pattern=r"^[A-Z0-9]{2,12}$")
    semestre: int | None = Field(default=None, ge=1, le=20)


@router_admin.post("/calculos", status_code=202)
def disparar_recalculo(pedido: PedidoCalculo, request: Request, usuario: Usuario = Depends(exigir_perfis(ADMIN)),
                       conexao: Connection = Depends(obter_conexao)):
    """Recalculo total ou filtrado (Anexo D.1). A API so enfileira; o servico de calculo processa."""
    total = conexao.execute(sqlp.ENFILEIRAR_TODOS, {"id_curso": pedido.curso, "semestre": pedido.semestre}).rowcount
    conexao.execute(sqlp.ACORDAR_CALCULO)
    conexao.commit()
    auditoria.registrar(request, "DISPARAR_RECALCULO", "PERMITIDO", usuario=usuario)
    return {"alunos_enfileirados": total}


# ---------------------------------------------------------------------------
# Parametros (RN22, RF23)
# ---------------------------------------------------------------------------

class PedidoParametro(Fechado):
    valor: float
    justificativa: str = Field(min_length=10, max_length=500)


class PedidoDecisao(Fechado):
    aprovar: bool


def _valores_vigentes(conexao: Connection) -> dict:
    return {l["chave"]: float(l["valor"]) for l in conexao.execute(sqlp.VALORES_PARAMETROS).mappings()}


def _aplicar(conexao: Connection, chave: str, valor: float, autor: int, aprovador: int | None,
             justificativa: str) -> int:
    """Grava o valor e a versao nova (fotografia completa) na mesma transacao."""
    conexao.execute(sqlp.TRAVAR_VERSOES)
    problemas = problemas_de_coerencia({**_valores_vigentes(conexao), chave: valor})
    if problemas:
        raise erro_http(422, "Valor incoerente com os demais parâmetros: " + " ".join(problemas))
    versao = conexao.execute(sqlp.PROXIMA_VERSAO).scalar()
    momento = agora()
    conexao.execute(sqlp.APLICAR_PARAMETRO, {"valor": valor, "agora": momento, "chave": chave})
    conexao.execute(sqlp.CRIAR_VERSAO, {"versao": versao, "agora": momento, "autor": autor, "aprovador": aprovador,
                                        "justificativa": f"{chave}: {justificativa}"[:500]})
    return versao


@router_admin.get("/parametros", tags=["parametros"])
def listar_parametros(usuario: Usuario = Depends(exigir_perfis(ADMIN, COORDENACAO)),
                      conexao: Connection = Depends(obter_conexao)):
    linhas = conexao.execute(sqlp.LISTAR_PARAMETROS).mappings().all()
    return {
        "parametros": [{**{k: valor_json(v) for k, v in l.items()},
                        "padrao_srs": CATALOGO[l["chave"]][0] if l["chave"] in CATALOGO else None,
                        "quem_altera": quem_altera(l["chave"], l["editavel"])} for l in linhas],
        "versoes": [{k: valor_json(v) for k, v in l.items()} for l in conexao.execute(sqlp.VERSOES).mappings()],
        "propostas": [{k: valor_json(v) for k, v in l.items()} for l in conexao.execute(sqlp.PROPOSTAS).mappings()],
    }


@router_admin.put("/parametros/{chave}", tags=["parametros"])
def alterar_parametro(chave: Annotated[str, Path(pattern=r"^[A-Z0-9_]{3,40}$")], pedido: PedidoParametro,
                      request: Request, usuario: Usuario = Depends(exigir_perfis(ADMIN, COORDENACAO)),
                      conexao: Connection = Depends(obter_conexao)):
    atual = conexao.execute(sqlp.PARAMETRO, {"chave": chave}).mappings().first()
    if atual is None:
        raise erro_http(404, "Parâmetro não encontrado.")
    if not atual["editavel"]:
        raise erro_http(409, "Este parâmetro só muda por recalibração formal do modelo (Anexo A.9).")
    da_coordenacao = chave in ALTERADOS_PELA_COORDENACAO
    if da_coordenacao != (usuario.perfil == COORDENACAO):
        raise erro_http(403, f"Quem altera este parâmetro: {quem_altera(chave, True)}.")
    if not numero(atual["minimo"]) <= pedido.valor <= numero(atual["maximo"]):
        raise erro_http(422, f"Valor fora da faixa permitida ({numero(atual['minimo']):g} a "
                             f"{numero(atual['maximo']):g}).")
    if pedido.valor == numero(atual["valor"]):
        raise erro_http(409, "O valor informado é o valor vigente.")

    if chave in PRECISA_APROVACAO_COORDENACAO:
        if conexao.execute(sqlp.PENDENTE_DA_CHAVE, {"chave": chave}).first():
            raise erro_http(409, "Já existe uma proposta pendente para este parâmetro.")
        problemas = problemas_de_coerencia({**_valores_vigentes(conexao), chave: pedido.valor})
        if problemas:
            raise erro_http(422, "Valor incoerente com os demais parâmetros: " + " ".join(problemas))
        id_proposta = conexao.execute(sqlp.CRIAR_PROPOSTA, {
            "chave": chave, "valor_anterior": atual["valor"], "valor_novo": pedido.valor,
            "justificativa": pedido.justificativa, "proposto_por": usuario.id_usuario, "agora": agora()}).scalar()
        notificar(conexao, usuarios_do_perfil(conexao, COORDENACAO), "PARAMETRO", "Parâmetro aguarda aprovação",
                  f"Proposta de mudar {chave} de {numero(atual['valor']):g} para {pedido.valor:g}.")
        conexao.commit()
        auditoria.registrar(request, "PROPOR_PARAMETRO", "PERMITIDO", usuario=usuario)
        return {"situacao": "PENDENTE", "id_proposta": id_proposta,
                "observacao": "A mudança vale depois da aprovação da coordenação."}

    versao = _aplicar(conexao, chave, pedido.valor, usuario.id_usuario, None, pedido.justificativa)
    conexao.commit()
    auditoria.registrar(request, "ALTERAR_PARAMETRO", "PERMITIDO", usuario=usuario)
    return {"situacao": "APLICADO", "versao": versao,
            "observacao": "Scores anteriores continuam com a versão que os gerou; os alunos serão recalculados."}


@router_admin.post("/parametros/propostas/{id_proposta}/decisao", tags=["parametros"])
def decidir_proposta(id_proposta: Annotated[int, Path(ge=1)], pedido: PedidoDecisao, request: Request,
                     usuario: Usuario = Depends(exigir_perfis(COORDENACAO)),
                     conexao: Connection = Depends(obter_conexao)):
    proposta = conexao.execute(sqlp.PROPOSTA_PENDENTE, {"id_proposta": id_proposta}).mappings().first()
    if proposta is None:
        raise erro_http(404, "Proposta não encontrada ou já decidida.")
    if proposta["proposto_por"] == usuario.id_usuario:
        raise erro_http(403, "Quem propõe não aprova a própria proposta.")
    versao = None
    if pedido.aprovar:
        versao = _aplicar(conexao, proposta["chave"], float(proposta["valor_novo"]), proposta["proposto_por"],
                          usuario.id_usuario, proposta["justificativa"])
    conexao.execute(sqlp.DECIDIR_PROPOSTA, {"situacao": "APROVADA" if pedido.aprovar else "REJEITADA",
                                            "decidido_por": usuario.id_usuario, "agora": agora(), "versao": versao,
                                            "id_proposta": id_proposta})
    notificar(conexao, [proposta["proposto_por"]], "PARAMETRO",
              f"Proposta de {proposta['chave']} {'aprovada' if pedido.aprovar else 'rejeitada'}",
              f"A coordenação {'aprovou' if pedido.aprovar else 'rejeitou'} a proposta {id_proposta}.")
    conexao.commit()
    auditoria.registrar(request, "DECIDIR_PARAMETRO", "PERMITIDO", usuario=usuario)
    return {"situacao": "APROVADA" if pedido.aprovar else "REJEITADA", "versao": versao}


# ---------------------------------------------------------------------------
# Encarregado de dados: resposta aos pedidos do titular (LGPD art. 18)
# ---------------------------------------------------------------------------

class SituacaoSolicitacao(str, Enum):
    EM_ANALISE = "EM_ANALISE"
    ATENDIDA = "ATENDIDA"
    NEGADA = "NEGADA"


class PedidoRespostaSolicitacao(Fechado):
    situacao: SituacaoSolicitacao


@router_admin.patch("/privacidade/solicitacoes/{id_solicitacao}", tags=["privacidade"])
def responder_solicitacao(id_solicitacao: Annotated[int, Path(ge=1)], pedido: PedidoRespostaSolicitacao,
                          request: Request, usuario: Usuario = Depends(exigir_perfis(ENCARREGADO_DADOS)),
                          conexao: Connection = Depends(obter_conexao)):
    linha = conexao.execute(sqlp.SOLICITACAO_POR_ID, {"id": id_solicitacao}).mappings().first()
    if linha is None:
        raise erro_http(404, "Solicitação não encontrada.")
    if linha["situacao"] in ("ATENDIDA", "NEGADA"):
        raise erro_http(409, "Esta solicitação já foi respondida.")
    conexao.execute(sqlp.RESPONDER_SOLICITACAO, {"situacao": pedido.situacao.value, "id": id_solicitacao,
                                                 "agora": agora() if pedido.situacao != SituacaoSolicitacao.EM_ANALISE
                                                 else None})
    conexao.commit()
    auditoria.registrar(request, "RESPONDER_SOLICITACAO", "PERMITIDO", usuario=usuario)
    return {"situacao": pedido.situacao.value}
