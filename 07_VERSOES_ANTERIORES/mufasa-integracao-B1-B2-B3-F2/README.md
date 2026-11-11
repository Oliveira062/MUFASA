# MUFASA — Sistema integrado (B1 + B2 + B3 + F2)

API do sistema de alerta precoce de evasão. Este pacote junta o módulo de cálculo do B2 (sem alteração), o banco do B1 (lido, não alterado), a camada B3 de API e segurança e o chatbot do F2, reescrito para funcionar dentro da API.

O painel (F1) ainda não foi entregue. Ele vai consumir esta mesma API; os requisitos estão em `docs/AUDITORIA_CHATBOT.md`, seção F1. Os originais de cada parte estão em `../originais/`, sem alteração.

## Como rodar

```bash
python -m venv venv && source venv/bin/activate      # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Banco: dump do B1 e depois o complemento do B3, como dono do banco
psql -d mufasa -f "../banco/Parte Samuel BackEnd B1 - limpo.sql"   # dump do B1 sem as sobras de importação
psql -d mufasa -f sql/b3_complemento.sql
psql -d mufasa -f sql/chatbot.sql
psql -d mufasa -c "ALTER ROLE mufasa_api PASSWORD 'escolha-uma-senha-forte'"
psql -d mufasa -c "ALTER ROLE mufasa_chat PASSWORD 'outra-senha-forte'"

cp .env.example .env        # preencher JWT_SECRET, DATABASE_URL, CHAT_DATABASE_URL e SALARIO_MINIMO
                            # GROQ_API_KEY é opcional: sem ela o chat usa os textos prontos
DATABASE_URL_ADMIN=postgresql+psycopg://postgres:...@localhost/mufasa \
  python -m scripts.criar_usuario --login ALU0001 --perfil ALUNO --aluno ALU0001

uvicorn app.main:app --reload
```

Testes (não precisam de PostgreSQL nem de internet): `pytest -v` → 79 testes (38 da API e 41 do chatbot).

## Estrutura

```
app/
├── main.py              cria o app; HTTPS, hosts permitidos, CORS, cabeçalhos
├── config.py            configuração só por variável de ambiente; sem segredo padrão
├── calculo/             módulo do B2 v2.2, copiado sem alteração
├── chatbot/             F2, dentro da API (mesmo login, perfis e escopo)
│   ├── rotas_chat.py    /api/v1/chat/abertura, /consultas, /historico, /encerrar
│   ├── intencoes.py     catálogo fechado de 24 intenções e classificação por regras
│   ├── servico.py       executa a intenção com o escopo do usuário; monta dados e rascunho
│   ├── redacao.py       texto humanizado pela IA com marcadores, sem dado pessoal; conferência
│   ├── ia.py            cliente HTTP da Groq (opcional)
│   ├── conversa.py      encerramento por inatividade (RN13) e histórico
│   ├── consultas_chat.py TODO o SQL do chatbot, só sobre as visões vw_chat_*
│   ├── texto.py         normalização, remoção de CPF/e-mail/telefone/matrícula
│   ├── banco_chat.py    conexão com o perfil mufasa_chat
│   ├── config_chat.py   configuração por variável de ambiente
│   └── esquemas_chat.py contratos de entrada e saída
└── api/
    ├── rotas.py         endpoints
    ├── auth.py          bcrypt, JWT, usuário atual, exigir_perfis
    ├── permissoes.py    perfis do Anexo E, escopo por aluno (anti-IDOR), ocultação de fatores
    ├── consultas.py     TODO o SQL, só com parâmetros nomeados
    ├── integracao.py    ponte B1 → B2 (conversão de unidade e descarte de valor impossível)
    ├── esquemas.py      contratos Pydantic de entrada e saída
    ├── erros.py         erro padronizado, sem pilha nem SQL
    ├── auditoria.py     trilha de acesso em transação própria
    ├── seguranca.py     cabeçalhos, limite de requisições e de tamanho
    └── banco.py         conexão (usuário mufasa_api)
sql/b3_complemento.sql   tabelas do B3, perfis de banco, auditoria imutável
sql/chatbot.sql          visões do chatbot, histórico e permissões do mufasa_chat
sql/b1_limpeza_sobras.sql remove as 2.000 sobras de importação de quem já carregou o dump original
scripts/criar_usuario.py cria usuário com senha digitada sem eco
testes/teste_api.py      38 testes da API
testes/teste_chatbot.py  41 testes do chatbot
docs/                    políticas LGPD, aviso de armazenamento, auditorias
```

## Endpoints

