"""
Area do aluno (RN17), disciplinas e acompanhamento na ficha, turmas do
docente, lista do setor financeiro e calendario de retorno (RN14).
"""

from datetime import datetime, timedelta
from enum import Enum
from typing import Annotated

from fastapi import APIRouter, Depends, Path, Query, Request
from pydantic import Field, field_validator
from sqlalchemy.engine import Connection

from app.api import auditoria, consultas as sql, consultas_painel as sqlp
from app.api.auth import Usuario, exigir_perfis
from app.api.banco import obter_conexao
from app.api.erros import MSG_ACESSO_NEGADO, erro_http
from app.api.esquemas import AVISO_METODOLOGICO, PADRAO_MATRICULA, Fechado, Matricula
from app.api.notificar import notificar, usuarios_do_perfil
from app.api.parametros_db import parametros_vigentes
from app.api.permissoes import (ALUNO, COORDENACAO, DOCENTE, FINANCEIRO, NUCLEO_APOIO, verificar_escopo_aluno)
from app.api.rotas_alertas import evento_visivel
from app.api.util import agora, lista_json, numero, sim_nao, valor_json
from app.api.visibilidade import principais_visiveis, recomendacoes_visiveis, recortar_score
from app.calculo.score import AVISO_PESOS, FATORES, ROTULOS

router_aluno = APIRouter(prefix="/api/v1", tags=["aluno"])

# RN17: para o aluno, situacao de acompanhamento; nunca "risco de evasao" nem numero isolado.
SITUACAO_PARA_ALUNO = {
    "BAIXO": ("Sem pendências de acompanhamento", "Seus indicadores estão dentro do esperado."),
    "MODERADO": ("Acompanhamento preventivo",
                 "Alguns fatores merecem atenção. A equipe está disponível se você quiser conversar."),
    "ALTO": ("Acompanhamento prioritário",
             "Há fatores que costumam dificultar a permanência no curso. A equipe vai procurar você, "
             "e você pode falar com ela agora."),
    "CRITICO": ("Acompanhamento imediato",
                "Há fatores que pedem atenção agora. Fale com a equipe pelo ambiente virtual ou marque um horário."),
    "INDETERMINADO": ("Dados incompletos",
                      "Faltam dados para avaliar sua situação. A secretaria foi avisada para completar o cadastro."),
}
CANAL_IMEDIATO = {"texto": "Falar com a equipe agora pelo ambiente virtual", "destino": "chat"}


def _matricula_do_aluno(usuario: Usuario) -> str:
    if not usuario.id_aluno:
        raise erro_http(403, MSG_ACESSO_NEGADO)
    return usuario.id_aluno


# ---------------------------------------------------------------------------
# Area do aluno
# ---------------------------------------------------------------------------

@router_aluno.get("/aluno/situacao")
def minha_situacao(request: Request, usuario: Usuario = Depends(exigir_perfis(ALUNO)),
                   conexao: Connection = Depends(obter_conexao)):
    """Situacao de acompanhamento, fatores com o numero concreto e apoios (RN17 a, b, c)."""
    matricula = _matricula_do_aluno(usuario)
    linha = conexao.execute(sql.SCORE_ATUAL, {"id_aluno": matricula}).mappings().first()
    auditoria.registrar(request, "LER_PROPRIA_SITUACAO", "PERMITIDO", usuario=usuario, id_aluno_alvo=matricula)
    if linha is None:
        return {"situacao": "Em processamento", "mensagem": "Seus dados ainda estão sendo processados.",
                "fatores": [], "apoios": [], "canal_imediato": None, "aviso": AVISO_METODOLOGICO}
    recorte = recortar_score(ALUNO, linha)
    titulo, mensagem = SITUACAO_PARA_ALUNO[recorte["nivel"]]
    return {
        "situacao": titulo,
        "mensagem": mensagem,
        "nivel": recorte["nivel"],
        "fatores": [{"fator": f["fator"], "nome": f["nome"], "explicacao": f["explicacao"],
                     "acionavel": f.get("acionavel")} for f in recorte["fatores"]
                    if f.get("pontuacao") is None or f["pontuacao"] > 0],
        "apoios": [{"texto": r["texto"], "area": r["perfil_atendimento"], "fator": r.get("fator_rotulo")}
                   for r in recorte["recomendacoes"]],
        "canal_imediato": CANAL_IMEDIATO if recorte["nivel"] in ("ALTO", "CRITICO") else None,
        "pode_contestar": True,
        "atualizado_em": valor_json(recorte["calculado_em"]),
        "aviso": AVISO_METODOLOGICO,
        "aviso_pesos": AVISO_PESOS,
    }


