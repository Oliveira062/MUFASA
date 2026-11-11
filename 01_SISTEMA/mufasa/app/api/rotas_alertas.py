"""
Fila de alertas e acompanhamento (RN03, RN05, RN19, RF16, RF18, RF19, RF20).

Quem faz o que (Anexo E, "Alertas e acoes"):
- Coordenacao: gerencia os alertas do curso (atribui, registra, encerra).
- Nucleo de apoio: gerencia os alertas atribuidos a ele.
- Docente: registra acao e marca divergencia nos alertas dos seus alunos.
- Financeiro: registra acao nos alertas com fator financeiro.

O alerta nasce no servico de calculo. Aqui so ha decisao humana: nada e
executado sem um responsavel identificado (RN05).
"""

from enum import Enum
from typing import Annotated

from fastapi import APIRouter, Depends, Path, Query, Request
from pydantic import Field, model_validator
from sqlalchemy.engine import Connection

from app.api import auditoria, consultas_painel as sqlp
from app.api.auth import Usuario, exigir_perfis
from app.api.banco import obter_conexao
from app.api.erros import erro_http
from app.api.esquemas import Fechado, Nivel
from app.api.notificar import notificar, usuarios_do_perfil
from app.api.parametros_db import parametros_vigentes
from app.api.permissoes import COORDENACAO, DOCENTE, FINANCEIRO, NUCLEO_APOIO
from app.api.util import agora, valor_json
from app.api.visibilidade import principais_visiveis

router_alertas = APIRouter(prefix="/api/v1/alertas", tags=["alertas"])

MSG_ALERTA_NEGADO = "Você não tem permissão para acessar este alerta, ou ele não existe."
ROTULO_REGISTRO_RESTRITO = "Registro do núcleo de apoio (detalhe restrito ao núcleo)."

GERENCIAM = (COORDENACAO, NUCLEO_APOIO)
REGISTRAM = (COORDENACAO, NUCLEO_APOIO, DOCENTE, FINANCEIRO)


class Situacao(str, Enum):
    ABERTO = "ABERTO"
    EM_ATENDIMENTO = "EM_ATENDIMENTO"
    ENCERRADO = "ENCERRADO"


class TipoAlerta(str, Enum):
    PEDAGOGICO = "PEDAGOGICO"
    DADOS = "DADOS"


class TipoAcao(str, Enum):
    CONVERSA = "CONVERSA"
    ORIENTACAO_ACADEMICA = "ORIENTACAO_ACADEMICA"
    ENCAMINHAMENTO_NAE = "ENCAMINHAMENTO_NAE"
    ENCAMINHAMENTO_FINANCEIRO = "ENCAMINHAMENTO_FINANCEIRO"
    CONTATO_SEM_RETORNO = "CONTATO_SEM_RETORNO"
    OUTRO = "OUTRO"


class Causa(str, Enum):
    FINANCEIRA = "FINANCEIRA"
    ACADEMICA = "ACADEMICA"
    TRABALHO = "TRABALHO"
    SAUDE = "SAUDE"
    FAMILIAR = "FAMILIAR"
    TRANSPORTE = "TRANSPORTE"
    ESCOLHA_DE_CURSO = "ESCOLHA_DE_CURSO"
    INSTITUCIONAL = "INSTITUCIONAL"
    NAO_IDENTIFICADA = "NAO_IDENTIFICADA"


class Desfecho(str, Enum):
    PERMANECEU = "PERMANECEU"
    TRANCOU = "TRANCOU"
    EVADIU = "EVADIU"
    TRANSFERIU = "TRANSFERIU"
    EM_ACOMPANHAMENTO = "EM_ACOMPANHAMENTO"
    DADOS_CORRIGIDOS = "DADOS_CORRIGIDOS"


class Canal(str, Enum):
    AMBIENTE_VIRTUAL = "AMBIENTE_VIRTUAL"
    PRESENCIAL = "PRESENCIAL"
    EMAIL_INSTITUCIONAL = "EMAIL_INSTITUCIONAL"
    EMERGENCIA_RN19 = "EMERGENCIA_RN19"


class PedidoMudanca(Fechado):
    id_responsavel: int | None = Field(default=None, ge=1, description="Somente coordenação: atribui o alerta")
    assumir: bool = Field(default=False, description="Marca o alerta como em atendimento")

    @model_validator(mode="after")
    def _algo(self):
        if self.id_responsavel is None and not self.assumir:
            raise ValueError("informe id_responsavel ou assumir")
        return self


