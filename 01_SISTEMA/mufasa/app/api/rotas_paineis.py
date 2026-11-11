"""
Paineis da coordenacao (curso) e da gestao/direcao (instituicao), Anexo D.3.

Tudo e lido do banco a cada chamada: score atual (vw_score_atual), alertas
e historico. Nenhum numero fixo no codigo.

Direcao (Anexo E, RN07, CA19): so agregados, sem nome nem matricula, e
toda celula com menos alunos que MINIMO_GRUPO sai como suprimida. Havendo
celula suprimida, o total do recorte e os percentuais tambem saem, para que
ninguem chegue ao valor escondido por subtracao.
"""

from datetime import date, timedelta
from enum import Enum
from typing import Annotated

from fastapi import APIRouter, Depends, Query, Request
from sqlalchemy.engine import Connection

from app.api import auditoria, consultas_painel as sqlp
from app.api.auth import Usuario, exigir_perfis
from app.api.banco import obter_conexao
from app.api.erros import erro_http
from app.api.esquemas import AVISO_METODOLOGICO
from app.api.parametros_db import parametros_vigentes
from app.api.permissoes import COORDENACAO, DIRECAO, FATORES_SAUDE, ROTULO_ENCAMINHADO
from app.api.util import agora, como_datetime, valor_json
from app.calculo.score import AVISO_PESOS, ROTULOS

router_paineis = APIRouter(prefix="/api/v1/paineis", tags=["paineis"])

NIVEIS = ("CRITICO", "ALTO", "MODERADO", "BAIXO", "INDETERMINADO", "PENDENTE")
FAIXAS = ("0-25", "26-50", "51-75", "76-100")
SINAL_CALCULO_MAXIMO_S = 60
DIAS_EVOLUCAO = 30


class Turno(str, Enum):
    Matutino = "Matutino"
    Vespertino = "Vespertino"
    Noturno = "Noturno"


class Tendencia(str, Enum):
    MELHORA = "MELHORA"
    ESTAVEL = "ESTAVEL"
    PIORA = "PIORA"
    PIORA_SUSTENTADA = "PIORA_SUSTENTADA"


class Fator(str, Enum):
    notas = "notas"
    frequencia = "frequencia"
    reprovacao = "reprovacao"
    engajamento_ava = "engajamento_ava"
    financeiro = "financeiro"
    trabalho = "trabalho"
    deslocamento = "deslocamento"
    moradia = "moradia"
    dependentes = "dependentes"


def suprimir(valores: dict, minimo: int | None) -> tuple[dict, bool]:
    """Celula entre 1 e minimo-1 vira None. Devolve tambem se houve supressao."""
    if not minimo:
        return dict(valores), False
    saida = {k: (None if v is not None and 0 < v < minimo else v) for k, v in valores.items()}
    return saida, any(saida[k] is None and valores[k] is not None for k in valores)


class Recorte:
    """Filtros combinaveis do painel (Anexo D.3), refletidos na URL pelo painel."""

    def __init__(self, semestre: Annotated[int | None, Query(ge=1, le=20)] = None, turno: Turno | None = None,
                 fator: Fator | None = None, tendencia: Tendencia | None = None,
                 curso: Annotated[str | None, Query(pattern=r"^[A-Z0-9]{2,12}$")] = None):
        self.semestre, self.turno, self.fator, self.tendencia, self.curso = semestre, turno, fator, tendencia, curso

    def parametros(self, usuario: Usuario) -> dict:
        if usuario.perfil == COORDENACAO:
            if usuario.id_curso is None:
                raise erro_http(403, "Seu usuário não está vinculado a um curso.")
            id_curso = usuario.id_curso
        else:
            id_curso = self.curso
        return {"id_curso": id_curso, "semestre": self.semestre, "turno": self.turno.value if self.turno else None,
                "fator": self.fator.value if self.fator else None,
                "tendencia": self.tendencia.value if self.tendencia else None}


def _situacao_do_calculo(conexao: Connection) -> dict:
    ultimo = conexao.execute(sqlp.ULTIMO_CALCULO).mappings().first()
    sinal = conexao.execute(sqlp.SINAL_DO_CALCULO).mappings().first()
    fila = conexao.execute(sqlp.TAMANHO_FILA).scalar()
    idade = None if sinal is None else (agora() - como_datetime(sinal["ultimo_sinal"])).total_seconds()
    return {"ultimo_calculo": valor_json(ultimo["ultimo"]) if ultimo else None,
            "servico_no_ar": idade is not None and idade <= SINAL_CALCULO_MAXIMO_S,
            "segundos_desde_sinal": None if idade is None else int(idade),
            "alunos_na_fila": int(fila or 0),
            "aviso": None if idade is not None and idade <= SINAL_CALCULO_MAXIMO_S else
            "O serviço de cálculo não responde: os números mostram o último cálculo gravado."}


