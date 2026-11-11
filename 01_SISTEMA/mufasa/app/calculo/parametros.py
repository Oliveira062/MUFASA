"""
Parametros do modelo de score (SRS v1.1, Anexo B, tabela C.2; RN22).

Nenhum limiar, peso ou faixa e constante no calculo: tudo vem daqui. Os
valores abaixo sao so o PADRAO do SRS, usado para criar a primeira versao
na tabela parametros (sql/painel.sql) e nos testes. Em operacao, o servico
de calculo le a versao vigente do banco e grava, junto de cada score, o
numero da versao que o produziu.
"""

from dataclasses import dataclass, field

# chave: (valor padrao, unidade, minimo, maximo, editavel pela interface, descricao)
# "editavel" False = muda so por recalibracao formal (Anexo A.9), nunca por um
# ajuste avulso na tela: os pesos precisam continuar somando 1,00.
CATALOGO = {
    # Pesos (Anexo A, B.4). Somam 1,00.
    "PESO_I1_DESEMPENHO":   (0.20, "fração", 0, 1, False, "Peso do desempenho acadêmico (I1)."),
    "PESO_I2_FREQUENCIA":   (0.18, "fração", 0, 1, False, "Peso da frequência (I2)."),
    "PESO_I3_REPROVACAO":   (0.09, "fração", 0, 1, False, "Peso da taxa de reprovação acumulada (I3)."),
    "PESO_I4_AVA":          (0.08, "fração", 0, 1, False, "Peso do engajamento no AVA (I4)."),
    "PESO_I5_FINANCEIRO":   (0.11, "fração", 0, 1, False, "Peso da situação financeira (I5)."),
    "PESO_I6_TRABALHO":     (0.07, "fração", 0, 1, False, "Peso do trabalho (I6)."),
    "PESO_I7_DESLOCAMENTO": (0.05, "fração", 0, 1, False, "Peso do deslocamento (I7)."),
    "PESO_I8_SAUDE_MENTAL": (0.08, "fração", 0, 1, False, "Peso da saúde mental (I8)."),
    "PESO_I9_SAUDE_FISICA": (0.05, "fração", 0, 1, False, "Peso da saúde física (I9)."),
    "PESO_I10_MORADIA":     (0.05, "fração", 0, 1, False, "Peso da moradia (I10)."),
    "PESO_I11_DEPENDENTES": (0.04, "fração", 0, 1, False, "Peso dos dependentes sob cuidado (I11)."),
    # Notas (C.2)
    "NOTA_MINIMA":          (6.0, "nota 0 a 10", 0, 10, True, "Nota mínima de aprovação. Autonomia institucional (CF art. 207; LDB art. 53)."),
    "NOTA_CONFORTAVEL":     (8.0, "nota 0 a 10", 0, 10, True, "Nota a partir da qual o desempenho não gera risco."),
    "NOTA_CRITICA":         (4.0, "nota 0 a 10", 0, 10, True, "Nota abaixo da qual a curva de I1 entra no último trecho."),
    # Frequencia (C.2)
    "FREQUENCIA_MINIMA":    (75.0, "%", 0, 100, True, "Frequência mínima para aprovação (LDB art. 47, §3º; prática regulamentar de 75%)."),
    "FREQUENCIA_CONFORTAVEL": (90.0, "%", 0, 100, True, "Frequência a partir da qual não há risco."),
    "FREQUENCIA_CRITICA":   (60.0, "%", 0, 100, True, "Frequência abaixo da qual a curva de I2 entra no último trecho."),
    # Renda (C.2), em salarios minimos por pessoa
    "RENDA_EXTREMA":        (0.25, "SM por pessoa", 0, 10, True, "Até este valor: extrema vulnerabilidade (I5 = 100)."),
    "RENDA_VULNERAVEL":     (0.5, "SM por pessoa", 0, 10, True, "Corte de baixa renda do CadÚnico (Decreto nº 6.135/2007)."),
    "RENDA_UM_SM":          (1.0, "SM por pessoa", 0, 10, True, "Abaixo de um salário mínimo por pessoa."),
    "RENDA_AUXILIO":        (1.5, "SM por pessoa", 0, 10, True, "Teto de prioridade do PNAES (Decreto nº 7.234/2010, art. 5º)."),
    "SALARIO_MINIMO":       (1621.0, "reais", 1000, 10000, True, "Salário mínimo nacional vigente (R$ 1.621,00 em 2026). Atualizar a cada decreto anual."),
    # Trabalho e deslocamento (C.2)
    "JORNADA_LIMITE":       (20.0, "horas por semana", 0, 80, True, "Jornada acima da qual o trabalho compete com o estudo (Lei nº 11.788/2008 como referência)."),
    "DESLOCAMENTO_LIMITE":  (60.0, "minutos por trajeto", 0, 300, True, "Deslocamento de referência por trajeto (faixas do IBGE)."),
    "AVA_DIAS_SEM_ACESSO":  (21.0, "dias", 1, 90, True, "Dias sem acesso ao AVA que levam I4 a 100 (Astin, 1984)."),
    # Faixas (RN02) e completude (B.4)
    "CORTE_BAIXO":          (25.0, "pontos", 0, 100, True, "Score até este valor: nível Baixo."),
    "CORTE_MODERADO":       (50.0, "pontos", 0, 100, True, "Score até este valor: nível Moderado."),
    "CORTE_ALTO":           (75.0, "pontos", 0, 100, True, "Score até este valor: nível Alto; acima, Crítico."),
    "COMPLETUDE_MINIMA":    (40.0, "% dos pesos", 0, 100, True, "Abaixo disto o nível é Indeterminado (RN01)."),
    "COMPLETUDE_PLENA":     (70.0, "% dos pesos", 0, 100, True, "Abaixo disto o score é parcial e só chega a Crítico por sobreposição."),
    # Operacao (RN02, RN07, RN13, RN14, C.2)
    "SLA_CRITICO_HORAS":    (48.0, "horas", 12, 168, True, "Prazo do primeiro atendimento de alerta Crítico."),
    "SLA_ALTO_DIAS_UTEIS":  (5.0, "dias úteis", 1, 15, True, "Prazo do primeiro atendimento de alerta Alto (sábado e domingo não contam; feriados não estão cadastrados)."),
    "SLA_DADOS_DIAS_UTEIS": (10.0, "dias úteis", 1, 30, True, "Prazo da tarefa de correção de dados de aluno Indeterminado."),
    "MINIMO_GRUPO":         (5.0, "alunos", 3, 50, True, "Grupos menores são suprimidos nos agregados (RN07, CA19)."),
    "INTERVALO_ATENDIMENTOS": (15.0, "dias", 1, 60, True, "Intervalo mínimo entre atendimentos (RN14)."),
    "TETO_ALERTAS_RESPONSAVEL": (30.0, "alertas", 1, 500, True, "Teto de alertas abertos por responsável (valor a confirmar na Sprint 1)."),
}