class PedidoAcao(Fechado):
    tipo_acao: TipoAcao
    descricao: str = Field(min_length=5, max_length=1000)
    visivel_aluno: bool = Field(default=False, description="O aluno vê este registro na área dele")


class PedidoEncerramento(Fechado):
    causa: Causa
    desfecho: Desfecho
    houve_contato: bool
    canal_contato: Canal | None = None
    acoes_executadas: str = Field(min_length=10, max_length=1000)

    @model_validator(mode="after")
    def _canal(self):
        if self.houve_contato and self.canal_contato is None:
            raise ValueError("informe o canal do contato")
        if not self.houve_contato and self.canal_contato is not None:
            raise ValueError("canal informado sem contato")
        return self


class PedidoDivergencia(Fechado):
    justificativa: str = Field(min_length=10, max_length=1000)


def _parametros_escopo(usuario: Usuario) -> dict:
    return {"id_curso": usuario.id_curso, "id_usuario": usuario.id_usuario, "id_professor": usuario.id_professor}


def obter_alerta(conexao: Connection, request: Request, usuario: Usuario, id_alerta: int, operacao: str):
    """Barra (e registra) alerta fora do escopo, com a mesma mensagem de inexistente."""
    linha = conexao.execute(sqlp.consulta_alerta_no_escopo(usuario.perfil),
                            {"id_alerta": id_alerta, **_parametros_escopo(usuario)}).mappings().first()
    if linha is None:
        auditoria.registrar(request, operacao, "NEGADO", usuario=usuario)
        raise erro_http(403, MSG_ALERTA_NEGADO)
    auditoria.registrar(request, operacao, "PERMITIDO", usuario=usuario, id_aluno_alvo=linha["id_aluno"])
    return linha


def _horas_para_prazo(prazo, momento) -> float | None:
    if prazo is None:
        return None
    return round((prazo - momento).total_seconds() / 3600, 1)


@router_alertas.get("")
def fila_de_alertas(request: Request,
                    situacao: Situacao | None = None, tipo: TipoAlerta | None = None, nivel: Nivel | None = None,
                    responsavel: Annotated[int | None, Query(ge=1)] = None, sem_responsavel: bool = False,
                    so_vencidos: bool = False,
                    limite: Annotated[int, Query(ge=1, le=200)] = 50,
                    pagina: Annotated[int, Query(ge=1, le=10_000)] = 1,
                    usuario: Usuario = Depends(exigir_perfis(*REGISTRAM)),
                    conexao: Connection = Depends(obter_conexao)):
    """Fila priorizada: Critico antes de Alto, prazo, score, tendencia e tempo sem contato (RN03, RF18)."""
    momento = agora()
    filtros = {"situacao": situacao.value if situacao else None, "tipo": tipo.value if tipo else None,
               "nivel": nivel.value if nivel else None, "responsavel": responsavel,
               "sem_responsavel": sem_responsavel, "so_vencidos": so_vencidos, "agora": momento,
               **_parametros_escopo(usuario)}
    total = conexao.execute(sqlp.consulta_total_fila(usuario.perfil), filtros).scalar()
    linhas = conexao.execute(sqlp.consulta_fila(usuario.perfil), {
        **filtros, "limite": limite, "deslocamento": (pagina - 1) * limite}).mappings().all()
    auditoria.registrar(request, "LISTAR_ALERTAS", "PERMITIDO", usuario=usuario)
    return {"total": total, "pagina": pagina, "limite": limite, "itens": [{
        "id_alerta": l["id_alerta"], "matricula": l["id_aluno"], "nome": l["nome_ficticio"],
        "semestre": l["semestre_atual"], "tipo": l["tipo"], "nivel": l["nivel"], "situacao": l["situacao"],
        "criado_em": valor_json(l["criado_em"]), "prazo_em": valor_json(l["prazo_em"]),
        "vencido": bool(l["vencido"]), "horas_para_prazo": _horas_para_prazo(l["prazo_em"], momento),
        "responsavel": l["responsavel"], "id_responsavel": l["id_responsavel"], "score": l["score"],
        "tendencia": l["tendencia"], "fatores_principais": principais_visiveis(usuario.perfil, l["fatores_principais"]),
        "ultima_acao_em": valor_json(l["ultima_acao_em"]), "primeira_acao_em": valor_json(l["primeira_acao_em"]),
        "causa": l["causa"], "desfecho": l["desfecho"],
    } for l in linhas]}


