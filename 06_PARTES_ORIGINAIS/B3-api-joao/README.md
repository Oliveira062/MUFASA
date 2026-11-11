# B3 — API e Segurança

Módulo da API do MUFASA. Pastas deste módulo no repositório `mufasa-backend`: **`app/api/`** e **`app/main.py`**. Ninguém de fora do B3 altera essas pastas sem pull request revisado pelo B3.

> Responsabilidade no guia de construção: B3. No plano de construção v1.1, a camada de API corresponde às tarefas T10, T11, T13 e T20 (Dérik Sousa Silva).

---

## 1. O que o B3 faz

| Responsabilidade | Entrega |
|---|---|
| Endpoints | Rotas REST que servem o painel (F1) e o chatbot (F2) |
| Autenticação | JWT, perfis e permissões por papel |
| Isolamento | Garantir a RN17: um aluno nunca vê dados de outro |
| Documentação viva | O `/docs` do FastAPI é o contrato com o F1 e o F2 |
| Orquestração | Liga ingestão → cálculo → persistência → resposta |

**O que o B3 não faz:** regra de cálculo dentro do endpoint. O endpoint **chama** o módulo do B2 (`app/calculo/`) e **lê** o banco do B1 (`app/banco/`). Se aparecer uma conta, um peso ou um limiar dentro de `app/api/`, está no lugar errado.

Fluxo entre as camadas:

```
B1 (banco e dados) → B2 (cálculo) → B3 (API) → Interface (F1 painel, F2 chatbot)
```

---

## 2. Como rodar

Pré-requisitos: Python 3.12, PostgreSQL 16 e o ambiente virtual criado (Passos 1 a 5 do guia).

```bash
# 1. Ativar o ambiente virtual
venv\Scripts\activate          # Windows
source venv/bin/activate       # Mac / Linux

# 2. Instalar dependências
pip install -r requirements.txt

# 3. Criar o arquivo .env a partir do modelo (ver seção 8)
cp .env.example .env

# 4. Subir a API
uvicorn app.main:app --reload
```

Conferir:

- http://127.0.0.1:8000/saude → `{"status": "no ar", "sistema": "MUFASA"}`
- http://127.0.0.1:8000/docs → documentação gerada automaticamente

Porta 8000 ocupada? Feche o servidor antigo com `Ctrl + C` ou rode com `--port 8001`.

---

## 3. Estrutura do módulo

```
app/
├── main.py                 # cria o app, registra os routers e o tratador de erros
└── api/
    ├── __init__.py
    ├── rotas.py            # endpoints (começa com dados falsos)
    ├── auth.py             # login, emissão e leitura do JWT, hash de senha
    ├── permissoes.py       # perfis e checagem de acesso (Anexo E do SRS)
    ├── esquemas.py         # modelos Pydantic de entrada e saída (os contratos)
    ├── erros.py            # formato padronizado de erro
    └── auditoria.py        # registro de leitura de dado sensível
testes/
└── teste_api.py
```

---

## 4. Padrões da API (SRS, Anexo D.1)

- Prefixo base: **`/api/v1`**
- JSON em UTF-8
- **Todo endpoint exige autenticação por JWT**, exceto `/saude` e `/auth/token`
- Paginação: padrão de 25 registros, máximo de 200
- Identificador de requisição em toda resposta, para cruzar com a auditoria
- Limite: 120 requisições por minuto por usuário; 20 por minuto no chat
- Matrícula é sempre **texto** com exatamente 7 dígitos (`"0012345"`, nunca `12345`)
- Nível de risco sempre em maiúsculas: `BAIXO`, `MODERADO`, `ALTO`, `CRITICO`, `INDETERMINADO`

### Erro padronizado

Nenhum erro devolve rastreamento de pilha, nome de tabela ou consulta SQL.

