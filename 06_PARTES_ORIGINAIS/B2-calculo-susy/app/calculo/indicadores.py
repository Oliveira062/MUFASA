"""
Indicadores academicos basicos do MUFASA.

Funcoes puras: entram numeros, saem numeros. Nenhuma depende de banco
ou de API, o que permite testar o modulo inteiro sem infraestrutura.

REGRA GERAL DESTE MODULO: dado ausente retorna None, nunca um valor
neutro inventado. Preencher ausencia com valor otimista transforma o
maior sinal de abandono em sinal de normalidade.
"""


def calcular_faltas_restantes(aulas_previstas: int, faltas: int) -> int:
    """
    Quantas faltas o aluno ainda pode acumular antes de reprovar por falta.

    Limite de 25% das aulas previstas (LDB art. 47 par. 3: minimo de 75%
    de frequencia). O piso em zero evita numero negativo quando o limite
    ja foi estourado.

    >>> calcular_faltas_restantes(80, 12)
    8
    """
    if aulas_previstas is None or aulas_previstas <= 0:
        return 0
    limite_faltas = int(aulas_previstas * 0.25)
    return max(0, limite_faltas - faltas)


def calcular_percentual_frequencia(aulas_realizadas: int, faltas: int):
    """
    Percentual de frequencia sobre as aulas JA REALIZADAS.

    ASSINATURA ALTERADA na v2.2: antes recebia (aulas_previstas, presencas).
    O SRS calcula frequencia sobre aulas realizadas, nao previstas. Usar as
    previstas no meio do semestre faz todo aluno parecer com frequencia
    baixissima, porque as aulas que ainda nao aconteceram contam como falta.

    Retorna None quando nenhuma aula foi lancada. NAO retorna 100.0:
    ausencia de lancamento nao e frequencia perfeita.

    >>> calcular_percentual_frequencia(80, 20)
    75.0
    """
    if aulas_realizadas is None or aulas_realizadas <= 0:
        return None
    if faltas is None:
        return None
    percentual = (1 - (faltas / aulas_realizadas)) * 100.0
    return round(max(0.0, min(100.0, percentual)), 2)


def calcular_media_ponderada(notas: list[tuple[float, float]]):
    """
    Media ponderada pela carga horaria: soma(nota * CH) / soma(CH).

    notas: lista de tuplas (nota, carga_horaria).
    Retorna None quando nao ha nota lancada ou a soma das cargas e zero.

    >>> calcular_media_ponderada([(5.0, 2.0), (6.0, 3.0)])
    5.6
    """
    if not notas:
        return None
    soma_pesos = sum(peso for _, peso in notas)
    if soma_pesos == 0:
        return None
    soma = sum(nota * peso for nota, peso in notas)
    return round(soma / soma_pesos, 3)


def calcular_taxa_reprovacao(disciplinas_cursadas: int, reprovacoes: int):
    """
    Proporcao de reprovacoes no historico, de 0.0 a 1.0.

    Retorna None para aluno sem historico (primeiro periodo), em vez de
    0.0: nao ter reprovado nada e nunca ter cursado nada sao situacoes
    diferentes, e tratar as duas igual esconde o aluno ingressante.

    >>> calcular_taxa_reprovacao(6, 2)
    0.333
    """
    if disciplinas_cursadas is None or disciplinas_cursadas <= 0:
        return None
    if reprovacoes is None:
        return None
    return round(reprovacoes / disciplinas_cursadas, 3)


def calcular_completude_cadastro(campos_preenchidos: int, campos_totais: int) -> float:
    """
    Proporcao de campos preenchidos no cadastro, de 0.0 a 1.0.

    Util para o painel exibir "cadastro 60% completo". O score usa a
    completude ponderada pelos pesos, calculada dentro de score.py.
    """
    if campos_totais is None or campos_totais <= 0:
        return 0.0
    return round(campos_preenchidos / campos_totais, 4)
