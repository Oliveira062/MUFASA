"""
Endpoints do MUFASA (prefixo /api/v1, SRS Anexo D).

Cada endpoint segue a mesma sequencia:
1. exigir_perfis(...)          o perfil pode usar o recurso?
2. verificar_escopo_aluno(...) pode ver ESTE aluno? (registra na auditoria)
3. consulta parametrizada      so as colunas que o perfil pode receber
4. resposta                    sem campo que o perfil nao pode ver
"""

from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, Request
from sqlalchemy.engine import Connection

from app.api import auditoria, consultas as sql
from app.api.auth import (VERSAO_TERMO, Usuario, conferir_senha, emitir_token, exigir_perfis,
                          obter_carga_token, obter_usuario_atual)
from app.api.cifra import ChaveIndisponivel, decifrar
from app.api.banco import obter_conexao
from app.api.erros import MSG_ACESSO_NEGADO, erro_http
from app.api.esquemas import (AVISO_METODOLOGICO, AlunoResumo, Consentimento, FiltroAuditoria, FiltroPagina,
                              FiltrosLista, GrupoAgregado, Matricula, PaginaAlunos, PedidoConsentimento,
                              PedidoLogin, PedidoSolicitacao, RegistroAuditoria, RespostaAgregados, RespostaToken,
                              Solicitacao, SolicitacaoRegistrada, filtro_auditoria, filtro_pagina, filtros_lista)
from app.api.parametros_db import parametros_vigentes
from app.api.permissoes import (ALUNO, COORDENACAO, DIRECAO, DOCENTE, ENCARREGADO_DADOS, FINANCEIRO,
                                NUCLEO_APOIO, faixa_qualitativa, verificar_escopo_aluno)
from app.api.seguranca import ip_do_cliente, limitador
from app.api.util import agora, como_datetime, linha_json, numero, sim_nao, valor_json
from app.api.visibilidade import recortar_score
from app.calculo.score import AVISO_PESOS, explicar_score, risco_por_renda_per_capita
from app.config import obter_configuracao

router = APIRouter(prefix="/api/v1")

MAIORIDADE = 18


# ---------------------------------------------------------------------------
# Autenticacao
# ---------------------------------------------------------------------------

class _UsuarioAuditoria:
    """Identifica na auditoria quem tentou entrar, antes de existir sessao."""

    def __init__(self, linha):
        self.id_usuario = linha["id_usuario"] if linha else None
        self.perfil = linha["perfil"] if linha else None


def _demonstracao_bloqueada(linha) -> bool:
    """Contas de demonstracao (senha conhecida) nunca entram em producao."""
    return bool(linha and linha["demonstracao"]) and obter_configuracao().em_producao


MSG_LOGIN_FALHOU = ("Login ou senha incorretos. Após 5 tentativas erradas, o acesso fica bloqueado "
                    "por 15 minutos.")


