# MUFASA — construção do software, do primeiro passo à versão 1.1.0

Este documento conta, em ordem, como o MUFASA foi construído: o que foi feito em cada etapa, por quê, e onde está o resultado no código. Para a parte de cada integrante, ver `02_PARTES_DOS_INTEGRANTES.md`. Para rodar o sistema, ver `04_USO_LOCAL_E_TESTES.md`.

## O que é o MUFASA

Sistema de alerta precoce de evasão para a universidade. Ele lê notas, frequência e contexto socioeconômico de cada aluno, calcula um score de risco explicável (0 a 100), classifica em Baixo, Moderado, Alto ou Crítico, abre alertas com prazo para a equipe agir e registra o acompanhamento até o desfecho. Cada perfil (coordenação, núcleo de apoio, docente, financeiro, gestão, administração técnica, encarregado de dados e o próprio aluno) vê só o que precisa ver, conforme a LGPD.

## Visão geral da arquitetura final

```
            navegador
                │  http://127.0.0.1:8501
        ┌───────▼────────┐
        │  painel (F1)   │  Streamlit; não acessa o banco, só a API
        └──┬──────────┬──┘
           │          │
   ┌───────▼──┐   ┌───▼──────┐
   │ API :8000│   │ chat:8001│   FastAPI; login JWT, perfis, auditoria
   └───────┬──┘   └───┬──────┘
           │          │            serviço de cálculo (sem porta):
           │          │            recalcula scores e alertas pela fila
   ┌───────▼──────────▼──────────────▼───┐
   │ PostgreSQL 16  (um usuário por serviço: │
   │ mufasa_api, mufasa_chat, mufasa_calculo)│
   └──────────────────────────────────────┘
```

Cada parte é um processo separado. Se uma cair, só ela para e é reiniciada; as outras seguem (o painel mostra "indisponível" só na seção afetada).

## Etapa 0 — Leitura dos documentos e plano (22/10/2026)

1. Leitura do guia de construção do back-end (`MUFASA_Guia_Construcao_Backend.pdf`), do SRS v1.1 e do Plano de Construção v1.1.
2. Divisão em blocos: B1 dados e banco, B2 cálculo e score, B3 API e segurança, F1 painel, F2 chatbot.
3. Escrita do README do B3 com os endpoints do SRS (`/api/v1/...`). Decisão: rota `/score` (como no SRS) em vez de `/risco` (como no guia).
4. Normalização da base de 1.000 alunos simulados em tabelas (`banco-evasao/`): curso Inteligência Artificial, 24 professores, 48 disciplinas, 96 turmas, 6.000 matrículas e dados socioeconômicos em tabela separada.

## Etapa 1 — B3: API e segurança, por João Victor (27/10/2026)

1. Projeto FastAPI com configuração lida só do `.env`, sem segredo padrão no código (`app/config.py`). Se faltar `JWT_SECRET` ou `DATABASE_URL`, a API não sobe.
2. Login com senha em bcrypt e token JWT de 30 minutos (`app/api/auth.py`), bloqueio após 5 falhas (RN12), revogação de token ao sair.
3. Perfis do Anexo E do SRS e verificação de escopo em toda consulta de aluno, para um usuário nunca ler aluno fora do seu alcance (`app/api/permissoes.py`).
4. Todo SQL em arquivos de consultas, só com parâmetros nomeados (`app/api/consultas.py`); um teste automático reprova SQL montado com texto variável.
5. Trilha de auditoria que não pode ser apagada nem alterada (`auditoria_acessos`), cabeçalhos de segurança, limite de requisições e de tamanho.
6. Tabelas do B3 e usuários de banco com o mínimo de privilégio (`sql/b3_complemento.sql`).
7. Documentos LGPD: política de privacidade, termos de uso, cookies, consentimento de dados de saúde, e as auditorias de segurança, acessibilidade e conteúdo (`docs/`).

## Etapa 2 — Integração das partes B1, B2 e F2 (28/10/2026)

1. **Banco do B1, de Samuel** (dump PostgreSQL). Foram removidas 2.000 linhas órfãs em `matriculas`, restos da importação, com aprovação do João (`sql/b1_limpeza_sobras.sql`; o dump limpo está em `banco/`).
2. **Correções do B1** (`sql/b1_correcoes.sql`): notas convertidas de 0–100 para 0–10, chaves primárias e estrangeiras, tipos corretos.
3. **Cálculo do B2, de Susyanne**, copiado para `app/calculo/`.
4. **Chatbot do F2** reescrito dentro do sistema, com o mesmo login e os mesmos perfis. Ele só lê visões próprias (`vw_chat_*`, `sql/chatbot.sql`) com o usuário de banco `mufasa_chat`. As respostas usam 24 intenções fechadas. Quando há IA (Groq, opcional), ela só redige o texto com marcadores; o servidor preenche os números reais depois e remove CPF, matrícula, e-mail e telefone antes de enviar qualquer texto para fora.
5. Auditoria do chatbot com os problemas encontrados e as correções (`docs/AUDITORIA_CHATBOT.md`).

## Etapa 3 — Métricas pelo SRS v1.1 (28/10/2026)

