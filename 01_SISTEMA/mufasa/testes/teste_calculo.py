"""
Testes do calculo do score (SRS v1.1, Anexo A; Plano de Construcao v1.1, Secao 4.1).

PRINCIPIO: um teste precisa poder REPROVAR. Todo teste exige valor exato ou
relacao de ordem verificavel. Os casos CT-01 a CT-21 sao os do Plano de
Construcao; os que dependem de banco ou de tela (CT-18, CT-19, CT-21) estao
em testes/teste_ponta_a_ponta.py. CT-20 (agendamento) depende do modulo de
calendario de retorno, que ainda nao existe.
"""

import pytest

from app.calculo.indicadores import (
    calcular_faltas_restantes,
    calcular_media_ponderada,
    calcular_percentual_frequencia,
    calcular_taxa_reprovacao,
)
from app.calculo.parametros import CATALOGO, PADRAO, PESOS_POR_FATOR, problemas_de_coerencia
from app.calculo.score import (
    arredondar,
    calcular_score_aluno,
    calcular_tendencia,
    classificar_nivel_risco,
    explicar_score,
    risco_por_categoria,
    risco_por_dependentes,
    risco_por_deslocamento,
    risco_por_engajamento_ava,
    risco_por_frequencia,
    risco_por_nota,
    risco_por_renda_per_capita,
    risco_por_reprovacao,
    risco_por_trabalho,
    SAUDE_FISICA,
    SAUDE_MENTAL,
    MORADIA,
)


# ---------------------------------------------------------------------------
# Indicadores
# ---------------------------------------------------------------------------

def test_faltas_restantes():
    assert calcular_faltas_restantes(80, 12) == 8
    assert calcular_faltas_restantes(80, 25) == 0
    assert calcular_faltas_restantes(80, 10) == 10
    assert calcular_faltas_restantes(40, 0) == 10


def test_faltas_restantes_nunca_negativo():
    """Limite estourado devolve 0, nao numero negativo."""
    assert calcular_faltas_restantes(80, 50) == 0


def test_frequencia():
    assert calcular_percentual_frequencia(80, 20) == 75.0
    assert calcular_percentual_frequencia(80, 0) == 100.0
    assert calcular_percentual_frequencia(50, 16) == 68.0


def test_frequencia_sem_aula_lancada_retorna_none():
    """
    Ausencia de lancamento NAO e frequencia perfeita.

    Este e o erro que o SRS proibe explicitamente: imputar 100% a
    frequencia ausente transforma o maior sinal de abandono em sinal
    de normalidade.
    """
    assert calcular_percentual_frequencia(0, 0) is None
    assert calcular_percentual_frequencia(None, 5) is None
    assert calcular_percentual_frequencia(80, None) is None


def test_media_ponderada():
    assert calcular_media_ponderada([(5.0, 2.0), (6.0, 3.0)]) == 5.6
    assert calcular_media_ponderada([(8.0, 4.0)]) == 8.0


def test_media_ponderada_sem_nota_retorna_none():
    assert calcular_media_ponderada([]) is None
    assert calcular_media_ponderada([(7.0, 0.0)]) is None


def test_taxa_reprovacao():  # fracao 0-1; o score recebe em % (x 100)
    assert calcular_taxa_reprovacao(6, 2) == 0.333
    assert calcular_taxa_reprovacao(10, 0) == 0.0


def test_taxa_reprovacao_sem_historico_retorna_none():
    """Aluno ingressante nao tem taxa 0: nao tem taxa."""
    assert calcular_taxa_reprovacao(0, 0) is None
    assert calcular_taxa_reprovacao(None, 0) is None



# ---------------------------------------------------------------------------
# Faixas (RN02, CA09)
# ---------------------------------------------------------------------------

def test_faixas_nos_limites_exatos_ca09():
    assert [classificar_nivel_risco(s) for s in (0, 25, 26, 50, 51, 75, 76, 100)] == [
        "BAIXO", "BAIXO", "MODERADO", "MODERADO", "ALTO", "ALTO", "CRITICO", "CRITICO"]


def test_score_vazio_e_indeterminado():
    assert classificar_nivel_risco(None) == "INDETERMINADO"


def test_valor_interno_063_vira_63_alto():
    """RN02: score = arredondar(valor x 100); 0,63 sempre exibe 63 e nivel Alto."""
    assert arredondar(0.63 * 100) == 63
    assert classificar_nivel_risco(63) == "ALTO"
    assert arredondar(62.5) == 63  # meio sobe, sem o arredondamento bancario do Python