@router.post("/auth/token", response_model=RespostaToken, tags=["autenticacao"])
def entrar(pedido: PedidoLogin, request: Request, conexao: Connection = Depends(obter_conexao)):
    """Aluno entra com matricula + senha (RN12: matricula sozinha nunca basta)."""
    cfg = obter_configuracao()

    for chave in (f"login-ip:{ip_do_cliente(request)}", f"login-conta:{pedido.login.lower()}"):
        permitido, espera = limitador.permitir(chave, cfg.limite_login_minuto)
        if not permitido:
            raise erro_http(429, "Muitas tentativas de login. Aguarde e tente de novo.",
                            {"Retry-After": str(espera)})

    linha = conexao.execute(sql.USUARIO_POR_LOGIN, {"login": pedido.login}).mappings().first()
    momento = agora()

    bloqueado = linha is not None and (como_datetime(linha["bloqueado_ate"]) or momento) > momento
    senha_ok = conferir_senha(pedido.senha, linha["senha_hash"] if linha else None)

    # Perfil escolhido na tela diferente do da conta conta como falha, com a
    # mesma mensagem: a resposta nao revela qual perfil a conta tem.
    perfil_ok = linha is not None and linha["perfil"] == pedido.perfil.value
    if (linha is None or bloqueado or not linha["ativo"] or not senha_ok or not perfil_ok
            or _demonstracao_bloqueada(linha)):
        if linha is not None and not bloqueado:
            conexao.execute(sql.REGISTRAR_FALHA_LOGIN, {
                "id_usuario": linha["id_usuario"], "max_falhas": cfg.login_max_falhas,
                "bloquear_ate": momento + timedelta(minutes=cfg.login_bloqueio_minutos),
            })
            conexao.commit()
        auditoria.registrar(request, "LOGIN", "BLOQUEADO" if bloqueado else "NEGADO",
                            usuario=_UsuarioAuditoria(linha))
        raise erro_http(401, MSG_LOGIN_FALHOU)

    conexao.execute(sql.ZERAR_FALHAS_LOGIN, {"id_usuario": linha["id_usuario"], "agora": momento})
    conexao.commit()
    token, segundos = emitir_token(linha["id_usuario"], linha["perfil"])
    auditoria.registrar(request, "LOGIN", "PERMITIDO", usuario=_UsuarioAuditoria(linha))
    estado = conexao.execute(sql.USUARIO_POR_ID, {"id_usuario": linha["id_usuario"]}).mappings().first()
    return RespostaToken(access_token=token, expira_em_segundos=segundos, perfil=linha["perfil"],
                         deve_trocar_senha=bool(estado["deve_trocar_senha"]),
                         termo_pendente=estado["termo_versao"] != VERSAO_TERMO)


@router.post("/auth/sair", status_code=204, tags=["autenticacao"])
def sair(request: Request, usuario: Usuario = Depends(obter_usuario_atual),
         carga: dict = Depends(obter_carga_token), conexao: Connection = Depends(obter_conexao)):
    """Encerra a sessao: o token deixa de valer antes de expirar."""
    expira = datetime.fromtimestamp(carga["exp"], tz=timezone.utc)
    conexao.execute(sql.REVOGAR_TOKEN, {"jti": carga["jti"], "expira_em": expira})
    conexao.commit()
    auditoria.registrar(request, "LOGOUT", "PERMITIDO", usuario=usuario)


# ---------------------------------------------------------------------------
# Alunos
# ---------------------------------------------------------------------------

@router.get("/alunos", response_model=PaginaAlunos, tags=["alunos"])
def listar_alunos(request: Request, filtros: FiltrosLista = Depends(filtros_lista),
                  usuario: Usuario = Depends(exigir_perfis(DOCENTE, COORDENACAO, NUCLEO_APOIO)),
                  conexao: Connection = Depends(obter_conexao)):
    """Lista so os alunos do escopo do perfil: turmas do docente, curso da coordenacao."""
    valores = {
        "semestre": filtros.semestre,
        "nivel": filtros.nivel.value if filtros.nivel else None,
        "busca": f"%{filtros.busca.lower()}%" if filtros.busca else None,
        "id_usuario": usuario.id_usuario,
        "id_professor": usuario.id_professor,
        "id_curso": usuario.id_curso,
    }
    total = conexao.execute(sql.consulta_total_alunos(usuario.perfil), valores).scalar()
    linhas = conexao.execute(sql.consulta_lista_alunos(usuario.perfil, filtros.ordem.value), {
        **valores, "limite": filtros.limite, "deslocamento": (filtros.pagina - 1) * filtros.limite,
    }).mappings().all()
    auditoria.registrar(request, "LISTAR_ALUNOS", "PERMITIDO", usuario=usuario)
    return PaginaAlunos(pagina=filtros.pagina, limite=filtros.limite, total=total, itens=[
        AlunoResumo(matricula=l["id_aluno"], nome=l["nome_ficticio"], semestre=l["semestre_atual"],
                    nivel_risco=l["nivel"], score=l["score"])
        for l in linhas
    ])


