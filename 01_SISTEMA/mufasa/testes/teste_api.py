"""
Testes do B3 (SRS: CA04, CA08, CA14, CA19, RN07, RN12, RN17, Secao 3.3) no
PostgreSQL de teste (ver conftest.py): mesma estrutura da producao, dados
controlados, e a API conectada com o perfil restrito mufasa_api.

    pytest testes/teste_api.py -v
"""

from datetime import datetime, timedelta, timezone

import jwt
import pytest

from app.api.auth import gerar_hash_senha
from app.api.erros import MSG_ACESSO_NEGADO
from testes.conftest import JWT_TESTE, SENHA, entrar, sql


def contar(cliente, consulta, **params):
    return list(sql(cliente, consulta, params)[0].values())[0]


# ---------------------------------------------------------------------------
# Basico e cabecalhos
# ---------------------------------------------------------------------------

def test_saude_e_cabecalhos_de_seguranca(cliente):
    r = cliente.get("/saude")
    assert r.status_code == 200
    assert r.headers["X-Content-Type-Options"] == "nosniff"
    assert r.headers["X-Frame-Options"] == "DENY"
    assert "default-src 'none'" in r.headers["Content-Security-Policy"]
    assert r.headers["Cache-Control"] == "no-store"
    assert r.headers["X-Request-ID"]


def test_endpoint_sem_token_retorna_401(cliente):
    r = cliente.get("/api/v1/alunos/ALU0001/score")
    assert r.status_code == 401
    assert set(r.json()) >= {"titulo", "status", "detalhe", "requisicao"}


# ---------------------------------------------------------------------------
# Autenticacao (RN12, CA04)
# ---------------------------------------------------------------------------

def test_login_so_com_matricula_falha(cliente):
    r = cliente.post("/api/v1/auth/token", json={"login": "ALU0001"})
    assert r.status_code == 422


def test_login_com_senha_errada_falha_sem_revelar_se_existe(cliente):
    a = cliente.post("/api/v1/auth/token", json={"login": "ALU0001", "senha": "errada", "perfil": "ALUNO"})
    b = cliente.post("/api/v1/auth/token", json={"login": "ALU9999", "senha": "errada", "perfil": "ALUNO"})
    assert a.status_code == b.status_code == 401
    assert a.json()["detalhe"] == b.json()["detalhe"]
    sql(cliente, "UPDATE usuarios SET falhas_login = 0 WHERE login = 'ALU0001'")


def test_bloqueio_apos_cinco_falhas(cliente):
    sql(cliente, "INSERT INTO usuarios (login, senha_hash, perfil, id_aluno, deve_trocar_senha) "
                 "VALUES ('bloq.teste', :h, 'ALUNO', 'ALU0003', FALSE)", {"h": gerar_hash_senha(SENHA)})
    for _ in range(5):
        r = cliente.post("/api/v1/auth/token", json={"login": "bloq.teste", "senha": "errada", "perfil": "ALUNO"})
        assert r.status_code == 401
    # Mesmo com a senha certa, continua bloqueado.
    r = cliente.post("/api/v1/auth/token", json={"login": "bloq.teste", "senha": SENHA, "perfil": "ALUNO"})
    assert r.status_code in (401, 423)
    assert contar(cliente, "SELECT COUNT(*) FROM auditoria_acessos WHERE operacao='LOGIN' AND resultado='BLOQUEADO'") >= 1


def test_limite_de_tentativas_de_login_por_ip(cliente):
    codigos = [cliente.post("/api/v1/auth/token", json={"login": f"nao.existe{i}", "senha": "x", "perfil": "ALUNO"}).status_code
               for i in range(11)]
    assert codigos[-1] == 429


def test_erro_de_validacao_nao_ecoa_a_senha(cliente):
    r = cliente.post("/api/v1/auth/token", json={"login": "a", "senha": "MinhaSenhaSecreta!", "perfil": "ALUNO"})
    assert r.status_code == 422
    assert "MinhaSenhaSecreta" not in r.text