def _distribuicao(linhas, minimo: int | None) -> tuple[list, int, bool]:
    contagens = {n: 0 for n in NIVEIS}
    for l in linhas:
        contagens[l["nivel"]] = int(l["total"])
    total = sum(contagens.values())
    mostradas, suprimiu = suprimir(contagens, minimo)
    return [{"nivel": n, "total": mostradas[n],
             "pct": None if suprimiu or mostradas[n] is None or not total else round(100 * mostradas[n] / total, 1)}
            for n in NIVEIS if contagens[n] or n not in ("INDETERMINADO", "PENDENTE")], total, suprimiu


@router_paineis.get("/visao-geral")
def visao_geral(request: Request, recorte: Recorte = Depends(),
                usuario: Usuario = Depends(exigir_perfis(COORDENACAO, DIRECAO)),
                conexao: Connection = Depends(obter_conexao)):
    """Alunos, distribuicao por nivel, alertas abertos e vencidos, variacao (Anexo D.3, Visao geral)."""
    filtros = recorte.parametros(usuario)
    p = parametros_vigentes(conexao)
    minimo = int(p["MINIMO_GRUPO"]) if usuario.perfil == DIRECAO else None
    momento = agora()

    distribuicao, total, suprimiu = _distribuicao(
        conexao.execute(sqlp.PAINEL_DISTRIBUICAO, filtros).mappings().all(), minimo)
    faixas = {f: 0 for f in FAIXAS}
    for l in conexao.execute(sqlp.PAINEL_FAIXAS_SCORE, filtros).mappings():
        faixas[l["faixa"]] = int(l["total"])
    faixas, suprimiu_faixa = suprimir(faixas, minimo)

    alertas = dict(conexao.execute(sqlp.PAINEL_ALERTAS, {"id_curso": filtros["id_curso"], "agora": momento})
                   .mappings().first())
    alertas, _ = suprimir({k: int(v or 0) for k, v in alertas.items()}, minimo)

    agora_risco = conexao.execute(sqlp.EM_RISCO_EM, {"id_curso": filtros["id_curso"], "momento": momento}).mappings().first()
    antes = conexao.execute(sqlp.EM_RISCO_EM, {"id_curso": filtros["id_curso"],
                                               "momento": momento - timedelta(days=7)}).mappings().first()
    variacao = None
    if antes["com_score"]:
        variacao = {"em_risco_agora": int(agora_risco["em_risco"]), "em_risco_ha_7_dias": int(antes["em_risco"]),
                    "diferenca": int(agora_risco["em_risco"]) - int(antes["em_risco"])}

    auditoria.registrar(request, "LER_PAINEL", "PERMITIDO", usuario=usuario)
    return {
        "escopo": "curso" if usuario.perfil == COORDENACAO else "instituicao",
        "filtros": {k: v for k, v in filtros.items() if v is not None},
        "alunos": None if suprimiu or suprimiu_faixa or (minimo and total < minimo) else total,
        "houve_supressao": bool(suprimiu or suprimiu_faixa),
        "distribuicao": distribuicao,
        "faixas_score": [{"faixa": f, "total": faixas[f]} for f in FAIXAS],
        "cortes": {"baixo": p["CORTE_BAIXO"], "moderado": p["CORTE_MODERADO"], "alto": p["CORTE_ALTO"]},
        "alertas": alertas,
        "variacao_7_dias": variacao,
        "periodo_anterior": None,
        "observacao_periodo_anterior": "Sem dado: o banco do B1 não tem score do período anterior.",
        "calculo": _situacao_do_calculo(conexao),
        "minimo_grupo": minimo,
        "aviso_pesos": AVISO_PESOS,
        "aviso": AVISO_METODOLOGICO,
    }


def _rotulo_fator(fator: str, perfil: str) -> str:
    if fator in FATORES_SAUDE and perfil == COORDENACAO:
        return ROTULO_ENCAMINHADO
    return ROTULOS.get(fator, fator)