@router.get("/alunos/{matricula}", tags=["alunos"])
def perfil_do_aluno(matricula: Matricula, request: Request,
                    usuario: Usuario = Depends(exigir_perfis(ALUNO, DOCENTE, COORDENACAO, NUCLEO_APOIO, FINANCEIRO)),
                    conexao: Connection = Depends(obter_conexao)):
    """Perfil com campos ocultados conforme o perfil (SRS Anexo E)."""
    verificar_escopo_aluno(request, conexao, usuario, matricula, "LER_PERFIL")

    base = conexao.execute(sql.ALUNO_BASICO, {"id_aluno": matricula}).mappings().first()
    if base is None:
        raise erro_http(403, MSG_ACESSO_NEGADO)
    resposta = {"matricula": base["id_aluno"], "nome": base["nome_ficticio"],
                "curso": base["curso"], "semestre": base["semestre_atual"]}

    if usuario.perfil in (ALUNO, DOCENTE, COORDENACAO, NUCLEO_APOIO):
        ind = conexao.execute(sql.INDICADORES_ATUAIS, {"id_aluno": matricula}).mappings().first()
        resposta["academico"] = None if ind is None else {
            "periodo_letivo": ind["periodo_letivo"], "faltas_total": ind["faltas_total"],
            "frequencia_pct": numero(ind["frequencia_pct"]), "media_atual": numero(ind["media_atual"]),
            "tendencia_media": numero(ind["tendencia_media"]), "atividades_pendentes": ind["atividades_pendentes"],
        }

    if usuario.perfil in (COORDENACAO, NUCLEO_APOIO, FINANCEIRO):
        soc = conexao.execute(sql.SOCIOECONOMICO_RESTRITO, {"id_aluno": matricula}).mappings().first()
        p = parametros_vigentes(conexao)
        salario_minimo = p["SALARIO_MINIMO"]
        if usuario.perfil == COORDENACAO:
            # Coordenacao ve so a faixa qualitativa (RN07).
            faixa = None
            if soc and soc["renda_per_capita"] is not None:
                risco = risco_por_renda_per_capita(float(soc["renda_per_capita"]) / salario_minimo,
                                                   auxilio_ativo=sim_nao(soc["auxilio_bolsa"]) or False, p=p)
                faixa = faixa_qualitativa(risco)
            resposta["vulnerabilidade_socioeconomica"] = faixa
        elif usuario.perfil == FINANCEIRO:
            resposta["financeiro"] = None if soc is None else {
                "renda_per_capita": numero(soc["renda_per_capita"]),
                "renda_per_capita_sm": None if soc["renda_per_capita"] is None
                else round(float(soc["renda_per_capita"]) / salario_minimo, 2),
                "auxilio_bolsa": soc["auxilio_bolsa"]}
        else:
            resposta["socioeconomico"] = None if soc is None else {
                "renda_per_capita": numero(soc["renda_per_capita"]), "trabalha": soc["trabalha"],
                "horas_trabalho_dia": soc["horas_trabalho_dia"],
                "tempo_deslocamento_min": soc["tempo_deslocamento_min"], "auxilio_bolsa": soc["auxilio_bolsa"]}

    if usuario.perfil == NUCLEO_APOIO:
        resposta["apoio"] = ler_apoio(conexao, matricula)
        auditoria.registrar(request, "LER_DADO_SENSIVEL", "PERMITIDO", usuario=usuario, id_aluno_alvo=matricula)

    if usuario.perfil in (DOCENTE, COORDENACAO, NUCLEO_APOIO, FINANCEIRO):
        alerta = conexao.execute(sql.ALERTA_ABERTO_DO_ALUNO, {"id_aluno": matricula}).mappings().first()
        resposta["alerta"] = None if alerta is None else {
            "id_alerta": alerta["id_alerta"], "nivel": alerta["nivel"], "situacao": alerta["situacao"],
            "prazo_em": valor_json(alerta["prazo_em"])}

    return resposta