@router_alertas.get("/responsaveis")
def responsaveis(usuario: Usuario = Depends(exigir_perfis(COORDENACAO)), conexao: Connection = Depends(obter_conexao)):
    """Quem pode receber alertas do curso, com a carga atual e o teto (Anexo B)."""
    teto = int(parametros_vigentes(conexao)["TETO_ALERTAS_RESPONSAVEL"])
    linhas = conexao.execute(sqlp.RESPONSAVEIS, {"id_curso": usuario.id_curso}).mappings().all()
    return [{"id_usuario": l["id_usuario"], "nome": l["nome"], "perfil": l["perfil"],
             "alertas_abertos": int(l["alertas_abertos"]), "teto": teto,
             "no_teto": int(l["alertas_abertos"]) >= teto} for l in linhas]


def evento_visivel(usuario: Usuario, evento) -> dict:
    """Descricao livre pode citar saude ou renda: so o autor e o nucleo leem tudo."""
    descricao = evento["descricao"]
    proprio = evento["id_usuario"] == usuario.id_usuario
    if usuario.perfil == NUCLEO_APOIO or proprio or evento["id_usuario"] is None:
        pass
    elif evento["perfil_autor"] == NUCLEO_APOIO:
        descricao = ROTULO_REGISTRO_RESTRITO
    elif usuario.perfil in (DOCENTE, FINANCEIRO):
        descricao = "Registro de outro profissional."
    return {"momento": valor_json(evento["momento"]), "tipo": evento["tipo"], "tipo_acao": evento["tipo_acao"],
            "descricao": descricao, "autor": evento["autor"] or "Sistema", "perfil_autor": evento["perfil_autor"],
            "visivel_aluno": bool(evento["visivel_aluno"])}


@router_alertas.get("/{id_alerta}")
def detalhe_do_alerta(id_alerta: Annotated[int, Path(ge=1)], request: Request,
                      usuario: Usuario = Depends(exigir_perfis(*REGISTRAM)),
                      conexao: Connection = Depends(obter_conexao)):
    alerta = obter_alerta(conexao, request, usuario, id_alerta, "LER_ALERTA")
    eventos = conexao.execute(sqlp.EVENTOS_DO_ALERTA, {"id_alerta": id_alerta}).mappings().all()
    momento = agora()
    conexao.rollback()  # libera a trava de leitura
    gerencia = usuario.perfil == COORDENACAO or (usuario.perfil == NUCLEO_APOIO
                                                 and alerta["id_responsavel"] == usuario.id_usuario)
    return {
        "id_alerta": alerta["id_alerta"], "matricula": alerta["id_aluno"], "nome": alerta["nome_ficticio"],
        "tipo": alerta["tipo"], "nivel": alerta["nivel"], "situacao": alerta["situacao"],
        "criado_em": valor_json(alerta["criado_em"]), "prazo_em": valor_json(alerta["prazo_em"]),
        "vencido": alerta["situacao"] != "ENCERRADO" and alerta["prazo_em"] < momento,
        "horas_para_prazo": _horas_para_prazo(alerta["prazo_em"], momento),
        "responsavel": alerta["responsavel"], "id_responsavel": alerta["id_responsavel"],
        "atribuido_em": valor_json(alerta["atribuido_em"]), "primeira_acao_em": valor_json(alerta["primeira_acao_em"]),
        "encerramento": None if alerta["situacao"] != "ENCERRADO" else {
            "encerrado_em": valor_json(alerta["encerrado_em"]), "causa": alerta["causa"],
            "desfecho": alerta["desfecho"], "houve_contato": alerta["houve_contato"],
            "canal_contato": alerta["canal_contato"],
            "acoes_executadas": alerta["acoes_executadas"] if usuario.perfil in GERENCIAM else None,
            "score_no_encerramento": alerta["score_no_encerramento"]},
        "menor_de_idade": alerta["idade"] is not None and alerta["idade"] < 18,
        "pode_gerenciar": gerencia and alerta["situacao"] != "ENCERRADO",
        "pode_atribuir": usuario.perfil == COORDENACAO and alerta["situacao"] != "ENCERRADO",
        "eventos": [evento_visivel(usuario, e) for e in eventos],
    }


