"""
Testes de ponta a ponta dos fluxos do painel (F1) contra a API e o banco de
teste: primeiro acesso, fila de alertas, encerramento (CA20), agendamento
(RN14), parametros versionados (RN22), carga de CSV (RN08), paineis com
supressao (CA19), area do aluno (RN17), administracao e encarregado.

Rodam depois de teste_api e teste_chatbot (ordem alfabetica): mudam
parametros e dados do banco de teste, nunca do banco principal.

    pytest testes/teste_fluxos.py -v
"""

import io
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

import pytest

from testes.conftest import URLS, calcular_tudo, entrar, sql

FUSO = ZoneInfo("America/Sao_Paulo")


def um(cliente, consulta, **p):
    linhas = sql(cliente, consulta, p)
    return list(linhas[0].values())[0] if linhas else None


def alerta_de(cliente, aluno):
    return um(cliente, "SELECT id_alerta FROM alertas WHERE id_aluno = :a AND situacao <> 'ENCERRADO' "
                       "ORDER BY id_alerta DESC LIMIT 1", a=aluno)


# ---------------------------------------------------------------------------
# Conta e primeiro acesso
# ---------------------------------------------------------------------------

def test_conta_eu_mostra_perfil_e_pendencias(cliente):
    r = cliente.get("/api/v1/conta/eu", headers=entrar(cliente, "coord.ia"))
    assert r.status_code == 200
    eu = r.json()
    assert eu["perfil"] == "COORDENACAO" and eu["termo_pendente"] is False and eu["deve_trocar_senha"] is False


def test_conta_nova_exige_trocar_senha_antes_de_usar(cliente):
    r = cliente.post("/api/v1/admin/usuarios", headers=entrar(cliente, "admin"),
                     json={"login": "nae.novo", "nome": "NAE Novo", "perfil": "NUCLEO_APOIO", "id_curso": "CUR01"})
    assert r.status_code == 201, r.text
    provisoria = r.json()["senha_provisoria"]
    cab = entrar(cliente, "nae.novo", senha=provisoria, perfil="NUCLEO_APOIO")
    bloqueado = cliente.get("/api/v1/alertas", headers=cab)
    assert bloqueado.status_code == 403 and bloqueado.headers.get("X-Pendencia") in ("senha", "termo")
    # Senha fraca ou com o login dentro e recusada.
    fraca = cliente.post("/api/v1/conta/senha", headers=cab, json={"senha_atual": provisoria, "senha_nova": "nae.novo123"})
    assert fraca.status_code == 422
    ok = cliente.post("/api/v1/conta/senha", headers=cab,
                      json={"senha_atual": provisoria, "senha_nova": "Acolhimento2026"})
    assert ok.status_code in (200, 204), ok.text
    cab = entrar(cliente, "nae.novo", senha="Acolhimento2026", perfil="NUCLEO_APOIO")
    assert cliente.post("/api/v1/conta/termo", headers=cab, json={"versao": "1.0", "aceito": True}).status_code in (200, 201, 204)
    assert cliente.get("/api/v1/alertas", headers=cab).status_code == 200


def test_admin_nao_le_dado_de_aluno(cliente):
    cab = entrar(cliente, "admin")
    assert cliente.get("/api/v1/alunos", headers=cab).status_code == 403
    assert cliente.get("/api/v1/alunos/ALU0001/score", headers=cab).status_code == 403


# ---------------------------------------------------------------------------
# Fila de alertas e encerramento (RN03, RF18, CA20, RN19)
# ---------------------------------------------------------------------------

def test_fila_da_coordenacao_tem_critico_primeiro(cliente):
    r = cliente.get("/api/v1/alertas", headers=entrar(cliente, "coord.ia"))
    assert r.status_code == 200
    itens = r.json()["itens"]
    assert itens and itens[0]["nivel"] == "CRITICO"
    assert all(i["matricula"] != "ALU0003" for i in itens)  # outro curso