def ler_apoio(conexao: Connection, matricula: str) -> dict:
    """Decifra o bloco de apoio. Sem a chave, so este bloco fica indisponivel."""
    linha = conexao.execute(sql.DADOS_SENSIVEIS_APOIO, {"id_aluno": matricula}).mappings().first()
    if linha is None:
        return {"disponivel": True, "apoio_psicossocial_solicitado": None, "necessidade_acessibilidade": None}
    try:
        return {"disponivel": True, **decifrar(linha["dados_cifrados"])}
    except ChaveIndisponivel:
        return {"disponivel": False, "motivo": "Dado de apoio indisponível no momento."}


@router.get("/alunos/{matricula}/score", tags=["alunos"])
def score_do_aluno(matricula: Matricula, request: Request,
                   usuario: Usuario = Depends(exigir_perfis(ALUNO, DOCENTE, COORDENACAO, NUCLEO_APOIO, FINANCEIRO)),
                   conexao: Connection = Depends(obter_conexao)):
    """
    Score gravado pelo servico de calculo, com fatores, modificadores e
    recomendacoes (RN04, Anexo A B.7), recortado por perfil (Anexo E). Os
    fatores sao os persistidos junto do score, nunca recalculados na exibicao.
    """
    verificar_escopo_aluno(request, conexao, usuario, matricula, "LER_SCORE")
    linha = conexao.execute(sql.SCORE_ATUAL, {"id_aluno": matricula}).mappings().first()
    if linha is None:
        return {"matricula": matricula, "score": None, "nivel": "PENDENTE", "fatores": [],
                "explicacao": "O score deste aluno ainda não foi calculado.", "aviso": AVISO_METODOLOGICO,
                "aviso_pesos": AVISO_PESOS}
    recorte = recortar_score(usuario.perfil, linha)
    explicacao = explicar_score({**recorte, "motivo_sobreposicao": recorte["motivo_sobreposicao"]})
    if usuario.perfil == FINANCEIRO:
        recorte["modificadores"] = []
    return {"matricula": matricula, **{k: valor_json(v) for k, v in recorte.items()},
            "explicacao": explicacao, "aviso": AVISO_METODOLOGICO, "aviso_pesos": AVISO_PESOS}


@router.get("/alunos/{matricula}/historico", tags=["alunos"])
def historico_do_aluno(matricula: Matricula, request: Request,
                       usuario: Usuario = Depends(exigir_perfis(ALUNO, DOCENTE, COORDENACAO, NUCLEO_APOIO)),
                       conexao: Connection = Depends(obter_conexao)):
    """Serie historica dos scores (RN09): cada recalculo e uma linha nova."""
    verificar_escopo_aluno(request, conexao, usuario, matricula, "LER_HISTORICO")
    linhas = conexao.execute(sql.HISTORICO_SCORE, {"id_aluno": matricula, "limite": 500}).mappings().all()
    return [{"calculado_em": valor_json(l["calculado_em"]), "score": l["score"], "nivel": l["nivel"],
             "nivel_origem": l["nivel_origem"], "completude": numero(l["completude"]),
             "versao_modelo": l["versao_modelo"], "versao_parametros": f"param-v{l['versao_parametros']}"}
            for l in linhas]


