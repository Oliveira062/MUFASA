# Revisão das métricas contra o SRS v1.1 e o Plano de Construção v1.1

Data: 28/10/2026. Base conferida: banco montado do zero a partir da semente da entrega (1.000 alunos, parâmetros versão 1).

Os documentos de referência são o SRS v1.1 ("Imprimir .docx") e o Plano de Construção v1.1 ("Imprimir 2.docx"). Quando o código e o documento divergiam, o código foi corrigido para seguir o documento.

## 1. Tabela de parâmetros (SRS, Anexo C.2)

O SRS diz que "nenhum destes valores pode ser constante fixa no código". Todos ficam na tabela `parametros`, com versão, autor, data e justificativa em `parametros_versoes` (RN22). A tela **Administração → Parâmetros** altera os valores; nota e cortes de risco viram proposta e só valem depois da aprovação da coordenação.

| Parâmetro (SRS) | Padrão no SRS | No sistema (`parametros`) | Situação |
|---|---|---|---|
| Nota mínima de aprovação | 6,0 | `NOTA_MINIMA` = 6,0 | Igual. Mudança exige aprovação da coordenação |
| Nota de zona confortável | 8,0 | `NOTA_CONFORTAVEL` = 8,0 | Igual |
| Nota de zona crítica | 4,0 | `NOTA_CRITICA` = 4,0 | Igual |
| Frequência mínima legal | 75% | `FREQUENCIA_MINIMA` = 75 | Igual |
| Frequência confortável / crítica | 90 / 60% | `FREQUENCIA_CONFORTAVEL` = 90, `FREQUENCIA_CRITICA` = 60 | Igual |
| Renda de vulnerabilidade alta | 0,5 SM por pessoa | `RENDA_VULNERAVEL` = 0,5 | Igual |
| Renda de elegibilidade a auxílio | 1,5 SM por pessoa | `RENDA_AUXILIO` = 1,5 | Igual |
| Limite de jornada de trabalho | 20 h/semana | `JORNADA_LIMITE` = 20 | Igual |
| Limite de deslocamento | 60 min/trajeto | `DESLOCAMENTO_LIMITE` = 60 | Igual |
| Janela de inatividade no AVA | 21 dias | `AVA_DIAS_SEM_ACESSO` = 21 | Igual (o B1 não tem dado de AVA; ver seção 5) |
| Cortes de risco | 25 / 50 / 75 | `CORTE_BAIXO` 25, `CORTE_MODERADO` 50, `CORTE_ALTO` 75 | Igual. Mudança exige aprovação da coordenação |
| Completude mínima para calcular | 40% dos pesos | `COMPLETUDE_MINIMA` = 40 | Igual. Entre 40% e 70% o score sai "parcial" (`COMPLETUDE_PLENA` = 70), como no Anexo A |
| Intervalo entre atendimentos | 15 dias | `INTERVALO_ATENDIMENTOS` = 15 | Igual (RN14; Crítico é exceção) |
| Encerramento do chat | 2 horas | `CHAT_INATIVIDADE_MINUTOS` = 120 no `.env` | Valor igual, mas fica no `.env` do chat e não na tabela. Ver seção 6 |
| Tempo máximo de carregamento | 3 s | Não é parâmetro; é meta de desempenho | Ainda sem medição formal; ver o tempo de cada requisição em `logs/api.log` (requisições acima de 2 s viram aviso) |
| Tamanho da matrícula | 7 dígitos | Validação aceita 7 dígitos ou o formato do B1 `ALU0000` | O banco do B1 usa `ALU0001` a `ALU1000` (7 caracteres, não 7 dígitos) |
| Teto de alertas abertos por responsável | 30 (a confirmar na Sprint 1) | `TETO_ALERTAS_RESPONSAVEL` = 30 | Igual; segue marcado como "a confirmar" |

Parâmetros que o sistema tem a mais, todos tirados de outros trechos do SRS: `RENDA_EXTREMA` 0,25 e `RENDA_UM_SM` 1,0 (faixas do I5, Anexo A), `SALARIO_MINIMO` R$ 1.621,00, `SLA_CRITICO_HORAS` 48, `SLA_ALTO_DIAS_UTEIS` 5, `SLA_DADOS_DIAS_UTEIS` 10 e `MINIMO_GRUPO` 5 (RN07, CA19).