def test_token_com_alg_none_e_recusado(cliente):
    falso = jwt.encode({"sub": "1", "exp": datetime.now(timezone.utc) + timedelta(minutes=5)}, key=None, algorithm="none")
    r = cliente.get("/api/v1/alunos/ALU0001/score", headers={"Authorization": f"Bearer {falso}"})
    assert r.status_code == 401


def test_token_expirado_e_recusado(cliente):
    agora = datetime.now(timezone.utc)
    vencido = jwt.encode({"sub": "1", "iat": agora - timedelta(hours=2), "nbf": agora - timedelta(hours=2),
                          "exp": agora - timedelta(hours=1), "jti": "a", "iss": "mufasa-api", "aud": "mufasa-interface"},
                         JWT_TESTE, algorithm="HS256")
    r = cliente.get("/api/v1/alunos/ALU0001/score", headers={"Authorization": f"Bearer {vencido}"})
    assert r.status_code == 401


def test_sair_revoga_o_token(cliente):
    cab = entrar(cliente, "ALU0001", novo=True)
    assert cliente.post("/api/v1/auth/sair", headers=cab).status_code == 204
    assert cliente.get("/api/v1/alunos/ALU0001/score", headers=cab).status_code == 401


# ---------------------------------------------------------------------------
# SQL injection e validacao de entrada
# ---------------------------------------------------------------------------

@pytest.mark.parametrize("matricula", [
    "ALU0001' OR '1'='1", "ALU0001;DROP TABLE alunos", "12345", "12345678", "ALU 001", "1 OR 1=1",
])
def test_matricula_maliciosa_ou_fora_do_formato_e_rejeitada(cliente, matricula):
    cab = entrar(cliente, "coord.ia")
    r = cliente.get(f"/api/v1/alunos/{matricula}/score", headers=cab)
    assert r.status_code in (404, 422)
    assert contar(cliente, "SELECT COUNT(*) FROM alunos") > 0


@pytest.mark.parametrize("params", [
    {"ordem": "nome; DROP TABLE alunos"}, {"semestre": "1 OR 1=1"}, {"limite": "1000"}, {"pagina": "-1"},
])
def test_filtros_maliciosos_sao_rejeitados(cliente, params):
    cab = entrar(cliente, "coord.ia")
    assert cliente.get("/api/v1/alunos", params=params, headers=cab).status_code == 422


def test_login_com_sql_e_rejeitado(cliente):
    r = cliente.post("/api/v1/auth/token", json={"login": "' OR 1=1 --", "senha": "x", "perfil": "ADMIN"})
    assert r.status_code == 422


def test_campo_extra_e_recusado(cliente):
    r = cliente.post("/api/v1/auth/token", json={"login": "ALU0001", "senha": SENHA, "perfil": "ALUNO", "papel": "ADMIN"})
    assert r.status_code == 422


def test_perfil_diferente_do_cadastrado_nao_entra(cliente):
    r = cliente.post("/api/v1/auth/token", json={"login": "ALU0001", "senha": SENHA, "perfil": "COORDENACAO"})
    assert r.status_code == 401


# ---------------------------------------------------------------------------
# Isolamento e permissoes (RN07, RN17, CA14, CA19)
# ---------------------------------------------------------------------------

def test_aluno_ve_o_proprio_score_com_explicacao(cliente):
    r = cliente.get("/api/v1/alunos/ALU0001/score", headers=entrar(cliente, "ALU0001"))
    assert r.status_code == 200
    corpo = r.json()
    assert corpo["nivel"] in ("BAIXO", "MODERADO", "ALTO", "CRITICO", "INDETERMINADO")
    assert corpo["explicacao"] and corpo["aviso"]
    # CA08: cada fator com o valor concreto e a explicacao em texto.
    calculados = [f for f in corpo["fatores"] if f.get("pontuacao") is not None]
    assert calculados and all(f["valor_bruto"] is not None and f["explicacao"] for f in calculados)