def _disciplinas(conexao: Connection, matricula: str) -> list[dict]:
    p = parametros_vigentes(conexao)
    saida = []
    for d in conexao.execute(sqlp.DISCIPLINAS_DO_ALUNO, {"id_aluno": matricula}).mappings():
        nota, freq = numero(d["nota_final"]), numero(d["frequencia_pct"])
        saida.append({
            "id_turma": d["id_turma"], "disciplina": d["materia"], "periodo_letivo": d["periodo_letivo"],
            "turno": d["turno"], "carga_horaria_h": d["carga_horaria_h"], "professor": d["professor"],
            "va1": numero(d["va1"]), "va2": numero(d["va2"]), "va3": numero(d["va3"]),
            "nota_final": nota, "frequencia_pct": freq, "situacao": d["situacao"],
            "nota_abaixo_do_minimo": None if nota is None else nota < p["NOTA_MINIMA"],
            "frequencia_abaixo_do_minimo": None if freq is None else freq < p["FREQUENCIA_MINIMA"],
            # RF17 precisa de aulas previstas e faltas por disciplina, que o B1 nao registra.
            "faltas_restantes": None,
            "observacao_faltas": "Sem dado: o banco não registra aulas previstas nem faltas por disciplina.",
        })
    return saida


@router_aluno.get("/aluno/disciplinas")
def minhas_disciplinas(request: Request, usuario: Usuario = Depends(exigir_perfis(ALUNO)),
                       conexao: Connection = Depends(obter_conexao)):
    matricula = _matricula_do_aluno(usuario)
    auditoria.registrar(request, "LER_PROPRIAS_DISCIPLINAS", "PERMITIDO", usuario=usuario, id_aluno_alvo=matricula)
    p = parametros_vigentes(conexao)
    return {"nota_minima": p["NOTA_MINIMA"], "frequencia_minima": p["FREQUENCIA_MINIMA"],
            "disciplinas": _disciplinas(conexao, matricula)}


@router_aluno.get("/aluno/acompanhamento")
def meu_acompanhamento(request: Request, usuario: Usuario = Depends(exigir_perfis(ALUNO)),
                       conexao: Connection = Depends(obter_conexao)):
    """Registros que a equipe marcou como visiveis, agendamentos e pedidos do aluno."""
    matricula = _matricula_do_aluno(usuario)
    eventos = conexao.execute(sqlp.EVENTOS_VISIVEIS_AO_ALUNO, {"id_aluno": matricula}).mappings().all()
    agendamentos = conexao.execute(sqlp.AGENDAMENTOS_DO_ALUNO, {"id_aluno": matricula}).mappings().all()
    pedidos = conexao.execute(sqlp.SOLICITACOES_DO_ALUNO, {"id_aluno": matricula}).mappings().all()
    auditoria.registrar(request, "LER_PROPRIO_ACOMPANHAMENTO", "PERMITIDO", usuario=usuario, id_aluno_alvo=matricula)
    return {"registros": [{k: valor_json(v) for k, v in e.items()} for e in eventos],
            "agendamentos": [{k: valor_json(v) for k, v in a.items()} for a in agendamentos],
            "pedidos": [{k: valor_json(v) for k, v in s.items()} for s in pedidos]}


class PedidoContestacao(Fechado):
    fator: str = Field(max_length=30)
    descricao: str = Field(min_length=10, max_length=1000)

    @field_validator("fator")
    @classmethod
    def _fator_conhecido(cls, v: str) -> str:
        if v not in FATORES:
            raise ValueError("fator desconhecido")
        return v