```json
{
  "titulo": "Permissao insuficiente",
  "status": 403,
  "detalhe": "O perfil DOCENTE nao tem acesso a dados socioeconomicos deste aluno.",
  "requisicao": "3f9a-b21"
}
```

Acesso negado a outro aluno **não revela se o aluno existe** (RN07).

---

## 5. Endpoints

| Método | Endpoint | Perfis | Função | Sprint |
|---|---|---|---|---|
| GET | `/saude` | Público | Verificação de disponibilidade | 1 ✅ |
| POST | `/auth/token` | Todos | Autentica e devolve o token | 2 |
| GET | `/alunos` | Docente, Coordenação, Núcleo | Lista com filtros | 2 |
| GET | `/alunos/{matricula}` | Idem | Perfil, com campos ocultados conforme o perfil | 2 |
| GET | `/alunos/{matricula}/score` | Idem + o próprio aluno | Score com fatores e modificadores | 2 |
| GET | `/alunos/{matricula}/historico` | Idem | Série histórica (RN09) | 2 |
| GET | `/alunos/{matricula}/recomendacoes` | Coordenação, Núcleo | Recomendações com o fator de origem | 3 |
| POST | `/importacoes` | Administração | Envia arquivo e inicia a carga | 3 |
| GET | `/importacoes/{id}` | Administração | Situação da carga e relatório de rejeições | 3 |
| POST | `/calculos` | Administração | Dispara recálculo total ou filtrado | 3 |
| GET · PATCH | `/alertas`, `/alertas/{id}` | Coordenação, Núcleo | Fila priorizada e mudança de estado | 3 |
| POST | `/alertas/{id}/acoes` | Coordenação, Núcleo | Registra ação, causa e desfecho | 3 |
| POST | `/alertas/{id}/divergencia` | Docente, Coordenação | Marca classificação equivocada | 3 |
| GET · POST | `/agendamentos` | Aluno, Coordenação, Núcleo | Consulta e solicita agendamento (RN14) | 4 |
| GET | `/indicadores/agregados` | Coordenação, Direção | Agregados com supressão de grupos < 5 | 4 |
| POST | `/chat/consultas` | Autenticados | Pergunta em linguagem natural | 4 |
| GET · PUT | `/parametros` | Administração | Leitura e alteração versionada | 4 |
| GET | `/auditoria` | Encarregado de dados | Trilha de acessos | 4 |

A coluna Sprint é uma sugestão de ordem; ajustem no planejamento.

> **Atenção à divergência:** o guia usa `/alunos/{matricula}/risco` como exemplo; o SRS define `/api/v1/alunos/{matricula}/score`. Este README segue o SRS. Avisem o F1 e o F2 antes de mudar.

---

## 6. Perfis e permissões (SRS, Anexo E)

A autorização é verificada **no servidor, em todo endpoint**. Esconder um botão na tela não é controle de acesso.

| Perfil | Alcance | Restrição |
|---|---|---|
| `ALUNO` | Apenas o próprio perfil | Nunca vê dado de outro aluno (RN17) |
| `DOCENTE` | Alunos das suas turmas | Não vê renda, trabalho, moradia nem saúde; vê "fator encaminhado ao núcleo de apoio" |
| `COORDENACAO` | Alunos do seu curso | Vulnerabilidade só em faixa qualitativa; não vê natureza de dado de saúde |
| `NUCLEO_APOIO` | Alunos com alerta atribuído | Único com valores socioeconômicos e natureza de saúde |
| `FINANCEIRO` | Alunos com fator financeiro no alerta | Não vê saúde nem desempenho detalhado |
| `DIRECAO` | Somente agregados | Nunca vê nome ou matrícula; grupos < 5 suprimidos |
| `ADMIN` | Configuração, cargas, usuários | Sem leitura do conteúdo dos dados |
| `ENCARREGADO_DADOS` | Trilha de auditoria | Não vê os dados em si |

### Login do aluno (RN12)

