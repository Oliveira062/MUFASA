# Auditoria de Segurança e LGPD — MUFASA (B1, B2 e B3)

27/10/2026 · Revisão estática do código entregue, mais os testes automatizados do B3.

## Escopo

| Parte | Material analisado |
|---|---|
| B1 — Dados e Banco (Samuel) | `Parte Samuel BackEnd B1.sql`: dump do PostgreSQL 16 com 11 tabelas e dados (1.000 alunos, 8.000 matrículas) |
| B2 — Cálculo (Susy) | `app/calculo/score.py`, `app/calculo/indicadores.py`, `testes/test_calculo.py`, README, CHANGELOG |
| B3 — API (este pacote) | `app/main.py`, `app/config.py`, `app/api/*.py`, `sql/b3_complemento.sql`, `testes/teste_api.py` |
| Referências | Guia de Construção do Back-end, SRS v1.1, `b3/README.md` |

**Limites desta revisão.** Os 41 testes do B2 não foram executados aqui (o ambiente de análise bloqueou a execução do código enviado), e o dump do B1 não foi restaurado num PostgreSQL. Os achados do B1 e do B2 vêm da leitura do código e dos dados. Os 38 testes do B3 foram executados e passam, num SQLite com as mesmas tabelas e colunas do B1.

**Sobre o modelo de prioridades.** A estrutura das 5 prioridades veio de outro projeto (webhook Stripe, ReviewLive, ETS, Tailwind). Os itens que não existem neste código aparecem como **"Não se aplica"**, com o ponto equivalente do MUFASA quando ele existe. Nenhum achado foi inventado para preencher o modelo.

## Resumo por severidade

| # | Severidade | Achado | Situação |
|---|---|---|---|
| 1.1-A | Crítica | Endpoint de score sem autenticação nem checagem de dono (BOLA) | Corrigido no B3 |
| 1.2-A | Alta | Nenhuma força de HTTPS nem HSTS | Corrigido no B3 (por configuração) |
| 1.1-B | Alta | Banco inteiro de dono `postgres`, sem perfis; API orientada a conectar como superusuário | Corrigido para o B3 em `sql/b3_complemento.sql` |
| 1.1-C | Alta | Dados sensíveis de saúde e deficiência na tabela principal de alunos | Sugestão para o B1 |
| 2.1-A | Alta | Sem limite de requisições nem bloqueio de login | Corrigido no B3 |
| 2.2-A | Alta | Biblioteca de JWT com falhas conhecidas e chave de exemplo previsível | Corrigido no B3 |
| D-1 | Alta | Versões fixadas no guia com vulnerabilidades conhecidas | Corrigido no `requirements.txt` |
| 4.3-A | Média | Nenhuma trilha de auditoria de acesso | Corrigido no B3 |
| 4.4-A | Média | B2 aceita risco "pronto" injetado no dicionário de entrada | Sugestão para o B2 |
| 4.5-A | Média | B2 aceita NaN, infinito e valores fora de faixa | Sugestão para o B2 (o B3 já filtra) |
| 4.5-B | Média | B2 quebra com erro 500 quando `faltas` chega vazio | Sugestão para o B2 |
| 4.5-C | Média | B2 devolve 0 faltas restantes quando o dado não existe | Contornado no B3; sugestão para o B2 |
| 4.5-D | Média | B1 grava notas de 0 a 100; o B2 espera 0 a 10 | Sugestão para o B1 |
| 2.3-A | Média | Tabelas do B1 sem chave primária, estrangeira, restrição ou índice | Sugestão para o B1 (índices no complemento) |
| L-1 | Média | Coleta socioeconômica além do que o cálculo usa | Sugestão para o B1 |
| L-2 | Média | 163 alunos menores de 18 anos sem registro de consentimento do responsável | B3 bloqueia; sugestão para o B1 |
| 3.3-A | Média | Erro de validação do FastAPI devolve o valor enviado, inclusive senha | Corrigido no B3 |
| 4.1-A | Média | Sem cabeçalhos de segurança (CSP e outros) | Corrigido no B3 |
| 4.4-B | Baixa | Formato da matrícula do B1 (`ALU0001`) diverge do SRS (7 dígitos) | B3 aceita os dois por ora |
| 4.5-E | Baixa | Nível `CRITICO` (B2) e `Crítico` (B1) não batem | Contornado no B3 |
| 4.2-A | Baixa | `/docs` carrega o Swagger de CDN externa | Desligado em produção |
| 5.3-A | Baixa | Listagens sem paginação no desenho original | Corrigido no B3 |
| 5.4-A | Informativa | Nenhum segredo encontrado no código; `.pyc` enviados revelam caminho local do autor | Remover os caches |

---

## Prioridade 1: Questões Críticas de Segurança (Hoje)

### 1.1 Corrigir Bypass na Verificação de Assinatura do Webhook

**Não se aplica.** O MUFASA não tem webhook nem integração de pagamento. O "bypass" equivalente neste projeto é o acesso a dados de aluno sem autenticação, abaixo.

#### 1.1-A Endpoint de score sem autenticação e sem checagem de dono