@router_aluno.post("/aluno/contestacoes", status_code=201)
def contestar_fator(pedido: PedidoContestacao, request: Request, usuario: Usuario = Depends(exigir_perfis(ALUNO)),
                    conexao: Connection = Depends(obter_conexao)):
    """RN17 (d): o aluno contesta um fator; abre tarefa de verificacao de dados."""
    matricula = _matricula_do_aluno(usuario)
    conexao.execute(sql.REGISTRAR_SOLICITACAO_TITULAR, {
        "id_aluno": matricula, "tipo": "CORRECAO", "registrada_em": agora(),
        "descricao": f"Contestação do fator {ROTULOS.get(pedido.fator, pedido.fator)}: {pedido.descricao}"[:1000]})
    id_curso = conexao.execute(sql.ALUNO_BASICO, {"id_aluno": matricula}).mappings().first()["id_curso"]
    notificar(conexao, usuarios_do_perfil(conexao, COORDENACAO, id_curso), "TAREFA_DADOS",
              "Contestação de dado pelo aluno", f"A matrícula {matricula} pediu a verificação de um fator do score.")
    conexao.commit()
    auditoria.registrar(request, "CONTESTAR_FATOR", "PERMITIDO", usuario=usuario, id_aluno_alvo=matricula)
    return {"registrado": True, "prazo": "A equipe verifica o dado e responde em até 15 dias."}


# ---------------------------------------------------------------------------
# Ficha do aluno para a equipe
# ---------------------------------------------------------------------------

@router_aluno.get("/alunos/{matricula}/disciplinas")
def disciplinas_do_aluno(matricula: Matricula, request: Request,
                         usuario: Usuario = Depends(exigir_perfis(DOCENTE, COORDENACAO, NUCLEO_APOIO)),
                         conexao: Connection = Depends(obter_conexao)):
    verificar_escopo_aluno(request, conexao, usuario, matricula, "LER_DISCIPLINAS")
    p = parametros_vigentes(conexao)
    return {"nota_minima": p["NOTA_MINIMA"], "frequencia_minima": p["FREQUENCIA_MINIMA"],
            "disciplinas": _disciplinas(conexao, matricula)}


@router_aluno.get("/alunos/{matricula}/recomendacoes")
def recomendacoes_do_aluno(matricula: Matricula, request: Request,
                           usuario: Usuario = Depends(exigir_perfis(COORDENACAO, NUCLEO_APOIO)),
                           conexao: Connection = Depends(obter_conexao)):
    """No maximo 4, por severidade, cada uma com o fator que a originou (Anexo F, RF12)."""
    verificar_escopo_aluno(request, conexao, usuario, matricula, "LER_RECOMENDACOES")
    linha = conexao.execute(sql.SCORE_ATUAL, {"id_aluno": matricula}).mappings().first()
    if linha is None:
        return {"recomendacoes": [], "observacao": "O score deste aluno ainda não foi calculado."}
    return {"recomendacoes": recomendacoes_visiveis(usuario.perfil, linha["recomendacoes"]),
            "recomendacao_nivel": linha["recomendacao"],
            "observacao": "Recomendação é sugestão: a decisão de agir é da equipe (RN05)."}


@router_aluno.get("/alunos/{matricula}/acompanhamento")
def acompanhamento_do_aluno(matricula: Matricula, request: Request,
                            usuario: Usuario = Depends(exigir_perfis(DOCENTE, COORDENACAO, NUCLEO_APOIO, FINANCEIRO)),
                            conexao: Connection = Depends(obter_conexao)):
    """Historico de alertas e contatos na ficha (Anexo D.3, Perfil do aluno)."""
    verificar_escopo_aluno(request, conexao, usuario, matricula, "LER_ACOMPANHAMENTO")
    alertas = []
    for a in conexao.execute(sqlp.ALERTAS_DO_ALUNO, {"id_aluno": matricula}).mappings():
        if usuario.perfil in (DOCENTE, FINANCEIRO) and a["tipo"] != "PEDAGOGICO":
            continue
        eventos = conexao.execute(sqlp.EVENTOS_DO_ALERTA, {"id_alerta": a["id_alerta"]}).mappings().all()
        alertas.append({**{k: valor_json(v) for k, v in a.items()},
                        "eventos": [evento_visivel(usuario, e) for e in eventos]})
    agendamentos = []
    if usuario.perfil in (COORDENACAO, NUCLEO_APOIO):
        agendamentos = [{k: valor_json(v) for k, v in g.items()}
                        for g in conexao.execute(sqlp.AGENDAMENTOS_DO_ALUNO, {"id_aluno": matricula}).mappings()]
    return {"alertas": alertas, "agendamentos": agendamentos}