@router_paineis.get("/analises")
def analises(request: Request, recorte: Recorte = Depends(),
             dias: Annotated[int, Query(ge=7, le=365)] = DIAS_EVOLUCAO,
             usuario: Usuario = Depends(exigir_perfis(COORDENACAO, DIRECAO)),
             conexao: Connection = Depends(obter_conexao)):
    """Evolucao do risco, fatores frequentes, comparacao e eficacia (Anexo D.3, Analises; RF25)."""
    filtros = recorte.parametros(usuario)
    p = parametros_vigentes(conexao)
    minimo = int(p["MINIMO_GRUPO"]) if usuario.perfil == DIRECAO else None
    id_curso = filtros["id_curso"]

    primeiro, _ = conexao.execute(sqlp.PRIMEIRO_CALCULO).first()
    evolucao = []
    if primeiro is not None:
        fim = date.today()
        inicio = max(como_datetime(primeiro).date(), fim - timedelta(days=dias - 1))
        for l in conexao.execute(sqlp.EVOLUCAO_RISCO, {"inicio": inicio, "fim": fim, "id_curso": id_curso}).mappings():
            ponto = {"dia": valor_json(l["dia"]), "em_risco": int(l["em_risco"]), "criticos": int(l["criticos"]),
                     "com_score": int(l["com_score"])}
            contagens, _ = suprimir({k: v for k, v in ponto.items() if k != "dia"}, minimo)
            evolucao.append({"dia": ponto["dia"], **contagens})

    fatores: dict[str, int] = {}
    for l in conexao.execute(sqlp.FATORES_FREQUENTES, filtros).mappings():
        rotulo = _rotulo_fator(l["fator"], usuario.perfil)
        fatores[rotulo] = fatores.get(rotulo, 0) + int(l["total"])
    fatores, _ = suprimir(fatores, minimo)

    comparacao = {}
    if usuario.perfil == DIRECAO:
        for l in conexao.execute(sqlp.POR_CURSO).mappings():
            comparacao.setdefault(l["curso"], {n: 0 for n in NIVEIS})[l["nivel"]] = int(l["total"])
    else:
        for l in conexao.execute(sqlp.POR_SEMESTRE, filtros).mappings():
            comparacao.setdefault(f"{l['semestre']}º semestre", {n: 0 for n in NIVEIS})[l["nivel"]] = int(l["total"])
    comparacao = {k: suprimir(v, minimo)[0] for k, v in comparacao.items()}

    eficacia = _eficacia(conexao.execute(sqlp.EFICACIA, {"id_curso": id_curso}).mappings().all(), minimo or 1)
    causas = {(l["causa"] or "NAO_INFORMADA"): int(l["total"])
              for l in conexao.execute(sqlp.CAUSAS, {"id_curso": id_curso}).mappings()}
    causas, _ = suprimir(causas, minimo)

    atendimento = []
    for l in conexao.execute(sqlp.TEMPO_PRIMEIRA_ACAO, {"id_curso": id_curso}).mappings():
        total = int(l["total"])
        if minimo and total < minimo:
            atendimento.append({"nivel": l["nivel"], "total": None, "no_prazo_pct": None, "horas_media": None})
            continue
        atendimento.append({"nivel": l["nivel"], "total": total, "no_prazo_pct": round(100 * l["no_prazo"] / total, 1),
                            "horas_media": round(float(l["horas_media"]), 1)})

    divergencias = int(conexao.execute(sqlp.DIVERGENCIAS, {"id_curso": id_curso}).scalar() or 0)
    auditoria.registrar(request, "LER_ANALISES", "PERMITIDO", usuario=usuario)
    return {
        "evolucao": evolucao,
        "observacao_evolucao": None if evolucao else "Sem dado: ainda não há scores calculados.",
        "fatores_frequentes": [{"fator": k, "alunos": v} for k, v in
                               sorted(fatores.items(), key=lambda x: -(x[1] or 0))],
        "comparacao": [{"grupo": g, "niveis": v} for g, v in comparacao.items()],
        "tipo_comparacao": "curso" if usuario.perfil == DIRECAO else "semestre",
        "eficacia": eficacia,
        "causas_identificadas": [{"causa": k, "alertas": v} for k, v in causas.items()],
        "primeiro_atendimento": atendimento,
        "divergencias_registradas": None if minimo and 0 < divergencias < minimo else divergencias,
        "minimo_grupo": minimo,
        "aviso_pesos": AVISO_PESOS,
    }


def _eficacia(linhas, minimo: int) -> dict:
    """RF25: permanencia de quem teve contato x quem nao teve, nos alertas encerrados."""
    grupos = {True: {"total": 0, "permaneceu": 0}, False: {"total": 0, "permaneceu": 0}}
    for l in linhas:
        g = grupos[bool(l["houve_contato"])]
        g["total"] += int(l["total"])
        if l["desfecho"] in ("PERMANECEU", "EM_ACOMPANHAMENTO"):
            g["permaneceu"] += int(l["total"])

    def taxa(g):
        if g["total"] == 0 or g["total"] < minimo:
            return None
        return round(100 * g["permaneceu"] / g["total"], 1)

    com, sem = grupos[True], grupos[False]
    if com["total"] + sem["total"] == 0:
        return {"disponivel": False, "motivo": "Sem dado: nenhum alerta foi encerrado com desfecho registrado ainda."}
    return {"disponivel": True,
            "com_intervencao": {"alertas": com["total"] if com["total"] >= minimo else None,
                                "permanencia_pct": taxa(com)},
            "sem_intervencao": {"alertas": sem["total"] if sem["total"] >= minimo else None,
                                "permanencia_pct": taxa(sem)},
            "nota": "Permanência = desfecho 'permaneceu' ou 'em acompanhamento'. Comparação descritiva, "
                    "não prova causa."}