# ---------------------------------------------------------------------------
# Indicadores I1 a I11 (B.2) e casos CT-02 a CT-12
# ---------------------------------------------------------------------------

@pytest.mark.parametrize("media,esperado", [(7.0, 20.0), (5.0, 60.0), (3.0, 85.0), (8.0, 0.0), (10.0, 0.0),
                                            (6.0, 40.0), (4.0, 80.0), (0.0, 100.0)])
def test_ct02_a_ct04_i1(media, esperado):
    assert risco_por_nota(media) == pytest.approx(esperado, abs=0.01)


def test_rf02_media_ponderada_pela_carga_horaria():
    """RF02: nota 7,0 (60 h) e 5,0 (30 h) -> media 6,33 e I1 = 33,3."""
    media = calcular_media_ponderada([(7.0, 60), (5.0, 30)])
    assert media == pytest.approx(6.333, abs=0.001)
    assert risco_por_nota(media) == pytest.approx(33.3, abs=0.1)


@pytest.mark.parametrize("freq,esperado", [(82.0, 21.3), (68.0, 58.7), (90.0, 0.0), (75.0, 40.0),
                                           (60.0, 80.0), (50.0, 83.3), (0.0, 100.0)])
def test_ct05_ct06_i2(freq, esperado):
    assert risco_por_frequencia(freq) == pytest.approx(esperado, abs=0.1)


def test_ct06_frequencia_68_forca_alto_por_s1():
    r = calcular_score_aluno({"media_ponderada": 9.0, "percentual_frequencia": 68.0, "taxa_reprovacao_pct": 0,
                              "renda_per_capita_sm": 3.0, "horas_trabalho_semana": 0, "minutos_deslocamento": 10})
    assert r["score"] < 51
    assert r["nivel"] == "ALTO"
    assert r["nivel_origem"] == "SOBREPOSICAO"
    assert r["motivo_sobreposicao"].startswith("S1: frequência de 68%")


def test_s1_vale_para_qualquer_disciplina_ca11():
    """CA11: uma disciplina abaixo de 75% basta, mesmo com a frequencia geral alta."""
    r = calcular_score_aluno({"media_ponderada": 9.0, "percentual_frequencia": 88.0, "taxa_reprovacao_pct": 0,
                              "renda_per_capita_sm": 3.0, "horas_trabalho_semana": 0, "minutos_deslocamento": 10,
                              "disciplinas": [{"nome": "Cálculo I", "frequencia_pct": 70},
                                              {"nome": "Algoritmos", "frequencia_pct": 100}]})
    assert r["nivel"] == "ALTO"
    assert "Cálculo I" in r["motivo_sobreposicao"]


def test_s1_nao_vale_com_periodo_encerrado():
    r = calcular_score_aluno({"media_ponderada": 9.0, "percentual_frequencia": 70.0, "taxa_reprovacao_pct": 0,
                              "renda_per_capita_sm": 3.0, "horas_trabalho_semana": 0, "minutos_deslocamento": 10,
                              "periodo_em_andamento": False})
    assert r["nivel_origem"] == "FAIXA"


@pytest.mark.parametrize("tr,esperado", [(0, 0), (10, 25), (15, 25), (20, 50), (30, 50), (40, 75), (50, 75),
                                         (51, 100)])
def test_i3_degraus(tr, esperado):
    assert risco_por_reprovacao(tr) == esperado


def test_ct07_i3_com_pre_requisito():
    assert risco_por_reprovacao(35.0, reprovou_pre_requisito=True) == 90.0
    assert risco_por_reprovacao(60.0, reprovou_pre_requisito=True, terceira_tentativa=True) == 100.0


def test_i3_sem_disciplinas_cursadas_fica_ausente():
    """Primeiro periodo: sem divisao por zero e sem inventar taxa 0 (RN20)."""
    assert calcular_taxa_reprovacao(0, 0) is None
    assert risco_por_reprovacao(None) is None


def test_ct08_ct09_i5():
    assert risco_por_renda_per_capita(0.40) == 85.0
    assert risco_por_renda_per_capita(0.40, auxilio_ativo=True) == 65.0


@pytest.mark.parametrize("renda,esperado", [(0.25, 100), (0.3, 85), (0.5, 85), (0.7, 60), (1.0, 30), (1.5, 30),
                                            (1.6, 0)])
