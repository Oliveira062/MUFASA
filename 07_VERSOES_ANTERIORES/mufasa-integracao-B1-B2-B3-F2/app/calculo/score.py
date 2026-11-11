"""
Score de risco de evasao do MUFASA.

ESCALA: 0 = aluno seguro, 100 = risco maximo de evasao.

ATENCAO AO SENTIDO DA ESCALA. Esta e a inversao corrigida na v2.2: a
pontuacao mede RISCO, nao desempenho. Aluno com nota 10 e frequencia
100% tem risco proximo de ZERO, nao de 100. Em quase todo contexto
escolar numero alto e coisa boa; aqui e o contrario.

Toda funcao de risco deste modulo segue essa convencao: recebe o valor
bruto do fator e devolve de 0 (sem risco) a 100 (risco maximo), ou None
quando o dado nao existe.

Conformidade: RN01 (score auditavel e explicavel), RN05 (nenhuma decisao
automatizada - a saida e recomendacao a humano), LGPD art. 20.
"""

from app.calculo.indicadores import calcular_faltas_restantes

# Pesos dos 11 fatores, conforme SRS v1.1. Somam 1.00.
PESOS = {
    "notas": 0.20,
    "frequencia": 0.18,
    "financeiro": 0.11,
    "reprovacao": 0.09,
    "engajamento_ava": 0.08,
    "saude_mental": 0.08,
    "trabalho": 0.07,
    "deslocamento": 0.05,
    "saude_fisica": 0.05,
    "moradia": 0.05,
    "dependentes": 0.04,
}

# Abaixo deste percentual de peso disponivel, o score nao e calculado.
COMPLETUDE_MINIMA = 0.40

# Frequencia minima legal (LDB art. 47 par. 3). Parametro configuravel.
FREQUENCIA_MINIMA_LEGAL = 75.0

# Nota minima de aprovacao. SEM BASE LEGAL no ensino superior: decorre da
# autonomia universitaria (CF art. 207, LDB art. 53). Confirmar no regimento.
NOTA_MINIMA_APROVACAO = 6.0

FAIXAS = (
    (25, "BAIXO"),
    (50, "MODERADO"),
    (75, "ALTO"),
    (100, "CRITICO"),
)

RECOMENDACOES = {
    "BAIXO": "Monitoramento periodico.",
    "MODERADO": "Atencao preventiva da tutoria.",
    "ALTO": "Contato em ate 5 dias uteis.",
    "CRITICO": "Busca ativa imediata pela coordenacao e nucleo de apoio, em ate 48 horas.",
    "INDETERMINADO": "Dados insuficientes para avaliar. Completar cadastro antes de classificar.",
}

ROTULOS = {
    "notas": "desempenho academico",
    "frequencia": "frequencia",
    "financeiro": "situacao financeira",
    "reprovacao": "historico de reprovacoes",
    "engajamento_ava": "engajamento no ambiente virtual",
    "saude_mental": "saude mental",
    "trabalho": "jornada de trabalho",
    "deslocamento": "tempo de deslocamento",
    "saude_fisica": "saude fisica",
    "moradia": "situacao de moradia",
    "dependentes": "dependentes sob cuidado",
}


# ---------------------------------------------------------------------------
# Classificacao
# ---------------------------------------------------------------------------

def classificar_nivel_risco(score: int) -> str:
    """
    Converte o score de risco na faixa correspondente.

    Faixas do SRS: 0-25 BAIXO, 26-50 MODERADO, 51-75 ALTO, 76-100 CRITICO.

    >>> classificar_nivel_risco(63)
    'ALTO'
    """
    if score is None:
        return "INDETERMINADO"
    for limite, nome in FAIXAS:
        if score <= limite:
            return nome
    return "CRITICO"


# ---------------------------------------------------------------------------
# Funcoes de risco por fator
#
# Todas retornam 0 (sem risco) a 100 (risco maximo), ou None sem dado.
# As retas por trecho sao deliberadas: o coordenador precisa poder refazer
# a conta a mao e chegar ao mesmo numero.
# ---------------------------------------------------------------------------