1. O SRS v1.1 e o Plano v1.1 passaram a ser a referência obrigatória das métricas.
2. O score foi reescrito conforme o Anexo A (versão de código 3.0): 11 indicadores com as curvas do documento, modificadores M1 a M5, completude parcial entre 40% e 70%, sobreposições e fatores com frases da RN04.
3. Todos os valores do Anexo C.2 foram para a tabela versionada `parametros` (nada fixo no código).
4. Média e frequência dos indicadores recalculadas a partir das disciplinas, ponderadas pela carga horária (`sql/b1_recalculo_indicadores.sql`). Os valores originais do B1 ficam em `b1_indicadores_originais`.
5. Conferência completa em `docs/REVISAO_METRICAS_SRS.md`.

## Etapa 4 — Painel (F1) e sistema modular (28/10/2026)

1. Ponto de partida: o `app.py` em Streamlit do repositório do F1 e o protótipo do Figma com 82 telas (login, termo LGPD, painéis, fila de alertas, ficha do aluno, docente, portal do aluno, administração e encarregado).
2. Problemas do `app.py` original corrigidos: lia CSV direto (sem login), a exportação vazava dados de saúde para a Gestão, havia números fixos inventados, e a "taxa de evasão" era só a soma de Alto e Crítico.
3. Painel reescrito (`painel/`): ele não toca no banco e consome só a API. Tem login com seletor de perfil, troca de senha e aceite do termo no primeiro acesso, e um hub por perfil (`painel/paginas/`).
4. Gráficos em tempo real: as seções atualizam sozinhas (de 15 em 15 ou de 30 em 30 segundos), sempre com os dados do banco.
5. API ampliada para o painel: alertas e ações (`rotas_alertas.py`), painéis agregados com supressão de grupos menores que 5 (`rotas_paineis.py`), portal do aluno (`rotas_aluno.py`), administração (`rotas_admin.py`), conta e notificações (`rotas_conta.py`), cargas de dados com validação prévia (`validacao_carga.py`) e parâmetros com proposta e aprovação.
6. **Serviço de cálculo separado** (`app/servico_calculo/`): gatilhos no banco colocam o aluno numa fila quando um dado muda, e o serviço recalcula score e alertas sem travar a API (`sql/painel.sql`).
7. **Isolamento de falhas:**
   - cada serviço grava um sinal de vida em `servicos_status`;
   - `/saude` responde 503 quando o banco cai;
   - o painel tem um disjuntor (para de insistir num serviço fora do ar);
   - cada seção da tela é isolada (`ui.secao`), então um erro numa parte não derruba a tela.
8. **Contas:** um login para cada um dos 1.000 alunos, com troca de senha no primeiro acesso, e uma conta de demonstração por perfil (`scripts/gerar_contas.py`, `banco/contas_iniciais.sql`).
9. Dados de apoio psicossocial e de acessibilidade cifrados no banco com chave Fernet (`app/api/cifra.py`, `scripts/migrar_apoio.py`).

## Etapa 5 — Cores, ferramentas de evolução e entrega local (28/10/2026)

1. **Cores pedidas pelo João:** Crítico em `#9A4A1E` (vermelho-tijolo) e Alto em `#523E1D` (marrom), nos selos e em todos os gráficos (`painel/ui.py`). Os selos levam também ícone e texto, para quem não distingue cores.
2. **Registros (logs)** em `logs/<serviço>.log`, com rotação, e um código de suporte em todo erro mostrado na tela (`app/registro.py`, `painel/registro_painel.py`).
3. **Diagnóstico:** `python -m scripts.diagnostico` confere tudo e acha um erro pelo código da tela.
4. **Migrações versionadas** (`sql/migracoes/`, `scripts/migrar.py`) e número de versão do sistema (`app/__init__.py`, hoje 1.1.0).
5. **Instalação simples:**
   - `scripts/configurar.py` gera o `.env` com senhas novas;
   - `scripts/montar_banco.py` monta o banco inteiro sem precisar do `psql`;
   - `scripts/iniciar.py` sobe tudo e reinicia o que cair;
   - também roda via Docker (`docker-compose.yml`).
6. **Testes:** 201 testes automáticos rodando num banco PostgreSQL de teste separado (`mufasa_teste`), mais um teste no navegador com todos os perfis.
7. Documentação final: este documento e os de número 02 a 05.

## Como as etapas se ligam no código

| Etapa | Pastas e arquivos principais |
|---|---|
| Banco (B1 + correções) | `banco/`, `sql/b1_*.sql`, `sql/painel.sql` |
| Cálculo (B2 → SRS 3.0) | `app/calculo/`, `app/servico_calculo/` |
| API e segurança (B3) | `app/api/`, `app/fabrica.py`, `app/main.py`, `sql/b3_complemento.sql` |
| Chatbot (F2) | `app/chatbot/`, `app/main_chat.py`, `sql/chatbot.sql` |
| Painel (F1) | `painel/` |
| Operação e evolução | `scripts/`, `sql/migracoes/`, `docker-compose.yml`, `Dockerfile` |
| Testes | `testes/` |
