# MUFASA — passo a passo do uso local com Docker

Este guia leva do computador vazio até o primeiro login, usando só o Docker. Não é preciso instalar Python nem PostgreSQL. Todos os comandos foram testados em 28/10/2026 a partir do `mufasa-1.1.0.zip`, numa pasta nova.

Os comandos estão escritos para o **PowerShell do Windows**. As diferenças para macOS e Linux aparecem como nota logo abaixo de cada passo.

---

## Visão geral

O Docker sobe 6 containers:

| Container | O que é | Fica |
|---|---|---|
| `db` | Banco PostgreSQL 16 | sempre ligado |
| `montar` | Monta o banco na primeira vez | roda uma vez e para ("Exited (0)") |
| `api` | API, porta 8000 | sempre ligado |
| `chat` | Assistente, porta 8001 | sempre ligado |
| `calculo` | Recalcula scores e alertas | sempre ligado |
| `painel` | Telas do sistema, porta 8501 | sempre ligado |

Se um container cair, o Docker sobe ele de novo sozinho, e os outros continuam funcionando. Os dados do banco ficam guardados num volume do Docker e não se perdem quando o computador desliga.

---

## Passo 1 — Instalar o Docker Desktop (uma vez)

1. Requisitos:
   - Windows 10 ou 11 de 64 bits;
   - 8 GB de RAM ou mais;
   - cerca de 3 GB livres em disco.
2. Baixe o Docker Desktop em **docker.com/products/docker-desktop** e instale.
   - Quando o instalador perguntar, deixe marcada a opção **"Use WSL 2"**.
   - Se o Windows pedir para instalar ou atualizar o WSL, aceite e reinicie o computador.
3. Abra o Docker Desktop e espere aparecer **"Engine running"** no canto inferior esquerdo.
4. Abra o **PowerShell** (menu Iniciar → digite "PowerShell") e confira a instalação:
   ```powershell
   docker --version
   docker compose version
   ```
   Os dois comandos precisam mostrar um número de versão.

> **macOS:** instale o Docker Desktop para Mac e use o app Terminal.
> **Linux:** instale o Docker Engine e o plugin Compose (`docker-compose-plugin`). Para usar `docker` sem `sudo`, coloque seu usuário no grupo `docker`.

---

## Passo 2 — Descompactar o projeto (uma vez)

1. Descompacte o `mufasa-1.1.0.zip` numa pasta curta e sem acentos, por exemplo `C:\mufasa`.
2. No PowerShell, entre na pasta do projeto. É a pasta que contém o `docker-compose.yml`:
   ```powershell
   cd C:\mufasa\mufasa
   dir docker-compose.yml
   ```
   O `dir` precisa listar o arquivo. Todos os comandos dos próximos passos rodam nesta pasta.

**Se o `cd` der erro:**

- **Caminho com espaço** (por exemplo, "Área de Trabalho"): coloque o caminho entre aspas, como em `cd "C:\Users\voce\Área de Trabalho\mufasa"`.
- **Pasta dentro de pasta:** se o `dir` não achar o arquivo, o zip criou uma pasta dentro da outra. Rode `cd mufasa` e repita o `dir`.
- **Atalho:** no Explorador de Arquivos, abra a pasta onde aparece o `docker-compose.yml`, clique na barra de endereço, digite `powershell` e aperte Enter. O PowerShell já abre na pasta certa.
- **Evite o OneDrive:** a sincronização pode travar os arquivos de registro e de backup enquanto o Docker usa a pasta. Prefira `C:\mufasa`.

---

## Passo 3 — Construir a imagem do sistema (uma vez, e a cada atualização)

```powershell
docker build -t mufasa:1.1.0 .
```

- **O que faz:** baixa o Python 3.13 e instala os pacotes do `requirements.lock`.
- **Tempo:** de 2 a 5 minutos na primeira vez, conforme a internet.
- **Esperado:** a última linha mostra `naming to docker.io/library/mufasa:1.1.0` ou `DONE`.

**Se der `429 Too Many Requests`:** o Docker Hub limita downloads anônimos. Entre na sua conta com `docker login` (a conta gratuita basta) e repita o comando.

---

## Passo 4 — Gerar o arquivo de configuração `.env` (uma vez)

O `.env` guarda as senhas do banco e as chaves do sistema. O comando abaixo gera todas na hora, aleatórias:

```powershell
docker run --rm -u root -v "${PWD}:/app" mufasa:1.1.0 python -m scripts.configurar --docker
```

- **Esperado:** `.env criado em /app/.env`. A mensagem também sugere `python -m scripts.montar_banco` como próximo passo; ignore essa parte, porque no Docker o banco é montado no passo 5.
- **Confira:** `dir .env` precisa listar o arquivo.

> **Prompt de Comando (cmd):** troque `"${PWD}:/app"` por `"%cd%:/app"`.
> **macOS:** igual ao Windows.
> **Linux:** troque `-u root` por `-u "$(id -u):$(id -g)"`, para o arquivo ficar com o seu usuário.