def test_aluno_nao_ve_outro_aluno_e_fica_registrado(cliente):
    cab = entrar(cliente, "ALU0001")
    outro = cliente.get("/api/v1/alunos/ALU0002/score", headers=cab)
    inexistente = cliente.get("/api/v1/alunos/ALU9999/score", headers=cab)
    assert outro.status_code == inexistente.status_code == 403
    assert outro.json()["detalhe"] == inexistente.json()["detalhe"] == MSG_ACESSO_NEGADO
    assert contar(cliente, "SELECT COUNT(*) FROM auditoria_acessos WHERE id_aluno_alvo='ALU0002' AND resultado='NEGADO'") >= 1


def test_docente_lista_so_alunos_das_suas_turmas(cliente):
    r = cliente.get("/api/v1/alunos", headers=entrar(cliente, "prof.um"))
    assert r.status_code == 200
    assert {a["matricula"] for a in r.json()["itens"]} == {"ALU0001", "ALU0002"}


def test_docente_nao_ve_aluno_de_outra_turma(cliente):
    assert cliente.get("/api/v1/alunos/ALU0003", headers=entrar(cliente, "prof.um")).status_code == 403


def test_docente_nao_recebe_dado_socioeconomico(cliente):
    cab = entrar(cliente, "prof.um")
    perfil = cliente.get("/api/v1/alunos/ALU0001", headers=cab).json()
    assert "socioeconomico" not in perfil and "apoio" not in perfil and "financeiro" not in perfil
    score = cliente.get("/api/v1/alunos/ALU0001/score", headers=cab).json()
    nomes = set(score["fatores_principais"]) | {f["fator"] for f in score["fatores"]}
    assert not nomes & {"financeiro", "trabalho", "deslocamento", "moradia", "dependentes", "saude_mental", "saude_fisica"}


def test_coordenacao_ve_so_faixa_socioeconomica(cliente):
    perfil = cliente.get("/api/v1/alunos/ALU0001", headers=entrar(cliente, "coord.ia")).json()
    assert perfil["vulnerabilidade_socioeconomica"] in ("baixa", "média", "alta")
    assert "socioeconomico" not in perfil


def test_nucleo_ve_valores_e_dado_de_apoio(cliente):
    perfil = cliente.get("/api/v1/alunos/ALU0001", headers=entrar(cliente, "nucleo.ia")).json()
    assert perfil["socioeconomico"]["renda_per_capita"] == 600
    assert perfil["apoio"]["apoio_psicossocial_solicitado"] is True


def test_direcao_nao_le_aluno_individual(cliente):
    cab = entrar(cliente, "direcao")
    assert cliente.get("/api/v1/alunos", headers=cab).status_code == 403
    assert cliente.get("/api/v1/alunos/ALU0001", headers=cab).status_code == 403


def test_agregados_suprimem_grupos_pequenos(cliente):
    r = cliente.get("/api/v1/indicadores/agregados", headers=entrar(cliente, "direcao"))
    assert r.status_code == 200
    grupos = r.json()["grupos"]
    assert all(g["total"] >= 5 for g in grupos)
    assert {"semestre": 5, "nivel_risco": "BAIXO", "total": 6} in grupos
    assert not any(g["semestre"] == 6 for g in grupos)
    assert "matricula" not in r.text and "nome" not in r.text


def test_auditoria_so_para_encarregado(cliente):
    assert cliente.get("/api/v1/auditoria", headers=entrar(cliente, "coord.ia")).status_code == 403
    r = cliente.get("/api/v1/auditoria", headers=entrar(cliente, "encarregado"))
    assert r.status_code == 200 and len(r.json()) > 0


# ---------------------------------------------------------------------------
# LGPD: consentimento e direitos do titular
# ---------------------------------------------------------------------------

def test_menor_de_idade_nao_consente_sozinho_dado_de_saude(cliente):
    r = cliente.post("/api/v1/privacidade/consentimentos", headers=entrar(cliente, "ALU0002"),
                     json={"finalidade": "DADOS_SAUDE", "concedido": True, "versao_termo": "1.0"})
    assert r.status_code == 422