@router.get("/indicadores/agregados", response_model=RespostaAgregados, tags=["indicadores"])
def indicadores_agregados(request: Request, usuario: Usuario = Depends(exigir_perfis(COORDENACAO, DIRECAO)),
                          conexao: Connection = Depends(obter_conexao)):
    """Contagem por semestre e nivel, sem nome nem matricula; grupos < 5 suprimidos (CA19)."""
    id_curso = usuario.id_curso if usuario.perfil == COORDENACAO else None
    if usuario.perfil == COORDENACAO and id_curso is None:
        raise erro_http(403, "Seu usuário não está vinculado a um curso.")
    minimo = int(parametros_vigentes(conexao)["MINIMO_GRUPO"])
    linhas = conexao.execute(sql.AGREGADOS_POR_SEMESTRE, {
        "id_curso": id_curso, "minimo_grupo": minimo}).mappings().all()
    auditoria.registrar(request, "LER_AGREGADOS", "PERMITIDO", usuario=usuario)
    return RespostaAgregados(minimo_por_grupo=minimo, grupos=[
        GrupoAgregado(semestre=l["semestre"], nivel_risco=l["nivel_risco"], total=l["total"])
        for l in linhas])


# ---------------------------------------------------------------------------
# Privacidade: direitos do titular (LGPD arts. 8, 11, 14, 18, 20)
# ---------------------------------------------------------------------------

@router.get("/privacidade/meus-dados", tags=["privacidade"])
def meus_dados(request: Request, usuario: Usuario = Depends(exigir_perfis(ALUNO)),
               conexao: Connection = Depends(obter_conexao)):
    """Acesso e portabilidade: tudo o que o sistema guarda sobre o proprio aluno (art. 18, II e V)."""
    id_aluno = usuario.id_aluno
    cadastro = conexao.execute(sql.MEUS_DADOS_CADASTRO, {"id_aluno": id_aluno}).mappings().first()
    socio = conexao.execute(sql.MEUS_DADOS_SOCIOECONOMICO, {"id_aluno": id_aluno}).mappings().first()
    matriculas = conexao.execute(sql.MEUS_DADOS_MATRICULAS, {"id_aluno": id_aluno}).mappings().all()
    avaliacoes = conexao.execute(sql.HISTORICO_RISCO, {"id_aluno": id_aluno, "limite": 200}).mappings().all()
    scores = conexao.execute(sql.HISTORICO_SCORE, {"id_aluno": id_aluno, "limite": 500}).mappings().all()
    consent = conexao.execute(sql.CONSENTIMENTOS_DO_ALUNO, {"id_aluno": id_aluno}).mappings().all()
    apoio = ler_apoio(conexao, id_aluno)
    auditoria.registrar(request, "EXPORTAR_MEUS_DADOS", "PERMITIDO", usuario=usuario, id_aluno_alvo=id_aluno)

    return {
        "gerado_em": agora().isoformat(),
        "controlador": "Universidade (controladora dos dados). Contato: encarregado de dados da instituição.",
        "cadastro": linha_json(cadastro),
        "socioeconomico": linha_json(socio),
        "apoio": apoio,
        "matriculas": [linha_json(m) for m in matriculas],
        "scores_calculados": [linha_json(a) for a in scores],
        "avaliacoes_de_risco_b1": [linha_json(a) for a in avaliacoes],
        "consentimentos": [linha_json(c) for c in consent],
    }


@router.get("/privacidade/consentimentos", response_model=list[Consentimento], tags=["privacidade"])
def listar_consentimentos(usuario: Usuario = Depends(exigir_perfis(ALUNO)),
                          conexao: Connection = Depends(obter_conexao)):
    linhas = conexao.execute(sql.CONSENTIMENTOS_DO_ALUNO, {"id_aluno": usuario.id_aluno}).mappings().all()
    return [Consentimento(**{**l, "concedido": bool(l["concedido"])}) for l in linhas]


