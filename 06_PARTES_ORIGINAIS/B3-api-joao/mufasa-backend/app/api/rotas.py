"""
Endpoints do MUFASA (prefixo /api/v1, SRS Anexo D).

Cada endpoint segue a mesma sequencia:
1. exigir_perfis(...)          o perfil pode usar o recurso?
2. verificar_escopo_aluno(...) pode ver ESTE aluno? (registra na auditoria)
3. consulta parametrizada      so as colunas que o perfil pode receber
4. resposta                    sem campo que o perfil nao pode ver
"""

from datetime import date, datetime, timedelta, timezone
from decimal import Decimal

from fastapi import APIRouter, Depends, Request
from sqlalchemy.engine import Connection

from app.api import auditoria, consultas as sql
from app.api.auth import (Usuario, conferir_senha, emitir_token, exigir_perfis,
                          obter_carga_token, obter_usuario_atual)
from app.api.banco import obter_conexao
from app.api.erros import MSG_ACESSO_NEGADO, erro_http
from app.api.esquemas import (AlunoResumo, AvaliacaoHistorica, Consentimento, FatorScore,
                              FiltroPagina, FiltrosLista, GrupoAgregado, Matricula, PaginaAlunos,
                              PedidoConsentimento, PedidoLogin, PedidoSolicitacao, RegistroAuditoria,
                              RespostaAgregados, RespostaScore, RespostaToken, Solicitacao,
                              SolicitacaoRegistrada, converter_data, filtro_pagina, filtros_lista)
from app.api.integracao import NIVEL_DO_BANCO, fatores_ausentes, montar_dados_score
from app.api.permissoes import (ALUNO, COORDENACAO, DIRECAO, DOCENTE, ENCARREGADO_DADOS, FINANCEIRO,
                                NUCLEO_APOIO, ROTULO_ENCAMINHADO, faixa_qualitativa, fator_visivel,
                                valor_do_fator_visivel, verificar_escopo_aluno)
from app.api.seguranca import ip_do_cliente, limitador
from app.calculo.score import calcular_score_aluno, explicar_score, risco_por_renda_per_capita
from app.config import obter_configuracao

router = APIRouter(prefix="/api/v1")

MINIMO_GRUPO_AGREGADO = 5
MAIORIDADE = 18


def _agora() -> datetime:
    return datetime.now(timezone.utc)


def _como_datetime(valor) -> datetime | None:
    if valor is None:
        return None
    if isinstance(valor, datetime):
        return valor if valor.tzinfo else valor.replace(tzinfo=timezone.utc)
    convertido = datetime.fromisoformat(str(valor))
    return convertido if convertido.tzinfo else convertido.replace(tzinfo=timezone.utc)


def _sim_nao(valor) -> bool | None:
    if valor is None:
        return None
    if isinstance(valor, bool):
        return valor
    return str(valor).strip().lower() in ("sim", "s", "true", "1")


def _float(valor) -> float | None:
    return None if valor is None else float(valor)


def _valor_json(valor):
    if isinstance(valor, Decimal):
        return float(valor)
    if isinstance(valor, (date, datetime)):
        return valor.isoformat()
    return valor


def _linha_json(linha) -> dict | None:
    return None if linha is None else {k: _valor_json(v) for k, v in dict(linha).items()}


def _nivel(valor) -> str | None:
    return NIVEL_DO_BANCO.get(valor, valor) if valor is not None else None


# ---------------------------------------------------------------------------
# Autenticacao
# ---------------------------------------------------------------------------