def test_maior_de_idade_concede_e_revoga(cliente):
    cab = entrar(cliente, "ALU0001")
    for concedido in (True, False):
        r = cliente.post("/api/v1/privacidade/consentimentos", headers=cab,
                         json={"finalidade": "DADOS_SAUDE", "concedido": concedido, "versao_termo": "1.0"})
        assert r.status_code == 201
    historico = cliente.get("/api/v1/privacidade/consentimentos", headers=cab).json()
    assert [c["concedido"] for c in historico][-2:] == [True, False]


def test_meus_dados_traz_so_o_proprio_aluno(cliente):
    r = cliente.get("/api/v1/privacidade/meus-dados", headers=entrar(cliente, "ALU0001"))
    assert r.status_code == 200
    assert r.json()["cadastro"]["id_aluno"] == "ALU0001"
    assert "ALU0002" not in r.text


def test_solicitacao_de_direito_do_titular(cliente):
    r = cliente.post("/api/v1/privacidade/solicitacoes", headers=entrar(cliente, "ALU0001"),
                     json={"tipo": "REVISAO_DECISAO_AUTOMATIZADA", "descricao": "Quero revisao do meu nivel."})
    assert r.status_code == 201
    lista = cliente.get("/api/v1/privacidade/solicitacoes", headers=entrar(cliente, "encarregado")).json()
    assert any(s["tipo"] == "REVISAO_DECISAO_AUTOMATIZADA" for s in lista)


# ---------------------------------------------------------------------------
# Erros (SRS Secao 3.3)
# ---------------------------------------------------------------------------

def test_erro_500_nao_expoe_pilha_nem_sql(cliente, monkeypatch):
    from app.api import rotas

    def _quebra(*_):
        raise RuntimeError("SELECT * FROM socioeconomico -- detalhe interno")

    monkeypatch.setattr(rotas, "recortar_score", _quebra)
    r = cliente.get("/api/v1/alunos/ALU0001/score", headers=entrar(cliente, "coord.ia"))
    assert r.status_code == 500
    assert "Traceback" not in r.text and "SELECT" not in r.text and "socioeconomico" not in r.text
    codigo = r.json()["requisicao"]
    assert codigo and r.headers["X-Request-ID"] == codigo
    # O mesmo codigo fica no registro tecnico, para o suporte achar o erro.
    assert contar(cliente, "SELECT COUNT(*) FROM logs_tecnicos WHERE id_requisicao = :c", c=codigo) == 1


# ---------------------------------------------------------------------------
# Guarda estatica contra SQL montado com texto
# ---------------------------------------------------------------------------

def _so_constantes(no) -> bool:
    """SQL feito so de literais, constantes do modulo (NOMES_EM_MAIUSCULAS) e listas brancas, juntos com +."""
    import ast
    if isinstance(no, ast.Constant):
        return isinstance(no.value, str)
    if isinstance(no, ast.Name):
        return no.id.lstrip("_").replace("_", "").isupper()
    if isinstance(no, ast.Subscript):  # lista branca constante: FILTROS[perfil]
        return _so_constantes(no.value)
    if isinstance(no, ast.BinOp) and isinstance(no.op, ast.Add):
        return _so_constantes(no.left) and _so_constantes(no.right)
    return False


def test_nenhum_sql_montado_com_texto_variavel():
    """Reprova text() com f-string, % ou concatenacao com valor variavel, em qualquer arquivo."""
    import ast
    import pathlib

    raiz = pathlib.Path(__file__).resolve().parents[1]
    for arquivo in list((raiz / "app").rglob("*.py")) + list((raiz / "scripts").rglob("*.py")):
        for no in ast.walk(ast.parse(arquivo.read_text(encoding="utf-8"))):
            if isinstance(no, ast.Call) and getattr(no.func, "id", getattr(no.func, "attr", None)) == "text":
                assert no.args and _so_constantes(no.args[0]), f"{arquivo}:{no.lineno}"