@router.post("/privacidade/consentimentos", status_code=201, tags=["privacidade"])
def registrar_consentimento(pedido: PedidoConsentimento, request: Request,
                            usuario: Usuario = Depends(exigir_perfis(ALUNO)),
                            conexao: Connection = Depends(obter_conexao)):
    """
    Concede ou revoga o consentimento para dados de saude (art. 11, I).
    Revogar e sempre possivel e nao traz prejuizo ao aluno (art. 8, par. 5).
    """
    if pedido.concedido:
        idade = conexao.execute(sql.IDADE_ALUNO, {"id_aluno": usuario.id_aluno}).scalar()
        if idade is None or int(idade) < MAIORIDADE:
            raise erro_http(422, "Para menores de 18 anos, o consentimento é dado pelo responsável legal, "
                                 "com termo assinado entregue à secretaria (LGPD, art. 14).")
    conexao.execute(sql.REGISTRAR_CONSENTIMENTO, {
        "id_aluno": usuario.id_aluno, "finalidade": pedido.finalidade.value, "concedido": pedido.concedido,
        "concedido_por": "TITULAR", "versao_termo": pedido.versao_termo, "registrado_em": agora(),
        "id_usuario": usuario.id_usuario,
    })
    conexao.commit()
    auditoria.registrar(request, "CONSENTIMENTO_" + ("CONCEDIDO" if pedido.concedido else "REVOGADO"),
                        "PERMITIDO", usuario=usuario, id_aluno_alvo=usuario.id_aluno)
    return {"registrado": True}


@router.post("/privacidade/solicitacoes", status_code=201, response_model=SolicitacaoRegistrada, tags=["privacidade"])
def solicitar_direito(pedido: PedidoSolicitacao, request: Request,
                      usuario: Usuario = Depends(exigir_perfis(ALUNO)),
                      conexao: Connection = Depends(obter_conexao)):
    """Correcao, eliminacao, revisao de decisao automatizada e demais direitos do art. 18."""
    conexao.execute(sql.REGISTRAR_SOLICITACAO_TITULAR, {
        "id_aluno": usuario.id_aluno, "tipo": pedido.tipo.value, "descricao": pedido.descricao,
        "registrada_em": agora()})
    conexao.commit()
    auditoria.registrar(request, "SOLICITACAO_TITULAR", "PERMITIDO", usuario=usuario, id_aluno_alvo=usuario.id_aluno)
    return SolicitacaoRegistrada()


@router.get("/privacidade/solicitacoes", response_model=list[Solicitacao], tags=["privacidade"])
def listar_solicitacoes(request: Request, pagina: FiltroPagina = Depends(filtro_pagina),
                        usuario: Usuario = Depends(exigir_perfis(ENCARREGADO_DADOS)),
                        conexao: Connection = Depends(obter_conexao)):
    linhas = conexao.execute(sql.LISTAR_SOLICITACOES_TITULAR, {
        "limite": pagina.limite, "deslocamento": (pagina.pagina - 1) * pagina.limite}).mappings().all()
    auditoria.registrar(request, "LISTAR_SOLICITACOES", "PERMITIDO", usuario=usuario)
    return [Solicitacao(**l) for l in linhas]


@router.get("/auditoria", response_model=list[RegistroAuditoria], tags=["auditoria"])
def ler_auditoria(request: Request, filtro: FiltroAuditoria = Depends(filtro_auditoria),
                  usuario: Usuario = Depends(exigir_perfis(ENCARREGADO_DADOS)),
                  conexao: Connection = Depends(obter_conexao)):
    """Trilha de acessos para o encarregado de dados. Ler a trilha tambem fica registrado."""
    linhas = conexao.execute(sql.LISTAR_AUDITORIA, {
        "id_aluno": filtro.matricula, "perfil": filtro.perfil.value if filtro.perfil else None,
        "resultado": filtro.resultado.value if filtro.resultado else None, "operacao": filtro.operacao, "de": filtro.de, "ate": filtro.ate,
        "limite": filtro.limite, "deslocamento": (filtro.pagina - 1) * filtro.limite}).mappings().all()
    auditoria.registrar(request, "LER_AUDITORIA", "PERMITIDO", usuario=usuario)
    return [RegistroAuditoria(**l) for l in linhas]