def risco_por_nota(media):
    """
    Risco derivado da media ponderada. Media ALTA produz risco BAIXO.

    Media >= 8.0            -> 0   (sem risco)
    Media entre 6.0 e 8.0   -> 0 a 40, linear
    Media entre 4.0 e 6.0   -> 40 a 80, linear
    Media < 4.0             -> 100

    >>> round(risco_por_nota(5.4), 1)
    52.0
    """
    if media is None:
        return None
    if media >= 8.0:
        return 0.0
    if media >= 6.0:
        return round(40 * (8.0 - media) / 2.0, 2)
    if media >= 4.0:
        return round(40 + 40 * (6.0 - media) / 2.0, 2)
    return 100.0


def risco_por_frequencia(frequencia):
    """
    Risco derivado do percentual de frequencia. Frequencia ALTA produz risco BAIXO.

    Freq >= 90%         -> 0
    Freq 75% a 90%      -> 0 a 40, linear
    Freq 60% a 75%      -> 40 a 80, linear
    Freq < 60%          -> 100

    >>> round(risco_por_frequencia(68.0), 1)
    58.7
    """
    if frequencia is None:
        return None
    if frequencia >= 90.0:
        return 0.0
    if frequencia >= 75.0:
        return round(40 * (90.0 - frequencia) / 15.0, 2)
    if frequencia >= 60.0:
        return round(40 + 40 * (75.0 - frequencia) / 15.0, 2)
    return 100.0


def risco_por_trabalho(horas_semana):
    """
    Risco derivado da jornada de trabalho semanal.

    O limiar de 20h vem da Lei 11.788/2008 (estagio), que trata 20h
    semanais como jornada compativel com a vida academica.

    0h          -> 0
    1 a 20h     -> 25
    21 a 30h    -> 50
    31 a 40h    -> 75
    acima de 40h-> 100
    """
    if horas_semana is None:
        return None
    if horas_semana <= 0:
        return 0.0
    if horas_semana <= 20:
        return 25.0
    if horas_semana <= 30:
        return 50.0
    if horas_semana <= 40:
        return 75.0
    return 100.0


def risco_por_reprovacao(taxa):
    """
    Risco derivado da taxa de reprovacao no historico (0.0 a 1.0).

    Taxa de 50% ou mais satura em 100: metade do historico reprovado
    ja e o cenario de risco maximo neste fator.

    >>> risco_por_reprovacao(0.333)
    66.6
    """
    if taxa is None:
        return None
    return round(min(100.0, taxa * 200.0), 2)


def risco_por_renda_per_capita(renda_per_capita_sm):
    """
    Risco derivado da renda familiar por pessoa, em salarios minimos.

    Limiares com base legal:
    - 0,5 SM por pessoa: Decreto 6.135/2007 (criterio do CadUnico)
    - 1,5 SM por pessoa: Decreto 7.234/2010 (PNAES) e Lei 12.711/2012

    <= 0,5 SM       -> 100
    0,5 a 1,5 SM    -> 100 a 40, linear
    1,5 a 3,0 SM    -> 40 a 0, linear
    > 3,0 SM        -> 0
    """
    if renda_per_capita_sm is None:
        return None
    if renda_per_capita_sm <= 0.5:
        return 100.0
    if renda_per_capita_sm <= 1.5:
        return round(100 - 60 * (renda_per_capita_sm - 0.5) / 1.0, 2)
    if renda_per_capita_sm <= 3.0:
        return round(40 - 40 * (renda_per_capita_sm - 1.5) / 1.5, 2)
    return 0.0


def risco_por_engajamento_ava(acessos_semana):
    """
    Risco derivado do engajamento no ambiente virtual.

    Nenhum acesso na semana e sinal forte de desengajamento.

    0 acessos       -> 100
    1 a 2 acessos   -> 60
    3 a 5 acessos   -> 30
    6 ou mais       -> 0
    """
    if acessos_semana is None:
        return None
    if acessos_semana <= 0:
        return 100.0
    if acessos_semana <= 2:
        return 60.0
    if acessos_semana <= 5:
        return 30.0
    return 0.0