- Matrícula é **identificador, não senha**. O login exige um segundo elemento: senha, código no e-mail institucional ou login único da universidade.
- Bloqueio após **5 tentativas** malsucedidas.
- Sessão expira após inatividade.
- Tentativa de acessar com a matrícula de outro aluno é bloqueada e registrada.

---

## 7. Checklist de segurança (SRS, Seção 4.1 e RN18)

- [ ] Senhas com **bcrypt custo ≥ 12** (ou Argon2id). Nunca texto puro, MD5 ou SHA-1
- [ ] CPF nunca legível: só hash com sal institucional
- [ ] Nenhum segredo no repositório: senha do banco, chave do JWT e sal ficam no `.env`, que está no `.gitignore`
- [ ] Consultas só parametrizadas ou via SQLAlchemy. **Proibido** montar SQL concatenando texto
- [ ] Toda leitura de dado sensível e de perfil individual gravada na auditoria (autor, data, aluno, campo, operação, origem)
- [ ] Erros sem stack trace, nome de tabela ou SQL
- [ ] Em produção: HTTPS com TLS 1.2+; HTTP simples é redirecionado
- [ ] Chatbot (RN06): sem SQL livre; só intenções de lista fechada com consultas aprovadas; usuário de banco somente leitura; escopo aplicado no servidor; limite de linhas em toda consulta
- [ ] Durante as sprints, **só dados simulados**. Dado real nunca vai para o GitHub

---

## 8. Variáveis de ambiente

Arquivo `.env.example` (este sim vai para o repositório, sem valores reais):

```env
DATABASE_URL=postgresql://postgres:SUA_SENHA@localhost:5432/mufasa
JWT_SECRET=troque-por-uma-chave-longa-e-aleatoria
JWT_ALGORITMO=HS256
JWT_EXPIRA_MINUTOS=30
CPF_SAL=troque-por-um-sal-aleatorio
```

Para gerar uma chave: `python -c "import secrets; print(secrets.token_hex(32))"`

---

## 9. Contratos

### Contrato 2 — o que o B2 entrega ao B3

Formato mínimo combinado no guia:

```json
{
  "matricula": "2024001",
  "score": 63,
  "nivel": "ALTO",
  "fatores_principais": ["frequencia", "notas", "trabalho"],
  "faltas_restantes": 0,
  "recomendacao": "contato em ate 5 dias uteis"
}
```

O formato completo, a ser congelado ao fim da Sprint 2, está no SRS (Anexo A, item B.7): inclui versão do modelo e dos parâmetros, completude, origem do nível (`FAIXA` ou `SOBREPOSICAO`), fatores com valor, peso, contribuição e explicação em português, modificadores, histórico, tendência e o aviso metodológico. **A API devolve a explicação junto com o score** (RN04), sempre.

### O que o B3 entrega à Interface

A URL da API e a página `/docs`. O F1 e o F2 descobrem o que podem pedir por ela, sem precisar perguntar. Todo endpoint novo só está pronto quando aparece no `/docs` com exemplo de resposta.

Os contratos completos ficam em `CONTRATOS.md` na raiz do repositório.

---

## 10. Ordem de trabalho do B3

1. **Esqueleto** (Passo 7 do guia): `app/main.py` com `/saude`. ✅
2. **Rotas com dados falsos** em `app/api/rotas.py`, para o F1 e o F2 começarem hoje:

   ```python
   # app/api/rotas.py
   from fastapi import APIRouter

   router = APIRouter(prefix="/api/v1")

   @router.get("/alunos/{matricula}/score")
   def score_do_aluno(matricula: str):
       # Dados falsos até o módulo do B2 ficar pronto
       return {"matricula": matricula, "score": 63, "nivel": "ALTO"}
   ```

   ```python
   # app/main.py
   from fastapi import FastAPI
   from app.api.rotas import router

   app = FastAPI(title="MUFASA", version="0.1.0")
   app.include_router(router)

   @app.get("/saude")
   def verificar_saude():
       return {"status": "no ar", "sistema": "MUFASA"}
   ```

   Depois troca-se o conteúdo por dentro e nada quebra do lado da Interface.
