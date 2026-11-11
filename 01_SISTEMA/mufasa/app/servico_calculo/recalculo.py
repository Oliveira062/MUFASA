"""
Recalculo do score e atualizacao dos alertas (RN01, RN03, RN09).

Cada lote roda numa transacao: le alunos da fila (FOR UPDATE SKIP LOCKED,
para dois servicos de calculo nunca pegarem o mesmo aluno), calcula, grava
uma linha NOVA em scores_risco quando algo mudou (a tabela e so de
insercao) e cria ou atualiza o alerta. Se um aluno der erro, o lote todo
volta e o erro vai para os registros tecnicos, sem dado pessoal.
"""

import json
import logging
from collections import defaultdict
from datetime import datetime, timedelta, timezone

from sqlalchemy.engine import Connection

from app.calculo.parametros import Parametros
from app.calculo.recomendacoes import gerar_recomendacoes
from app.calculo.score import NOMES_NIVEL, calcular_score_aluno, calcular_tendencia
from app.servico_calculo import consultas_calculo as sql
from app.servico_calculo.dados import montar_dados

log = logging.getLogger("mufasa.calculo")

NIVEIS_DE_ALERTA = ("ALTO", "CRITICO")


def somar_dias_uteis(inicio: datetime, dias: int) -> datetime:
    """Soma dias uteis (segunda a sexta). Feriados nao estao cadastrados no sistema."""
    atual = inicio
    restantes = int(dias)
    while restantes > 0:
        atual += timedelta(days=1)
        if atual.weekday() < 5:
            restantes -= 1
    return atual


def prazo_do_nivel(nivel: str, agora: datetime, p: Parametros) -> datetime:
    """RN02: Critico 48 h; Alto 5 dias uteis; Indeterminado (tarefa de dados) 10 dias uteis."""
    if nivel == "CRITICO":
        return agora + timedelta(hours=p["SLA_CRITICO_HORAS"])
    if nivel == "ALTO":
        return somar_dias_uteis(agora, p["SLA_ALTO_DIAS_UTEIS"])
    return somar_dias_uteis(agora, p["SLA_DADOS_DIAS_UTEIS"])


def _json(valor) -> str:
    return json.dumps(valor, ensure_ascii=False, default=float)


def _como_lista(valor):
    if valor is None:
        return []
    return json.loads(valor) if isinstance(valor, str) else valor


def _mudou(resultado: dict, ultimo, versao: int) -> bool:
    if ultimo is None:
        return True
    return (resultado["score"], resultado["nivel"], resultado["nivel_origem"], versao,
            resultado["motivo_sobreposicao"], _json(resultado["fatores"]), _json(resultado["modificadores"])) != (
        ultimo["score"], ultimo["nivel"], ultimo["nivel_origem"], ultimo["versao_parametros"],
        ultimo["motivo_sobreposicao"], _json(_como_lista(ultimo["fatores"])),
        _json(_como_lista(ultimo["modificadores"])))


class Avisos:
    """Junta as notificacoes do lote: uma por pessoa, nao uma por aluno."""

    def __init__(self):
        self.novos = defaultdict(lambda: defaultdict(int))   # id_curso -> nivel -> quantidade
        self.pessoais = []                                    # (id_usuario, tipo, titulo, texto, id_alerta)
        self.tarefas_dados = 0

    def enviar(self, conexao: Connection, agora: datetime) -> None:
        for id_curso, por_nivel in self.novos.items():
            total = sum(por_nivel.values())
            partes = [f"{q} {NOMES_NIVEL[n]}" for n, q in sorted(por_nivel.items(), key=lambda x: x[0] != "CRITICO")]
            texto = f"{total} aluno(s) entraram na fila de alertas: " + ", ".join(partes) + "."
            for pessoa in conexao.execute(sql.EQUIPE_DO_CURSO, {"id_curso": id_curso}).mappings():
                conexao.execute(sql.CRIAR_NOTIFICACAO, {"id_usuario": pessoa["id_usuario"], "agora": agora,
                                                        "tipo": "ALERTA_NOVO", "titulo": "Novos alertas",
                                                        "texto": texto[:300], "id_alerta": None})
        for id_usuario, tipo, titulo, texto, id_alerta in self.pessoais:
            conexao.execute(sql.CRIAR_NOTIFICACAO, {"id_usuario": id_usuario, "agora": agora, "tipo": tipo,
                                                    "titulo": titulo, "texto": texto[:300], "id_alerta": id_alerta})
        if self.tarefas_dados:
            for admin in conexao.execute(sql.ADMINISTRACAO).mappings():
                conexao.execute(sql.CRIAR_NOTIFICACAO, {
                    "id_usuario": admin["id_usuario"], "agora": agora, "tipo": "TAREFA_DADOS",
                    "titulo": "Tarefas de correção de dados",
                    "texto": f"{self.tarefas_dados} aluno(s) sem dados suficientes para o score (abaixo de 40%).",
                    "id_alerta": None})