def risco_por_deslocamento(minutos):
    """
    Risco derivado do tempo de deslocamento ate o campus, em minutos.

    O limiar de 60 minutos acompanha as faixas de deslocamento do IBGE.

    <= 30 min       -> 0
    31 a 60 min     -> 30
    61 a 90 min     -> 60
    > 90 min        -> 100
    """
    if minutos is None:
        return None
    if minutos <= 30:
        return 0.0
    if minutos <= 60:
        return 30.0
    if minutos <= 90:
        return 60.0
    return 100.0


def risco_por_dependentes(quantidade):
    """
    Risco derivado do numero de dependentes sob cuidado do aluno.

    0 dependentes   -> 0
    1               -> 40
    2               -> 70
    3 ou mais       -> 100
    """
    if quantidade is None:
        return None
    if quantidade <= 0:
        return 0.0
    if quantidade == 1:
        return 40.0
    if quantidade == 2:
        return 70.0
    return 100.0


def risco_por_escala_declarada(nivel):
    """
    Converte uma escala declarada de 1 a 5 em risco de 0 a 100.

    Usada para os fatores autodeclarados em questionario: saude mental,
    saude fisica e situacao de moradia. Nivel 1 = situacao otima,
    nivel 5 = situacao critica.

    DADO SENSIVEL: saude mental e saude fisica sao dados de saude
    (LGPD art. 11). Exigem consentimento especifico e ficam em tabela
    separada e criptografada, sob responsabilidade do B1.
    """
    if nivel is None:
        return None
    if nivel < 1 or nivel > 5:
        return None
    return round((nivel - 1) * 25.0, 2)


# ---------------------------------------------------------------------------
# Score consolidado
# ---------------------------------------------------------------------------

def _coletar_riscos(dados_aluno: dict) -> dict:
    """
    Monta o dicionario fator -> risco, aceitando dado bruto ou risco pronto.

    Para cada fator, se a chave "risco_<fator>" vier preenchida ela e usada
    diretamente; caso contrario o risco e derivado do dado bruto. Isso
    permite ao B1 entregar dados crus e ao B3 injetar valores calculados,
    sem mudar a interface.
    """
    def escolher(nome_fator, valor_derivado):
        pronto = dados_aluno.get(f"risco_{nome_fator}")
        return pronto if pronto is not None else valor_derivado

    return {
        "notas": escolher("notas", risco_por_nota(dados_aluno.get("media_ponderada"))),
        "frequencia": escolher("frequencia", risco_por_frequencia(dados_aluno.get("percentual_frequencia"))),
        "financeiro": escolher("financeiro", risco_por_renda_per_capita(dados_aluno.get("renda_per_capita_sm"))),
        "reprovacao": escolher("reprovacao", risco_por_reprovacao(dados_aluno.get("taxa_reprovacao"))),
        "engajamento_ava": escolher("engajamento_ava", risco_por_engajamento_ava(dados_aluno.get("acessos_ava_semana"))),
        "saude_mental": escolher("saude_mental", risco_por_escala_declarada(dados_aluno.get("escala_saude_mental"))),
        "trabalho": escolher("trabalho", risco_por_trabalho(dados_aluno.get("horas_trabalho_semana"))),
        "deslocamento": escolher("deslocamento", risco_por_deslocamento(dados_aluno.get("minutos_deslocamento"))),
        "saude_fisica": escolher("saude_fisica", risco_por_escala_declarada(dados_aluno.get("escala_saude_fisica"))),
        "moradia": escolher("moradia", risco_por_escala_declarada(dados_aluno.get("escala_moradia"))),
        "dependentes": escolher("dependentes", risco_por_dependentes(dados_aluno.get("qtd_dependentes"))),
    }


