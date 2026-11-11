# MUFASA — a parte de cada integrante

Este documento junta duas fontes: o que o Plano de Construção v1.1 atribui a cada integrante e o que de fato chegou para a integração. Para cada parte há o que foi feito, o que foi usado e como foi construído.

> **Autoria confirmada pelo João em 28/10/2026:** B1 (banco) é de Samuel, B2 (cálculo e score) é de Susyanne e B3 (API e segurança) é de João Victor. Essa divisão difere da prevista no Plano v1.1 (seção 1). Vale o que foi confirmado: a seção 2 mostra quem fez cada parte.

## 1. Divisão prevista no Plano v1.1

| Integrante | Papel Scrum | Frente | Atividades do Plano |
|---|---|---|---|
| Susyanne Sanne Souza Inácio | Product Owner | Grupo 2 — regras de negócio e prioridades | T03, T18, T22, T24, T25 |
| João Victor Lúcio Luna de Oliveira | Scrum Master | Grupo 1 — ritmo das sprints e impedimentos | T01, T02, T19, T23, T27 |
| Gabriel Farinha de Bastos | Developer | Grupo 1 — banco de dados | T04, T07, T15 |
| Davi dos Santos Xavier Gomes | Developer | Grupo 1 — análise de dados e score de risco | T08, T09, T16, T26 |
| Dérik Sousa Silva | Developer | Grupo 1 — API e back-end | T10, T11, T13, T20 |
| Eduardo Borges Souza Rodovalho | Developer | Grupo 2 — painel e front-end | T05, T12, T14 |
| Samuel Sampaio Oliveira Lima | Developer | Grupo 2 — chatbot e integração | T06, T17, T21 |

## 2. O que chegou para a integração

| Entrega | Conteúdo | Feita por | Previsto no Plano |
|---|---|---|---|
| "Parte Samuel BackEnd B1" | Dump PostgreSQL com 1.000 alunos | **Samuel** (confirmado) | Gabriel (T04, T07) |
| "B2 Susy" | Módulo de cálculo e score v2.2, 41 testes | **Susyanne** (confirmado) | Davi (T08, T09) |
| B3 — João | API, login, perfis, auditoria, LGPD | **João Victor** (confirmado) | Dérik (T10, T11, T13, T20) e João (T19) |
| "Parte Eduardo" | Chatbot em FastAPI com Groq | Eduardo (pelo nome da entrega) | Samuel (T17, T21) |
| F1 — repositório daviXvier/MUFASA e Figma | Painel em Streamlit e protótipo com 82 telas | repositório de Davi (daviXvier) | Eduardo (T05, T12, T14) |

Os originais de cada entrega estão em `integrado/originais/`, sem alteração.

## 3. Cada parte: o que foi feito, usado e construído

### B1 Banco de dados — Samuel Sampaio Oliveira Lima

- **O que foi feito:** base com 1.000 alunos simulados do curso de Inteligência Artificial, com disciplinas, turmas, matrículas, notas parciais (VA1 a VA3), frequência, indicadores acadêmicos e contexto socioeconômico.
- **O que foi usado:** PostgreSQL, entregue como dump `pg_dump`.
- **Como foi construído:** tabelas sem chaves, notas de 0 a 100, dados de saúde dentro da tabela de alunos.
- **O que a integração acrescentou:**
  - remoção de 2.000 linhas órfãs;
  - chaves primárias e estrangeiras, datas como DATE e restrições de faixa;
  - notas convertidas para 0 a 10;
  - dados de saúde movidos para uma tabela cifrada;
  - indicadores recalculados das disciplinas.
  
  Arquivos: `sql/b1_limpeza_sobras.sql`, `sql/b1_correcoes.sql`, `sql/b1_recalculo_indicadores.sql`.

### B2 Cálculo e score — Susyanne Sanne Souza Inácio

- **O que foi feito:** os 11 indicadores, pesos, faixas, completude, sobreposição por frequência e explicação dos fatores.
- **O que foi usado:** Python puro, sem banco, com 41 testes em pytest.
- **Como foi construído:** funções puras em `indicadores.py` e `score.py`. A versão 2.2 corrigiu a escala invertida (0 = seguro, 100 = risco máximo).
- **O que a integração acrescentou:**
  - reescrita para seguir o Anexo A do SRS v1.1 (curvas, modificadores M1 a M5, completude parcial, frases da RN04);
  - parâmetros lidos da tabela versionada;
  - serviço de cálculo separado que recalcula pela fila.
  
  Arquivos: `app/calculo/`, `app/servico_calculo/`.

