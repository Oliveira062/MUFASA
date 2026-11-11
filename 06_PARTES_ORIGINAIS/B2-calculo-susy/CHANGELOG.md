# Backend B2 — Histórico de versões

## v2.2 — Correção da escala e implementação completa dos 11 fatores

### Correção crítica

**A escala do score estava invertida.** Na v2.1, frequência e nota eram convertidas em pontuação de desempenho (frequência 100% → 100 pontos) e o resultado era entregue como se fosse risco. Como o SRS define o score como risco de evasão (0 = seguro, 100 = crítico), o sistema fazia o oposto do pretendido.

Comprovação por execução:

| Caso | v2.1 | v2.2 |
|---|---|---|
| Aluno exemplar (média 9,5 · freq. 98% · não trabalha) | score 90 — CRÍTICO | **score 0 — BAIXO** |
| Aluno em abandono (média 2,0 · freq. 40% · 48h de trabalho) | score 0 — BAIXO | **score 98 — CRÍTICO** |
| Caso canônico do SRS (média 5,4 · freq. 68% · 44h) | score 51 | **score 63 — ALTO** |

A correção está nas funções `risco_por_*`, que recebem o valor bruto do fator e devolvem risco de 0 a 100: nota alta produz risco baixo.

### Correções pontuais

| Item | v2.1 | v2.2 |
|---|---|---|
| `classificar_nivel_risco` | Declarada duas vezes; a primeira sem corpo, com a docstring órfã | Declaração única, com a docstring no lugar |
| Nome do segundo nível | `"MÉDIO"`, divergindo do SRS e do próprio dicionário de recomendações | `"MODERADO"` em todo o módulo |
| Nível `"MUITO BAIXO"` | Recomendação para nível inexistente | Removido |
| `import calcular_faltas_restantes` | Dentro da função, na linha 54 | No topo do arquivo |
| Frequência com 0 aulas lançadas | Retornava `100.0` | Retorna `None` — ausência de lançamento não é frequência perfeita |
| `calcular_percentual_frequencia` | Assinatura `(aulas_previstas, presencas)` | Assinatura `(aulas_realizadas, faltas)`, conforme o SRS |

### Implementações que faltavam

- **Os 11 fatores do SRS**, contra 3 na v2.1. Entraram: situação financeira, taxa de reprovação, engajamento no AVA, saúde mental, deslocamento, saúde física, moradia e dependentes.
- **Pesos do SRS** no dicionário `PESOS` (20/18/11/9/8/8/7/5/5/5/4), em lugar dos 45/45/10 improvisados. Soma verificada em teste.
- **Tratamento de completude** (RN01): fatores ausentes são excluídos do numerador e do denominador; abaixo de 40% de peso disponível o nível sai como `INDETERMINADO` e o score como `None`.
- **Regra de sobreposição**: frequência abaixo de 75% força nível ALTO, qualquer que seja o ponderado.
- **Explicabilidade por contribuição real** ao score (`peso × risco` ordenado), em lugar dos limiares fixos da v2.1 — atende RN01 e a regra de negócio 8.
- **`explicar_score()`**: gera a explicação em linguagem natural para o painel e o chatbot.
- **`calcular_taxa_reprovacao()`** e **`calcular_completude_cadastro()`** em `indicadores.py`.
- **Campo `detalhamento`** no retorno: o risco de cada fator disponível, para auditoria.

### Testes

De 5 testes para **41**, todos passando.

O defeito da escala atravessou a v2.1 porque o `test_caso_canonico_srs` verificava apenas `assert "score" in resultado` e `assert nivel in ["CRÍTICO","ALTO","BAIXO"]` — asserções que passam com quase qualquer resultado. Os testes novos exigem valor exato ou relação de ordem verificável.

Testes que não existiam e agora protegem o módulo:

- `test_sentido_da_escala` — compara aluno exemplar e aluno em abandono. É o teste que reprova qualquer reintrodução da inversão.
- `test_monotonicidade_da_nota` e `test_monotonicidade_da_frequencia` — piorar um fator nunca pode reduzir o risco.
- `test_completude_insuficiente_vira_indeterminado` e `test_fator_ausente_nao_entra_na_media`.
- `test_sobreposicao_frequencia_forca_alto` e `test_sobreposicao_nao_rebaixa_critico`.
- `test_frequencia_sem_aula_lancada_retorna_none` — o erro que o SRS proíbe.
- `test_pesos_somam_um`, `test_pesos_conforme_srs`, `test_onze_fatores`.
- `test_caso_canonico_do_srs` com assert nos valores numéricos (52,0 · 58,7 · 100,0 · score 63).
- `test_contrato_de_saida_tem_todas_as_chaves` — valida o Contrato 2 com o B3.

### Estrutura

- Removidas as cópias duplicadas `Teste/score.py` e `Teste/indicadores.py`, idênticas às de `app/calculo/`.
- Pasta `Teste/` renomeada para `testes/`.
- Criados os `__init__.py` em `app/`, `app/calculo/` e `testes/` — sem eles os imports falhavam.
- Criado `.gitignore` cobrindo `__pycache__/`, `.pytest_cache/`, `venv/`, `.env` e dados reais de alunos.
- Removidos os caches versionados.

---

## v2.1 — Versão inicial (entregue pelo B2)

Primeira implementação dos indicadores e do score. Três indicadores corretos: faltas restantes, percentual de frequência e média ponderada. Estrutura de pastas, type hints, docstrings e separação entre indicadores e score conforme a arquitetura combinada. Formato de retorno em conformidade com o Contrato 2.