def test_nae_ve_so_alertas_atribuidos_a_ele(cliente):
    cab = entrar(cliente, "nucleo.ia")
    id_nae = um(cliente, "SELECT id_usuario FROM usuarios WHERE login = 'nucleo.ia'")
    itens = cliente.get("/api/v1/alertas", headers=cab).json()["itens"]
    ids = {i["id_alerta"] for i in itens}
    atribuidos = {l["id_alerta"] for l in sql(cliente, "SELECT id_alerta FROM alertas WHERE id_responsavel = :u "
                                                       "AND situacao <> 'ENCERRADO'", {"u": id_nae})}
    assert ids == atribuidos


def test_ciclo_do_alerta_atribuir_agir_encerrar(cliente):
    coord = entrar(cliente, "coord.ia")
    alerta = alerta_de(cliente, "ALU0001")
    assert alerta, "ALU0001 (Critico) deveria ter alerta aberto"
    id_nae = um(cliente, "SELECT id_usuario FROM usuarios WHERE login = 'nucleo.ia'")
    assert cliente.patch(f"/api/v1/alertas/{alerta}", headers=coord, json={"id_responsavel": id_nae}).status_code == 200
    nae = entrar(cliente, "nucleo.ia")
    detalhe = cliente.get(f"/api/v1/alertas/{alerta}", headers=nae)
    assert detalhe.status_code == 200 and detalhe.json()["pode_gerenciar"] is True
    encerrar = {"causa": "FINANCEIRA", "desfecho": "PERMANECEU", "houve_contato": True,
                "canal_contato": "PRESENCIAL", "acoes_executadas": "Conversa e encaminhamento ao auxilio."}
    # CA20: sem nenhuma acao registrada, nao encerra.
    assert cliente.post(f"/api/v1/alertas/{alerta}/encerramento", headers=nae, json=encerrar).status_code in (409, 422)
    acao = cliente.post(f"/api/v1/alertas/{alerta}/acoes", headers=nae,
                        json={"tipo_acao": "CONVERSA", "descricao": "Conversa de acolhimento.", "visivel_aluno": True})
    assert acao.status_code in (200, 201), acao.text
    r = cliente.post(f"/api/v1/alertas/{alerta}/encerramento", headers=nae, json=encerrar)
    assert r.status_code in (200, 201), r.text
    assert um(cliente, "SELECT situacao FROM alertas WHERE id_alerta = :a", a=alerta) == "ENCERRADO"
    # O aluno ve o registro marcado como visivel.
    regs = cliente.get("/api/v1/aluno/acompanhamento", headers=entrar(cliente, "ALU0001")).json()["registros"]
    assert any("acolhimento" in (r.get("descricao") or "") for r in regs)


def test_canal_de_emergencia_so_para_critico(cliente):
    # Alerta Alto controlado para ALU0002 (o calculo deixou ALU0002 em Baixo).
    sql(cliente, "INSERT INTO alertas (id_aluno, id_score_origem, nivel, prazo_em) "
                 "SELECT 'ALU0002', id_score, 'ALTO', now() + interval '5 days' FROM vw_score_atual "
                 "WHERE id_aluno = 'ALU0002'")
    alto = alerta_de(cliente, "ALU0002")
    coord = entrar(cliente, "coord.ia")
    cliente.post(f"/api/v1/alertas/{alto}/acoes", headers=coord,
                 json={"tipo_acao": "CONVERSA", "descricao": "Contato feito.", "visivel_aluno": False})
    r = cliente.post(f"/api/v1/alertas/{alto}/encerramento", headers=coord, json={
        "causa": "ACADEMICA", "desfecho": "PERMANECEU", "houve_contato": True, "canal_contato": "EMERGENCIA_RN19",
        "acoes_executadas": "Contato pelo canal de emergencia."})
    assert r.status_code in (403, 409, 422), r.text
    assert um(cliente, "SELECT situacao FROM alertas WHERE id_alerta = :a", a=alto) != "ENCERRADO"