3. **Autenticação JWT** com os perfis e o isolamento da RN17.
4. **Trocar os dados falsos** pelas chamadas reais ao módulo do B2 e ao banco do B1.
5. Upload, alertas, agendamentos, chat e auditoria, na ordem da tabela da seção 5.

Fluxo de Git: nunca programar na `main`.

```bash
git checkout main
git pull
git checkout -b feat/endpoint-score
# ... trabalho ...
git add .
git commit -m "Endpoint de score com dados falsos"
git push -u origin feat/endpoint-score
```

Abrir pull request e pedir revisão a outro integrante.

---

## 11. Testes

```bash
pytest testes/teste_api.py
```

Testes mínimos que o B3 deve ter (ligados aos critérios de aceite do SRS):

| Teste | Critério |
|---|---|
| Matrícula com 6 ou 8 dígitos, letras ou espaços é rejeitada | CA04 |
| Login só com matrícula, sem segundo fator, falha | CA04 |
| Aluno A pedindo o score do aluno B recebe 403 e gera registro de auditoria | CA14 |
| Docente não recebe renda, trabalho, moradia nem saúde | RN07 |
| Direção não recebe nome nem matrícula; grupos < 5 somem | CA19 |
| Resposta de score sempre traz fatores com número concreto | CA08 |
| Erro 500 não expõe stack trace nem SQL | Seção 3.3 do SRS |
| Chatbot recusa pedido de alteração e "ignore suas regras", e registra | CA15 |

Antes da integração, validar os endpoints também no **Postman** (RF05).

---

## 12. Definição de pronto

Um endpoint só está pronto quando:

- está na `main` via pull request revisado por outra pessoa;
- aparece no `/docs` com exemplo de entrada e saída;
- exige autenticação e checa o perfil no servidor;
- tem teste automatizado de permissão;
- não tem segredo no código;
- o F3 validou contra o critério de aceite.

---

## 13. Pendências que afetam o B3

- [ ] Qual segundo fator para o aluno: senha, código por e-mail ou login único da universidade?
- [ ] Painel em Streamlit ou React (muda como o F1 consome a API e se precisa de CORS)
- [ ] Nomes finais dos campos (Contrato 3): `matricula` ou `ra`; frequência `68.0` ou `0.68`
- [ ] Rota de risco: `/risco` (guia) ou `/score` (SRS)
- [ ] Versões no `requirements.txt`: o `passlib` está sem manutenção e costuma dar aviso ou erro com versões novas do `bcrypt`; avaliar usar `bcrypt` direto (e `PyJWT` no lugar de `python-jose`) antes de escrever o `auth.py`

---

## 14. Erros comuns

| Sintoma | Causa | Solução |
|---|---|---|
| `ModuleNotFoundError: fastapi` | Ambiente virtual não ativado | Ativar e conferir o `(venv)` |
| `ImportError` entre pastas | Falta `__init__.py` | Criar o arquivo vazio na pasta |
| Erro de conexão com o banco | PostgreSQL parado ou senha errada no `.env` | Conferir serviço e `DATABASE_URL` |
| `401` em tudo | Token ausente ou expirado | Pegar novo token em `/api/v1/auth/token` e mandar no cabeçalho `Authorization: Bearer ...` |
| Funciona na sua máquina e não na do colega | Biblioteca fora do `requirements.txt` | Adicionar e avisar o grupo |

---

Referências: *MUFASA — Guia de Construção do Back-end*; *SRS v1.1* (Seções 3.3, 4.1, RN06, RN07, RN12, RN17, RN18, Anexos D e E); *Plano de Construção v1.1* (T10, T11, T13, T20).