# ---------------------------------------------------------------------------
# Docente: turmas
# ---------------------------------------------------------------------------

@router_aluno.get("/turmas", tags=["docente"])
def minhas_turmas(request: Request, usuario: Usuario = Depends(exigir_perfis(DOCENTE)),
                  conexao: Connection = Depends(obter_conexao)):
    linhas = conexao.execute(sqlp.TURMAS_DO_DOCENTE, {"id_professor": usuario.id_professor}).mappings().all()
    auditoria.registrar(request, "LISTAR_TURMAS", "PERMITIDO", usuario=usuario)
    return [{"id_turma": l["id_turma"], "disciplina": l["materia"], "periodo_letivo": l["periodo_letivo"],
             "turno": l["turno"], "carga_horaria_h": l["carga_horaria_h"], "alunos": int(l["alunos"]),
             "criticos": int(l["criticos"]), "altos": int(l["altos"]),
             "media_turma": None if l["media_turma"] is None else round(float(l["media_turma"]), 2),
             "frequencia_turma": None if l["frequencia_turma"] is None else round(float(l["frequencia_turma"]), 1)}
            for l in linhas]


@router_aluno.get("/turmas/{id_turma}/alunos", tags=["docente"])
def alunos_da_turma(id_turma: Annotated[str, Path(pattern=r"^[A-Za-z0-9_-]{2,40}$")], request: Request,
                    usuario: Usuario = Depends(exigir_perfis(DOCENTE)), conexao: Connection = Depends(obter_conexao)):
    """So turma do proprio docente; fatores de contexto aparecem como encaminhados (RN07)."""
    turma = conexao.execute(sqlp.TURMA_DO_DOCENTE, {"id_turma": id_turma,
                                                    "id_professor": usuario.id_professor}).mappings().first()
    if turma is None:
        auditoria.registrar(request, "LER_TURMA", "NEGADO", usuario=usuario)
        raise erro_http(403, "Você não tem acesso a esta turma, ou ela não existe.")
    linhas = conexao.execute(sqlp.ALUNOS_DA_TURMA, {"id_turma": id_turma}).mappings().all()
    auditoria.registrar(request, "LER_TURMA", "PERMITIDO", usuario=usuario)
    return {"turma": dict(turma), "alunos": [{
        "matricula": l["id_aluno"], "nome": l["nome_ficticio"], "semestre": l["semestre_atual"],
        "nota_final": numero(l["nota_final"]), "frequencia_pct": numero(l["frequencia_pct"]),
        "situacao": l["situacao"], "nivel": l["nivel"], "score": l["score"],
        "fatores_principais": principais_visiveis(DOCENTE, l["fatores_principais"])} for l in linhas]}


# ---------------------------------------------------------------------------
# Setor financeiro (Anexo E: pendencias e elegibilidade; sem saude nem desempenho)
# ---------------------------------------------------------------------------

@router_aluno.get("/financeiro/alunos", tags=["financeiro"])
def alunos_do_financeiro(request: Request, limite: Annotated[int, Query(ge=1, le=200)] = 50,
                         pagina: Annotated[int, Query(ge=1, le=10_000)] = 1,
                         usuario: Usuario = Depends(exigir_perfis(FINANCEIRO)),
                         conexao: Connection = Depends(obter_conexao)):
    salario = parametros_vigentes(conexao)["SALARIO_MINIMO"]
    linhas = conexao.execute(sqlp.ALUNOS_DO_FINANCEIRO, {"limite": limite,
                                                         "deslocamento": (pagina - 1) * limite}).mappings().all()
    auditoria.registrar(request, "LISTAR_FINANCEIRO", "PERMITIDO", usuario=usuario)
    return [{"matricula": l["id_aluno"], "nome": l["nome_ficticio"], "id_alerta": l["id_alerta"],
             "nivel": l["nivel"], "situacao_alerta": l["situacao"], "prazo_em": valor_json(l["prazo_em"]),
             "renda_per_capita_sm": None if l["renda_per_capita"] is None
             else round(float(l["renda_per_capita"]) / salario, 2),
             "auxilio_ativo": sim_nao(l["auxilio_bolsa"]),
             "recomendacoes": [r["texto"] for r in lista_json(l["recomendacoes"])
                               if r["perfil_atendimento"] == "Financeiro"]} for l in linhas]