@router_alertas.patch("/{id_alerta}")
def mudar_alerta(id_alerta: Annotated[int, Path(ge=1)], pedido: PedidoMudanca, request: Request,
                 usuario: Usuario = Depends(exigir_perfis(*GERENCIAM)),
                 conexao: Connection = Depends(obter_conexao)):
    """Atribui (coordenacao) ou assume o atendimento (coordenacao e nucleo)."""
    alerta = obter_alerta(conexao, request, usuario, id_alerta, "MUDAR_ALERTA")
    if alerta["situacao"] == "ENCERRADO":
        raise erro_http(409, "Este alerta já foi encerrado.")
    momento = agora()

    if pedido.id_responsavel is not None:
        if usuario.perfil != COORDENACAO:
            raise erro_http(403, "Só a coordenação atribui alertas.")
        if alerta["tipo"] == "DADOS":
            raise erro_http(409, "Tarefa de correção de dados fica com a coordenação do curso.")
        destino = conexao.execute(sqlp.RESPONSAVEL_VALIDO, {"id_usuario": pedido.id_responsavel,
                                                             "id_curso": alerta["id_curso"]}).mappings().first()
        if destino is None:
            raise erro_http(422, "Responsável inválido: escolha alguém do núcleo de apoio ou da coordenação do curso.")
        teto = int(parametros_vigentes(conexao)["TETO_ALERTAS_RESPONSAVEL"])
        if destino["id_usuario"] != alerta["id_responsavel"] and int(destino["alertas_abertos"]) >= teto:
            raise erro_http(409, f"Este responsável já tem {destino['alertas_abertos']} alertas abertos "
                                 f"(teto de {teto}). Escolha outra pessoa.")
        conexao.execute(sqlp.ATRIBUIR_ALERTA, {"id_responsavel": destino["id_usuario"], "agora": momento,
                                               "id_alerta": id_alerta})
        conexao.execute(sqlp.REGISTRAR_EVENTO, {"id_alerta": id_alerta, "agora": momento,
                                                "id_usuario": usuario.id_usuario, "tipo": "ATRIBUIDO",
                                                "tipo_acao": None, "descricao": "Alerta atribuído.",
                                                "visivel_aluno": False})
        if destino["id_usuario"] != usuario.id_usuario:
            notificar(conexao, [destino["id_usuario"]], "ALERTA_ATRIBUIDO", "Alerta atribuído a você",
                      f"Alerta {alerta['nivel'].lower()} da matrícula {alerta['id_aluno']}. Prazo: "
                      f"{alerta['prazo_em']:%d/%m/%Y %H:%M}.", id_alerta)

    if pedido.assumir:
        if usuario.perfil == NUCLEO_APOIO and alerta["id_responsavel"] != usuario.id_usuario:
            raise erro_http(403, MSG_ALERTA_NEGADO)
        conexao.execute(sqlp.ASSUMIR_ALERTA, {"agora": momento, "id_alerta": id_alerta})
    conexao.commit()
    return {"atualizado": True}


@router_alertas.post("/{id_alerta}/acoes", status_code=201)
def registrar_acao(id_alerta: Annotated[int, Path(ge=1)], pedido: PedidoAcao, request: Request,
                   usuario: Usuario = Depends(exigir_perfis(*REGISTRAM)),
                   conexao: Connection = Depends(obter_conexao)):
    """Registro de acao executada, com autor e data (RN05, RF16)."""
    alerta = obter_alerta(conexao, request, usuario, id_alerta, "REGISTRAR_ACAO")
    if alerta["situacao"] == "ENCERRADO":
        raise erro_http(409, "Este alerta já foi encerrado.")
    momento = agora()
    conexao.execute(sqlp.REGISTRAR_EVENTO, {"id_alerta": id_alerta, "agora": momento,
                                            "id_usuario": usuario.id_usuario, "tipo": "ACAO",
                                            "tipo_acao": pedido.tipo_acao.value, "descricao": pedido.descricao,
                                            "visivel_aluno": pedido.visivel_aluno})
    conexao.execute(sqlp.PRIMEIRA_ACAO, {"agora": momento, "id_alerta": id_alerta})
    if pedido.tipo_acao in (TipoAcao.ENCAMINHAMENTO_NAE, TipoAcao.ENCAMINHAMENTO_FINANCEIRO):
        perfil_destino = NUCLEO_APOIO if pedido.tipo_acao == TipoAcao.ENCAMINHAMENTO_NAE else FINANCEIRO
        # O nucleo so ve alerta atribuido: o encaminhamento avisa a coordenacao, que atribui.
        destinos = (usuarios_do_perfil(conexao, COORDENACAO, alerta["id_curso"]) if perfil_destino == NUCLEO_APOIO
                    else usuarios_do_perfil(conexao, FINANCEIRO))
        notificar(conexao, [d for d in destinos if d != usuario.id_usuario], "ALERTA_ATRIBUIDO",
                  "Encaminhamento registrado",
                  f"A matrícula {alerta['id_aluno']} foi encaminhada ao "
                  f"{'núcleo de apoio' if perfil_destino == NUCLEO_APOIO else 'setor financeiro'}.", id_alerta)
    conexao.commit()
    return {"registrado": True}


