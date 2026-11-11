# MUFASA — como rodar localmente e testar

Há dois caminhos. Escolha um:

- **Caminho A: instalação direta.** Python e PostgreSQL instalados na máquina. Bom para desenvolver e para rodar os testes.
- **Caminho B: Docker.** Só o Docker Desktop instalado. Bom para só usar o sistema.

Os comandos valem para Windows (PowerShell), Linux e macOS. Quando houver diferença, o Windows vem indicado. Rode tudo **dentro da pasta `mufasa/`**.

---

## 1. O que instalar

### Caminho A

1. **Python 3.13** (python.org). No Windows, marque "Add python.exe to PATH" na instalação.
2. **PostgreSQL 16** (postgresql.org/download). Anote a senha do usuário `postgres` definida na instalação; ela vai ser pedida uma vez. A porta padrão é 5432.
3. Conferir no terminal:
   ```
   python --version      # Python 3.13.x  (no Linux/macOS pode ser python3)
   ```

O `psql` não é necessário, porque o banco é montado pelo próprio Python.

### Caminho B

1. **Docker Desktop** (Windows/macOS) ou Docker Engine com o plugin Compose (Linux).
2. Python 3, só para gerar o `.env` (passo 2 abaixo). Se não quiser instalar Python, copie `.env.example` para `.env` e preencha à mão.

---

## 2. Caminho A: instalação direta, passo a passo

```bash
# 1. Ambiente virtual e pacotes (uma vez)
python -m venv venv
venv\Scripts\activate            # Windows
source venv/bin/activate         # Linux/macOS
pip install -r requirements.lock

# 2. Configuração: cria o .env com senhas e chaves novas (uma vez)
python -m scripts.configurar
#    pergunta: endereço do PostgreSQL [localhost], porta [5432] e a senha do postgres

# 3. Banco: cria o banco "mufasa", carrega o B1, aplica as correções, cria as contas
python -m scripts.montar_banco
#    pede confirmação porque APAGA e recria o banco "mufasa". Leva cerca de 1 minuto.

# 4. Subir o sistema (deixe este terminal aberto)
python -m scripts.iniciar

# 5. Abrir no navegador
#    http://127.0.0.1:8501
```

Para parar: `Ctrl+C` no terminal do passo 4. Para subir de novo outro dia, basta ativar o ambiente virtual e rodar o passo 4.

**Opções do `iniciar`:**

| Comando | O que faz |
|---|---|
| `python -m scripts.iniciar` | Sobe API, chat, cálculo e painel |
| `python -m scripts.iniciar --sem-chat` | Sobe tudo menos o assistente |
| `python -m scripts.iniciar --so api,painel` | Sobe só as partes escolhidas |

Se uma parte cair, o `iniciar` sobe ela de novo sozinho (espera 2 s, depois 4 s, até 60 s) e as outras continuam funcionando.

---

## 3. Caminho B: Docker, passo a passo

O guia completo, com instalação do Docker Desktop, backup e atualização, está em `docs/06_USO_LOCAL_DOCKER.md`. Abaixo vai só o resumo.

```bash
python -m scripts.configurar --docker     # uma vez: cria o .env para os containers
docker compose up -d --build              # sobe tudo; na 1ª vez monta o banco (alguns minutos)
docker compose ps                         # todos devem ficar "healthy"; "montar" termina como "exited (0)"
#  abra http://127.0.0.1:8501
```

| Comando | O que faz |
|---|---|
| `docker compose logs -f api` | Ver os registros da API ao vivo (Ctrl+C para sair) |
| `docker compose restart painel` | Reiniciar uma parte |
| `docker compose down` | Parar tudo (os dados ficam guardados) |
| `docker compose down -v` | Parar e **apagar o banco**. Na próxima subida ele é montado do zero |

Os containers reiniciam sozinhos se caírem (`restart: unless-stopped`).

---

## 4. Logins

As contas iniciais ficam em `banco/credenciais_iniciais.csv` (separador `;`). **É um arquivo sensível:** não envie por e-mail nem suba para o GitHub.

| Perfil | Login | Observação |
|---|---|---|
| Coordenação | `coordenacao.demo` | |
| Núcleo de apoio (NAE) | `nae.demo` e `nae2.demo` | |
| Docente | `docente.demo` | |
| Financeiro | `financeiro.demo` | |
| Gestão / Direção | `gestao.demo` | |
| Administração técnica | `admin.demo` | |
| Encarregado de dados | `encarregado.demo` | |
| Aluno | `ALU0001` a `ALU1000` | Troca a senha no primeiro acesso |

A senha de cada conta está na coluna `senha_provisoria` do CSV. Na tela de login, escolha o perfil, informe login e senha e aceite o termo no primeiro acesso.

- **Senhas novas para todos:** `python -m scripts.montar_banco --contas-novas`. Elas são gravadas em `credenciais.csv`.
- **Criar um usuário avulso:** pela tela Administração → Usuários, ou com `python -m scripts.criar_usuario --login X --perfil DOCENTE --professor PROF001`.

As contas `*.demo` são de demonstração e não entram quando `AMBIENTE=producao`.

---

## 5. Testes para verificar se está tudo funcionando

### 5.1 Diagnóstico (1 minuto, com o sistema ligado)

```bash
python -m scripts.diagnostico
```

Confere Python e pacotes, `.env`, conexão de cada usuário de banco, tabelas, parâmetros, migrações, os quatro serviços, a fila de cálculo e os erros recentes. **Precisa terminar com "0 falha(s)".** Cada falha vem com a dica do que fazer.