def _atualizar_alertas(conexao, id_aluno, id_score, resultado, anterior_nivel, contexto, p, agora, avisos):
    nivel = resultado["nivel"]

    # Tarefa de dados (RN01, CA12): nunca vira alerta pedagogico.
    tarefa = conexao.execute(sql.ALERTA_ABERTO, {"id_aluno": id_aluno, "tipo": "DADOS"}).mappings().first()
    if nivel == "INDETERMINADO" and tarefa is None:
        id_tarefa = conexao.execute(sql.CRIAR_ALERTA, {
            "id_aluno": id_aluno, "id_score": id_score, "tipo": "DADOS", "nivel": "INDETERMINADO", "agora": agora,
            "prazo_em": prazo_do_nivel("INDETERMINADO", agora, p), "id_responsavel": None}).scalar_one()
        conexao.execute(sql.REGISTRAR_EVENTO, {"id_alerta": id_tarefa, "agora": agora, "tipo": "CRIADO",
                                               "descricao": "Completude abaixo de 40%: tarefa de correção de dados."})
        avisos.tarefas_dados += 1
    elif nivel != "INDETERMINADO" and tarefa is not None:
        conexao.execute(sql.ENCERRAR_TAREFA_DADOS, {"id_alerta": tarefa["id_alerta"], "agora": agora})
        conexao.execute(sql.REGISTRAR_EVENTO, {"id_alerta": tarefa["id_alerta"], "agora": agora, "tipo": "ENCERRADO",
                                               "descricao": "Dados completados; o score foi calculado."})

    alerta = conexao.execute(sql.ALERTA_ABERTO, {"id_aluno": id_aluno, "tipo": "PEDAGOGICO"}).mappings().first()
    if alerta is None:
        if nivel not in NIVEIS_DE_ALERTA:
            return
        responsavel = None
        if nivel == "CRITICO":
            responsavel = conexao.execute(sql.NAE_DISPONIVEL, {
                "id_curso": contexto["id_curso"], "teto": int(p["TETO_ALERTAS_RESPONSAVEL"])}).scalar()
        id_alerta = conexao.execute(sql.CRIAR_ALERTA, {
            "id_aluno": id_aluno, "id_score": id_score, "tipo": "PEDAGOGICO", "nivel": nivel, "agora": agora,
            "prazo_em": prazo_do_nivel(nivel, agora, p), "id_responsavel": responsavel}).scalar_one()
        descricao = f"Nível {NOMES_NIVEL[nivel]} (score {resultado['score'] if resultado['score'] is not None else '—'})."
        if resultado.get("motivo_sobreposicao"):
            descricao += f" {resultado['motivo_sobreposicao']}."
        conexao.execute(sql.REGISTRAR_EVENTO, {"id_alerta": id_alerta, "agora": agora, "tipo": "CRIADO",
                                               "descricao": descricao[:1000]})
        if responsavel is not None:
            conexao.execute(sql.REGISTRAR_EVENTO, {
                "id_alerta": id_alerta, "agora": agora, "tipo": "ATRIBUIDO",
                "descricao": "Alerta Crítico atribuído automaticamente ao núcleo de apoio (RN02)."})
            avisos.pessoais.append((responsavel, "ALERTA_ATRIBUIDO", "Alerta atribuído a você",
                                    "Um alerta Crítico foi atribuído a você. Prazo de 48 horas.", id_alerta))
        avisos.novos[contexto["id_curso"]][nivel] += 1
        return

    if alerta["nivel"] == nivel:
        return
    # RN03: mudou o nivel -> o alerta e atualizado, nunca apagado.
    prazo = alerta["prazo_em"]
    if nivel == "CRITICO" and alerta["situacao"] == "ABERTO":
        prazo = min(prazo, prazo_do_nivel("CRITICO", agora, p))
    conexao.execute(sql.ATUALIZAR_NIVEL_ALERTA, {"id_alerta": alerta["id_alerta"], "nivel": nivel,
                                                 "prazo_em": prazo, "agora": agora})
    conexao.execute(sql.REGISTRAR_EVENTO, {
        "id_alerta": alerta["id_alerta"], "agora": agora, "tipo": "NIVEL_ALTERADO",
        "descricao": f"Nível passou de {NOMES_NIVEL.get(alerta['nivel'], alerta['nivel'])} para "
                     f"{NOMES_NIVEL[nivel]} (score {resultado['score'] if resultado['score'] is not None else '—'})."})
    if alerta["id_responsavel"]:
        avisos.pessoais.append((alerta["id_responsavel"], "ALERTA_NIVEL", "Nível de alerta alterado",
                                f"Um aluno sob sua responsabilidade passou para o nível {NOMES_NIVEL[nivel]}.",
                                alerta["id_alerta"]))