| Método | Rota | Perfis |
|---|---|---|
| GET | `/saude` | Público |
| POST | `/api/v1/auth/token` | Público (matrícula ou login + senha) |
| POST | `/api/v1/auth/sair` | Autenticado |
| GET | `/api/v1/alunos` | Docente, Coordenação, Núcleo de apoio |
| GET | `/api/v1/alunos/{matricula}` | Aluno (só o próprio), Docente, Coordenação, Núcleo, Financeiro, com campos conforme o perfil |
| GET | `/api/v1/alunos/{matricula}/score` | Aluno (só o próprio), Docente, Coordenação, Núcleo |
| GET | `/api/v1/alunos/{matricula}/historico` | Idem |
| GET | `/api/v1/indicadores/agregados` | Coordenação (do curso), Direção; grupos < 5 suprimidos |
| GET | `/api/v1/privacidade/meus-dados` | Aluno |
| GET · POST | `/api/v1/privacidade/consentimentos` | Aluno |
| POST | `/api/v1/privacidade/solicitacoes` | Aluno (direitos do art. 18 e revisão do art. 20) |
| GET | `/api/v1/privacidade/solicitacoes` | Encarregado de dados |
| GET | `/api/v1/auditoria` | Encarregado de dados |
| GET | `/api/v1/chat/abertura` | Autenticado (mensagem de abertura e horário do atendimento humano) |
| POST | `/api/v1/chat/consultas` | Autenticado; os dados respeitam o escopo de cada perfil |
| GET | `/api/v1/chat/historico` | Autenticado (só o próprio histórico) |
| POST | `/api/v1/chat/encerrar` | Autenticado |

A rota de score segue o SRS (`/score`), não o exemplo `/risco` do guia.

## Decisões tomadas neste pacote

- **Segundo fator do aluno:** matrícula + senha com bcrypt custo 12. É o mecanismo mais simples previsto na RN12. Trocar por código no e-mail ou login único depois não muda as rotas.
- **Matrícula:** aceita 7 dígitos (SRS) ou `ALU0000` (banco simulado do B1). Remover o segundo formato quando o B1 migrar.
- **Núcleo de apoio e financeiro:** enquanto não existe o módulo de alertas, "aluno com alerta" = aluno do mesmo curso cuja última avaliação é Alto ou Crítico.
- **Fatores ausentes no B1:** saúde, moradia, dependentes, AVA, taxa de reprovação e aulas previstas não existem no banco. Ficam ausentes (o B2 os exclui da conta) e a resposta lista quais são em `dados_ausentes`.
- **Horas de trabalho:** `horas_trabalho_dia × 5`. Confirmar com o B1.

## Documentos

| Arquivo | Conteúdo |
|---|---|
| `docs/AUDITORIA_SEGURANCA.md` | Auditoria de B1, B2 e B3 (OWASP Top 10, autenticação, validação, segredos, dependências, LGPD) |
| `docs/AUDITORIA_CHATBOT.md` | Auditoria do F2 e da integração (OWASP Top 10, OWASP LLM Top 10, LGPD, cookies, acessibilidade, conteúdo) e requisitos do painel F1 |
| `docs/AUDITORIA_ACESSIBILIDADE.md` | WCAG 2.1 AA nos textos da API e no aviso; checklist para o F1 e o F2 |
| `docs/REVISAO_DE_CONTEUDO.md` | Avaliações falsas e afirmações sem comprovação |
| `docs/POLITICA_DE_PRIVACIDADE.md` | Minuta da política de privacidade |
| `docs/TERMOS_DE_USO.md` | Minuta dos termos de uso |
| `docs/POLITICA_DE_COOKIES.md` | Política de cookies e orientações ao F1 |
| `docs/CONSENTIMENTO_DADOS_SAUDE.md` | Texto e fluxo do consentimento de saúde |
| `docs/aviso-armazenamento.html` | Componente acessível do aviso de armazenamento |

## Decisões do chatbot

- **Intenções fechadas:** a pergunta é classificada por regras; a IA nunca escolhe a consulta nem o escopo (RN06).
- **IA só para o tom:** a Groq recebe um rascunho com marcadores (`[[NIVEL]]`) e sinais sem identificação. Ela não recebe nome, matrícula, nota, frequência nem a pergunta digitada. Resposta com número inventado ou marcador faltando é descartada.
- **Sem invenção:** sem dado no banco, a resposta diz que não há dado. As notas aparecem exatamente como estão no B1, inclusive os zeros, com a escala (0 a 100 nas disciplinas, 0 a 10 na média geral).
- **Classificação pela IA desligada** (`CHAT_IA_CLASSIFICAR=false`): é o único caso em que o texto digitado (redigido) sairia do servidor.

## Pendências

- [ ] B1: aplicar as sugestões 1.1-C, 2.3-A, 4.5-D, L-1 e L-2 da auditoria
- [ ] B2: aplicar 4.4-A, 4.5-A, 4.5-B, 4.5-C, A-1 a A-3 e C-1 a C-6
- [ ] B3: `POST /auth/renovar` (aviso de sessão, WCAG 2.2.1), limitador em Redis para produção, rotas da Sprint 3 em diante (importações, alertas, agendamentos)
- [ ] Encarregado de dados: definir as bases legais marcadas entre colchetes na política de privacidade
- [ ] Confirmar o valor do salário mínimo vigente para `SALARIO_MINIMO`
- [ ] **Eduardo: revogar a chave da Groq que estava no `.env` (C-0) e gerar uma nova para o projeto**
- [x] Sobras de importação: as 2.000 matrículas sem aluno foram removidas (aprovado pelo João em 28/10/2026)
- [ ] Samuel e João: decidir sobre os indicadores que não acompanham as matrículas e sobre os cortes de nível do B1 (C-B1)
- [ ] Encarregado de dados: fornecedor de IA e prazo do histórico do chat na política de privacidade
- [ ] Instituição: preencher `CHAT_JANELA_ATENDIMENTO` com o horário real do atendimento humano
- [ ] F1: entregar o painel e passar pela lista P-1 a P-12 de `docs/AUDITORIA_CHATBOT.md`
