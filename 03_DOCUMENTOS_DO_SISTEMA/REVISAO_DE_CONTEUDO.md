# Revisão de Conteúdo: avaliações falsas e promessas sem comprovação

27/10/2026 · Material revisado: B1 (dump), B2 (código, README, CHANGELOG), Guia de Construção, SRS v1.1, Plano de Construção v1.1 e `b3/README.md`.

## Avaliações e depoimentos

**Nenhuma avaliação falsa, depoimento, nota de usuário, selo ou "aprovado por" foi encontrado** em nenhum dos materiais. Não há o que remover.

Os novos textos do B3 (política de privacidade, termos de uso, política de cookies) foram escritos sem garantias absolutas: dizem o que está implementado, admitem que nenhum sistema é imune a incidentes e que a disponibilidade não é ininterrupta.

## Afirmações sem comprovação ou imprecisas

| # | Onde | Texto atual | Problema | Texto sugerido |
|---|---|---|---|---|
| C-1 | B2: `README.md` linha 84; `indicadores.py` linha 17; `score.py` linha 39 | "Frequência mínima de 75% vem da LDB art. 47 §3º" | O art. 47, §3º da LDB diz que a frequência é obrigatória, mas **não fixa 75%**. O percentual de 75% está no art. 24, VI, que trata da educação básica. No ensino superior, o mínimo vem do regimento e das normas do sistema de ensino | "Frequência mínima de 75%, conforme o regimento da instituição (a LDB, art. 47, §3º, torna a frequência obrigatória; o percentual de 75% segue o art. 24, VI, aplicado por analogia). Confirmar no regimento." |
| C-2 | B2: `score.py` linha 155 | "O limiar de 20h vem da Lei 11.788/2008 (estágio), que trata 20h semanais como jornada compatível com a vida acadêmica" | O art. 10 da Lei 11.788/2008 fixa 20 horas semanais para educação especial e anos finais do fundamental. Para **ensino superior**, o limite é de 6 horas diárias e **30 horas semanais** (art. 10, II) | "Limiares definidos pelo grupo. Referência: a Lei 11.788/2008, art. 10, II, admite até 30h semanais de estágio no ensino superior." Avaliar se o corte de 20h continua fazendo sentido |
| C-3 | B2: `score.py` linha 198 | "1,5 SM por pessoa: Decreto 7.234/2010 (PNAES) e Lei 12.711/2012" | A Lei 14.723/2023 alterou a Lei 12.711/2012 e reduziu o critério de renda das cotas para **1 salário mínimo per capita**. O 1,5 SM do PNAES (Decreto 7.234/2010, art. 5º) permanece | "1,5 SM por pessoa: Decreto 7.234/2010 (PNAES), art. 5º." Retirar a Lei 12.711/2012 da justificativa ou citar o valor atualizado |
| C-4 | B2: `score.py` linha 242 | "O limiar de 60 minutos acompanha as faixas de deslocamento do IBGE" | Sem referência exata (pesquisa, ano, tabela). Conferir: nas faixas usuais do Censo para tempo de deslocamento (até 30 minutos, de 30 minutos a 1 hora, de 1 a 2 horas) não há corte em 90 minutos, que a função usa | Citar a fonte exata, por exemplo "IBGE, Censo Demográfico, tempo habitual de deslocamento ao trabalho", e dizer que o corte de 90 minutos é escolha do grupo |
| C-5 | B2: `score.py`, cabeçalho | "Conformidade: RN01 (...), RN05 (...), LGPD art. 20" | Um módulo de cálculo sozinho não garante conformidade. O art. 20 depende do registro da revisão humana, que fica na API e nos processos | "Contribui para RN01, RN05 e LGPD art. 20: a saída é explicável e serve de recomendação a uma pessoa." |
| C-6 | B2: `CHANGELOG.md` | "Removidos os caches versionados" | O pacote enviado contém `__pycache__` e `.pytest_cache` | Remover os caches de fato, ou corrigir a frase |
| C-7 | B2: `CHANGELOG.md` e `README.md` | "De 5 testes para 41, todos passando" | Há de fato 41 funções de teste. A execução não pôde ser repetida nesta revisão | Manter a frase, acrescentando a data e o comando da última execução (`pytest -v`, 27/10/2026) |
| C-8 | SRS v1.1, Seção 3.1 | "cerca de uma parcela relevante da população masculina tem alguma forma de daltonismo" | "Cerca de uma parcela" não é um número, e não há fonte | "cerca de 8% dos homens têm alguma deficiência na percepção de cores (fonte: [referência])" |
| C-9 | SRS v1.1, Seção 3.3 | "O FastAPI (...) elimina a dependência de explicação verbal" | Promessa absoluta: a documentação automática reduz, mas não elimina, a necessidade de combinar contratos | "reduz a dependência de explicação verbal" |

## O que está bem

- O aviso metodológico obrigatório (RN05) deixa claro que o nível de risco **não é previsão** nem julgamento. A API devolve esse aviso em toda resposta de score.
- O SRS e o B2 tratam ausência de dado como ausência, sem inventar valor otimista. É o oposto de uma promessa sem base.
- As métricas do modelo estatístico do SRS (sensibilidade mínima de 0,70, AUC mínimo de 0,75) aparecem como **critério de aceite**, não como resultado já obtido. Assim não são promessa.
