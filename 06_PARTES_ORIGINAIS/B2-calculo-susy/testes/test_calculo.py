"""
Testes do modulo de calculo do MUFASA.

PRINCIPIO: um teste precisa poder REPROVAR. Asserçoes como
`assert "score" in resultado` ou `assert nivel in ["ALTO","BAIXO","CRITICO"]`
passam mesmo com o codigo errado, e foi exatamente por isso que a escala
invertida atravessou a v2.1 sem ser detectada. Todo teste aqui exige
valor exato ou relacao de ordem verificavel.
"""

import pytest

from app.calculo.indicadores import (
    calcular_faltas_restantes,
    calcular_percentual_frequencia,
    calcular_media_ponderada,
    calcular_taxa_reprovacao,
    calcular_completude_cadastro,
)
from app.calculo.score import (
    PESOS,
    COMPLETUDE_MINIMA,
    calcular_score_aluno,
    classificar_nivel_risco,
    explicar_score,
    risco_por_nota,
    risco_por_frequencia,
    risco_por_trabalho,
    risco_por_reprovacao,
    risco_por_renda_per_capita,
    risco_por_engajamento_ava,
    risco_por_deslocamento,
    risco_por_dependentes,
    risco_por_escala_declarada,
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


def test_taxa_reprovacao():
    assert calcular_taxa_reprovacao(6, 2) == 0.333
    assert calcular_taxa_reprovacao(10, 0) == 0.0


def test_taxa_reprovacao_sem_historico_retorna_none():
    """Aluno ingressante nao tem taxa 0: nao tem taxa."""
    assert calcular_taxa_reprovacao(0, 0) is None
    assert calcular_taxa_reprovacao(None, 0) is None


def test_completude_cadastro():
    assert calcular_completude_cadastro(6, 10) == 0.6
    assert calcular_completude_cadastro(0, 10) == 0.0
    assert calcular_completude_cadastro(5, 0) == 0.0


# ---------------------------------------------------------------------------
# Faixas de classificacao
# ---------------------------------------------------------------------------

def test_faixas_nos_limites_exatos():
    """Testa as bordas, onde erro de <= vs < aparece."""
    assert classificar_nivel_risco(0) == "BAIXO"
    assert classificar_nivel_risco(25) == "BAIXO"
    assert classificar_nivel_risco(26) == "MODERADO"
    assert classificar_nivel_risco(50) == "MODERADO"
    assert classificar_nivel_risco(51) == "ALTO"
    assert classificar_nivel_risco(75) == "ALTO"
    assert classificar_nivel_risco(76) == "CRITICO"
    assert classificar_nivel_risco(100) == "CRITICO"


def test_faixa_usa_moderado_nao_medio():
    """Padronizacao do SRS: o nivel chama MODERADO."""
    assert classificar_nivel_risco(40) == "MODERADO"


def test_score_none_vira_indeterminado():
    assert classificar_nivel_risco(None) == "INDETERMINADO"


# ---------------------------------------------------------------------------
# O TESTE QUE PEGOU O DEFEITO DA v2.1
# ---------------------------------------------------------------------------

def test_sentido_da_escala():
    """
    A escala e de RISCO, nao de desempenho.

    Na v2.1 o aluno exemplar recebia score 90 (CRITICO) e o aluno em
    abandono recebia 0 (BAIXO). Este teste reprova qualquer reintroducao
    dessa inversao.
    """
    aluno_exemplar = {
        "media_ponderada": 9.5,
        "percentual_frequencia": 98.0,
        "horas_trabalho_semana": 0,
        "taxa_reprovacao": 0.0,
        "renda_per_capita_sm": 4.0,
        "acessos_ava_semana": 10,
        "escala_saude_mental": 1,
        "minutos_deslocamento": 15,
        "escala_saude_fisica": 1,
        "escala_moradia": 1,
        "qtd_dependentes": 0,
        "aulas_previstas": 80,
        "faltas": 2,
    }
    aluno_em_abandono = {
        "media_ponderada": 2.0,
        "percentual_frequencia": 40.0,
        "horas_trabalho_semana": 48,
        "taxa_reprovacao": 0.8,
        "renda_per_capita_sm": 0.3,
        "acessos_ava_semana": 0,
        "escala_saude_mental": 5,
        "minutos_deslocamento": 110,
        "escala_saude_fisica": 4,
        "escala_moradia": 5,
        "qtd_dependentes": 2,
        "aulas_previstas": 80,
        "faltas": 48,
    }

    r_exemplar = calcular_score_aluno(aluno_exemplar)
    r_abandono = calcular_score_aluno(aluno_em_abandono)

    assert r_exemplar["score"] < r_abandono["score"]
    assert r_exemplar["score"] == 0
    assert r_exemplar["nivel"] == "BAIXO"
    assert r_abandono["score"] >= 76
    assert r_abandono["nivel"] == "CRITICO"


def test_monotonicidade_da_nota():
    """Piorar a nota nunca pode reduzir o risco."""
    base = {
        "percentual_frequencia": 85.0,
        "horas_trabalho_semana": 0,
        "taxa_reprovacao": 0.0,
        "renda_per_capita_sm": 2.0,
        "acessos_ava_semana": 6,
    }
    anterior = -1
    for media in [10.0, 8.0, 7.0, 6.0, 5.0, 4.0, 2.0]:
        atual = calcular_score_aluno({**base, "media_ponderada": media})["score"]
        assert atual >= anterior, f"risco caiu ao piorar a nota para {media}"
        anterior = atual


def test_monotonicidade_da_frequencia():
    """Piorar a frequencia nunca pode reduzir o risco."""
    base = {
        "media_ponderada": 7.0,
        "horas_trabalho_semana": 0,
        "taxa_reprovacao": 0.0,
        "renda_per_capita_sm": 2.0,
        "acessos_ava_semana": 6,
    }
    anterior = -1
    for freq in [100.0, 90.0, 85.0, 80.0, 75.0, 70.0, 50.0]:
        atual = calcular_score_aluno({**base, "percentual_frequencia": freq})["score"]
        assert atual >= anterior, f"risco caiu ao piorar a frequencia para {freq}"
        anterior = atual


# ---------------------------------------------------------------------------
# Funcoes de risco por fator, com valores do SRS
# ---------------------------------------------------------------------------

def test_risco_por_nota_valores_do_srs():
    assert risco_por_nota(5.4) == pytest.approx(52.0, abs=0.5)
    assert risco_por_nota(9.0) == 0.0
    assert risco_por_nota(8.0) == 0.0
    assert risco_por_nota(7.0) == pytest.approx(20.0, abs=0.5)
    assert risco_por_nota(6.0) == pytest.approx(40.0, abs=0.5)
    assert risco_por_nota(3.0) == 100.0
    assert risco_por_nota(None) is None


def test_risco_por_frequencia_valores_do_srs():
    assert risco_por_frequencia(68.0) == pytest.approx(58.7, abs=0.5)
    assert risco_por_frequencia(95.0) == 0.0
    assert risco_por_frequencia(90.0) == 0.0
    assert risco_por_frequencia(75.0) == pytest.approx(40.0, abs=0.5)
    assert risco_por_frequencia(55.0) == 100.0
    assert risco_por_frequencia(None) is None


def test_risco_por_trabalho_valores_do_srs():
    assert risco_por_trabalho(0) == 0.0
    assert risco_por_trabalho(20) == 25.0
    assert risco_por_trabalho(30) == 50.0
    assert risco_por_trabalho(40) == 75.0
    assert risco_por_trabalho(44) == 100.0
    assert risco_por_trabalho(None) is None


def test_risco_por_reprovacao():
    assert risco_por_reprovacao(0.0) == 0.0
    assert risco_por_reprovacao(0.25) == 50.0
    assert risco_por_reprovacao(0.5) == 100.0
    assert risco_por_reprovacao(0.9) == 100.0
    assert risco_por_reprovacao(None) is None


def test_risco_por_renda_limiares_legais():
    """0,5 SM = CadUnico; 1,5 SM = PNAES."""
    assert risco_por_renda_per_capita(0.5) == 100.0
    assert risco_por_renda_per_capita(1.5) == pytest.approx(40.0, abs=0.5)
    assert risco_por_renda_per_capita(3.0) == 0.0
    assert risco_por_renda_per_capita(5.0) == 0.0
    assert risco_por_renda_per_capita(None) is None


def test_risco_por_engajamento_ava():
    assert risco_por_engajamento_ava(0) == 100.0
    assert risco_por_engajamento_ava(2) == 60.0
    assert risco_por_engajamento_ava(5) == 30.0
    assert risco_por_engajamento_ava(10) == 0.0
    assert risco_por_engajamento_ava(None) is None


def test_risco_por_deslocamento():
    assert risco_por_deslocamento(20) == 0.0
    assert risco_por_deslocamento(60) == 30.0
    assert risco_por_deslocamento(90) == 60.0
    assert risco_por_deslocamento(120) == 100.0
    assert risco_por_deslocamento(None) is None


def test_risco_por_dependentes():
    assert risco_por_dependentes(0) == 0.0
    assert risco_por_dependentes(1) == 40.0
    assert risco_por_dependentes(2) == 70.0
    assert risco_por_dependentes(4) == 100.0
    assert risco_por_dependentes(None) is None


def test_risco_por_escala_declarada():
    assert risco_por_escala_declarada(1) == 0.0
    assert risco_por_escala_declarada(3) == 50.0
    assert risco_por_escala_declarada(5) == 100.0
    assert risco_por_escala_declarada(None) is None
    assert risco_por_escala_declarada(9) is None


# ---------------------------------------------------------------------------
# Pesos
# ---------------------------------------------------------------------------

def test_pesos_somam_um():
    assert sum(PESOS.values()) == pytest.approx(1.0, abs=0.001)


def test_pesos_conforme_srs():
    assert PESOS["notas"] == 0.20
    assert PESOS["frequencia"] == 0.18
    assert PESOS["financeiro"] == 0.11
    assert PESOS["reprovacao"] == 0.09
    assert PESOS["engajamento_ava"] == 0.08
    assert PESOS["saude_mental"] == 0.08
    assert PESOS["trabalho"] == 0.07
    assert PESOS["deslocamento"] == 0.05
    assert PESOS["saude_fisica"] == 0.05
    assert PESOS["moradia"] == 0.05
    assert PESOS["dependentes"] == 0.04


def test_onze_fatores():
    assert len(PESOS) == 11


# ---------------------------------------------------------------------------
# Completude
# ---------------------------------------------------------------------------

def test_completude_insuficiente_vira_indeterminado():
    """Abaixo de 40% de peso disponivel, o score nao e calculado."""
    resultado = calcular_score_aluno({
        "matricula": "2024002",
        "media_ponderada": 5.0,
        "aulas_previstas": 80,
        "faltas": 5,
    })
    assert resultado["nivel"] == "INDETERMINADO"
    assert resultado["score"] is None
    assert resultado["completude"] < COMPLETUDE_MINIMA
    assert "insuficientes" in resultado["recomendacao"].lower()


def test_indeterminado_ainda_entrega_faltas_restantes():
    """
    Mesmo sem score, a informacao mais util ao aluno continua disponivel.
    """
    resultado = calcular_score_aluno({
        "matricula": "2024003",
        "media_ponderada": 7.0,
        "aulas_previstas": 80,
        "faltas": 12,
    })
    assert resultado["nivel"] == "INDETERMINADO"
    assert resultado["faltas_restantes"] == 8


def test_fator_ausente_nao_entra_na_media():
    """
    Fator nulo e excluido do numerador E do denominador.

    Dois alunos identicos nos fatores conhecidos tem o mesmo score,
    ainda que um tenha mais fatores preenchidos com risco zero? Nao:
    o que importa e que a ausencia nao seja tratada como risco zero.
    """
    com_dado_ruim = calcular_score_aluno({
        "media_ponderada": 5.0,
        "percentual_frequencia": 80.0,
        "renda_per_capita_sm": 0.4,
        "acessos_ava_semana": 1,
    })
    sem_o_dado = calcular_score_aluno({
        "media_ponderada": 5.0,
        "percentual_frequencia": 80.0,
        "acessos_ava_semana": 1,
    })
    assert com_dado_ruim["completude"] > sem_o_dado["completude"]
    assert "financeiro" in com_dado_ruim["detalhamento"]
    assert "financeiro" not in sem_o_dado["detalhamento"]


def test_completude_reflete_pesos_disponiveis():
    resultado = calcular_score_aluno({
        "media_ponderada": 7.0,
        "percentual_frequencia": 90.0,
        "horas_trabalho_semana": 0,
    })
    esperado = PESOS["notas"] + PESOS["frequencia"] + PESOS["trabalho"]
    assert resultado["completude"] == pytest.approx(esperado, abs=0.001)


# ---------------------------------------------------------------------------
# Sobreposicao de frequencia
# ---------------------------------------------------------------------------

def test_sobreposicao_frequencia_forca_alto():
    """
    Frequencia abaixo de 75% eleva o nivel a ALTO, qualquer que seja
    o score ponderado. Aluno perto de reprovar por falta precisa de
    contato mesmo com os outros fatores bons.
    """
    resultado = calcular_score_aluno({
        "media_ponderada": 9.0,
        "percentual_frequencia": 70.0,
        "horas_trabalho_semana": 0,
        "taxa_reprovacao": 0.0,
        "renda_per_capita_sm": 4.0,
        "aulas_previstas": 80,
        "faltas": 24,
    })
    assert resultado["nivel"] == "ALTO"
    assert resultado["sobreposicao_frequencia"] is True


def test_sobreposicao_nao_rebaixa_critico():
    """A sobreposicao eleva, nunca reduz o nivel."""
    resultado = calcular_score_aluno({
        "media_ponderada": 2.0,
        "percentual_frequencia": 50.0,
        "horas_trabalho_semana": 48,
        "taxa_reprovacao": 0.9,
        "renda_per_capita_sm": 0.2,
        "acessos_ava_semana": 0,
    })
    assert resultado["nivel"] == "CRITICO"
    assert resultado["sobreposicao_frequencia"] is False


def test_sem_sobreposicao_quando_frequencia_ok():
    resultado = calcular_score_aluno({
        "media_ponderada": 9.5,
        "percentual_frequencia": 95.0,
        "horas_trabalho_semana": 0,
        "taxa_reprovacao": 0.0,
        "renda_per_capita_sm": 4.0,
    })
    assert resultado["sobreposicao_frequencia"] is False
    assert resultado["nivel"] == "BAIXO"


# ---------------------------------------------------------------------------
# Caso canonico do SRS
# ---------------------------------------------------------------------------

def test_caso_canonico_do_srs():
    """
    Caso canonico: media 5,4 / frequencia 68% / trabalho 44h.

    Pontuacoes individuais esperadas: nota 52, frequencia 58,7, trabalho 100.
    O nivel final deve ser ALTO, com a frequencia entre os fatores
    principais e a sobreposicao ativa.
    """
    aluno = {
        "matricula": "2024001",
        "media_ponderada": 5.4,
        "percentual_frequencia": 68.0,
        "aulas_previstas": 80,
        "faltas": 25,
        "horas_trabalho_semana": 44,
        "taxa_reprovacao": 0.33,
    }
    resultado = calcular_score_aluno(aluno)

    assert resultado["matricula"] == "2024001"
    assert resultado["nivel"] == "ALTO"
    assert resultado["faltas_restantes"] == 0
    assert "frequencia" in resultado["fatores_principais"]
    assert "notas" in resultado["fatores_principais"]
    assert resultado["detalhamento"]["notas"] == pytest.approx(52.0, abs=0.5)
    assert resultado["detalhamento"]["frequencia"] == pytest.approx(58.7, abs=0.5)
    assert resultado["detalhamento"]["trabalho"] == 100.0


def test_score_sempre_entre_zero_e_cem():
    extremos = [
        {"media_ponderada": 0.0, "percentual_frequencia": 0.0,
         "horas_trabalho_semana": 100, "taxa_reprovacao": 1.0,
         "renda_per_capita_sm": 0.0, "acessos_ava_semana": 0,
         "escala_saude_mental": 5, "escala_saude_fisica": 5,
         "escala_moradia": 5, "qtd_dependentes": 10,
         "minutos_deslocamento": 300},
        {"media_ponderada": 10.0, "percentual_frequencia": 100.0,
         "horas_trabalho_semana": 0, "taxa_reprovacao": 0.0,
         "renda_per_capita_sm": 50.0, "acessos_ava_semana": 100,
         "escala_saude_mental": 1, "escala_saude_fisica": 1,
         "escala_moradia": 1, "qtd_dependentes": 0,
         "minutos_deslocamento": 0},
    ]
    for dados in extremos:
        score = calcular_score_aluno(dados)["score"]
        assert 0 <= score <= 100


# ---------------------------------------------------------------------------
# Contrato de saida e explicabilidade
# ---------------------------------------------------------------------------

def test_contrato_de_saida_tem_todas_as_chaves():
    """Contrato 2, combinado entre B2 e B3."""
    resultado = calcular_score_aluno({
        "matricula": "2024001",
        "media_ponderada": 5.4,
        "percentual_frequencia": 68.0,
        "horas_trabalho_semana": 44,
        "aulas_previstas": 80,
        "faltas": 25,
    })
    for chave in (
        "matricula", "score", "nivel", "completude", "fatores_principais",
        "detalhamento", "faltas_restantes", "sobreposicao_frequencia",
        "recomendacao",
    ):
        assert chave in resultado, f"chave ausente no contrato: {chave}"


def test_explicabilidade_cita_os_fatores():
    """RN01 e regra de negocio 8: todo score vem com os fatores que o geraram."""
    resultado = calcular_score_aluno({
        "media_ponderada": 5.4,
        "percentual_frequencia": 68.0,
        "horas_trabalho_semana": 44,
        "aulas_previstas": 80,
        "faltas": 25,
    })
    texto = explicar_score(resultado)
    assert "frequencia" in texto.lower()
    assert str(resultado["score"]) in texto


def test_explicabilidade_do_indeterminado():
    resultado = calcular_score_aluno({"media_ponderada": 5.0})
    texto = explicar_score(resultado)
    assert "40%" in texto


def test_fatores_principais_sao_no_maximo_tres():
    resultado = calcular_score_aluno({
        "media_ponderada": 2.0,
        "percentual_frequencia": 40.0,
        "horas_trabalho_semana": 48,
        "taxa_reprovacao": 0.9,
        "renda_per_capita_sm": 0.2,
        "acessos_ava_semana": 0,
        "escala_saude_mental": 5,
    })
    assert len(resultado["fatores_principais"]) <= 3


def test_fatores_principais_ordenados_por_contribuicao():
    """O primeiro fator listado e o que mais pesou no score."""
    resultado = calcular_score_aluno({
        "media_ponderada": 2.0,
        "percentual_frequencia": 95.0,
        "horas_trabalho_semana": 0,
        "renda_per_capita_sm": 4.0,
        "acessos_ava_semana": 10,
    })
    assert resultado["fatores_principais"][0] == "notas"