def test_i5_degraus(renda, esperado):
    assert risco_por_renda_per_capita(renda) == esperado


def test_i5_atrasos_e_cadunico():
    assert risco_por_renda_per_capita(1.2, mensalidades_atraso=1) == 50.0
    assert risco_por_renda_per_capita(1.2, mensalidades_atraso=2) == 65.0
    assert risco_por_renda_per_capita(None, cadunico_sem_renda=True) == 85.0
    assert risco_por_renda_per_capita(None) is None


def test_ct10_ct11_i6():
    assert risco_por_trabalho(15, mesmo_turno=True) == 100.0
    assert risco_por_trabalho(20, estagio_na_area=True) == 5.0


@pytest.mark.parametrize("horas,esperado", [(0, 0), (1, 20), (20, 20), (21, 50), (30, 50), (31, 75), (40, 75),
                                            (44, 100)])
def test_i6_degraus(horas, esperado):
    assert risco_por_trabalho(horas) == esperado


def test_i6_informal():
    assert risco_por_trabalho(25, informal=True) == 60.0


@pytest.mark.parametrize("minutos,esperado", [(20, 0), (21, 25), (40, 25), (41, 50), (60, 50), (61, 75), (90, 75),
                                              (91, 100)])
def test_i7_degraus(minutos, esperado):
    assert risco_por_deslocamento(minutos) == esperado


def test_i7_dois_onibus():
    assert risco_por_deslocamento(50, dois_ou_mais_onibus=True) == 65.0


def test_ct12_i8_com_acompanhamento():
    assert risco_por_categoria(SAUDE_MENTAL, "COM_ACOMPANHAMENTO") == 40.0
    assert risco_por_categoria(SAUDE_MENTAL, None) is None


def test_i9_i10_i11():
    assert [SAUDE_FISICA[k] for k in ("NENHUMA", "CONTROLADA", "ATESTADOS", "AFASTAMENTO")] == [0, 30, 70, 90]
    assert [MORADIA[k] for k in ("ESTAVEL", "ALUGUEL_COMPROMETIDO", "MUDOU_SEM_REDE", "MUDANCA_NO_PERIODO",
                                 "PRECARIA")] == [0, 35, 55, 60, 100]
    assert [risco_por_dependentes(n) for n in (0, 1, 2, 5)] == [0, 40, 70, 70]
    assert risco_por_dependentes(1, cuidado_continuo=True) == 100


def test_i4_engajamento():
    assert risco_por_engajamento_ava() is None  # sem integracao com o AVA, fator ausente
    assert risco_por_engajamento_ava(0.8, 0.95) == 0
    assert risco_por_engajamento_ava(0.5, 0.95) == 35
    assert risco_por_engajamento_ava(0.2, 0.95) == 65
    assert risco_por_engajamento_ava(0.8, 0.95, dias_sem_acesso=22) == 100
    assert risco_por_engajamento_ava(0.8, 0.30) == 100


@pytest.mark.parametrize("funcao", [risco_por_nota, risco_por_frequencia, risco_por_renda_per_capita,
                                    risco_por_trabalho, risco_por_deslocamento])
def test_valor_invalido_vira_ausente(funcao):
    for invalido in (float("nan"), float("inf"), -1, "abc", True):
        assert funcao(invalido) is None


def test_monotonicidade():
    """B.2: piorar um fator nunca reduz a pontuacao."""
    notas = [risco_por_nota(m / 10) for m in range(0, 101)]
    assert all(a >= b for a, b in zip(notas, notas[1:]))
    freqs = [risco_por_frequencia(f) for f in range(0, 101)]
    assert all(a >= b for a, b in zip(freqs, freqs[1:]))


# ---------------------------------------------------------------------------
# Soma ponderada, completude, modificadores e sobreposicoes (B.4 a B.6)
# ---------------------------------------------------------------------------

def test_pesos_do_srs_somam_um():
    esperados = {"notas": .20, "frequencia": .18, "reprovacao": .09, "engajamento_ava": .08, "financeiro": .11,
                 "trabalho": .07, "deslocamento": .05, "saude_mental": .08, "saude_fisica": .05,
                 "moradia": .05, "dependentes": .04}
    assert {f: PADRAO.peso(f) for f in PESOS_POR_FATOR} == pytest.approx(esperados)
    assert problemas_de_coerencia(PADRAO.valores) == []