def calcular_score_aluno(dados_aluno: dict) -> dict:
    """
    Calcula o score de risco de evasao de um aluno.

    Formula: score = soma(peso_i * risco_i) / soma(peso_i disponivel)

    Fatores ausentes sao EXCLUIDOS do numerador e do denominador, em vez
    de receberem valor neutro inventado. A soma dos pesos disponiveis e a
    completude: abaixo de 40% o score nao e calculado e o nivel sai como
    INDETERMINADO (RN01).

    Sobreposicao: frequencia abaixo do minimo legal forca nivel ALTO,
    qualquer que seja o resultado ponderado. Aluno proximo de reprovar por
    falta precisa de contato mesmo que os outros fatores estejam bons.

    Retorna dicionario conforme o Contrato 2 combinado entre B2 e B3.
    """
    matricula = dados_aluno.get("matricula")

    riscos = _coletar_riscos(dados_aluno)
    disponiveis = {k: v for k, v in riscos.items() if v is not None}

    peso_disponivel = sum(PESOS[k] for k in disponiveis)
    completude = round(peso_disponivel, 4)

    faltas_restantes = calcular_faltas_restantes(
        dados_aluno.get("aulas_previstas", 0),
        dados_aluno.get("faltas", 0),
    )

    if completude < COMPLETUDE_MINIMA:
        return {
            "matricula": matricula,
            "score": None,
            "nivel": "INDETERMINADO",
            "completude": completude,
            "fatores_principais": [],
            "detalhamento": {k: round(v, 2) for k, v in disponiveis.items()},
            "faltas_restantes": faltas_restantes,
            "sobreposicao_frequencia": False,
            "recomendacao": RECOMENDACOES["INDETERMINADO"],
        }

    soma_ponderada = sum(PESOS[k] * v for k, v in disponiveis.items())
    score = int(round(soma_ponderada / peso_disponivel))
    score = max(0, min(100, score))

    nivel = classificar_nivel_risco(score)

    frequencia = dados_aluno.get("percentual_frequencia")
    sobreposicao = False
    if (
        frequencia is not None
        and frequencia < FREQUENCIA_MINIMA_LEGAL
        and nivel in ("BAIXO", "MODERADO")
    ):
        nivel = "ALTO"
        sobreposicao = True

    contribuicoes = sorted(
        ((k, PESOS[k] * v) for k, v in disponiveis.items()),
        key=lambda par: par[1],
        reverse=True,
    )
    fatores_principais = [nome for nome, contrib in contribuicoes[:3] if contrib > 0]

    return {
        "matricula": matricula,
        "score": score,
        "nivel": nivel,
        "completude": completude,
        "fatores_principais": fatores_principais,
        "detalhamento": {k: round(v, 2) for k, v in disponiveis.items()},
        "faltas_restantes": faltas_restantes,
        "sobreposicao_frequencia": sobreposicao,
        "recomendacao": RECOMENDACOES[nivel],
    }


def explicar_score(resultado: dict) -> str:
    """
    Gera a explicacao em linguagem natural do score, para o painel e o chatbot.

    Atende a regra de negocio 8 (todo score vem acompanhado dos fatores que
    o produziram) e o RN01.
    """
    if resultado.get("nivel") == "INDETERMINADO":
        return (
            "Nao foi possivel avaliar: apenas "
            f"{int(resultado.get('completude', 0) * 100)}% dos dados necessarios "
            "estao preenchidos. Minimo exigido: 40%."
        )

    fatores = resultado.get("fatores_principais", [])
    nomes = [ROTULOS.get(f, f) for f in fatores]

    if nomes:
        lista = ", ".join(nomes[:-1]) + " e " + nomes[-1] if len(nomes) > 1 else nomes[0]
        texto = (
            f"Score {resultado['score']} de 100, nivel {resultado['nivel']}. "
            f"Os fatores que mais pesaram foram: {lista}."
        )
    else:
        texto = (
            f"Score {resultado['score']} de 100, nivel {resultado['nivel']}. "
            "Nenhum fator apresentou risco relevante."
        )

    if resultado.get("sobreposicao_frequencia"):
        texto += (
            " O nivel foi elevado para ALTO porque a frequencia esta abaixo "
            f"do minimo de {int(FREQUENCIA_MINIMA_LEGAL)}%, "
            "independentemente dos demais fatores."
        )

    restantes = resultado.get("faltas_restantes")
    if restantes is not None:
        if restantes == 0:
            texto += " O limite de faltas ja foi atingido."
        else:
            texto += f" Restam {restantes} faltas antes do limite."

    return texto