**A confirmar com o grupo:** o salário mínimo de 2026 foi lançado como R$ 1.621,00. Se o decreto do ano tiver outro valor, basta trocar em Administração → Parâmetros; o recálculo é automático.

## 2. Pesos dos indicadores (Anexo A)

| Indicador | Peso SRS | No sistema |
|---|---|---|
| I1 Desempenho acadêmico | 0,20 | 0,20 |
| I2 Frequência | 0,18 | 0,18 |
| I5 Situação financeira | 0,11 | 0,11 |
| I3 Reprovação acumulada | 0,09 | 0,09 |
| I4 Engajamento no AVA | 0,08 | 0,08 |
| I8 Saúde mental | 0,08 | 0,08 |
| I6 Trabalho | 0,07 | 0,07 |
| I7 Deslocamento | 0,05 | 0,05 |
| I9 Saúde física | 0,05 | 0,05 |
| I10 Moradia | 0,05 | 0,05 |
| I11 Dependentes | 0,04 | 0,04 |
| **Soma** | **1,00** | **1,00** |

Os pesos não são editáveis pela tela (`editavel = false`), porque o SRS só permite mudá-los com nova versão do modelo.

## 3. Fórmulas

- **Média (M):** ponderada pela carga horária, `soma(nota × CH) / soma(CH)` (SRS B.2.1). Está em `app/calculo/indicadores.py` (`calcular_media_ponderada`) e em `sql/b1_recalculo_indicadores.sql`, que recalcula `indicadores_academicos.media_atual` a partir das disciplinas. O portal do aluno usa a mesma regra.
- **Frequência:** o SRS (B.2.2) define faltas ÷ aulas previstas. O B1 só traz o percentual por disciplina, então o sistema pondera esse percentual pela carga horária, que é a proporção das aulas. Fica documentado como aproximação até chegar o dado de aulas previstas.
- **Escala das notas:** 0 a 10 (o dump do B1 vinha de 0 a 100; `sql/b1_correcoes.sql` converte).
- **Score:** soma ponderada dos indicadores presentes, renormalizada pela completude, com os modificadores M1 a M5 e as sobreposições do Anexo A (`app/calculo/score.py`, versão de código 3.0, modelo `deterministico-v1.1`). Cada score guarda a versão dos parâmetros usada.
- **Níveis:** 0–25 Baixo, 26–50 Moderado, 51–75 Alto, 76–100 Crítico. Completude abaixo de 40% dá Indeterminado e abre tarefa de correção de dados com prazo de 10 dias úteis.
- **Prazos:** Crítico 48 horas, Alto 5 dias úteis (sábado e domingo não contam; feriados ainda não estão cadastrados).
- **Fila de alertas:** Crítico antes de Alto, depois prazo, depois score decrescente e tendência (SRS, RF07).

## 4. Resultado na base atual

Com a base do B1 recalculada, a distribuição é: Alto 506, Crítico 493, Moderado 1 (média geral 3,46; frequência média 66,6%). O número alto de alunos em risco vem dos dados, não da fórmula: no B1, 5.400 das 6.000 matrículas estão "Reprovado". Quando a base real chegar, a distribuição muda sozinha.

## 5. O que o SRS pede e a base não tem

O sistema mostra "sem dado" nesses casos e nunca inventa número:

- Acesso ao AVA (I4), atividades entregues e evolução semanal.
- Faltas restantes por disciplina (RF17): falta o total de aulas previstas.
- Eficácia das intervenções e evasão real: dependem de desfechos registrados ao longo do semestre.

## 6. Pendências

- **Exportação XLSX e PDF:** o painel exporta CSV (com proteção contra fórmulas). XLSX e PDF não foram feitos.
- **Tela "Meu nível" do aluno (Figma):** ficou de fora por decisão pendente do grupo; o aluno vê a situação, nunca o número do score na tela (RN17).
- **Encerramento do chat:** o valor de 2 horas fica no `.env` do serviço de chat (`CHAT_INATIVIDADE_MINUTOS`), não na tabela de parâmetros. Funciona, mas a mudança não fica versionada como as outras. Passar para a tabela é uma migração simples (ver `docs/05_EVOLUCAO_E_DIAGNOSTICO.md`).
- **Notificação por e-mail (T24):** as notificações são internas, dentro do sistema. O envio por e-mail precisa de um servidor de e-mail da instituição.
- **Backup diário (T27):** não há rotina automática; o passo a passo manual está em `docs/04_USO_LOCAL_E_TESTES.md`.
