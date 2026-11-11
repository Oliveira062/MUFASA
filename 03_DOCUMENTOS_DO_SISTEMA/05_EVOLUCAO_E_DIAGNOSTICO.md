# MUFASA — encontrar erros e evoluir o sistema

Este documento é para quem vai manter o MUFASA. Ele cobre como achar um erro rápido quando algo falha e como mudar o sistema sem quebrar o que já funciona.

## 1. As ferramentas, em resumo

| Ferramenta | Comando ou lugar | Para que serve |
|---|---|---|
| Código de suporte | aparece na tela junto do erro | Liga o que o usuário viu ao registro exato do erro |
| Registros (logs) | pasta `logs/` | Histórico de tudo o que cada serviço fez |
| Diagnóstico | `python -m scripts.diagnostico` | Confere o sistema inteiro e aponta o que está errado |
| Busca por código | `python -m scripts.diagnostico --requisicao <código>` | Acha o erro a partir do código da tela |
| Saúde dos serviços | `/saude` e Administração → Serviços | Diz se cada parte está no ar e com qual versão |
| Registros técnicos | Administração → Registros (tabela `logs_tecnicos`) | Erros gravados no banco, visíveis no painel |
| Migrações | `python -m scripts.migrar` | Muda o banco de forma controlada e registrada |
| Testes automáticos | `pytest` | Garante que a mudança não quebrou nada (201 testes) |
| Versão | `app/__init__.py` e `CHANGELOG.md` | Diz o que mudou em cada versão |

## 2. Quando der erro: o caminho mais rápido

1. **Anote o código que aparece na tela.** Todo erro mostra "Código para o suporte: …":
   - um código como `3f9a1c0b2d4e` veio da API ou do chat;
   - um código como `P-1a2b3c4d` veio do próprio painel.
2. **Procure o código:**
   ```bash
   python -m scripts.diagnostico --requisicao 3f9a1c0b2d4e
   ```
   O comando mostra as linhas do log com aquele código (rota, resposta, tempo e a pilha do erro) e o registro no banco, se houver.
3. **Se não houver código** (por exemplo, "o sistema não abre"), rode o diagnóstico completo:
   ```bash
   python -m scripts.diagnostico
   python -m scripts.diagnostico --saida relatorio.txt      # para enviar a quem vai corrigir
   ```
   Cada item sai como `ok`, `AVISO` ou `FALHA`, com a dica do que fazer. O relatório não contém senha, token nem dado de aluno, então pode ser enviado.
4. **Corrija, rode `pytest` e confira de novo** com o diagnóstico.

## 3. Os registros (logs)

Cada serviço grava na pasta `logs/` (ou em `MUFASA_LOG_DIR`):

| Arquivo | O que tem |
|---|---|
| `api.log`, `chat.log`, `calculo.log`, `painel.log` | Registros estruturados de cada serviço |
| `<serviço>.console.log` | Tudo o que o serviço imprimiu, inclusive erros de inicialização (só pelo `iniciar`) |
| `logs/testes/` | Registros gerados pelos testes |

Formato de uma linha:

```
2026-10-28 08:43:32,109 INFO    [api] mufasa.requisicoes: req=98e431284b85 GET /api/v1/conta/eu -> 200 em 6 ms
   data e hora          nível   serviço  origem           código        rota          resposta  tempo
```

- **O que é registrado:** cada requisição, com código, rota, resposta e tempo. Requisição com erro 500, ou mais lenta que 2 segundos, vira `WARNING`. Erros vêm com a pilha completa.
- **O que nunca é registrado:** senha, token e dado de aluno. A rota aparece como modelo, por exemplo `/alunos/{matricula}`, nunca com a matrícula real.
- **Tamanho:** cada arquivo vai até 5 MB e guarda as 5 últimas cópias (`api.log.1` a `api.log.5`), então a pasta não cresce sem limite.
- **Mais detalhe:** `MUFASA_LOG_NIVEL=DEBUG` no `.env` e reiniciar. Volte para `INFO` depois.

## 4. Isolamento de falhas: o que acontece quando uma parte cai

| Parte que cai | O que o usuário vê | O que se recupera sozinho |
|---|---|---|
| Chat | O assistente mostra "indisponível"; o resto funciona | O `iniciar` (ou o Docker) sobe o chat de novo |
| Cálculo | Os scores param de atualizar; as telas mostram o último cálculo | O serviço volta e processa a fila pendente |
| API | O painel mostra "API indisponível" nas seções e para de insistir por alguns segundos (disjuntor) | A API volta e as telas se atualizam |
| Banco | `/saude` responde 503; o painel avisa | Tudo volta quando o banco volta |
| Uma seção da tela | Só aquela seção mostra o erro com o código | O resto da tela segue normal |

Cada serviço grava um sinal de vida no banco (`servicos_status`). Administração → Serviços e o diagnóstico mostram há quanto tempo cada um deu sinal.

## 5. Como evoluir o sistema

### 5.1 Mudar um valor de regra (nota mínima, cortes, prazos…)