# ---------------------------------------------------------------------------
# Agendamento (RN14)
# ---------------------------------------------------------------------------

def _horario(dias: int) -> str:
    d = (datetime.now(FUSO) + timedelta(days=dias)).replace(hour=10, minute=0, second=0, microsecond=0)
    return d.isoformat()


def test_intervalo_minimo_entre_atendimentos(cliente):
    cab = entrar(cliente, "ALU0002")  # ALU0002 nao e Critico: sem excecao
    primeiro = cliente.post("/api/v1/agendamentos", headers=cab, json={"inicio": _horario(2)})
    assert primeiro.status_code == 201, primeiro.text
    segundo = cliente.post("/api/v1/agendamentos", headers=cab, json={"inicio": _horario(5)})
    assert segundo.status_code == 409
    assert "Próxima data possível" in segundo.json()["detalhe"]
    assert um(cliente, "SELECT count(*) FROM agendamentos_recusas WHERE id_aluno = 'ALU0002'") >= 1
    assert cliente.post("/api/v1/agendamentos", headers=cab, json={"inicio": _horario(20)}).status_code == 201


def test_aluno_nao_agenda_para_outro(cliente):
    r = cliente.post("/api/v1/agendamentos", headers=entrar(cliente, "ALU0002"),
                     json={"matricula": "ALU0001", "inicio": _horario(30)})
    assert um(cliente, "SELECT count(*) FROM agendamentos WHERE id_aluno = 'ALU0001'") == 0 or r.status_code != 201


# ---------------------------------------------------------------------------
# Area do aluno (RN17)
# ---------------------------------------------------------------------------

def test_situacao_do_aluno_sem_numero_de_score(cliente):
    r = cliente.get("/api/v1/aluno/situacao", headers=entrar(cliente, "ALU0001"))
    assert r.status_code == 200
    s = r.json()
    assert "score" not in s and "evasão" not in s["mensagem"].lower()
    assert s["situacao"] == "Acompanhamento imediato" and s["canal_imediato"]  # Critico: canal imediato
    disc = cliente.get("/api/v1/aluno/disciplinas", headers=entrar(cliente, "ALU0001")).json()
    calculo = next(d for d in disc["disciplinas"] if d["disciplina"] == "Cálculo I")
    assert calculo["va2"] == 0 and calculo["frequencia_abaixo_do_minimo"] is True


def test_aluno_contesta_fator(cliente):
    r = cliente.post("/api/v1/aluno/contestacoes", headers=entrar(cliente, "ALU0001"),
                     json={"fator": "frequencia", "descricao": "Minha frequencia em Calculo I esta errada."})
    assert r.status_code == 201
    assert um(cliente, "SELECT count(*) FROM solicitacoes_titular WHERE id_aluno = 'ALU0001' AND tipo = 'CORRECAO'") >= 1


# ---------------------------------------------------------------------------
# Paineis (RF07, CA19)
# ---------------------------------------------------------------------------

def test_painel_da_gestao_agrega_e_suprime(cliente):
    r = cliente.get("/api/v1/paineis/visao-geral", headers=entrar(cliente, "direcao"))
    assert r.status_code == 200
    v = r.json()
    assert "ALU00" not in r.text and "Julia" not in r.text
    for d in v["distribuicao"]:
        assert d["total"] is None or d["total"] == 0 or d["total"] >= 5
    if v["houve_supressao"]:
        assert v["alunos"] is None and all(d.get("pct") is None for d in v["distribuicao"])


def test_aluno_e_docente_nao_abrem_paineis(cliente):
    for login in ("ALU0001", "prof.um"):
        assert cliente.get("/api/v1/paineis/visao-geral", headers=entrar(cliente, login)).status_code == 403


def test_analises_do_painel(cliente):
    r = cliente.get("/api/v1/paineis/analises", headers=entrar(cliente, "coord.ia"))
    assert r.status_code == 200
    assert {"evolucao", "fatores_frequentes", "comparacao", "eficacia"} <= set(r.json())