# ---------------------------------------------------------------------------
# Calendario de retorno (RN14, CA03, RF14)
# ---------------------------------------------------------------------------

class PedidoAgendamento(Fechado):
    matricula: str | None = Field(default=None, pattern=PADRAO_MATRICULA, description="Equipe: aluno do agendamento")
    inicio: datetime
    motivo_excecao: str | None = Field(default=None, min_length=10, max_length=300)

    @field_validator("inicio")
    @classmethod
    def _horario(cls, v: datetime) -> datetime:
        if v.tzinfo is None:
            raise ValueError("informe o fuso horário")
        if v.minute not in (0, 30) or v.second or v.microsecond:
            raise ValueError("horários de 30 em 30 minutos")
        return v


class SituacaoAgendamento(str, Enum):
    REALIZADO = "REALIZADO"
    CANCELADO = "CANCELADO"


class PedidoMudancaAgendamento(Fechado):
    situacao: SituacaoAgendamento


def _aluno_do_pedido(request, conexao, usuario: Usuario, matricula: str | None, operacao: str) -> str:
    if usuario.perfil == ALUNO:
        return _matricula_do_aluno(usuario)
    if not matricula:
        raise erro_http(422, "Informe a matrícula do aluno.")
    verificar_escopo_aluno(request, conexao, usuario, matricula, operacao)
    return matricula


@router_aluno.get("/agendamentos", tags=["agendamentos"])
def listar_agendamentos(request: Request, matricula: Annotated[str | None, Query(pattern=PADRAO_MATRICULA)] = None,
                        usuario: Usuario = Depends(exigir_perfis(ALUNO, COORDENACAO, NUCLEO_APOIO)),
                        conexao: Connection = Depends(obter_conexao)):
    aluno = _aluno_do_pedido(request, conexao, usuario, matricula, "LER_AGENDAMENTOS")
    p = parametros_vigentes(conexao)
    ultimo = conexao.execute(sqlp.ULTIMO_AGENDAMENTO_ATIVO, {"id_aluno": aluno}).scalar()
    return {"intervalo_minimo_dias": int(p["INTERVALO_ATENDIMENTOS"]),
            "proxima_data_livre": None if ultimo is None
            else valor_json(ultimo + timedelta(days=int(p["INTERVALO_ATENDIMENTOS"]))),
            "agendamentos": [{k: valor_json(v) for k, v in g.items()}
                             for g in conexao.execute(sqlp.AGENDAMENTOS_DO_ALUNO, {"id_aluno": aluno}).mappings()]}