@router_alertas.post("/{id_alerta}/encerramento")
def encerrar_alerta(id_alerta: Annotated[int, Path(ge=1)], pedido: PedidoEncerramento, request: Request,
                    usuario: Usuario = Depends(exigir_perfis(*GERENCIAM)),
                    conexao: Connection = Depends(obter_conexao)):
    """Encerramento com causa, desfecho e acoes (CA20, RF19). Sem esses campos, nao fecha."""
    alerta = obter_alerta(conexao, request, usuario, id_alerta, "ENCERRAR_ALERTA")
    if alerta["situacao"] == "ENCERRADO":
        raise erro_http(409, "Este alerta já foi encerrado.")
    if usuario.perfil == NUCLEO_APOIO and alerta["id_responsavel"] != usuario.id_usuario:
        raise erro_http(403, MSG_ALERTA_NEGADO)
    if alerta["tipo"] == "DADOS" and pedido.desfecho != Desfecho.DADOS_CORRIGIDOS:
        raise erro_http(422, "Tarefa de dados encerra com o desfecho DADOS_CORRIGIDOS.")
    if alerta["tipo"] == "PEDAGOGICO" and pedido.desfecho == Desfecho.DADOS_CORRIGIDOS:
        raise erro_http(422, "Alerta pedagógico precisa de desfecho do acompanhamento, não de dados.")

    score = conexao.execute(sqlp.SCORE_E_SOBREPOSICAO, {"id_aluno": alerta["id_aluno"]}).mappings().first()
    if pedido.canal_contato == Canal.EMERGENCIA_RN19:
        # RN19: so em nivel Critico por ausencia total de 15 dias (sobreposicao S2).
        motivo = (score or {}).get("motivo_sobreposicao") or ""
        if alerta["nivel"] != "CRITICO" or "S2" not in motivo:
            raise erro_http(422, "O contato de emergência (RN19) só vale para Crítico por 15 dias sem presença.")

    if alerta["tipo"] == "PEDAGOGICO":
        acoes = [e for e in conexao.execute(sqlp.EVENTOS_DO_ALERTA, {"id_alerta": id_alerta}).mappings()
                 if e["tipo"] == "ACAO"]
        if not acoes:
            raise erro_http(422, "Registre ao menos uma ação antes de encerrar o alerta.")

    momento = agora()
    conexao.execute(sqlp.ENCERRAR_ALERTA, {
        "agora": momento, "causa": pedido.causa.value, "desfecho": pedido.desfecho.value,
        "houve_contato": pedido.houve_contato, "canal_contato": pedido.canal_contato.value if pedido.canal_contato else None,
        "acoes_executadas": pedido.acoes_executadas, "score": score["score"] if score else None, "id_alerta": id_alerta})
    conexao.execute(sqlp.REGISTRAR_EVENTO, {"id_alerta": id_alerta, "agora": momento,
                                            "id_usuario": usuario.id_usuario, "tipo": "ENCERRADO", "tipo_acao": None,
                                            "descricao": f"Encerrado: causa {pedido.causa.value}, desfecho "
                                                         f"{pedido.desfecho.value}.", "visivel_aluno": False})
    conexao.commit()
    return {"encerrado": True}


@router_alertas.post("/{id_alerta}/divergencia", status_code=201)
def marcar_divergencia(id_alerta: Annotated[int, Path(ge=1)], pedido: PedidoDivergencia, request: Request,
                       usuario: Usuario = Depends(exigir_perfis(DOCENTE, COORDENACAO)),
                       conexao: Connection = Depends(obter_conexao)):
    """Classificacao equivocada, com justificativa (RF20, Anexo A.8): entra no relatorio de qualidade."""
    alerta = obter_alerta(conexao, request, usuario, id_alerta, "MARCAR_DIVERGENCIA")
    conexao.execute(sqlp.REGISTRAR_EVENTO, {"id_alerta": id_alerta, "agora": agora(),
                                            "id_usuario": usuario.id_usuario, "tipo": "DIVERGENCIA",
                                            "tipo_acao": None, "descricao": pedido.justificativa,
                                            "visivel_aluno": False})
    if usuario.perfil == DOCENTE:
        notificar(conexao, usuarios_do_perfil(conexao, COORDENACAO, alerta["id_curso"]), "DIVERGENCIA",
                  "Classificação contestada por docente",
                  f"Um docente marcou como equivocada a classificação da matrícula {alerta['id_aluno']}.", id_alerta)
    conexao.commit()
    return {"registrado": True}