def test_ct01_aluno_sem_risco():
    r = calcular_score_aluno({"media_ponderada": 9.0, "percentual_frequencia": 95.0, "taxa_reprovacao_pct": 0})
    assert (r["score"], r["nivel"]) == (0, "BAIXO")


def test_ct13_so_i1_e_i2_e_indeterminado():
    r = calcular_score_aluno({"media_ponderada": 7.0, "percentual_frequencia": 80.0})
    assert round(r["completude"] * 100) == 38
    assert r["nivel"] == "INDETERMINADO"
    assert r["score"] is None


def test_ct14_parcial_so_chega_a_critico_por_sobreposicao():
    dados = {"media_ponderada": 2.0, "percentual_frequencia": 76.0, "taxa_reprovacao_pct": 60,
             "renda_per_capita_sm": 0.2, "periodo_atual": 1}
    r = calcular_score_aluno(dados)
    assert round(r["completude"] * 100) == 58
    assert r["parcial"] is True
    assert r["score"] > 75
    assert (r["nivel"], r["nivel_origem"]) == ("ALTO", "FAIXA_PARCIAL")
    r = calcular_score_aluno({**dados, "trancamento_solicitado": True})
    assert (r["nivel"], r["nivel_origem"]) == ("CRITICO", "SOBREPOSICAO")


def test_ct15_quinze_dias_sem_presenca_e_critico():
    r = calcular_score_aluno({"media_ponderada": 9.0, "percentual_frequencia": 95.0, "taxa_reprovacao_pct": 0,
                              "renda_per_capita_sm": 3, "dias_sem_presenca": 15})
    assert r["nivel"] == "CRITICO"
    assert r["motivo_sobreposicao"].startswith("S2")


def test_ct16_fatores_ordenados_e_soma_das_contribuicoes():
    r = calcular_score_aluno({"media_ponderada": 5.4, "percentual_frequencia": 80.0, "horas_trabalho_semana": 44,
                              "renda_per_capita_sm": 0.8, "taxa_reprovacao_pct": 20, "minutos_deslocamento": 70})
    pontos = [f["contribuicao_pontos"] for f in r["fatores"]]
    assert pontos == sorted(pontos, reverse=True)
    assert sum(pontos) == pytest.approx(r["score"], abs=0.5)
    assert sum(f["contribuicao_pct"] for f in r["fatores"]) == pytest.approx(100, abs=0.5)


def test_rn04_principais_tem_tres_maiores_e_todos_acima_de_50():
    r = calcular_score_aluno({"media_ponderada": 3.0, "percentual_frequencia": 50.0, "horas_trabalho_semana": 44,
                              "renda_per_capita_sm": 0.2, "taxa_reprovacao_pct": 60, "minutos_deslocamento": 100})
    acima_de_50 = {f["fator"] for f in r["fatores"] if f["pontuacao"] >= 50}
    assert set(r["fatores_principais"]) >= acima_de_50
    assert len(r["fatores_principais"]) >= 3


def test_rn04_toda_explicacao_tem_numero():
    r = calcular_score_aluno({"media_ponderada": 5.4, "percentual_frequencia": 68.0, "horas_trabalho_semana": 44,
                              "renda_per_capita_sm": 0.8, "taxa_reprovacao_pct": 20, "minutos_deslocamento": 70})
    for fator in r["fatores"]:
        assert any(ch.isdigit() for ch in fator["explicacao"]), fator
    assert "68%" in next(f["explicacao"] for f in r["fatores"] if f["fator"] == "frequencia")
    assert "5,4" in next(f["explicacao"] for f in r["fatores"] if f["fator"] == "notas")


def test_ct17_nota_minima_7_gera_score_com_nova_versao():
    dados = {"media_ponderada": 6.5, "percentual_frequencia": 95.0, "taxa_reprovacao_pct": 0}
    antes = calcular_score_aluno(dados)
    nova = PADRAO.com(NOTA_MINIMA=7.0)
    nova = type(nova)(nova.valores, versao=2)
    depois = calcular_score_aluno(dados, nova)
    assert depois["score"] > antes["score"]
    assert (antes["versao_parametros"], depois["versao_parametros"]) == ("param-padrao-srs-1.1", "param-v2")


