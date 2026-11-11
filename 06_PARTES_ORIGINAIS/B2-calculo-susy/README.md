# Backend B2 — Módulo de Cálculo e Score (v2.2)

Módulo de cálculo de risco de evasão do MUFASA. Funções puras: não acessa banco
nem expõe endpoints, o que permite testar tudo sem infraestrutura.

## Escala

**0 = aluno seguro · 100 = risco máximo de evasão.**

A pontuação mede RISCO, não desempenho. Aluno com nota 10 e frequência 100%
tem risco próximo de zero. Essa inversão foi o defeito corrigido na v2.2 —
ver CHANGELOG.md.

## Estrutura

    app/calculo/indicadores.py   Média ponderada, frequência, faltas restantes, taxa de reprovação
    app/calculo/score.py         Os 11 fatores, pesos, faixas, completude, sobreposição, explicabilidade
    testes/test_calculo.py       41 testes

## Como rodar os testes

    pip install pytest
    pytest -v

## Uso

    from app.calculo.score import calcular_score_aluno, explicar_score

    resultado = calcular_score_aluno({
        "matricula": "2024001",
        "media_ponderada": 5.4,
        "percentual_frequencia": 68.0,
        "aulas_previstas": 80,
        "faltas": 25,
        "horas_trabalho_semana": 44,
        "taxa_reprovacao": 0.33,
    })
    # {"score": 63, "nivel": "ALTO", ...}

    print(explicar_score(resultado))

## Pesos dos 11 fatores (SRS v1.1)

| Fator | Peso |
|---|---|
| Notas | 20% |
| Frequência | 18% |
| Situação financeira | 11% |
| Taxa de reprovação | 9% |
| Engajamento AVA | 8% |
| Saúde mental | 8% |
| Trabalho | 7% |
| Deslocamento | 5% |
| Saúde física | 5% |
| Moradia | 5% |
| Dependentes | 4% |

## Faixas

| Score | Nível | Prazo de ação |
|---|---|---|
| 0-25 | BAIXO | Monitoramento periódico |
| 26-50 | MODERADO | Atenção preventiva |
| 51-75 | ALTO | Contato em até 5 dias úteis |
| 76-100 | CRÍTICO | Busca ativa em até 48 horas |
| — | INDETERMINADO | Completude abaixo de 40% |

## Avisos para as outras frentes

**B1:** `calcular_percentual_frequencia` mudou de assinatura na v2.2. Agora recebe
`(aulas_realizadas, faltas)`, não `(aulas_previstas, presencas)`. Frequência ausente
deve chegar como `None`, nunca como 100.

**B1:** saúde mental e saúde física são dados sensíveis (LGPD art. 11) — tabela
separada e criptografada, com consentimento específico.

**B3:** o retorno ganhou as chaves `completude`, `detalhamento` e
`sobreposicao_frequencia`. As seis chaves do Contrato 2 seguem iguais.

## Parâmetros a confirmar no regimento

- Nota mínima de aprovação (`NOTA_MINIMA_APROVACAO = 6.0`) não tem base legal no
  ensino superior: decorre da autonomia universitária. Confirmar com a coordenação.
- Frequência mínima de 75% vem da LDB art. 47 §3º.