**Guarde uma cópia do `.env` em local seguro.** Sem ele, os dados de apoio cifrados não podem ser lidos. Não envie esse arquivo por e-mail nem suba para o GitHub.

---

## Passo 5 — Ligar o sistema

```powershell
docker compose up -d
```

Na primeira vez, o container `montar` cria o banco e carrega os 1.000 alunos, as correções, os scores e as contas. Isso leva menos de 1 minuto. Para acompanhar:

```powershell
docker compose ps -a
```

**Esperado depois de 1 a 2 minutos:**

```
SERVICE   STATUS
api       Up ... (healthy)
calculo   Up ...
chat      Up ... (healthy)
db        Up ... (healthy)
montar    Exited (0) ...
painel    Up ... (healthy)
```

- `montar` com **Exited (0)** está certo: ele terminou o trabalho.
- Se aparecer `Exited (1)`, veja o motivo com `docker compose logs montar`.
- A última linha esperada desse log é `Banco mufasa pronto.`

---

## Passo 6 — Entrar no sistema

1. Abra o navegador em **http://127.0.0.1:8501**.
2. Abra o arquivo `banco\credenciais_iniciais.csv`. No Excel, use Dados → De Texto/CSV com o separador `;`; também dá para abrir no Bloco de Notas.
3. Escolha uma conta. A senha fica na coluna `senha_provisoria`.

| Perfil na tela de login | Login |
|---|---|
| Coordenação | `coordenacao.demo` |
| NAE — Núcleo de apoio | `nae.demo` |
| Docente | `docente.demo` |
| Setor financeiro | `financeiro.demo` |
| Gestão | `gestao.demo` |
| Administração técnica | `admin.demo` |
| Encarregado de dados | `encarregado.demo` |
| Aluno | `ALU0001` a `ALU1000` |

4. Na tela de login, escolha o **perfil**, digite o login e a senha e clique em **Entrar**.
5. No primeiro acesso, aceite o termo. O aluno também cria uma senha nova.

O arquivo de credenciais é sensível: não divulgue.

---

## Passo 7 — Conferir se está tudo funcionando

### 7.1 Diagnóstico (30 segundos)

```powershell
docker compose exec painel sh -c "cd /app && python -m scripts.diagnostico"
```

- Todos os itens devem sair `ok`, **menos um**: `[ FALHA ] arquivo .env`.
- Essa falha é esperada no Docker, porque o arquivo fica fora do container e as variáveis chegam pelo Compose. As linhas seguintes confirmam que cada variável foi definida.
- **Esperado no fim:** `Resumo: 1 falha(s)`.

### 7.2 Testes automáticos (menos de 1 minuto)

Os testes rodam num banco separado (`mufasa_teste`) dentro do mesmo PostgreSQL. O banco do sistema não é tocado.

```powershell
docker compose run --rm -e HOSTS_PERMITIDOS='["testserver","localhost","127.0.0.1"]' montar python -m pytest -q -p no:cacheprovider
```

- **Esperado:** `201 passed`.
- A variável `HOSTS_PERMITIDOS` libera o endereço interno que os testes usam.

### 7.3 Roteiro no navegador

Siga a tabela da seção 5.3 de `docs/04_USO_LOCAL_E_TESTES.md`: 13 verificações, uma por perfil.

### 7.4 Isolamento de falhas

```powershell
docker compose exec chat sh -c "kill 1"
docker compose ps
```

- O `chat` volta sozinho em poucos segundos ("Up ... seconds").
- Durante a queda, o painel e a API continuam funcionando.

---

## Passo 8 — Uso no dia a dia

### Ligar e desligar com duplo clique

Na pasta do projeto há dois atalhos. Use-os sempre que fechar e abrir o computador:

| Arquivo | O que faz |
|---|---|
| `INICIAR_MUFASA.bat` | Abre o Docker Desktop se estiver fechado, cria o `.env` na primeira vez, liga todas as partes, espera o painel ficar pronto e abre `http://127.0.0.1:8501` no navegador |
| `PARAR_MUFASA.bat` | Desliga todas as partes. Os dados do banco ficam guardados |

No macOS ou Linux, os equivalentes são `./iniciar_mufasa.sh` e `./parar_mufasa.sh`.

**Para ligar sozinho ao entrar no Windows:** no Docker Desktop, abra *Settings → General* e marque *Start Docker Desktop when you sign in to your computer*. Como cada parte do MUFASA tem reinício automático, o sistema volta a funcionar sozinho depois que o Docker abrir, a menos que você tenha desligado com `PARAR_MUFASA.bat`. Nesse caso, ligue de novo com `INICIAR_MUFASA.bat`.

**Atalho na área de trabalho:** clique com o botão direito em `INICIAR_MUFASA.bat` → *Enviar para* → *Área de trabalho (criar atalho)*.

### Chave da Groq (assistente com IA)

A chave fica no arquivo `groq.env`, na pasta do projeto, numa linha `GROQ_API_KEY=...`. O `INICIAR_MUFASA.bat` copia a chave para o `.env` toda vez que liga o sistema. Para trocar a chave, edite só o `groq.env` e ligue de novo. Pelo PowerShell, o comando equivalente é:

```powershell
docker run --rm -u root -v "${PWD}:/app" mufasa:1.1.0 python -m scripts.configurar --chaves
docker compose up -d
```

O `groq.env` é um segredo: não envie para o GitHub nem para fora do grupo. O Git e o Docker já ignoram esse arquivo. Sem ele, o assistente funciona com as respostas prontas.

### Pelos comandos


| Para… | Comando |
|---|---|
| Ligar (depois de reiniciar o computador) | Duplo clique em `INICIAR_MUFASA.bat`, ou abrir o Docker Desktop e rodar `docker compose up -d --build` na pasta do projeto (o `--build` garante que a versão mais nova do código seja usada) |
| Ver se está tudo no ar | `docker compose ps` |
| Desligar (os dados ficam guardados) | Duplo clique em `PARAR_MUFASA.bat`, ou `docker compose down` |
| Reiniciar uma parte | `docker compose restart painel` (ou `api`, `chat`, `calculo`) |
| Ver os registros de uma parte ao vivo | `docker compose logs -f --tail 50 api` (Ctrl+C para sair) |
| Abrir os arquivos de registro | Pasta `logs\` do projeto (`api.log`, `chat.log`, `calculo.log`, `painel.log`) |
| Achar um erro pelo código da tela | `docker compose exec painel sh -c "cd /app && python -m scripts.diagnostico --requisicao CODIGO"` |
| Abrir o banco no terminal | `docker compose exec db psql -U postgres -d mufasa` (sair com `\q`) |

O Docker Desktop também mostra tudo isso pela interface: aba **Containers** → `mufasa`.

---

## Passo 9 — Cópia de segurança (backup)

**Fazer o backup.** Gera o arquivo `backup_mufasa.dump` na pasta do projeto:

```powershell
docker compose exec db pg_dump -U postgres -Fc -f /tmp/backup.dump mufasa
docker compose cp db:/tmp/backup.dump ./backup_mufasa.dump
```

**Restaurar um backup.** O banco atual é substituído:

```powershell
docker compose stop api chat calculo painel
docker compose cp ./backup_mufasa.dump db:/tmp/restaurar.dump
docker compose exec db pg_restore -U postgres -d mufasa --clean --if-exists /tmp/restaurar.dump
docker compose start api chat calculo painel
```

Guarde o `backup_mufasa.dump` junto com uma cópia do `.env`. Um não serve sem o outro.

---

## Passo 10 — Atualizar para uma versão nova

1. Faça o backup (passo 9).
2. Descompacte a versão nova por cima da pasta, **mantendo o `.env`**.
3. Reconstrua a imagem e religue o sistema. Troque o número pela versão nova, que aparece no `docker-compose.yml`:
   ```powershell
   docker build -t mufasa:1.1.0 .
   docker compose up -d
   ```
   Ou só dê duplo clique em `INICIAR_MUFASA.bat`, que já faz os dois.
4. As mudanças de banco da versão nova (migrações) são aplicadas sozinhas pelo `montar` ao ligar. Para conferir ou aplicar à mão:
   ```powershell
   docker compose run --rm montar python -m scripts.migrar
   ```
5. Confira com o diagnóstico (passo 7.1).

---

## Recomeçar do zero

Este comando **apaga o banco**, inclusive senhas trocadas, alertas e atendimentos. Na próxima subida, o banco é montado de novo a partir da semente da entrega:

```powershell
docker compose down -v
docker compose up -d
```

**Gerar senhas novas para todas as contas:**

```powershell
docker compose run --rm montar python -m scripts.montar_banco --sim --contas-novas
```

As senhas novas ficam em `credenciais\credenciais.csv`. Esse comando também recria o banco. Depois dele, rode `docker compose restart api chat calculo painel`.

---

## Problemas comuns

| Sintoma | O que fazer |
|---|---|
| `docker` não é reconhecido | O Docker Desktop não está instalado ou não está aberto. Abra e espere "Engine running" |
| `error during connect` / `cannot find the file specified` | O Docker Desktop está fechado ou ainda iniciando. Espere e repita |
| `required variable POSTGRES_SENHA is missing a value: rode python -m scripts.configurar --docker` | Falta o `.env`, ou você está fora da pasta do projeto. Volte ao passo 2 ou ao passo 4 |
| `port is already allocated` (8000, 8001 ou 8501) | Outro programa usa a porta. Feche o outro programa, ou o `scripts.iniciar` da instalação direta |
| `montar` com `Exited (1)` | Veja o motivo com `docker compose logs montar`, depois rode `docker compose down -v` e `docker compose up -d` |
| Página não abre em 127.0.0.1:8501 | `docker compose ps`: o painel precisa estar "healthy". Veja `docker compose logs painel` |
| Tela com "Código para o suporte: …" | Use o comando da busca por código (passo 8) e veja `docs/05_EVOLUCAO_E_DIAGNOSTICO.md` |
| `429 Too Many Requests` no passo 3 | `docker login` e repetir |
| Computador lento | No Docker Desktop, Settings → Resources: reserve pelo menos 4 GB de memória |
