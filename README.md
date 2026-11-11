# MUFASA

Sistema de alerta precoce de evasão acadêmica. Versão 1.1.0.

O MUFASA calcula um score de risco de evasão para cada aluno, gera alertas para a equipe da instituição e oferece um painel por perfil (aluno, docente, coordenação, núcleo de apoio, financeiro, gestão, encarregado e administração), com um assistente virtual (Mufa) que responde apenas com dados reais do banco.

Próximos passos em [ROADMAP.md](ROADMAP.md).

## Como rodar

Precisa do Docker Desktop instalado (passo a passo em `03_DOCUMENTOS_DO_SISTEMA/06_USO_LOCAL_DOCKER.md`, passo 1).

1. Baixe o repositório e entre na pasta `01_SISTEMA/mufasa`.
2. Se for usar o assistente com IA, copie `groq.env.example` para `groq.env` e preencha `GROQ_API_KEY`. Sem a chave, o assistente responde por regras.
3. **Para ligar:** no Windows, dê duplo clique em `INICIAR_MUFASA.bat`. No macOS ou Linux, rode `./iniciar_mufasa.sh`. Na primeira vez ele cria o `.env`, monta o banco e gera as contas iniciais em `banco/credenciais_iniciais.csv`. Depois abre o painel em http://127.0.0.1:8501.
4. **Para desligar:** `PARAR_MUFASA.bat` ou `./parar_mufasa.sh`. Os dados ficam guardados.

Uso sem Docker e testes: `03_DOCUMENTOS_DO_SISTEMA/04_USO_LOCAL_E_TESTES.md`. Para rodar os testes, `HOSTS_PERMITIDOS` no `.env` precisa incluir `"testserver"`.

## Estrutura

| Pasta | Conteúdo |
|---|---|
| `01_SISTEMA/mufasa/` | O sistema: API (FastAPI), chat, serviço de cálculo, painel (Streamlit), scripts, SQL, migrações, testes e documentação |
| `02_DOCUMENTOS_DO_GRUPO/` | SRS v1.1 e Plano de Construção v1.1, que valem para todas as métricas, e o Guia de Construção do Back-end |
| `03_DOCUMENTOS_DO_SISTEMA/` | Cópia para leitura dos documentos de `mufasa/docs`: construção, partes dos integrantes, ferramentas, uso local e Docker, evolução, auditorias, revisão das métricas, privacidade, termos, cookies e consentimento |
| `04_BANCO/` | Dump do B1 (`Parte Samuel BackEnd B1 - limpo.sql`), planilha `Banco_Evasao_IA_Normalizado.xlsx` e `schema.sql` |
| `05_IMAGENS/` | Telas do sistema: comparação com o Figma, assistente, acessibilidade e visual dos dados |
| `06_PARTES_ORIGINAIS/` | Partes como foram recebidas: B1 banco, B2 cálculo, B3 API, F1 painel (protótipo `MUFASA.fig`) e F2 chatbot |
| `07_VERSOES_ANTERIORES/` | Entregas antigas, guardadas só para consulta |

A pasta do sistema em uso é sempre `01_SISTEMA/mufasa`. Ao mudar um documento, mude o de `mufasa/docs`.

## O que não está no repositório

Por segurança e LGPD, ficam fora do Git:

- `groq.env` e `.env` (chaves e senhas do sistema);
- `banco/credenciais_iniciais.csv` e `banco/contas_iniciais.sql` (senhas das contas). O sistema gera contas novas ao montar o banco;
- `logs/`, bancos SQLite locais e arquivos `.zip`.

Os dados de alunos do banco B1 são fictícios, usados na fase de testes.

## Equipe

| Parte | Responsável |
|---|---|
| B1 Banco de dados | Samuel |
| B2 Cálculo do score | Susy |
| B3 API e Segurança | João |
| F1 Painel | Davi |
| F2 Chatbot | Eduardo |