PESOS_POR_FATOR = {
    "notas": "PESO_I1_DESEMPENHO", "frequencia": "PESO_I2_FREQUENCIA", "reprovacao": "PESO_I3_REPROVACAO",
    "engajamento_ava": "PESO_I4_AVA", "financeiro": "PESO_I5_FINANCEIRO", "trabalho": "PESO_I6_TRABALHO",
    "deslocamento": "PESO_I7_DESLOCAMENTO", "saude_mental": "PESO_I8_SAUDE_MENTAL",
    "saude_fisica": "PESO_I9_SAUDE_FISICA", "moradia": "PESO_I10_MORADIA", "dependentes": "PESO_I11_DEPENDENTES",
}

# Relacoes que precisam valer em qualquer versao de parametros.
REGRAS_COERENCIA = (
    ("NOTA_CRITICA", "NOTA_MINIMA", "NOTA_CONFORTAVEL"),
    ("FREQUENCIA_CRITICA", "FREQUENCIA_MINIMA", "FREQUENCIA_CONFORTAVEL"),
    ("RENDA_EXTREMA", "RENDA_VULNERAVEL", "RENDA_UM_SM", "RENDA_AUXILIO"),
    ("CORTE_BAIXO", "CORTE_MODERADO", "CORTE_ALTO"),
    ("COMPLETUDE_MINIMA", "COMPLETUDE_PLENA"),
)


def problemas_de_coerencia(valores: dict) -> list[str]:
    """Lista o que impede uma versao de parametros de ser usada (vazia = ok)."""
    problemas = []
    for sequencia in REGRAS_COERENCIA:
        numeros = [float(valores[c]) for c in sequencia]
        if any(a >= b for a, b in zip(numeros, numeros[1:])):
            problemas.append(" < ".join(sequencia) + " precisa ser estritamente crescente.")
    soma = sum(float(valores[c]) for c in PESOS_POR_FATOR.values())
    if abs(soma - 1.0) > 1e-6:
        problemas.append(f"Os pesos precisam somar 1,00 (somam {soma:.2f}).")
    return problemas


@dataclass(frozen=True)
class Parametros:
    valores: dict = field(default_factory=lambda: {k: v[0] for k, v in CATALOGO.items()})
    versao: int = 0  # 0 = padrao do SRS, sem versao gravada no banco

    def __getitem__(self, chave: str) -> float:
        return float(self.valores[chave])

    @property
    def rotulo_versao(self) -> str:
        return f"param-v{self.versao}" if self.versao else "param-padrao-srs-1.1"

    def peso(self, fator: str) -> float:
        return self[PESOS_POR_FATOR[fator]]

    def com(self, **alteracoes) -> "Parametros":
        """Copia com valores trocados (testes e simulacao de proposta)."""
        return Parametros({**self.valores, **alteracoes}, self.versao)


PADRAO = Parametros()