def processar_lote(conexao: Connection, p: Parametros, lote: int = 200) -> int:
    """Processa ate `lote` alunos da fila. Devolve quantos foram processados."""
    agora = datetime.now(timezone.utc)
    hoje = agora.date()
    pendentes = conexao.execute(sql.LER_FILA, {"lote": lote}).mappings().all()
    avisos = Avisos()
    for item in pendentes:
        id_aluno = item["id_aluno"]
        try:
            dados, contexto = montar_dados(conexao, id_aluno, p, hoje)
        except LookupError:
            conexao.execute(sql.TIRAR_DA_FILA, {"id_aluno": id_aluno, "lido_em": item["enfileirado_em"]})
            continue
        resultado = calcular_score_aluno(dados, p)
        resultado["recomendacoes"] = gerar_recomendacoes(resultado, dados, contexto["menor_de_idade"])

        recentes = conexao.execute(sql.SCORES_RECENTES, {"id_aluno": id_aluno}).mappings().all()
        ultimo = recentes[0] if recentes else None
        if _mudou(resultado, ultimo, p.versao):
            serie = [r["score"] for r in reversed(recentes)] + [resultado["score"]]
            id_score = conexao.execute(sql.GRAVAR_SCORE, {
                "id_aluno": id_aluno, "score": resultado["score"], "nivel": resultado["nivel"],
                "completude": resultado["completude"], "fatores_principais": _json(resultado["fatores_principais"]),
                "detalhamento": _json(resultado["detalhamento"]), "contribuicoes": _json(resultado["contribuicoes"]),
                "sobreposicao_frequencia": resultado["sobreposicao_frequencia"],
                "recomendacao": resultado["recomendacao"], "nivel_origem": resultado["nivel_origem"],
                "motivo_sobreposicao": (resultado["motivo_sobreposicao"] or None) and resultado["motivo_sobreposicao"][:400],
                "parcial": resultado["parcial"], "fatores": _json(resultado["fatores"]),
                "modificadores": _json(resultado["modificadores"]),
                "recomendacoes": _json(resultado["recomendacoes"]), "tendencia": calcular_tendencia(serie),
                "score_anterior": ultimo["score"] if ultimo else None,
                "nivel_anterior": ultimo["nivel"] if ultimo else None, "versao_parametros": p.versao,
                "versao_modelo": resultado["versao_modelo"], "motivo": item["motivo"][:40], "calculado_em": agora,
            }).scalar_one()
            _atualizar_alertas(conexao, id_aluno, id_score, resultado, ultimo["nivel"] if ultimo else None,
                               contexto, p, agora, avisos)
        conexao.execute(sql.TIRAR_DA_FILA, {"id_aluno": id_aluno, "lido_em": item["enfileirado_em"]})
    avisos.enviar(conexao, agora)
    return len(pendentes)


def avisar_prazos_vencidos(conexao: Connection) -> int:
    """Registra PRAZO_VENCIDO uma vez por alerta e avisa responsavel e coordenacao."""
    agora = datetime.now(timezone.utc)
    vencidos = conexao.execute(sql.ALERTAS_VENCIDOS_SEM_AVISO, {"agora": agora}).mappings().all()
    for a in vencidos:
        conexao.execute(sql.REGISTRAR_EVENTO, {"id_alerta": a["id_alerta"], "agora": agora, "tipo": "PRAZO_VENCIDO",
                                               "descricao": "Prazo do primeiro atendimento vencido sem ação registrada."})
        destinos = {a["id_responsavel"]} if a["id_responsavel"] else set()
        destinos |= {p["id_usuario"] for p in conexao.execute(sql.EQUIPE_DO_CURSO, {"id_curso": a["id_curso"]})
                     .mappings() if p["perfil"] == "COORDENACAO"}
        for id_usuario in destinos:
            conexao.execute(sql.CRIAR_NOTIFICACAO, {
                "id_usuario": id_usuario, "agora": agora, "tipo": "PRAZO_VENCIDO", "titulo": "Prazo vencido",
                "texto": f"Um alerta {NOMES_NIVEL[a['nivel']]} passou do prazo sem atendimento registrado.",
                "id_alerta": a["id_alerta"]})
    return len(vencidos)