### 5.2 Testes automáticos (menos de 1 minuto)

Rodam num banco separado, `mufasa_teste`, criado e apagado pelos próprios testes. O banco `mufasa` não é tocado e o sistema não precisa estar ligado.

```bash
pytest                       # tudo: precisa dar 201 passed
pytest -m "not banco"        # só os testes de cálculo, sem PostgreSQL
pytest testes/teste_fluxos.py -v    # um arquivo, mostrando cada teste
```

| Arquivo | Testes | O que cobre |
|---|---|---|
| `teste_calculo.py` | 94 | Indicadores, curvas, modificadores, níveis, completude (Anexo A) |
| `teste_api.py` | 39 | Login, perfis, escopo, auditoria, erros, cabeçalhos, SQL só com parâmetros |
| `teste_chatbot.py` | 41 | Intenções, escopo, dados reais, nada sensível para a IA |
| `teste_fluxos.py` | 24 | Ciclo do alerta, agendamento (RN14), cargas, parâmetros, LGPD, `/saude` |
| `teste_painel.py` | 3 | Seletor de perfil, API fora do ar sem quebrar a tela, CSV seguro |

### 5.3 Roteiro manual no navegador (15 minutos)

| # | Entrar como | Fazer | Esperado |
|---|---|---|---|
| 1 | qualquer conta | Errar a senha 5 vezes | Conta bloqueada por 15 minutos |
| 2 | `coordenacao.demo` | Abrir o painel e a fila de alertas | Crítico em vermelho-tijolo, Alto em marrom; Crítico no topo |
| 3 | `coordenacao.demo` | Abrir um alerta, atribuir ao NAE e registrar uma ação | A ação aparece no histórico do alerta |
| 4 | `nae.demo` | Ver os alertas | Só os atribuídos a ele |
| 5 | `nae.demo` | Encerrar um alerta sem causa | Recusado (CA20) |
| 6 | `docente.demo` | Ver as turmas | Só os alunos das próprias turmas, sem dado de saúde |
| 7 | `gestao.demo` | Ver os painéis | Só números agregados; grupos com menos de 5 alunos aparecem suprimidos |
| 8 | `ALU0001` | Primeiro acesso | Pede senha nova e aceite do termo; mostra situação, nunca o número do score |
| 9 | `ALU0001` | Agendar dois atendimentos em menos de 15 dias | O segundo é recusado (RN14), a menos que o nível seja Crítico |
| 10 | `admin.demo` | Administração → Serviços | API, chat, cálculo e painel "no ar", com a versão |
| 11 | `admin.demo` | Mudar a nota mínima | Vira proposta; só vale depois que a coordenação aprovar |
| 12 | `encarregado.demo` | Auditoria, filtrar por matrícula e exportar CSV | Lista de quem acessou cada dado |
| 13 | — | Fechar o terminal do chat (ou `docker compose stop chat`) | O resto do painel continua funcionando; o assistente mostra "indisponível" |

---

## 6. Problemas comuns

| Sintoma | Causa provável | O que fazer |
|---|---|---|
| `montar_banco` falha ao conectar como postgres | Senha do postgres errada no `.env` ou PostgreSQL parado | `python -m scripts.configurar --sobrescrever` e montar de novo |
| Porta 8501 (ou 8000) "em uso" | Outro programa ou um `iniciar` anterior aberto | Fechar o outro terminal; no Windows, `netstat -ano \| findstr 8501` mostra o processo |
| Tela com "Código para o suporte: …" | Erro numa parte do sistema | `python -m scripts.diagnostico --requisicao <código>` (ver documento 05) |
| Login recusa senha certa | Conta bloqueada ou perfil errado no seletor | Esperar 15 minutos ou desbloquear em Administração → Usuários |
| Painel diz "API indisponível" | API parada | Ver `logs/api.console.log`; o `iniciar` tenta subir de novo sozinho |
| `pytest` mostra "skipped … não configurado" | Falta o `.env` | Rodar o `configurar` antes |

---

## 7. Cópia de segurança (backup)

Guarde **sempre os dois juntos**: o banco e o `.env`. Sem a `APOIO_CHAVE` do `.env`, os dados de apoio cifrados não podem ser lidos.

```bash
# Caminho A (pg_dump vem com o PostgreSQL; no Windows fica em C:\Program Files\PostgreSQL\16\bin)
pg_dump -U postgres -h localhost -Fc -f backup_mufasa.dump mufasa
# restaurar num banco vazio:
pg_restore -U postgres -h localhost -d mufasa --clean backup_mufasa.dump

# Caminho B
docker compose exec db pg_dump -U postgres -Fc -f /tmp/backup.dump mufasa
docker compose cp db:/tmp/backup.dump ./backup_mufasa.dump
```

Teste a restauração de vez em quando num banco separado; um backup que nunca foi restaurado não garante nada.

---

## 8. Acesso por outros computadores da rede (opcional)

Por padrão tudo escuta só em `127.0.0.1`. Para abrir o painel na rede local:

1. Caminho A: em `painel/.streamlit/config.toml`, troque `address = "127.0.0.1"` por `address = "0.0.0.0"`. Caminho B: no `docker-compose.yml`, troque `127.0.0.1:8501:8501` por `8501:8501`. Libere a porta 8501 no firewall da máquina.
2. A API e o chat podem continuar só locais, porque o painel conversa com eles dentro da máquina.
3. Fora de uma rede de testes, use HTTPS (`FORCAR_HTTPS=true` atrás de um proxy com certificado) e `AMBIENTE=producao`.
