# MUFASA — sistema de alerta precoce de evasão (versão 1.1.0)

O MUFASA junta:

- o banco do B1, corrigido;
- o score calculado conforme o SRS v1.1 (Anexo A);
- a API e a segurança do B3;
- o chatbot F2;
- o painel F1 em Streamlit, com um hub por perfil.

Cada parte roda num processo separado. Se uma cair, as outras continuam.

## Começar em 5 comandos (instalação direta)

Antes, instale Python 3.13 e PostgreSQL 16.

```bash
python -m venv venv && venv\Scripts\activate        # Linux/macOS: source venv/bin/activate
pip install -r requirements.lock
python -m scripts.configurar                         # cria o .env com senhas novas
python -m scripts.montar_banco                       # monta o banco com os 1.000 alunos e as contas
python -m scripts.iniciar                            # sobe API, chat, cálculo e painel
```

Abra **http://127.0.0.1:8501**. Os logins estão em `banco/credenciais_iniciais.csv`. O arquivo é sensível: não divulgue.

**Com Docker:**

```bash
python -m scripts.configurar --docker
docker compose up -d --build
```

## Ligar e desligar no dia a dia

Com o Docker instalado, dê duplo clique em `INICIAR_MUFASA.bat` para ligar (abre o painel no navegador) e em `PARAR_MUFASA.bat` para desligar. Os dados ficam guardados. No macOS ou Linux use `./iniciar_mufasa.sh` e `./parar_mufasa.sh`. Detalhes em `docs/06_USO_LOCAL_DOCKER.md`, passo 8.

## Verificar

```bash
python -m scripts.diagnostico      # com o sistema ligado: precisa dar "0 falha(s)"
pytest                             # 201 testes num banco de teste separado
```

## Documentação

| Documento | Conteúdo |
|---|---|
| [01 — Construção passo a passo](docs/01_CONSTRUCAO_PASSO_A_PASSO.md) | Do primeiro passo à versão 1.1.0 |
| [02 — Partes dos integrantes](docs/02_PARTES_DOS_INTEGRANTES.md) | O que cada integrante fez, o que usou e como construiu |
| [03 — Ferramentas e versões](docs/03_FERRAMENTAS_E_VERSOES.md) | Programas, pacotes, versões e portas |
| [04 — Uso local e testes](docs/04_USO_LOCAL_E_TESTES.md) | Instalação, logins, testes, problemas comuns e backup |
| [06 — Uso local com Docker](docs/06_USO_LOCAL_DOCKER.md) | Passo a passo só com o Docker, do zero ao primeiro login |
| [05 — Evolução e diagnóstico](docs/05_EVOLUCAO_E_DIAGNOSTICO.md) | Como achar erros pelo código da tela; logs, migrações e versões |
| [Revisão das métricas](docs/REVISAO_METRICAS_SRS.md) | Parâmetros e fórmulas comparados ao SRS v1.1 |
| [CHANGELOG](CHANGELOG.md) | O que mudou em cada versão |
| `docs/AUDITORIA_SEGURANCA.md`, `AUDITORIA_CHATBOT.md`, `AUDITORIA_ACESSIBILIDADE.md` | Auditorias de segurança, do chatbot e de acessibilidade |
| `docs/POLITICA_DE_PRIVACIDADE.md`, `TERMOS_DE_USO.md`, `POLITICA_DE_COOKIES.md`, `CONSENTIMENTO_DADOS_SAUDE.md` | Minutas dos documentos LGPD |
| `docs/REVISAO_DE_CONTEUDO.md` | Revisão dos textos |

## Estrutura

```
app/
  api/              API REST /api/v1: login, perfis, alertas, painéis, aluno, admin, LGPD
  calculo/          indicadores e score (SRS Anexo A, código 3.0)
  servico_calculo/  serviço que recalcula scores e alertas pela fila
  chatbot/          assistente (intenções fechadas; IA opcional só para o tom)
  registro.py       registros em logs/ com código de requisição
  main.py           API (porta 8000)
  main_chat.py      chat (porta 8001)
painel/             interface Streamlit (porta 8501), hub por perfil
scripts/            configurar, montar_banco, iniciar, diagnostico, migrar, contas
sql/                correções do B1, complemento do B3, painel, chatbot, migracoes/
banco/              dump do B1 limpo, contas iniciais e credenciais iniciais
testes/             201 testes (pytest) num PostgreSQL de teste
docs/               documentação
```

A lista completa de rotas da API fica em http://127.0.0.1:8000/docs, com o sistema ligado e fora de produção.

## Decisões que valem para todo o sistema

- **Rota do score:** `/score`, como no SRS. O guia usava `/risco`.
- **Login do aluno:** matrícula e senha, com bcrypt de custo 12 e troca de senha no primeiro acesso. Trocar depois por código no e-mail ou login único não muda as rotas.
- **Matrícula:** aceita 7 dígitos (SRS) ou o formato `ALU0000` do banco simulado do B1.
- **Notas:** escala de 0 a 10 em todo o sistema. As notas originais de 0 a 100 do B1 ficam em `b1_notas_originais`.
- **Sem dado, sem número:** quando a base não tem o dado (AVA, faltas restantes, eficácia), a tela mostra "sem dado".
- **Chatbot:** a pergunta é classificada por regras, e a IA nunca escolhe a consulta nem o escopo (RN06). A Groq, opcional, só recebe um rascunho com marcadores, sem nome, matrícula, nota ou frequência. Resposta com número inventado é descartada.
- **Aluno:** vê a própria situação, nunca o número do score na tela (RN17).

## Pendências conhecidas

Detalhes na seção 6 de `docs/REVISAO_METRICAS_SRS.md` e na seção 4 de `docs/02_PARTES_DOS_INTEGRANTES.md`. As principais:

- exportação em XLSX e PDF;
- notificação por e-mail;
- backup automático;
- tela "Meu nível";
- confirmar o salário mínimo de 2026;
- preencher as bases legais entre colchetes na política de privacidade;
- **revogar a chave da Groq que veio no arquivo compartilhado.**