def test_fator_ausente_nao_vira_valor_medio_rn20():
    com = calcular_score_aluno({"media_ponderada": 5.0, "percentual_frequencia": 80.0, "taxa_reprovacao_pct": 20,
                                "renda_per_capita_sm": 2.0})
    sem = calcular_score_aluno({"media_ponderada": 5.0, "percentual_frequencia": 80.0, "taxa_reprovacao_pct": 20})
    assert "financeiro" not in sem["detalhamento"]
    assert sem["completude"] == pytest.approx(com["completude"] - 0.11)


def test_modificadores_m1_m2_m3():
    base = {"media_ponderada": 5.0, "percentual_frequencia": 80.0, "taxa_reprovacao_pct": 20,
            "renda_per_capita_sm": 0.7, "minutos_deslocamento": 80, "horas_trabalho_semana": 0}
    sem = calcular_score_aluno(base)
    com = calcular_score_aluno({**base, "variacao_media": -1.5, "periodo_atual": 1, "turno_noturno": True})
    assert [m["id"] for m in com["modificadores"]] == ["M1", "M2", "M3"]
    assert com["score"] == min(100, sem["score"] + 25)


def test_modificadores_m4_m5_precisam_de_tres_periodos():
    base = {"media_ponderada": 6.5, "percentual_frequencia": 90.0, "taxa_reprovacao_pct": 0}
    assert calcular_score_aluno({**base, "medias_ultimos_periodos": [8, 7]})["modificadores"] == []
    queda = calcular_score_aluno({**base, "medias_ultimos_periodos": [8, 7, 6.5]})
    assert [m["id"] for m in queda["modificadores"]] == ["M4"]
    melhora = calcular_score_aluno({**base, "medias_ultimos_periodos": [5, 6, 6.5]})
    assert [m["id"] for m in melhora["modificadores"]] == ["M5"]


def test_score_sempre_entre_0_e_100():
    pior = calcular_score_aluno({"media_ponderada": 0, "percentual_frequencia": 0, "taxa_reprovacao_pct": 100,
                                 "renda_per_capita_sm": 0.1, "minutos_deslocamento": 200, "horas_trabalho_semana": 60,
                                 "variacao_media": -5, "periodo_atual": 1, "turno_noturno": True})
    assert pior["score"] == 100
    melhor = calcular_score_aluno({"media_ponderada": 10, "percentual_frequencia": 100, "taxa_reprovacao_pct": 0,
                                   "medias_ultimos_periodos": [7, 8, 9]})
    assert melhor["score"] == 0


def test_tendencia_rn09():
    assert calcular_tendencia([32, 47, 63]) == "PIORA_SUSTENTADA"
    assert calcular_tendencia([47, 63]) == "PIORA"
    assert calcular_tendencia([63, 47]) == "MELHORA"
    assert calcular_tendencia([47, 47]) == "ESTAVEL"
    assert calcular_tendencia([47]) is None


def test_explicacao_resumo():
    r = calcular_score_aluno({"media_ponderada": 9.0, "percentual_frequencia": 68.0, "taxa_reprovacao_pct": 0,
                              "renda_per_capita_sm": 3.0})
    texto = explicar_score(r)
    assert texto.startswith(f"Pontuação de risco: {r['score']} de 100")
    assert "sobreposição" in texto
    assert "Não foi possível" in explicar_score(calcular_score_aluno({"media_ponderada": 7}))


def test_nenhum_limiar_fora_dos_parametros():
    """RN22 / Anexo B: cada parametro da tabela C.2 existe no catalogo versionado."""
    for chave in ("NOTA_MINIMA", "NOTA_CONFORTAVEL", "NOTA_CRITICA", "FREQUENCIA_MINIMA", "FREQUENCIA_CONFORTAVEL",
                  "FREQUENCIA_CRITICA", "RENDA_VULNERAVEL", "RENDA_AUXILIO", "JORNADA_LIMITE", "DESLOCAMENTO_LIMITE",
                  "AVA_DIAS_SEM_ACESSO", "CORTE_BAIXO", "CORTE_MODERADO", "CORTE_ALTO", "COMPLETUDE_MINIMA",
                  "INTERVALO_ATENDIMENTOS", "TETO_ALERTAS_RESPONSAVEL"):
        assert chave in CATALOGO


def test_parametros_incoerentes_sao_recusados():
    assert problemas_de_coerencia({**PADRAO.valores, "NOTA_MINIMA": 9.0})
    assert problemas_de_coerencia({**PADRAO.valores, "PESO_I1_DESEMPENHO": 0.3})