@router_aluno.post("/agendamentos", status_code=201, tags=["agendamentos"])
def agendar(pedido: PedidoAgendamento, request: Request,
            usuario: Usuario = Depends(exigir_perfis(ALUNO, COORDENACAO, NUCLEO_APOIO)),
            conexao: Connection = Depends(obter_conexao)):
    """
    RN14: intervalo minimo entre atendimentos, validado no servidor. Recusa
    informa a proxima data possivel. Excecao: aluno Critico ou com alerta
    aberto de prazo de 48 h, com o motivo registrado.
    """
    aluno = _aluno_do_pedido(request, conexao, usuario, pedido.matricula, "AGENDAR")
    momento = agora()
    if pedido.inicio <= momento + timedelta(hours=1):
        raise erro_http(422, "Escolha um horário com pelo menos 1 hora de antecedência.")
    if pedido.inicio > momento + timedelta(days=180):
        raise erro_http(422, "Agendamentos só até 180 dias à frente.")

    intervalo = int(parametros_vigentes(conexao)["INTERVALO_ATENDIMENTOS"])
    conflito = conexao.execute(sqlp.AGENDAMENTO_PROXIMO, {"id_aluno": aluno, "pedido": pedido.inicio,
                                                          "intervalo": intervalo}).scalar()
    alerta = conexao.execute(sql.ALERTA_ABERTO_DO_ALUNO, {"id_aluno": aluno}).mappings().first()
    motivo = None
    if conflito is not None:
        excecao = alerta is not None and alerta["nivel"] == "CRITICO"
        if not excecao:
            proxima = conflito + timedelta(days=intervalo)
            conexao.execute(sqlp.REGISTRAR_RECUSA_AGENDAMENTO, {"id_aluno": aluno, "pedido_para": pedido.inicio,
                                                                "proxima_data": proxima,
                                                                "solicitado_por": usuario.id_usuario,
                                                                "agora": momento})
            conexao.commit()
            auditoria.registrar(request, "AGENDAMENTO_RECUSADO", "NEGADO", usuario=usuario, id_aluno_alvo=aluno)
            raise erro_http(409, f"O intervalo mínimo entre atendimentos é de {intervalo} dias. "
                                 f"Próxima data possível: {proxima:%d/%m/%Y}.")
        motivo = pedido.motivo_excecao or ("Aluno em nível Crítico: atendimento antes do intervalo mínimo "
                                           "(RN14, exceção).")
        if usuario.perfil != ALUNO and not pedido.motivo_excecao:
            raise erro_http(422, "Atendimento antes do intervalo mínimo exige o motivo da exceção.")
    novo = conexao.execute(sqlp.CRIAR_AGENDAMENTO, {
        "id_aluno": aluno, "inicio": pedido.inicio, "solicitado_por": usuario.id_usuario, "agora": momento,
        "motivo_excecao": motivo, "id_alerta": alerta["id_alerta"] if alerta else None}).scalar()
    if alerta is not None and alerta["id_responsavel"] and alerta["id_responsavel"] != usuario.id_usuario:
        notificar(conexao, [alerta["id_responsavel"]], "ALERTA_ATRIBUIDO", "Novo agendamento",
                  f"Matrícula {aluno}: atendimento marcado para {pedido.inicio:%d/%m/%Y %H:%M}.", alerta["id_alerta"])
    conexao.commit()
    auditoria.registrar(request, "AGENDAMENTO_EXCECAO" if motivo else "AGENDAMENTO", "PERMITIDO",
                        usuario=usuario, id_aluno_alvo=aluno)
    return {"id_agendamento": novo, "inicio": pedido.inicio.isoformat(), "excecao": motivo}


@router_aluno.patch("/agendamentos/{id_agendamento}", tags=["agendamentos"])
def mudar_agendamento(id_agendamento: Annotated[int, Path(ge=1)], pedido: PedidoMudancaAgendamento,
                      request: Request, usuario: Usuario = Depends(exigir_perfis(ALUNO, COORDENACAO, NUCLEO_APOIO)),
                      conexao: Connection = Depends(obter_conexao)):
    linha = conexao.execute(sqlp.AGENDAMENTO_POR_ID, {"id_agendamento": id_agendamento}).mappings().first()
    if linha is None:
        raise erro_http(403, "Você não tem acesso a este agendamento, ou ele não existe.")
    if usuario.perfil == ALUNO:
        if linha["id_aluno"] != usuario.id_aluno:
            auditoria.registrar(request, "MUDAR_AGENDAMENTO", "NEGADO", usuario=usuario)
            raise erro_http(403, "Você não tem acesso a este agendamento, ou ele não existe.")
        if pedido.situacao != SituacaoAgendamento.CANCELADO:
            raise erro_http(403, "O aluno só pode cancelar o próprio agendamento.")
    else:
        verificar_escopo_aluno(request, conexao, usuario, linha["id_aluno"], "MUDAR_AGENDAMENTO")
    if linha["situacao"] != "MARCADO":
        raise erro_http(409, "Este agendamento já foi concluído ou cancelado.")
    conexao.execute(sqlp.MUDAR_AGENDAMENTO, {"situacao": pedido.situacao.value, "agora": agora(),
                                             "id_agendamento": id_agendamento})
    conexao.commit()
    return {"atualizado": True}