class _UsuarioAuditoria:
    """Identifica na auditoria quem tentou entrar, antes de existir sessao."""

    def __init__(self, linha):
        self.id_usuario = linha["id_usuario"] if linha else None
        self.perfil = linha["perfil"] if linha else None


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
    agora = _agora()

    bloqueado = linha is not None and (_como_datetime(linha["bloqueado_ate"]) or agora) > agora
    senha_ok = conferir_senha(pedido.senha, linha["senha_hash"] if linha else None)

    if linha is None or bloqueado or not linha["ativo"] or not senha_ok:
        if linha is not None and not bloqueado:
            conexao.execute(sql.REGISTRAR_FALHA_LOGIN, {
                "id_usuario": linha["id_usuario"], "max_falhas": cfg.login_max_falhas,
                "bloquear_ate": agora + timedelta(minutes=cfg.login_bloqueio_minutos),
            })
            conexao.commit()
        auditoria.registrar(request, "LOGIN", "BLOQUEADO" if bloqueado else "NEGADO",
                            usuario=_UsuarioAuditoria(linha))
        raise erro_http(401, MSG_LOGIN_FALHOU)

    conexao.execute(sql.ZERAR_FALHAS_LOGIN, {"id_usuario": linha["id_usuario"], "agora": agora})
    conexao.commit()
    token, segundos = emitir_token(linha["id_usuario"], linha["perfil"])
    auditoria.registrar(request, "LOGIN", "PERMITIDO", usuario=_UsuarioAuditoria(linha))
    return RespostaToken(access_token=token, expira_em_segundos=segundos, perfil=linha["perfil"])


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
    consulta = sql.consulta_lista_alunos(usuario.perfil, filtros.ordem.value)
    linhas = conexao.execute(consulta, {
        "semestre": filtros.semestre,
        "id_professor": usuario.id_professor,
        "id_curso": usuario.id_curso,
        "limite": filtros.limite,
        "deslocamento": (filtros.pagina - 1) * filtros.limite,
    }).mappings().all()
    auditoria.registrar(request, "LISTAR_ALUNOS", "PERMITIDO", usuario=usuario)
    return PaginaAlunos(pagina=filtros.pagina, limite=filtros.limite, itens=[
        AlunoResumo(matricula=l["id_aluno"], nome=l["nome_ficticio"], semestre=l["semestre_atual"],
                    nivel_risco=_nivel(l["nivel_risco"]))
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
            "frequencia_pct": _float(ind["frequencia_pct"]), "media_atual": _float(ind["media_atual"]),
            "tendencia_media": _float(ind["tendencia_media"]), "atividades_pendentes": ind["atividades_pendentes"],
        }

    if usuario.perfil in (COORDENACAO, NUCLEO_APOIO, FINANCEIRO):
        soc = conexao.execute(sql.SOCIOECONOMICO_RESTRITO, {"id_aluno": matricula}).mappings().first()
        cfg = obter_configuracao()
        if usuario.perfil == COORDENACAO:
            # Coordenacao ve so a faixa qualitativa (RN07).
            faixa = None
            if soc and soc["renda_per_capita"] is not None and cfg.salario_minimo:
                risco = risco_por_renda_per_capita(float(soc["renda_per_capita"]) / float(cfg.salario_minimo))
                faixa = faixa_qualitativa(risco)
            resposta["vulnerabilidade_socioeconomica"] = faixa
        elif usuario.perfil == FINANCEIRO:
            resposta["financeiro"] = None if soc is None else {
                "renda_per_capita": _float(soc["renda_per_capita"]), "auxilio_bolsa": soc["auxilio_bolsa"]}
        else:
            resposta["socioeconomico"] = None if soc is None else {
                "renda_per_capita": _float(soc["renda_per_capita"]), "trabalha": soc["trabalha"],
                "horas_trabalho_dia": soc["horas_trabalho_dia"],
                "tempo_deslocamento_min": soc["tempo_deslocamento_min"], "auxilio_bolsa": soc["auxilio_bolsa"]}

    if usuario.perfil == NUCLEO_APOIO:
        sens = conexao.execute(sql.DADOS_SENSIVEIS_APOIO, {"id_aluno": matricula}).mappings().first()
        resposta["apoio"] = {
            "apoio_psicossocial_solicitado": _sim_nao(sens["apoio_psicossocial_solicitado"]),
            "necessidade_acessibilidade": _sim_nao(sens["necessidade_acessibilidade"]),
        }
        auditoria.registrar(request, "LER_DADO_SENSIVEL", "PERMITIDO", usuario=usuario, id_aluno_alvo=matricula)

    return resposta


@router.get("/alunos/{matricula}/score", response_model=RespostaScore, tags=["alunos"])
def score_do_aluno(matricula: Matricula, request: Request,
                   usuario: Usuario = Depends(exigir_perfis(ALUNO, DOCENTE, COORDENACAO, NUCLEO_APOIO)),
                   conexao: Connection = Depends(obter_conexao)):
    """Score do B2 com explicacao (RN04) e o aviso obrigatorio (RN05)."""
    verificar_escopo_aluno(request, conexao, usuario, matricula, "LER_SCORE")

    dados = montar_dados_score(conexao, matricula, obter_configuracao())
    resultado = calcular_score_aluno(dados)
    ausentes = fatores_ausentes(resultado)
    # Sem aulas previstas no banco, o "0" do B2 seria lido como limite estourado.
    resultado["faltas_restantes"] = None

    perfil = usuario.perfil
    principais = []
    for fator in resultado["fatores_principais"]:
        nome = fator if fator_visivel(perfil, fator) else ROTULO_ENCAMINHADO
        if nome not in principais:
            principais.append(nome)

    detalhamento = []
    for fator, risco in resultado["detalhamento"].items():
        if not fator_visivel(perfil, fator):
            continue
        if valor_do_fator_visivel(perfil, fator):
            detalhamento.append(FatorScore(fator=fator, risco=risco))
        else:
            detalhamento.append(FatorScore(fator=fator, risco=None, faixa=faixa_qualitativa(risco)))

    explicacao = explicar_score({**resultado, "fatores_principais": principais})

    return RespostaScore(
        matricula=matricula, score=resultado["score"], nivel=resultado["nivel"],
        completude=resultado["completude"], fatores_principais=principais, detalhamento=detalhamento,
        faltas_restantes=None, sobreposicao_frequencia=resultado["sobreposicao_frequencia"],
        recomendacao=resultado["recomendacao"], explicacao=explicacao, dados_ausentes=ausentes,
    )


@router.get("/alunos/{matricula}/historico", response_model=list[AvaliacaoHistorica], tags=["alunos"])
def historico_do_aluno(matricula: Matricula, request: Request,
                       usuario: Usuario = Depends(exigir_perfis(ALUNO, DOCENTE, COORDENACAO, NUCLEO_APOIO)),
                       conexao: Connection = Depends(obter_conexao)):
    """Serie historica de avaliacoes de risco (RN09)."""
    verificar_escopo_aluno(request, conexao, usuario, matricula, "LER_HISTORICO")
    linhas = conexao.execute(sql.HISTORICO_RISCO, {"id_aluno": matricula, "limite": 200}).mappings().all()
    return [AvaliacaoHistorica(
        periodo_letivo=l["periodo_letivo"], tipo=l["tipo"], data_avaliacao=converter_data(l["data_avaliacao"]),
        risco_evasao_pct=_float(l["risco_evasao_pct"]), nivel_risco=_nivel(l["nivel_risco"]),
    ) for l in linhas]


@router.get("/indicadores/agregados", response_model=RespostaAgregados, tags=["indicadores"])
def indicadores_agregados(request: Request, usuario: Usuario = Depends(exigir_perfis(COORDENACAO, DIRECAO)),
                          conexao: Connection = Depends(obter_conexao)):
    """Contagem por semestre e nivel, sem nome nem matricula; grupos < 5 suprimidos (CA19)."""
    id_curso = usuario.id_curso if usuario.perfil == COORDENACAO else None
    if usuario.perfil == COORDENACAO and id_curso is None:
        raise erro_http(403, "Seu usuário não está vinculado a um curso.")
    linhas = conexao.execute(sql.AGREGADOS_POR_SEMESTRE, {
        "id_curso": id_curso, "minimo_grupo": MINIMO_GRUPO_AGREGADO}).mappings().all()
    auditoria.registrar(request, "LER_AGREGADOS", "PERMITIDO", usuario=usuario)
    return RespostaAgregados(minimo_por_grupo=MINIMO_GRUPO_AGREGADO, grupos=[
        GrupoAgregado(semestre=l["semestre"], nivel_risco=_nivel(l["nivel_risco"]), total=l["total"])
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
    consent = conexao.execute(sql.CONSENTIMENTOS_DO_ALUNO, {"id_aluno": id_aluno}).mappings().all()
    auditoria.registrar(request, "EXPORTAR_MEUS_DADOS", "PERMITIDO", usuario=usuario, id_aluno_alvo=id_aluno)

    return {
        "gerado_em": _agora().isoformat(),
        "controlador": "Universidade (controladora dos dados). Contato: encarregado de dados da instituição.",
        "cadastro": _linha_json(cadastro),
        "socioeconomico": _linha_json(socio),
        "matriculas": [_linha_json(m) for m in matriculas],
        "avaliacoes_de_risco": [_linha_json(a) for a in avaliacoes],
        "consentimentos": [_linha_json(c) for c in consent],
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
        "concedido_por": "TITULAR", "versao_termo": pedido.versao_termo, "registrado_em": _agora(),
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
        "registrada_em": _agora()})
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
def ler_auditoria(request: Request, pagina: FiltroPagina = Depends(filtro_pagina),
                  usuario: Usuario = Depends(exigir_perfis(ENCARREGADO_DADOS)),
                  conexao: Connection = Depends(obter_conexao)):
    """Trilha de acessos para o encarregado de dados. Ler a trilha tambem fica registrado."""
    linhas = conexao.execute(sql.LISTAR_AUDITORIA, {
        "id_aluno": None, "limite": pagina.limite,
        "deslocamento": (pagina.pagina - 1) * pagina.limite}).mappings().all()
    auditoria.registrar(request, "LER_AUDITORIA", "PERMITIDO", usuario=usuario)
    return [RegistroAuditoria(**l) for l in linhas]