# ---------------------------------------------------------------------------
# Carga de CSV (RN08: tudo ou nada)
# ---------------------------------------------------------------------------

def _enviar(cliente, tipo, conteudo: str):
    return cliente.post("/api/v1/importacoes", headers=entrar(cliente, "admin"), data={"tipo": tipo},
                        files={"arquivo": ("carga.csv", io.BytesIO(conteudo.encode("utf-8")), "text/csv")})


def test_carga_com_erro_nao_aplica_nada(cliente):
    r = _enviar(cliente, "INDICADORES", "id_aluno;periodo_letivo;faltas_total;atividades_pendentes;"
                                        "disciplinas_reprovadas_historico;media_semestre_anterior\n"
                                        "ALU0001;2026/2;3;1;0;7.0\nALU9999;2026/2;-1;x;0;20\n")
    assert r.status_code == 201, r.text
    corpo = r.json()
    assert corpo["situacao"] == "COM_ERROS" and corpo["linhas_com_erro"] == 1
    assert {e["campo"] for e in corpo["rejeicoes"]} >= {"id_aluno"}
    assert cliente.post(f"/api/v1/importacoes/{corpo['id_carga']}/confirmacao",
                        headers=entrar(cliente, "admin")).status_code == 409


def test_carga_valida_e_aplicada_e_recalcula(cliente):
    from sqlalchemy import create_engine

    from app.servico_calculo.cargas import aplicar_proxima_carga
    r = _enviar(cliente, "INDICADORES", "id_aluno;periodo_letivo;faltas_total;atividades_pendentes;"
                                        "disciplinas_reprovadas_historico;media_semestre_anterior\n"
                                        "ALU0002;2026/2;1;0;0;8.5\n")
    corpo = r.json()
    assert corpo["situacao"] == "VALIDADA", corpo
    # O mesmo arquivo de novo e recusado (hash SHA-256).
    assert _enviar(cliente, "INDICADORES", "id_aluno;periodo_letivo;faltas_total;atividades_pendentes;"
                                           "disciplinas_reprovadas_historico;media_semestre_anterior\n"
                                           "ALU0002;2026/2;1;0;0;8.5\n").status_code == 409
    assert cliente.post(f"/api/v1/importacoes/{corpo['id_carga']}/confirmacao",
                        headers=entrar(cliente, "admin")).status_code == 200
    engine = create_engine(URLS["CALCULO_DATABASE_URL"])
    assert aplicar_proxima_carga(engine) == corpo["id_carga"]
    engine.dispose()
    assert um(cliente, "SELECT faltas_total FROM indicadores_academicos WHERE id_aluno = 'ALU0002'") == 1
    assert um(cliente, "SELECT situacao FROM cargas WHERE id_carga = :c", c=corpo["id_carga"]) == "APLICADA"


# ---------------------------------------------------------------------------
# Parametros versionados (RN22, Anexo B)
# ---------------------------------------------------------------------------

def test_admin_nao_altera_parametro_da_coordenacao(cliente):
    r = cliente.put("/api/v1/parametros/INTERVALO_ATENDIMENTOS", headers=entrar(cliente, "admin"),
                    json={"valor": 10, "justificativa": "Teste de permissao do admin."})
    assert r.status_code == 403


