# Auditoria de Acessibilidade — MUFASA

27/10/2026 · Referência: WCAG 2.1 nível AA (exigido pelo SRS, Seção 3.1) e RN10 (linguagem acessível).

## Escopo e limite

Ainda não existe painel (F1) nem chatbot (F2). Esta auditoria cobre o que já existe e chega ao usuário final: **os textos que a API devolve** (mensagens de erro, explicação do score, recomendações, aviso metodológico) e o componente `docs/aviso-armazenamento.html`. Para o painel, há um checklist ao final, a ser aplicado pelo F1 e conferido pelo F3.

## Achados

| # | Severidade | Onde | Problema | Critério | Situação |
|---|---|---|---|---|---|
| A-1 | Alta | B2, `score.py`: `RECOMENDACOES`, `ROTULOS` e `explicar_score` | Textos sem acento ("nivel", "frequencia", "saude", "ate"). Leitor de tela pronuncia errado ("saúde" vira "sáude"), e o texto parece erro para quem lê | WCAG 3.1 (legível), RN10 | **Sugestão para o B2**, abaixo |
| A-2 | Média | B2, `score.py`, linha 451 | "Restam 1 faltas" | RN10 | Sugestão para o B2 |
| A-3 | Média | B2, `explicar_score` | "Score 66 de 100" usa termo em inglês para quem não é da área técnica | WCAG 3.1.3 (palavras incomuns), RN10 | Sugestão: "Pontuação de risco: 66 de 100" |
| A-4 | Média | Validação de entrada da API | Mensagens do Pydantic em inglês ("String should have at least 3 characters") | WCAG 3.3.1 e 3.3.3 | **Corrigido no B3**: mensagens em português em `app/api/erros.py` |
| A-5 | Média | Mensagens de erro do B3 | Escritas sem acento na primeira versão | WCAG 3.1, RN10 | **Corrigido no B3** |
| A-6 | Média | Sessão de 30 minutos | Expirar sem aviso tira do usuário o que ele estava fazendo, o que pesa mais para quem usa leitor de tela ou digita devagar | WCAG 2.2.1 (tempo ajustável) | Pendente: o painel deve avisar aos 25 minutos com opção de continuar; o B3 precisa de um `POST /auth/renovar` |
| A-7 | Baixa | Nível de risco | A API devolve o nível como texto (`ALTO`), nunca só como cor ou número, o que permite ao painel cumprir a regra "nunca só por cor" do SRS | WCAG 1.4.1 | Atendido no B3; F1 deve exibir rótulo e ícone junto da cor |
| A-8 | Baixa | Bloqueio de login | A mensagem diz quantas tentativas levam ao bloqueio e quanto tempo ele dura, e a resposta 429 traz `Retry-After` | WCAG 3.3.1 e 3.3.3 | Atendido no B3 |

### Correção sugerida para o B2 (A-1, A-2, A-3)

```python
RECOMENDACOES = {
    "BAIXO": "Monitoramento periódico.",
    "MODERADO": "Atenção preventiva da tutoria.",
    "ALTO": "Contato em até 5 dias úteis.",
    "CRITICO": "Busca ativa imediata pela coordenação e pelo núcleo de apoio, em até 48 horas.",
    "INDETERMINADO": "Dados insuficientes para avaliar. Completar o cadastro antes de classificar.",
}

ROTULOS = {
    "notas": "desempenho acadêmico", "frequencia": "frequência", "financeiro": "situação financeira",
    "reprovacao": "histórico de reprovações", "engajamento_ava": "participação no ambiente virtual",
    "saude_mental": "saúde mental", "trabalho": "jornada de trabalho", "deslocamento": "tempo de deslocamento",
    "saude_fisica": "saúde física", "moradia": "situação de moradia", "dependentes": "dependentes sob cuidado",
}

# em explicar_score:
texto = f"Pontuação de risco: {resultado['score']} de 100. Nível {NOMES_NIVEL[resultado['nivel']]}. "
...
if restantes == 1:
    texto += " Resta 1 falta antes do limite."
elif restantes:
    texto += f" Restam {restantes} faltas antes do limite."
```

Os códigos (`CRITICO`, `saude_mental`) continuam sem acento: são identificadores. Só o texto mostrado a pessoas muda. O teste `test_contrato_de_saida_tem_todas_as_chaves` do B2 não é afetado, porque as chaves não mudam.

## Componente `aviso-armazenamento.html`

Verificado contra WCAG 2.1 AA:

| Critério | Como o componente atende |
|---|---|
| 1.3.1 Informação e relações | `role="region"` com `aria-labelledby`; opções futuras em `fieldset`/`legend` com `label` em cada caixa |
| 1.4.3 Contraste (texto) | Tema claro: texto 17,4:1, link e botão 8,4:1. Tema escuro: texto 15,2:1, botão 10,6:1 |
| 1.4.11 Contraste (não texto) | Bordas 6,7:1 (claro) e 7,0:1 (escuro); anel de foco 4,8:1 e 9,7:1 |
| 1.4.4 e 1.4.10 Zoom e refluxo | Unidades relativas, quebra de linha nos botões, funciona em 320 px |
| 2.1.1 Teclado | Tudo é `button` ou link nativo; Esc fecha o aviso informativo |
| 2.4.3 Ordem do foco | O foco vai ao primeiro botão ao abrir e volta ao elemento anterior ao fechar |
| 2.4.7 Foco visível | `:focus-visible` com contorno de 3 px |
| 2.5.5 Tamanho do alvo (AAA, adotado) | Botões com no mínimo 44 × 44 px |
| 2.3.3 Movimento | Respeita `prefers-reduced-motion` |
| 3.1.1 Idioma | `lang="pt-BR"` |

## Checklist para o painel (F1) e o chatbot (F2)

Aplicar em cada tela antes de considerar a tarefa pronta:

- [ ] `lang="pt-BR"` na página; títulos (`h1`, `h2`) em ordem, sem pular nível
- [ ] Todo campo de formulário com `<label>` visível; erro ligado ao campo por `aria-describedby`
- [ ] Nível de risco com rótulo em texto e ícone, além da cor
- [ ] Contraste de 4,5:1 no texto e de 3:1 em bordas, ícones e gráficos (conferir com o Colour Contrast Analyser)
- [ ] Tudo operável só pelo teclado, com foco visível e sem armadilha de foco
- [ ] Gráficos com tabela equivalente ou texto alternativo que traga os números
- [ ] Tabelas de alunos com `<th scope="col">` e `<caption>`
- [ ] Aviso de sessão expirando com pelo menos 20 segundos para responder (WCAG 2.2.1)
- [ ] Respostas do chatbot em região `aria-live="polite"`
- [ ] Zoom de 200% sem perder conteúdo nem gerar rolagem horizontal
- [ ] Teste real com NVDA (Windows) ou VoiceOver (macOS/iOS), além de uma ferramenta automática (axe DevTools ou Lighthouse). Ferramenta automática sozinha encontra só parte dos problemas.
- [ ] Linguagem simples: frases curtas, sem sigla sem explicação, sem jargão técnico para o aluno