**Não mexa no código.** Use Administração → Parâmetros. Toda alteração fica versionada, com autor, data e justificativa. Nota mínima e cortes de risco viram proposta e só valem após aprovação da coordenação. O recálculo de todos os alunos é automático.

### 5.2 Mudar o banco (nova coluna, tabela, índice)

```bash
python -m scripts.migrar --nova "adicionar telefone do responsavel"
#  cria sql/migracoes/002_adicionar_telefone_do_responsavel.sql com um cabeçalho-modelo
#  escreva o SQL no arquivo
python -m scripts.migrar --listar     # confere: 002 aparece como pendente
python -m scripts.migrar              # aplica (tudo ou nada) e registra em esquema_migracoes
```

Regras:

- **Arquivo aplicado não se edita.** Para corrigir, crie outro. O script percebe a edição pelo hash e para.
- Tabela nova precisa de `GRANT` para o usuário do serviço que vai usá-la (`mufasa_api`, `mufasa_chat` ou `mufasa_calculo`).
- `montar_banco` aplica todas as migrações no fim, então um banco montado do zero já sai atualizado.
- Os testes também aplicam as migrações no banco de teste, então rode `pytest` depois de criar uma.

### 5.3 Mudar o código

| Para mudar… | Mexa em… | E teste em… |
|---|---|---|
| Uma fórmula do score | `app/calculo/score.py` (suba `VERSAO_CODIGO`) | `testes/teste_calculo.py` |
| Uma rota da API | `app/api/rotas_*.py`; o SQL vai em `consultas*.py`, sempre com parâmetros `:nome` | `testes/teste_api.py` ou `teste_fluxos.py` |
| Quem pode ver o quê | `app/api/permissoes.py` e `visibilidade.py` | `testes/teste_api.py` |
| Uma tela | `painel/paginas/<perfil>.py`; cores e selos em `painel/ui.py` | `testes/teste_painel.py` e no navegador |
| Uma resposta do chat | `app/chatbot/intencoes.py` e `servico.py` | `testes/teste_chatbot.py` |
| Uma variável de configuração | `app/config.py`, `.env.example` e `scripts/configurar.py` | `python -m scripts.diagnostico` |

Cuidados que os testes cobram:

- SQL montado com texto variável (f-string ou concatenação) reprova o teste `test_nenhum_sql_montado_com_texto_variavel`. Use sempre parâmetros.
- Toda nova rota de aluno precisa passar pela verificação de escopo, para um perfil não ler aluno de outro.
- Toda seção nova do painel deve ficar dentro de `with ui.secao():`, para um erro nela não derrubar a tela.

### 5.4 Escrever um teste novo

Os testes de banco usam dados pequenos e conhecidos (`testes/conftest.py`, `DADOS` e `USUARIOS`), então o resultado esperado é exato. Modelo:

```python
import pytest
from testes.conftest import entrar

pytestmark = pytest.mark.banco

def test_docente_nao_ve_aluno_de_outra_turma(cliente):
    cab = entrar(cliente, "prof.um")          # devolve o cabeçalho com o token
    r = cliente.get("/api/v1/alunos/ALU0003", headers=cab)
    assert r.status_code == 403                # mesma resposta para "não pode" e "não existe"
```

Rode só o seu teste com `pytest -k docente_nao_ve -v`.

### 5.5 Entregar uma versão nova

1. `pytest`: precisa dar tudo aprovado.
2. `python -m scripts.diagnostico`: precisa dar 0 falha.
3. Suba a versão em `app/__init__.py` (`__version__`), seguindo esta regra:
   - 1.1.**1** para correção;
   - 1.**2**.0 para funcionalidade nova;
   - **2**.0.0 para mudança que exige montar o banco de novo ou muda o contrato da API.
4. Escreva o que mudou no `CHANGELOG.md`.
5. No Docker, troque a tag `mufasa:1.1.0` no `docker-compose.yml` e rode `docker compose up -d --build`.

A versão aparece em `/saude`, na tela Administração → Serviços e no diagnóstico, então dá para saber qual versão está rodando em cada máquina.

## 6. Perguntas frequentes de manutenção

- **Um aluno diz que o nível dele está errado.**
  1. Coordenação → ficha do aluno → histórico: mostra cada cálculo, com os fatores e a versão dos parâmetros.
  2. Se for dado errado, corrija pela carga de dados (Administração → Cargas); o recálculo é automático.
  3. O aluno também pode contestar pela tela dele.
- **O score não atualiza.** Rode o diagnóstico e veja "sinal de vida de calculo" e "fila de recalculo". Se a fila só cresce, veja `logs/calculo.log`.
- **Recalcular todo mundo.** Administração → início → Recalcular, ou `POST /api/v1/calculos`.
- **Trocar a senha de um usuário de banco.** Mude no `.env` e rode `python -m scripts.montar_banco`. Atenção: isso recria o banco; num banco com dados reais, use `ALTER ROLE ... PASSWORD` como postgres.