### B3 API e segurança — João Victor Lúcio Luna de Oliveira

- **O que foi feito:**
  - API REST `/api/v1`;
  - login com JWT e bcrypt, bloqueio após 5 falhas;
  - perfis do Anexo E e verificação de escopo contra acesso indevido;
  - trilha de auditoria que não pode ser alterada;
  - limite de requisições e cabeçalhos de segurança;
  - documentos LGPD e auditorias de segurança, acessibilidade e conteúdo.
- **O que foi usado:** FastAPI, Pydantic, SQLAlchemy (só SQL com parâmetros nomeados), PyJWT, bcrypt e PostgreSQL com um usuário de banco por serviço.
- **Como foi construído:**
  - configuração só por `.env`;
  - todo o SQL em `consultas*.py`;
  - erros padronizados, sem pilha nem SQL na resposta;
  - testes que reprovam SQL montado com texto.
  
  Arquivos: `app/api/`, `sql/b3_complemento.sql`, `docs/AUDITORIA_*.md` e `docs/POLITICA_*.md`.

### Chatbot — entrega "Parte Eduardo"

- **O que foi feito:** assistente em linguagem natural que responde sobre notas, frequência e situação.
- **O que foi usado:** FastAPI, Groq (modelo `openai/gpt-oss-20b`) e SQLite próprio.
- **Como foi construído:** o modelo gerava a resposta livremente a partir dos dados do aluno.
- **O que a integração mudou:**
  - o chat passou a usar o login e os perfis da API;
  - só lê visões próprias do PostgreSQL;
  - responde por 24 intenções fechadas;
  - a IA só redige texto com marcadores e o servidor preenche os números reais;
  - nenhum dado pessoal sai para a Groq.
  
  Arquivos: `app/chatbot/`, `app/main_chat.py`, `sql/chatbot.sql`, `docs/AUDITORIA_CHATBOT.md`.
- **Pendência de segurança:** a chave da Groq que veio no arquivo compartilhado precisa ser revogada pelo dono da conta.

### Painel — F1 (Streamlit e Figma)

- **O que foi feito:**
  - painel em Streamlit (`app.py`) com gráficos e filtros;
  - protótipo no Figma com 82 telas: login, termo LGPD, painéis de Coordenação e Gestão, fila de alertas, ficha do aluno, docente, portal do aluno e administração.
- **O que foi usado:** Streamlit, Plotly e pandas, lendo arquivos CSV. Figma com a paleta mostarda (`#C99720`) e a fonte Inter.
- **Como foi construído:** o `app.py` lia CSVs direto, sem login.
- **O que a integração mudou:**
  - painel reescrito para consumir só a API;
  - hub por perfil e seletor de perfil no login;
  - gráficos que se atualizam sozinhos com os dados do banco;
  - isolamento de cada seção;
  - cores de Crítico e Alto definidas pelo João.
  
  Arquivos: `painel/`.

### Integração, testes e operação

- **O que foi feito:**
  - junção de todas as partes;
  - 201 testes num banco de teste;
  - teste no navegador com todos os perfis;
  - instalação local e por Docker;
  - registros, diagnóstico, migrações e esta documentação.
- **Atividades do Plano cobertas:** T01 (ambiente e contêiner), T19 (cifra e auditoria), T23 (testes ponta a ponta) e parte de T27 (degradação controlada; o backup automático ainda falta).

## 4. Atividades do Plano que ainda não têm entrega

| Atividade | O que falta |
|---|---|
| T03 Fechamento das regras com a coordenação | Validar os parâmetros do Anexo C com a coordenação. O sistema já usa os valores padrão do SRS |
| T18 Redação das mensagens | Revisão final dos textos pela PO (os textos atuais estão em `docs/REVISAO_DE_CONTEUDO.md`) |
| T22 Validação CA01 a CA20 | Registrar a evidência de cada critério. Os testes já cobrem vários, por exemplo CA19 e CA20 |
| T24 Notificação por e-mail | As notificações são internas; o e-mail depende do servidor da instituição |
| T25 Apresentação | — |
| T27 Backup diário | O passo a passo manual está no documento 04 |