1. **Severidade:** Crítica
2. **Localização:** `MUFASA_Guia_Construcao_Backend.pdf`, página 10 (B3, passo 2); `b3/README.md`, linha 226
3. **Descrição da Falha:** o ponto de partida do B3 é `@app.get("/alunos/{matricula}/risco")` sem nenhuma dependência de autenticação. Quando os dados falsos forem trocados pelos reais, qualquer pessoa na rede lê o score e os fatores de qualquer aluno trocando a matrícula na URL (OWASP A01, Broken Object Level Authorization / IDOR). A matrícula é sequencial e conhecida por colegas, então a enumeração é trivial. Viola RN07, RN17 e o art. 46 da LGPD.
4. **Sugestão de Correção:** implementada em `app/api/rotas.py` e `app/api/permissoes.py`:

```python
@router.get("/alunos/{matricula}/score", response_model=RespostaScore)
def score_do_aluno(matricula: Matricula, request: Request,
                   usuario: Usuario = Depends(exigir_perfis(ALUNO, DOCENTE, COORDENACAO, NUCLEO_APOIO)),
                   conexao: Connection = Depends(obter_conexao)):
    # 1. perfil autorizado (exigir_perfis)  2. este usuario pode ver ESTE aluno?
    verificar_escopo_aluno(request, conexao, usuario, matricula, "LER_SCORE")
    ...

def _no_escopo(conexao, usuario, id_aluno) -> bool:
    if usuario.perfil == ALUNO:
        return usuario.id_aluno is not None and usuario.id_aluno == id_aluno
    if usuario.perfil == DOCENTE:
        return conexao.execute(ALUNO_DAS_TURMAS_DO_DOCENTE,
                               {"id_aluno": id_aluno, "id_professor": usuario.id_professor}).first() is not None
    ...
```

A resposta de negação é a mesma para "não existe" e "não pode ver", e cada tentativa fica registrada. Testes: `test_aluno_nao_ve_outro_aluno_e_fica_registrado`, `test_docente_nao_ve_aluno_de_outra_turma`.

#### 1.1-B Banco com dono `postgres` e API orientada a conectar como superusuário

1. **Severidade:** Alta
2. **Localização:** `Parte Samuel BackEnd B1.sql`, linhas 45, 63, 81, 101, 119, 139, 157, 173, 199, 216 e 231 (`OWNER TO postgres`); `b3/README.md`, linha 176 (`DATABASE_URL=postgresql://postgres:...`)
3. **Descrição da Falha:** todas as tabelas pertencem ao superusuário e não existe nenhum perfil de banco. Se a API conectar como `postgres`, como sugere o `.env` de exemplo, qualquer falha futura (uma injeção de SQL, um endpoint mal protegido) dá leitura e escrita em tudo, apaga a auditoria e pode chegar a executar comandos no servidor (`COPY ... TO PROGRAM`). Viola o princípio do menor privilégio (OWASP A01/A05) e o art. 46 da LGPD.
4. **Sugestão de Correção:** em `sql/b3_complemento.sql`:

```sql
CREATE ROLE mufasa_api LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO mufasa_api;
GRANT SELECT ON alunos, cursos, materias, turmas, matriculas, indicadores_academicos,
               socioeconomico, avaliacoes_risco, professores TO mufasa_api;   -- só leitura no B1
GRANT SELECT, INSERT ON auditoria_acessos TO mufasa_api;                     -- sem UPDATE/DELETE
GRANT UPDATE (falhas_login, bloqueado_ate, ultimo_login) ON usuarios TO mufasa_api;
```

```env
DATABASE_URL=postgresql+psycopg://mufasa_api:TROQUE_AQUI@localhost:5432/mufasa
```

#### 1.1-C Dados sensíveis de saúde e deficiência na tabela principal