def test_nota_minima_precisa_de_aprovacao_e_gera_versao(cliente):
    admin, coord = entrar(cliente, "admin"), entrar(cliente, "coord.ia")
    versao_antes = um(cliente, "SELECT max(versao) FROM parametros_versoes")
    r = cliente.put("/api/v1/parametros/NOTA_MINIMA", headers=admin,
                    json={"valor": 6.5, "justificativa": "Teste: regimento novo pede 6,5."})
    assert r.status_code == 200 and r.json()["situacao"] == "PENDENTE"
    assert um(cliente, "SELECT valor FROM parametros WHERE chave = 'NOTA_MINIMA'") == 6  # ainda nao vale
    proposta = r.json()["id_proposta"]
    d = cliente.post(f"/api/v1/parametros/propostas/{proposta}/decisao", headers=coord, json={"aprovar": True})
    assert d.status_code == 200 and d.json()["versao"] == versao_antes + 1
    assert float(um(cliente, "SELECT valor FROM parametros WHERE chave = 'NOTA_MINIMA'")) == 6.5
    calcular_tudo(URLS["CALCULO_DATABASE_URL"])
    assert um(cliente, "SELECT min(versao_parametros) FROM vw_score_atual") == versao_antes + 1
    # Historico preservado: scores antigos continuam com a versao que os gerou.
    assert um(cliente, "SELECT count(*) FROM scores_risco WHERE versao_parametros = :v", v=versao_antes) > 0


def test_valor_fora_da_faixa_e_recusado(cliente):
    r = cliente.put("/api/v1/parametros/INTERVALO_ATENDIMENTOS", headers=entrar(cliente, "coord.ia"),
                    json={"valor": 999, "justificativa": "Valor absurdo para testar a faixa."})
    assert r.status_code == 422


# ---------------------------------------------------------------------------
# Encarregado de dados
# ---------------------------------------------------------------------------

def test_encarregado_responde_pedido(cliente):
    cliente.post("/api/v1/privacidade/solicitacoes", headers=entrar(cliente, "ALU0001"),
                 json={"tipo": "PORTABILIDADE", "descricao": "Quero meus dados."})
    pedido = um(cliente, "SELECT id_solicitacao FROM solicitacoes_titular WHERE tipo = 'PORTABILIDADE' "
                         "ORDER BY id_solicitacao DESC LIMIT 1")
    r = cliente.patch(f"/api/v1/privacidade/solicitacoes/{pedido}", headers=entrar(cliente, "encarregado"),
                      json={"situacao": "ATENDIDA"})
    assert r.status_code == 200
    assert um(cliente, "SELECT situacao FROM solicitacoes_titular WHERE id_solicitacao = :p", p=pedido) == "ATENDIDA"
    assert cliente.patch(f"/api/v1/privacidade/solicitacoes/{pedido}", headers=entrar(cliente, "coord.ia"),
                         json={"situacao": "NEGADA"}).status_code == 403


# ---------------------------------------------------------------------------
# Isolamento de servicos e diagnostico
# ---------------------------------------------------------------------------

def test_saude_responde_503_quando_o_banco_cai():
    from fastapi.testclient import TestClient

    from app.fabrica import criar_servico

    def engine_quebrado():
        raise ConnectionError("banco fora do ar")

    app = criar_servico("api", "Teste", (), engine_quebrado, sinal_de_vida=False)
    with TestClient(app) as tc:
        r = tc.get("/saude")
    assert r.status_code == 503 and r.json()["banco"] == "indisponível" and "versao" in r.json()


def test_chat_e_api_sao_servicos_separados(cliente, cliente_chat):
    cab = entrar(cliente, "coord.ia")
    assert cliente_chat.get("/api/v1/alunos", headers=cab).status_code == 404
    assert cliente.post("/api/v1/chat/consultas", headers=cab, json={"texto": "oi"}).status_code == 404


def test_migracoes_registradas(cliente):
    assert um(cliente, "SELECT count(*) FROM esquema_migracoes WHERE arquivo LIKE '001_%'") == 1


def test_exportacao_csv_protege_contra_formula():
    import sys
    from pathlib import Path
    sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "painel"))
    import ui
    texto = ui.csv_exportacao([{"nome": "=HYPERLINK(\"x\")", "n": 1}], ["nome", "n"], "Teste", "COORDENACAO").decode("utf-8-sig")
    assert "'=HYPERLINK" in texto and ("Confidencial" in texto or "LGPD" in texto)
