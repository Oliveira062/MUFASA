"""
Ponte B1 -> B2: le as tabelas do B1 e monta o dicionario que o
calcular_score_aluno() do B2 espera. Nenhuma regra de calculo aqui: so
leitura, conversao de unidade e descarte de valor impossivel.

Pontos que dependem do B1 (ver docs/AUDITORIA_SEGURANCA.md):
- O B1 nao tem aulas previstas nem disciplinas cursadas no historico, entao
  faltas restantes e taxa de reprovacao saem como ausentes.
- O B1 nao tem saude mental, saude fisica, moradia, dependentes nem AVA.
  Esses fatores ficam ausentes e o B2 os exclui da conta.
- horas_trabalho_dia vira horas por semana multiplicando por 5 dias uteis.
  Confirmar com o B1 se a coluna e por dia util.
"""

import math
from decimal import Decimal

from sqlalchemy.engine import Connection

from app.api.consultas import INDICADORES_ATUAIS, SOCIOECONOMICO_RESTRITO
from app.calculo.score import PESOS
from app.config import Configuracao

# O B2 devolve CRITICO; o banco do B1 grava "Crítico". A API devolve sempre o
# formato do SRS (maiusculas, sem acento).
NIVEL_DO_BANCO = {"Baixo": "BAIXO", "Moderado": "MODERADO", "Alto": "ALTO", "Crítico": "CRITICO"}
NIVEL_PARA_BANCO = {v: k for k, v in NIVEL_DO_BANCO.items()}

DIAS_UTEIS_SEMANA = 5


def _numero(valor, minimo: float, maximo: float) -> float | None:
    """Converte para float e descarta NaN, infinito e valor fora da faixa."""
    if valor is None:
        return None
    try:
        numero = float(valor)
    except (TypeError, ValueError):
        return None
    if not math.isfinite(numero) or numero < minimo or numero > maximo:
        return None
    return numero


def _trabalha(valor) -> bool | None:
    if valor is None:
        return None
    texto = str(valor).strip().lower()
    if texto in ("não", "nao", "n", "false", "0", ""):
        return False
    return True


def montar_dados_score(conexao: Connection, id_aluno: str, cfg: Configuracao) -> dict:
    ind = conexao.execute(INDICADORES_ATUAIS, {"id_aluno": id_aluno}).mappings().first() or {}
    soc = conexao.execute(SOCIOECONOMICO_RESTRITO, {"id_aluno": id_aluno}).mappings().first() or {}

    horas_dia = _numero(soc.get("horas_trabalho_dia"), 0, 24)
    trabalha = _trabalha(soc.get("trabalha"))
    if trabalha is False:
        horas_semana = 0.0
    elif horas_dia is not None:
        horas_semana = horas_dia * DIAS_UTEIS_SEMANA
    else:
        horas_semana = None

    renda_sm = None
    renda = _numero(soc.get("renda_per_capita"), 0, 1_000_000)
    if renda is not None and cfg.salario_minimo:
        renda_sm = float(Decimal(str(renda)) / cfg.salario_minimo)

    return {
        "matricula": id_aluno,
        "media_ponderada": _numero(ind.get("media_atual"), 0, 10),
        "percentual_frequencia": _numero(ind.get("frequencia_pct"), 0, 100),
        "faltas": _numero(ind.get("faltas_total"), 0, 10_000),
        "aulas_previstas": None,
        "taxa_reprovacao": None,
        "horas_trabalho_semana": horas_semana,
        "renda_per_capita_sm": renda_sm,
        "minutos_deslocamento": _numero(soc.get("tempo_deslocamento_min"), 0, 1_440),
    }


def fatores_ausentes(resultado: dict) -> list[str]:
    presentes = set(resultado.get("detalhamento", {}))
    return [f for f in PESOS if f not in presentes]