1. **Severidade:** Alta
2. **Localização:** `Parte Samuel BackEnd B1.sql`, linhas 40 e 41 (`apoio_psicossocial_solicitado`, `necessidade_acessibilidade` em `alunos`)
3. **Descrição da Falha:** pedido de apoio psicossocial e necessidade de acessibilidade revelam saúde e deficiência, dados sensíveis pelo art. 5º, II da LGPD. Estão na mesma tabela de nome e curso, em texto puro e sem separação. Qualquer consulta a `alunos` leva junto o dado sensível, e não há como dar acesso ao cadastro sem dar acesso à saúde. O guia exige "tabela separada e criptografada para dados de saúde (LGPD art. 11)". O B3 já lê essas colunas em consulta própria, só para o núcleo de apoio, mas a separação tem de existir no banco.
4. **Sugestão de Correção (para o B1):**

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE dados_sensiveis_apoio (
    id_aluno                       VARCHAR(10) PRIMARY KEY REFERENCES alunos(id_aluno) ON DELETE CASCADE,
    apoio_psicossocial_solicitado  BYTEA,   -- pgp_sym_encrypt(valor, chave vinda do cofre, não do SQL)
    necessidade_acessibilidade     BYTEA,
    atualizado_em                  TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- Migrar os valores e então:
ALTER TABLE alunos DROP COLUMN apoio_psicossocial_solicitado, DROP COLUMN necessidade_acessibilidade;
REVOKE ALL ON dados_sensiveis_apoio FROM PUBLIC;
```

A chave de criptografia vai para o `.env` do serviço, nunca para o script. Depois da migração, trocar a consulta `DADOS_SENSIVEIS_APOIO` em `app/api/consultas.py`.

### 1.2 Habilitar Força de HTTPS

#### 1.2-A Nenhum redirecionamento para HTTPS nem HSTS

1. **Severidade:** Alta (em produção)
2. **Localização:** `b3/README.md`, linha 45 (`uvicorn app.main:app --reload`); esqueleto do `app/main.py` no guia
3. **Descrição da Falha:** a API sobe em HTTP simples, sem redirecionamento e sem `Strict-Transport-Security`. Em produção, token JWT, senha do login e dados de aluno trafegam legíveis para qualquer um na mesma rede (OWASP A02). A RN18 exige TLS 1.2 ou superior sem atender HTTP simples.
4. **Sugestão de Correção:** em `app/main.py` e `app/api/seguranca.py`, ligados por `FORCAR_HTTPS=true`:

```python
app.add_middleware(TrustedHostMiddleware, allowed_hosts=cfg.hosts_permitidos)
if cfg.forcar_https:
    app.add_middleware(HTTPSRedirectMiddleware)
# em CabecalhosSeguranca:
if self.hsts:
    resposta.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
```

O TLS em si termina no proxy reverso (Nginx, Caddy ou o da hospedagem), configurado com `ssl_protocols TLSv1.2 TLSv1.3;`. Atrás do proxy, rodar `uvicorn --proxy-headers --forwarded-allow-ips=<ip do proxy>`.

---

## Prioridade 2: Questões Altas de Segurança (Essa Semana)

### 2.1 Implementar Limitação de Taxa

#### 2.1-A Sem limite de requisições e sem bloqueio de login

1. **Severidade:** Alta
2. **Localização:** desenho do B3 (guia, página 10; `b3/README.md`, seção 6); não havia `auth.py`
3. **Descrição da Falha:** sem limite, um script testa senhas sem parar (força bruta) e varre matrículas em sequência. A RN12 exige bloqueio após 5 falhas, e o Anexo D.1 do SRS limita a 120 requisições por minuto por usuário (OWASP A07).
4. **Sugestão de Correção:** implementada em `app/api/seguranca.py`, `app/api/auth.py` e `app/api/rotas.py`:

```python
# 10 tentativas de login por minuto por IP e por conta
for chave in (f"login-ip:{ip_do_cliente(request)}", f"login-conta:{pedido.login.lower()}"):
    permitido, espera = limitador.permitir(chave, cfg.limite_login_minuto)
    if not permitido:
        raise erro_http(429, "Muitas tentativas de login. Aguarde e tente de novo.", {"Retry-After": str(espera)})

# 5 falhas bloqueiam a conta por 15 minutos, no banco
UPDATE usuarios SET falhas_login = falhas_login + 1,
       bloqueado_ate = CASE WHEN falhas_login + 1 >= :max_falhas THEN :bloquear_ate ELSE bloqueado_ate END
 WHERE id_usuario = :id_usuario
```

A mensagem de falha é a mesma para conta inexistente, senha errada e conta bloqueada, e o tempo de resposta também (bcrypt contra um hash fictício quando o login não existe). Testes: `test_bloqueio_apos_cinco_falhas`, `test_limite_de_tentativas_de_login_por_ip`.

### 2.2 Adicionar Criptografia de Cookies de Sessão

**Não se aplica como está escrito:** a API do MUFASA não usa cookie de sessão. O token vai no cabeçalho `Authorization: Bearer`, o que também elimina CSRF por construção. O ponto equivalente é a segurança do token JWT.

#### 2.2-A JWT com biblioteca vulnerável e chave previsível

1. **Severidade:** Alta
2. **Localização:** `MUFASA_Guia_Construcao_Backend.pdf`, página 6 (`python-jose==3.3.0`, `passlib==1.7.4`); `b3/README.md`, linha 177 (`JWT_SECRET=troque-por-uma-chave-longa-e-aleatoria`)
3. **Descrição da Falha:** `python-jose` 3.3.0 tem falhas publicadas de confusão de algoritmo (CVE-2024-33663) e de negação de serviço por token comprimido (CVE-2024-33664). O `passlib` 1.7.4 está sem manutenção e quebra com as versões atuais do `bcrypt`. E a chave de exemplo do `.env` é texto conhecido: se alguém subir com ela, qualquer pessoa forja um token de coordenação ou de núcleo de apoio.
4. **Sugestão de Correção:** em `app/api/auth.py` e `app/config.py`, com PyJWT e bcrypt diretos:

```python
def ler_token(token: str) -> dict:
    cfg = obter_configuracao()
    return jwt.decode(
        token, cfg.jwt_secret.get_secret_value(),
        algorithms=[cfg.jwt_algoritmo],          # lista fixa: recusa "none" e troca de algoritmo
        audience=cfg.jwt_publico, issuer=cfg.jwt_emissor,
        options={"require": ["exp", "iat", "nbf", "sub", "jti", "iss", "aud"]},
    )

@field_validator("jwt_secret")
@classmethod
def _chave_forte(cls, v: SecretStr) -> SecretStr:
    if len(v.get_secret_value().encode()) < 32:
        raise ValueError("JWT_SECRET precisa de pelo menos 32 bytes aleatorios")
    return v
```

Além disso: validade de 30 minutos, `jti` revogável em `POST /api/v1/auth/sair`, perfil relido do banco a cada requisição (conta desativada perde acesso na hora) e senha com bcrypt custo 12, limitada a 72 bytes. Testes: `test_token_com_alg_none_e_recusado`, `test_token_expirado_e_recusado`, `test_sair_revoga_o_token`.

### 2.3 Adicionar Índice de Banco de Dados para ID do Cliente Stripe

**Não se aplica:** não há Stripe. O equivalente é a ausência de chaves e índices no banco do B1.

#### 2.3-A Tabelas do B1 sem chave primária, estrangeira, restrição ou índice

1. **Severidade:** Média
2. **Localização:** `Parte Samuel BackEnd B1.sql`, linhas 32 a 229 (as 11 instruções `CREATE TABLE`)
3. **Descrição da Falha:** nenhuma tabela tem `PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL`, `CHECK` ou índice; todas as colunas de texto são `varchar(255)`, e datas e "Sim/Não" estão como texto. Consequências: aluno duplicado, matrícula apontando para aluno inexistente, nota 150 aceita, consulta por aluno lendo a tabela inteira, e nenhuma garantia de integridade no dado que alimenta o score (LGPD, art. 6º, V, qualidade dos dados). O `banco-evasao/schema.sql` do projeto já tem a modelagem certa.
4. **Sugestão de Correção (para o B1):** recriar o banco a partir de `banco-evasao/schema.sql` e só então carregar os dados. Para o banco atual, o mínimo:

```sql
ALTER TABLE alunos     ADD PRIMARY KEY (id_aluno);
ALTER TABLE turmas     ADD PRIMARY KEY (id_turma);
ALTER TABLE matriculas ADD PRIMARY KEY (id_matricula),
                       ADD FOREIGN KEY (id_aluno) REFERENCES alunos(id_aluno),
                       ADD FOREIGN KEY (id_turma) REFERENCES turmas(id_turma);
ALTER TABLE avaliacoes_risco ALTER COLUMN data_avaliacao TYPE DATE USING data_avaliacao::date;
ALTER TABLE alunos ALTER COLUMN necessidade_acessibilidade TYPE BOOLEAN
      USING (necessidade_acessibilidade = 'Sim');
```

Os índices que a API usa já estão em `sql/b3_complemento.sql` (índice não altera dado).

### 2.4 Minificar Pacote JavaScript

**Não se aplica:** o back-end não tem JavaScript. Fica para o F1, se o painel for em React. O componente `docs/aviso-armazenamento.html` não depende de nada externo.

### D-1 Dependências com vulnerabilidades conhecidas

1. **Severidade:** Alta
2. **Localização:** `MUFASA_Guia_Construcao_Backend.pdf`, páginas 1 e 6 (`fastapi==0.110.0`, `python-jose==3.3.0`, `passlib==1.7.4`, `scikit-learn==1.4.0`)
3. **Descrição da Falha:** FastAPI 0.110.0 exige Starlette abaixo de 0.37, que tem negação de serviço no tratamento de formulário multipart (CVE-2024-47874, corrigida no Starlette 0.40.0). Isso afeta diretamente o `POST /importacoes` planejado, que recebe arquivo. `python-jose` 3.3.0 está no item 2.2-A. `scikit-learn` 1.4.0 tem a CVE-2024-5206 (vazamento de tokens no `TfidfVectorizer`, corrigida na 1.5.0), de baixo impacto aqui (OWASP A06).
4. **Sugestão de Correção:** `requirements.txt` deste pacote:

```text
fastapi>=0.115.6
starlette>=0.40.0
pydantic-settings>=2.6
SQLAlchemy>=2.0.36
psycopg[binary]>=3.2.3
PyJWT>=2.10.1
bcrypt>=4.2.0
# sem python-jose e sem passlib
```

Depois de instalar: `pip freeze > requirements.lock`, versionar o lock e rodar `pip-audit` a cada mudança de dependência.

---

## Prioridade 3: Questões Críticas de Desempenho (Essa Semana)

### 3.1 Refatorar `get_dates_with_content/1`

**Não se aplica:** a função não existe neste projeto.

### 3.2 Parar de Rebuscar dates_with_content em Cada Salvar

**Não se aplica:** não há diário nem fluxo de salvamento desse tipo.

### 3.3 Corrigir Consultas N+1 em ReviewLive

**Não se aplica:** não há ReviewLive. O risco equivalente seria a listagem de alunos calcular o score aluno por aluno. O B3 evita isso: `GET /api/v1/alunos` traz o nível da última avaliação gravada numa única consulta (`consulta_lista_alunos` em `app/api/consultas.py`), e o cálculo do B2 só roda no detalhe de um aluno.

#### 3.3-A Erro de validação devolve o valor enviado, inclusive a senha

1. **Severidade:** Média
2. **Localização:** comportamento padrão do FastAPI, que seria herdado pelo `app/main.py` do guia
3. **Descrição da Falha:** quando um campo falha na validação, o FastAPI devolve por padrão o campo `input` com o valor recebido. Num login com o nome de usuário mal formatado, a resposta repete a senha, que pode ir parar em log de proxy, de navegador ou de ferramenta de monitoramento (OWASP A04/A09; SRS, Seção 3.3).
4. **Sugestão de Correção:** em `app/api/erros.py`:

```python
@app.exception_handler(RequestValidationError)
async def _validacao(request: Request, exc: RequestValidationError):
    campos = [{"campo": ".".join(str(p) for p in e.get("loc", ()) if p != "body"),
               "mensagem": MENSAGENS_VALIDACAO.get(e.get("type"), "Valor inválido.")}
              for e in exc.errors()]
    return resposta_erro(request, 422, "Um ou mais campos estão inválidos.", {"campos": campos})

@app.exception_handler(Exception)
async def _inesperado(request: Request, exc: Exception):
    log.exception("Erro nao tratado na requisicao %s", _id_requisicao(request))   # pilha só no log
    return resposta_erro(request, 500, "Ocorreu um erro inesperado. Informe o código da requisição ao suporte.")
```

Testes: `test_erro_de_validacao_nao_ecoa_a_senha`, `test_erro_500_nao_expoe_pilha_nem_sql`.

---

## Prioridade 4: Questões Médias (Esse Mês)

### 4.1 Adicionar Cabeçalhos de Políticas de Segurança de Conteúdo

#### 4.1-A Sem CSP e demais cabeçalhos de segurança

1. **Severidade:** Média
2. **Localização:** esqueleto do `app/main.py` (guia e `b3/README.md`, seção 10)
3. **Descrição da Falha:** sem `Content-Security-Policy`, `X-Content-Type-Options`, `X-Frame-Options` e `Cache-Control: no-store`, uma resposta JSON pode ser interpretada como HTML pelo navegador (XSS por *content sniffing*), a API pode ser embutida em moldura de outro site e dado pessoal fica em cache de navegador ou proxy (OWASP A05).
4. **Sugestão de Correção:** em `app/api/seguranca.py`:

```python
CSP_API = "default-src 'none'; frame-ancestors 'none'; base-uri 'none'; form-action 'none'"
resposta.headers["Content-Security-Policy"] = CSP_DOCS if e_docs else CSP_API
resposta.headers["X-Content-Type-Options"] = "nosniff"
resposta.headers["X-Frame-Options"] = "DENY"
resposta.headers["Referrer-Policy"] = "no-referrer"
resposta.headers["Cache-Control"] = "no-store"
```

Teste: `test_saude_e_cabecalhos_de_seguranca`.

### 4.2 Remover CDN do Tailwind da Produção

**Não se aplica:** não há Tailwind. O equivalente está abaixo.

#### 4.2-A `/docs` carrega o Swagger UI de CDN externa

1. **Severidade:** Baixa
2. **Localização:** comportamento padrão do FastAPI em `/docs`
3. **Descrição da Falha:** a página `/docs` baixa script e estilo do jsDelivr. Em produção, isso expõe a documentação completa da API a qualquer visitante e faz o navegador de cada usuário contatar um terceiro.
4. **Sugestão de Correção:** em `app/main.py`, a documentação só existe fora de produção:

```python
docs = cfg.docs_habilitada and not cfg.em_producao
app = FastAPI(docs_url="/docs" if docs else None, redoc_url=None,
              openapi_url="/openapi.json" if docs else None)
```

### 4.3 Adicionar Registro de Auditoria

#### 4.3-A Nenhuma trilha de acesso

1. **Severidade:** Média
2. **Localização:** B1 (nenhuma tabela de auditoria no dump); desenho do B3 (`auditoria.py` previsto, não escrito)
3. **Descrição da Falha:** sem registro, não há como saber quem viu o dado socioeconômico de um aluno, nem provar que uma tentativa indevida foi bloqueada. A LGPD exige registro das operações (art. 37), e o SRS exige auditoria de cada leitura sensível (RN07, CA14) (OWASP A09).
4. **Sugestão de Correção:** em `app/api/auditoria.py`, gravando em transação própria para que a negação não apague o próprio registro:

```python
def registrar(request, operacao, resultado, *, usuario=None, id_aluno_alvo=None):
    with banco.obter_engine().begin() as conexao:
        conexao.execute(REGISTRAR_AUDITORIA, {
            "momento": datetime.now(timezone.utc), "id_requisicao": request.state.id_requisicao,
            "id_usuario": getattr(usuario, "id_usuario", None), "perfil": getattr(usuario, "perfil", None),
            "operacao": operacao, "recurso": request.url.path[:200], "id_aluno_alvo": id_aluno_alvo,
            "resultado": resultado, "origem": ip_do_cliente(request)[:45]})
```

No banco, a tabela é só de inserção: o perfil `mufasa_api` não tem `UPDATE` nem `DELETE`, e um gatilho recusa alteração (`sql/b3_complemento.sql`). Senha, token e valores de dado pessoal não entram no registro.

### 4.4 Validar IDs de Projetos nas Preferências

**Não se aplica literalmente:** não há projetos nem preferências. O equivalente é a validação dos identificadores que chegam à API e ao B2.

#### 4.4-A B2 aceita risco "pronto" injetado no dicionário de entrada

1. **Severidade:** Média
2. **Localização:** `app/calculo/score.py` do B2, linhas 312 a 314 (`escolher` / `dados_aluno.get(f"risco_{nome_fator}")`)
3. **Descrição da Falha:** se o dicionário de entrada trouxer `risco_frequencia`, `risco_notas` etc., o valor substitui o cálculo sem nenhuma checagem de faixa. Se algum endpoint futuro repassar o corpo da requisição ao B2 (no chatbot ou numa simulação, por exemplo), o usuário escolhe o próprio score: `{"risco_notas": -1000}` zera o resultado. Hoje o B3 monta o dicionário só com dados do banco, então não há exploração no código atual.
4. **Sugestão de Correção (para o B2):**

```python
def escolher(nome_fator, valor_derivado):
    pronto = dados_aluno.get(f"risco_{nome_fator}")
    if pronto is None:
        return valor_derivado
    try:
        pronto = float(pronto)
    except (TypeError, ValueError):
        return valor_derivado
    if not math.isfinite(pronto) or not 0.0 <= pronto <= 100.0:
        raise ValueError(f"risco_{nome_fator} fora de 0 a 100")
    return pronto
```

Regra para o B3, já seguida em `app/api/integracao.py`: nunca passar ao B2 um dicionário vindo do usuário.

#### 4.4-B Formato da matrícula diverge entre B1 e SRS

1. **Severidade:** Baixa
2. **Localização:** `Parte Samuel BackEnd B1.sql`, linha 240 em diante (`ALU0001`...); SRS v1.1, RN12 (7 dígitos)
3. **Descrição da Falha:** o SRS manda aceitar só 7 dígitos e recusar letras. O banco simulado usa `ALU` + 4 dígitos. Se o B3 seguisse o SRS à risca, nenhum aluno do B1 seria encontrado; se aceitasse qualquer texto, abriria espaço para entrada maliciosa.
4. **Sugestão de Correção:** em `app/api/esquemas.py`, lista fechada com os dois formatos até o B1 migrar:

```python
PADRAO_MATRICULA = r"^(?:\d{7}|ALU\d{4})$"
Matricula = Annotated[str, Path(pattern=PADRAO_MATRICULA)]
```

Quando o B1 adotar a matrícula oficial, remover `|ALU\d{4}`. Teste: `test_matricula_maliciosa_ou_fora_do_formato_e_rejeitada`.

### 4.5 Análise Segura de Inteiros

#### 4.5-A B2 aceita NaN, infinito e valores fora de faixa

1. **Severidade:** Média
2. **Localização:** `app/calculo/score.py` do B2, funções `risco_por_nota` (linha 105), `risco_por_frequencia`, `risco_por_trabalho`, `risco_por_deslocamento`, `risco_por_dependentes`
3. **Descrição da Falha:** `float("nan")` falha em todas as comparações e cai no último `return`, então `risco_por_nota(nan)` devolve 100 (risco máximo) para um dado corrompido. Frequência 150%, média 12 ou horas negativas também passam. Com dado ruim do B1, o aluno recebe uma classificação sem base, o que fere a RN08 e a RN11.
4. **Sugestão de Correção (para o B2):**

```python
import math

def _valido(valor, minimo, maximo):
    if valor is None:
        return None
    try:
        numero = float(valor)
    except (TypeError, ValueError):
        return None
    return numero if math.isfinite(numero) and minimo <= numero <= maximo else None

def risco_por_nota(media):
    media = _valido(media, 0.0, 10.0)
    if media is None:
        return None
    ...
```

O B3 já aplica esse filtro antes de chamar o B2 (`_numero` em `app/api/integracao.py`).

#### 4.5-B B2 quebra com erro 500 quando `faltas` chega vazio

1. **Severidade:** Média
2. **Localização:** `app/calculo/indicadores.py` do B2, linha 27; chamada em `app/calculo/score.py`, linhas 356 a 358
3. **Descrição da Falha:** `dados_aluno.get("faltas", 0)` devolve `None` quando a chave existe com valor vazio, e, havendo aulas previstas, `limite_faltas - None` lança `TypeError`. Para um aluno com aulas previstas e sem faltas lançadas, a requisição inteira responde 500. Contradiz a regra do próprio módulo ("dado ausente retorna None").
4. **Sugestão de Correção (para o B2):**

```python
def calcular_faltas_restantes(aulas_previstas, faltas):
    if aulas_previstas is None or aulas_previstas <= 0 or faltas is None:
        return None
    limite_faltas = int(aulas_previstas * 0.25)
    return max(0, limite_faltas - int(faltas))
```

#### 4.5-C B2 informa "limite de faltas já atingido" quando o dado não existe

1. **Severidade:** Média
2. **Localização:** `app/calculo/indicadores.py` do B2, linhas 24 e 25; `app/calculo/score.py`, linhas 446 a 449
3. **Descrição da Falha:** sem aulas previstas, `calcular_faltas_restantes` devolve `0`, e `explicar_score` diz ao aluno "O limite de faltas já foi atingido". É informação falsa sobre a situação acadêmica, entregue a quem pode desistir por causa dela. O B1 hoje não tem aulas previstas, então isso aconteceria com todos os alunos.
4. **Sugestão de Correção:** no B2, a correção do item 4.5-B (devolver `None`). O B3 já contorna em `app/api/rotas.py`:

```python
# Sem aulas previstas no banco, o "0" do B2 seria lido como limite estourado.
resultado["faltas_restantes"] = None
```

#### 4.5-D Notas do B1 em escala 0 a 100; B2 espera 0 a 10

1. **Severidade:** Média
2. **Localização:** `Parte Samuel BackEnd B1.sql`, linha 130 (`nota_final numeric`) e dados a partir da linha 3339 (7.836 de 8.000 notas acima de 10, como `74.67`)
3. **Descrição da Falha:** `matriculas.nota_final`, `va1`, `va2` e `va3` estão de 0 a 100, enquanto `indicadores_academicos.media_atual`, o `cursos.media_aprovacao` (6) e o B2 usam 0 a 10. Quem calcular a média ponderada a partir de `matriculas` passará 74,67 ao B2, que lerá como nota excelente (risco 0). É a mesma família da inversão de escala que o B2 corrigiu na v2.2. O `banco-evasao/schema.sql` limita a nota a `BETWEEN 0 AND 10`.
4. **Sugestão de Correção (para o B1):**

```sql
UPDATE matriculas SET nota_final = round(nota_final / 10, 1),
                      va1 = round(va1 / 10, 1), va2 = round(va2 / 10, 1), va3 = round(va3 / 10, 1);
ALTER TABLE matriculas ADD CHECK (nota_final BETWEEN 0 AND 10);
```

Até lá, o B3 usa só `indicadores_academicos.media_atual` e descarta qualquer média fora de 0 a 10.

#### 4.5-E Nível `CRITICO` (B2) e `Crítico` (B1)

1. **Severidade:** Baixa
2. **Localização:** `app/calculo/score.py` do B2, linha 50; `Parte Samuel BackEnd B1.sql`, linha 59 (dados com `Crítico`); `banco-evasao/schema.sql` (`CHECK (nivel_risco IN ('Baixo','Moderado','Alto','Crítico'))`)
3. **Descrição da Falha:** gravar a saída do B2 no banco viola o `CHECK` do esquema, e comparar os dois textos falha em silêncio (um filtro por `CRITICO` não acha nenhum aluno do B1).
4. **Sugestão de Correção:** tabela de conversão única em `app/api/integracao.py`, usada em toda leitura e gravação:

```python
NIVEL_DO_BANCO = {"Baixo": "BAIXO", "Moderado": "MODERADO", "Alto": "ALTO", "Crítico": "CRITICO"}
NIVEL_PARA_BANCO = {v: k for k, v in NIVEL_DO_BANCO.items()}
```

Melhor ainda: o B1 adotar o formato do SRS (`CRITICO`) no `CHECK`.

---

## Prioridade 5: Melhorias a Longo Prazo

### 5.1 Implementar Camada de Cache ETS

**Não se aplica:** ETS é do Erlang/Elixir. O ponto equivalente: o limitador de requisições do B3 fica em memória de um processo. Com mais de um worker do uvicorn, cada um conta separado. Para produção, trocar `LimitadorJanela` por Redis (`INCR` com `EXPIRE`).

### 5.2 Busca de Texto Completo PostgreSQL

**Não se aplica hoje:** não há busca por nome. Se o F1 pedir, a busca deve continuar parametrizada e escapar os curingas do `LIKE`:

```python
BUSCA_POR_NOME = text("""
    SELECT id_aluno, nome_ficticio FROM alunos
     WHERE id_curso = :id_curso AND nome_ficticio ILIKE :padrao ESCAPE '\\'
     LIMIT :limite
""")
termo = termo.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_")
conexao.execute(BUSCA_POR_NOME, {"id_curso": usuario.id_curso, "padrao": f"%{termo}%", "limite": 25})
```

Com volume grande, usar a extensão `pg_trgm` com índice GIN.

### 5.3 Paginando Entradas do Diário

#### 5.3-A Listagens sem paginação

1. **Severidade:** Baixa
2. **Localização:** desenho do B3 (`b3/README.md`, seção 4 prevê, mas não havia código)
3. **Descrição da Falha:** uma listagem sem limite devolve os 1.000 alunos de uma vez: exposição maior que a necessária e consulta pesada repetível (negação de serviço barata).
4. **Sugestão de Correção:** em `app/api/esquemas.py`, limite padrão de 25 e máximo de 200, com `LIMIT :limite OFFSET :deslocamento` parametrizado. Teste: `test_filtros_maliciosos_sao_rejeitados` (`limite=1000` recusado).

### 5.4 Mover Todos os Segredos para Variáveis de Ambiente

#### 5.4-A Segredos e artefatos no material entregue

1. **Severidade:** Informativa
2. **Localização:** B1 e B2 inteiros (busca por `password`, `senha`, `secret`, `token` e `api_key`); `app/calculo/__pycache__/*.pyc` e `testes/__pycache__/*.pyc` do B2
3. **Descrição da Falha:** nenhum segredo foi encontrado no código do B1 nem do B2. O `\restrict` do dump é um recurso de segurança do `pg_dump` 16, não uma senha. Dois cuidados: (a) os `.pyc` foram enviados, apesar de o CHANGELOG dizer que os caches foram removidos, e eles guardam o caminho local completo do arquivo na máquina do autor, incluindo o nome de usuário do Windows; (b) o dump traz dados de 1.000 alunos. São nomes fictícios, mas o mesmo procedimento com dado real violaria a LGPD se fosse para o GitHub.
4. **Sugestão de Correção:** configuração só por ambiente, sem padrão para segredo, em `app/config.py`:

```python
class Configuracao(BaseSettings):
    database_url: SecretStr      # obrigatório, sem valor padrão
    jwt_secret: SecretStr        # obrigatório, mínimo de 32 bytes
```

E no repositório: `git rm -r --cached '**/__pycache__' .pytest_cache`, manter o `.gitignore` (que já cobre `.env`, `*.dump` e `dados/`) e nunca versionar dump com dados.

---

## LGPD: coleta apenas do necessário

### L-1 Coleta socioeconômica além do que o cálculo usa

1. **Severidade:** Média
2. **Localização:** `Parte Samuel BackEnd B1.sql`, linhas 180 a 196 (`socioeconomico`) e 37 a 39 (`alunos`)
3. **Descrição da Falha:** o score do B2 usa da tabela socioeconômica só a renda per capita, as horas de trabalho e o tempo de deslocamento. A tabela guarda também renda familiar total, número de moradores, horas de estudo, horas de responsabilidades familiares, distância em km, meio de transporte, ProUni, FIES e desconto de funcionário. Em `alunos` há bairro e tipo de ensino médio, que a RN21 proíbe no cálculo. Guardar dado sem finalidade definida fere a necessidade (art. 6º, III) e aumenta o dano de um vazamento.
4. **Sugestão de Correção:** o B3 já seleciona só o necessário (`SOCIOECONOMICO_RESTRITO` em `app/api/consultas.py`) e não exibe o bairro a nenhuma equipe. Para o B1: para cada coluna, registrar a finalidade no inventário de dados ou removê-la.

```sql
-- Exemplo, se o grupo confirmar que não há uso:
ALTER TABLE socioeconomico DROP COLUMN desconto_funcionario, DROP COLUMN distancia_km;
```

### L-2 Menores de 18 anos sem registro de consentimento do responsável

1. **Severidade:** Média
2. **Localização:** `Parte Samuel BackEnd B1.sql`, tabela `alunos` (163 alunos com `idade` abaixo de 18)
3. **Descrição da Falha:** o art. 14, §1º da LGPD e a RN16 exigem consentimento de um dos pais ou do responsável para dados de saúde de menores. O banco não tem onde registrar isso. Além disso, só a idade é guardada: ela muda sem que o banco saiba, e em pouco tempo o filtro de menor deixa de valer.
4. **Sugestão de Correção:** o B3 recusa o consentimento de saúde dado pelo próprio aluno menor (`registrar_consentimento` em `app/api/rotas.py`) e grava cada concessão e revogação em `consentimentos`, com `concedido_por = 'RESPONSAVEL'` para o termo entregue à secretaria. Para o B1: trocar `idade` por `data_nascimento DATE` (o SRS já prevê, Anexo C) e calcular a idade na consulta.

---

## OWASP Top 10: o que foi verificado e não tem achado

| Categoria | Verificação | Resultado |
|---|---|---|
| A03 Injeção de SQL | B1 é um dump sem SQL dinâmico; B2 não acessa banco; B3 só usa `text()` com parâmetros nomeados | Sem achado. Testes com `' OR '1'='1`, `; DROP TABLE` e `1 OR 1=1` em matrícula, filtros e login, mais uma checagem automática que reprova `text()` com f-string, `+` ou `%` |
| A03 XSS | A API só devolve JSON, com `nosniff` e CSP `default-src 'none'` | Sem achado no back-end. O F1 não deve usar `unsafe_allow_html=True` (Streamlit) nem `dangerouslySetInnerHTML` (React) com texto vindo da API |
| CSRF | A API não usa cookie | Não se aplica. Manter o token em memória no painel (ver `POLITICA_DE_COOKIES.md`) |
| A02 Senha em texto puro ou hash fraco | B1 não tem tabela de usuários; B3 usa bcrypt custo 12 | Sem achado |
| A08 Desserialização insegura | Nenhum `pickle`, `eval` ou `yaml.load` | Sem achado |
| A10 SSRF | Nenhuma requisição de saída | Não se aplica |

## Como validar

```bash
pip install -r requirements.txt
pytest testes/teste_api.py -v     # 38 testes do B3
pip-audit -r requirements.txt     # dependências
```
