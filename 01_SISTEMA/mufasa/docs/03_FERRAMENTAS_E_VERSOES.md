# MUFASA — ferramentas e versões

Versões com que o sistema foi montado e testado em 28/10/2026. As versões exatas dos pacotes Python ficam em `requirements.lock`. As mínimas aceitas ficam em `requirements.txt`, que serve para atualizar.

## 1. Programas que precisam estar na máquina

| Ferramenta | Versão testada | Mínima | Para que serve |
|---|---|---|---|
| Python | 3.13.17 | 3.11 (testado só na 3.13; use a 3.13) | Linguagem de todo o sistema: API, chat, cálculo, painel e scripts |
| PostgreSQL | 16.15 | 16 | Banco de dados. O dump do B1 foi gerado na versão 16 |
| pip | o que vem com o Python | — | Instala os pacotes |
| Navegador | Chrome, Edge ou Firefox atual | — | Abre o painel em `http://127.0.0.1:8501` |

**Opcionais:**

| Ferramenta | Versão testada | Para que serve |
|---|---|---|
| Docker Engine / Docker Desktop | 29.9.2 | Rodar tudo em containers, sem instalar Python nem PostgreSQL |
| Docker Compose | v5.6.1 (plugin `docker compose`) | Sobe os 6 containers juntos |
| Imagem `postgres:16` | 16 | Banco dentro do Docker |
| Imagem `python:3.13-slim` | 3.13 | Base da imagem `mufasa:1.1.0` |
| Git | qualquer | Controle de versão do código |
| Node.js + Playwright | 22.22.0 + 1.63.0 | Só para repetir o teste de navegador. Não é preciso para usar o sistema |
| pgAdmin ou DBeaver | qualquer | Olhar o banco com interface gráfica |

## 2. Pacotes Python (`requirements.lock`)

| Pacote | Versão | Onde é usado | Para que serve |
|---|---|---|---|
| fastapi | 0.162.0 | API e chat | Framework das rotas, validação e documentação em `/docs` |
| starlette | 1.7.0 | API e chat | Base do FastAPI (a versão 0.40 ou mais nova corrige a CVE-2024-47874) |
| uvicorn[standard] | 0.54.0 | API e chat | Servidor HTTP que roda o FastAPI |
| pydantic | 2.13.5 | API, chat e cálculo | Contratos de entrada e saída, validação |
| pydantic-settings | 2.16.1 | Configuração | Lê o `.env` |
| python-multipart | 0.0.32 | API | Recebe o upload das cargas de dados |
| SQLAlchemy | 2.1.6 | API, chat e cálculo | Conexão e SQL com parâmetros nomeados (`text()`) |
| psycopg[binary] | 3.2.10 | Todos e os scripts | Driver do PostgreSQL; também monta o banco sem o `psql` |
| PyJWT | 2.15.0 | API e chat | Token de login (HS256) |
| bcrypt | 5.0.0 | API | Hash das senhas (custo 12) |
| cryptography | 50.0.1 | API e scripts | Cifra Fernet dos dados de apoio (LGPD art. 11) |
| httpx | 0.28.1 | Painel e chat | Cliente HTTP do painel para a API; chamada opcional à Groq |
| streamlit | 1.50.0 | Painel | Interface web |
| plotly | 6.3.1 | Painel | Gráficos |
| pandas | 2.3.3 | Painel | Tabelas e exportação CSV |
| pytest | 9.2.0 | Testes | Executa os 201 testes |
| pip-audit | 2.7 ou mais nova | Manutenção | Procura falhas conhecidas nos pacotes |

Dependências que vêm junto, nas versões testadas: numpy 2.5.3, pyarrow 26.0.0, altair 5.5.0, tornado 6.6, anyio 4.15.1, click 8.5.0, Jinja2 3.1.6, requests 2.34.2, protobuf 6.33.6 e pillow 11.3.0.

Recursos visuais do painel, que vêm junto no projeto (sem download na hora do uso):

| Recurso | Versão | Onde | Para quê |
|---|---|---|---|
| Fonte Inter | 4.0, subconjunto latino em WOFF2, convertida para TrueType com hinting (ttfautohint) para ficar nítida no Windows (licença OFL 1.1) | `painel/static/fontes/` | Fonte do Figma em todas as telas |
| Ícones Lucide | exportados do arquivo do Figma | `painel/icones.json` | Ícones do menu, dos selos, dos cartões e dos botões |
| Logo do MUFASA | do arquivo do Figma | `painel/static/logo.png` | Menu lateral, login e ícone da aba |

## 3. Serviço externo (opcional)

| Serviço | Modelo | Uso |
|---|---|---|
| Groq | `openai/gpt-oss-20b` | Redige as respostas do chat com mais naturalidade. Sem a chave `GROQ_API_KEY`, o chat usa respostas prontas e nada sai da máquina. Com a chave, conversa de forma mais livre e recebe a pergunta anonimizada. O texto enviado não leva nome, CPF, matrícula, e-mail, telefone nem números, e perguntas sobre saúde não saem do servidor |

## 4. Componentes do próprio sistema

| Componente | Versão | Onde ver |
|---|---|---|
| Sistema MUFASA | 1.1.0 | `app/__init__.py`, em `/saude` e na tela de serviços do Admin |
| Modelo de score | `deterministico-v1.1`, código 3.0 | `app/calculo/score.py`; cada score guarda a versão |
| Parâmetros | versão 1 (sobe a cada alteração aprovada) | Administração → Parâmetros; tabela `parametros_versoes` |
| Migrações do banco | 002 | `sql/migracoes/`, `python -m scripts.migrar --listar` |
| Termo de consentimento de dados de saúde | 1.0 | `docs/CONSENTIMENTO_DADOS_SAUDE.md` |

## 5. Portas usadas

| Porta | Serviço | Acesso |
|---|---|---|
| 5432 | PostgreSQL | só a máquina local |
| 8000 | API (`/api/v1`, `/saude`, `/docs`) | `127.0.0.1` |
| 8001 | Chat | `127.0.0.1` |
| 8501 | Painel | `127.0.0.1`. É o endereço que se abre no navegador |

Os serviços escutam só em `127.0.0.1`, então outros computadores da rede não acessam. Para liberar na rede, ver `04_USO_LOCAL_E_TESTES.md`, seção 8.

## 6. Como atualizar versões com segurança

1. Rodar `pip-audit -r requirements.txt` para ver se algum pacote tem falha conhecida.
2. Num ambiente separado, rodar `pip install -U -r requirements.txt`.
3. Rodar `pytest` (precisa dar 201 aprovados) e `python -m scripts.diagnostico`.
4. Se tudo passar, gravar as novas versões: `pip freeze > requirements.lock`, ou editar só os pacotes que mudaram.
5. Registrar a mudança no `CHANGELOG.md` e subir a versão em `app/__init__.py`.
