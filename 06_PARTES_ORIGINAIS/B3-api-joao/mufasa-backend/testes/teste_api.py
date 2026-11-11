"""
Testes do B3 (SRS: CA04, CA08, CA14, CA19, RN07, RN12, RN17, Secao 3.3).

Rodam sem PostgreSQL: um SQLite temporario recebe tabelas com os mesmos
nomes e colunas do dump do B1, mais as tabelas do B3.

    pytest testes/teste_api.py -v
"""

import os
import tempfile
from datetime import datetime, timedelta, timezone

import jwt
import pytest

_PASTA = tempfile.mkdtemp(prefix="mufasa-teste-")
os.environ.update({
    "DATABASE_URL": f"sqlite:///{_PASTA}/teste.db",
    "JWT_SECRET": "x" * 48,
    "SALARIO_MINIMO": "1518",
    "AMBIENTE": "desenvolvimento",
})

from fastapi.testclient import TestClient  # noqa: E402
from sqlalchemy import create_engine, event, text  # noqa: E402

from app.api import banco  # noqa: E402
from app.api.auth import gerar_hash_senha  # noqa: E402
from app.api.erros import MSG_ACESSO_NEGADO  # noqa: E402
from app.api.seguranca import limitador  # noqa: E402
from app.config import obter_configuracao  # noqa: E402

SENHA = "senha-de-teste-123"

ESQUEMA = """
CREATE TABLE cursos (id_curso TEXT, id_universidade TEXT, nome TEXT, grau TEXT, duracao_semestres INT,
                     media_aprovacao INT, frequencia_minima_pct INT);
CREATE TABLE alunos (id_aluno TEXT, nome_ficticio TEXT, id_curso TEXT, semestre_atual INT, idade INT, bairro TEXT,
                     tipo_ensino_medio TEXT, apoio_psicossocial_solicitado TEXT, necessidade_acessibilidade TEXT);
CREATE TABLE materias (id_materia TEXT, id_curso TEXT, nome TEXT, semestre_grade INT, carga_horaria_h INT,
                       media_aprovacao INT, frequencia_minima_pct INT);
CREATE TABLE turmas (id_turma TEXT, id_materia TEXT, id_professor TEXT, periodo_letivo TEXT, turma TEXT, turno TEXT);
CREATE TABLE matriculas (id_matricula TEXT, id_aluno TEXT, id_turma TEXT, nota_final NUMERIC, frequencia_pct INT,
                         situacao TEXT, va1 NUMERIC, va2 NUMERIC, va3 NUMERIC);
CREATE TABLE indicadores_academicos (id_aluno TEXT, periodo_letivo TEXT, faltas_total INT, frequencia_pct INT,
                         disciplinas_reprovadas_historico INT, atividades_pendentes INT,
                         media_semestre_anterior NUMERIC, media_atual NUMERIC, tendencia_media NUMERIC);
CREATE TABLE socioeconomico (id_aluno TEXT, renda_familiar_mensal INT, moradores_domicilio INT, renda_per_capita NUMERIC,
                         auxilio_bolsa TEXT, trabalha TEXT, horas_trabalho_dia INT, horas_estudo_semana NUMERIC,
                         responsabilidades_familiares_h_semana INT, distancia_km NUMERIC, tempo_deslocamento_min INT,
                         meio_transporte TEXT, prouni TEXT, fies TEXT, desconto_funcionario TEXT);
CREATE TABLE avaliacoes_risco (id_avaliacao TEXT, id_aluno TEXT, periodo_letivo TEXT, tipo TEXT, data_avaliacao TEXT,
                         risco_evasao_pct NUMERIC, nivel_risco TEXT);
CREATE TABLE usuarios (id_usuario INTEGER PRIMARY KEY AUTOINCREMENT, login TEXT UNIQUE, senha_hash TEXT, perfil TEXT,
                       id_aluno TEXT, id_professor TEXT, id_curso TEXT, ativo BOOLEAN DEFAULT 1,
                       falhas_login INT DEFAULT 0, bloqueado_ate TEXT, ultimo_login TEXT);
CREATE TABLE tokens_revogados (jti TEXT PRIMARY KEY, expira_em TEXT);
CREATE TABLE auditoria_acessos (id_auditoria INTEGER PRIMARY KEY AUTOINCREMENT, momento TEXT, id_requisicao TEXT,
                       id_usuario INT, perfil TEXT, operacao TEXT, recurso TEXT, id_aluno_alvo TEXT,
                       resultado TEXT, origem TEXT);
CREATE TABLE consentimentos (id_consentimento INTEGER PRIMARY KEY AUTOINCREMENT, id_aluno TEXT, finalidade TEXT,
                       concedido BOOLEAN, concedido_por TEXT, versao_termo TEXT, registrado_em TEXT, id_usuario INT);
CREATE TABLE solicitacoes_titular (id_solicitacao INTEGER PRIMARY KEY AUTOINCREMENT, id_aluno TEXT, tipo TEXT,
                       descricao TEXT, situacao TEXT, registrada_em TEXT, respondida_em TEXT);
"""

DADOS = """
INSERT INTO cursos VALUES ('CUR01','UNI01','Inteligencia Artificial','Bacharelado',8,6,75),
                          ('CUR02','UNI01','Outro Curso','Bacharelado',8,6,75);
INSERT INTO alunos VALUES ('ALU0001','Julia Teste','CUR01',2,23,'Centro','Regular presencial','Sim','Nao'),
                          ('ALU0002','Camila Teste','CUR01',1,17,'Centro','Regular presencial','Nao','Nao'),
                          ('ALU0003','Isabela Teste','CUR02',3,20,'Centro','Regular presencial','Nao','Nao');
INSERT INTO materias VALUES ('IA101','CUR01','Logica',1,60,6,75), ('IA102','CUR02','Algoritmos',1,80,6,75);
INSERT INTO turmas VALUES ('IA101-A','IA101','PROF001','2026/2','A','Matutino'),
                          ('IA102-A','IA102','PROF002','2026/2','A','Matutino');
INSERT INTO matriculas VALUES ('MAT1','ALU0001','IA101-A',60,68,'Cursando',60,60,60),
                              ('MAT2','ALU0002','IA101-A',80,90,'Cursando',80,80,80),
                              ('MAT3','ALU0003','IA102-A',70,80,'Cursando',70,70,70);
INSERT INTO indicadores_academicos VALUES ('ALU0001','2026/2',25,68,1,2,5.0,5.4,0.4),
                                          ('ALU0002','2026/2',2,95,0,0,9.0,9.5,0.5);
INSERT INTO socioeconomico VALUES ('ALU0001',3000,5,600,'nao','Tempo integral',8,4,0,10,65,'Onibus','nao','nao','nao');
INSERT INTO avaliacoes_risco VALUES ('AV1','ALU0001','2026/2','Inicial','2026-08-17',63,'Alto'),
                                    ('AV2','ALU0002','2026/2','Inicial','2026-08-17',80,'Crítico'),
                                    ('AV3','ALU0003','2026/2','Inicial','2026-08-17',60,'Alto');
"""

USUARIOS = [
    ("ALU0001", "ALUNO", "ALU0001", None, "CUR01"),
    ("ALU0002", "ALUNO", "ALU0002", None, "CUR01"),
    ("prof.um", "DOCENTE", None, "PROF001", None),
    ("coord.ia", "COORDENACAO", None, None, "CUR01"),
    ("nucleo.ia", "NUCLEO_APOIO", None, None, "CUR01"),
    ("direcao", "DIRECAO", None, None, None),
    ("encarregado", "ENCARREGADO_DADOS", None, None, None),
]


@pytest.fixture(scope="module")
def cliente():
    obter_configuracao.cache_clear()
    engine = create_engine(os.environ["DATABASE_URL"])

    @event.listens_for(engine, "connect")
    def _wal(conexao_dbapi, _):
        conexao_dbapi.execute("PRAGMA journal_mode=WAL")

    with engine.begin() as c:
        for comando in (ESQUEMA + DADOS).split(";"):
            if comando.strip():
                c.execute(text(comando))
        # 6 alunos no semestre 5 (grupo visivel) e 2 no semestre 6 (grupo suprimido).
        for i in range(10, 18):
            semestre = 5 if i < 16 else 6
            c.execute(text("INSERT INTO alunos VALUES (:id,'Agregado','CUR01',:s,20,'X','Y','Nao','Nao')"),
                      {"id": f"ALU00{i}", "s": semestre})
            c.execute(text("INSERT INTO avaliacoes_risco VALUES (:av,:id,'2026/2','Inicial','2026-08-17',10,'Baixo')"),
                      {"av": f"AVX{i}", "id": f"ALU00{i}"})
        hash_senha = gerar_hash_senha(SENHA)
        for login, perfil, aluno, prof, curso in USUARIOS:
            c.execute(text("INSERT INTO usuarios (login, senha_hash, perfil, id_aluno, id_professor, id_curso) "
                           "VALUES (:l, :h, :p, :a, :pr, :c)"),
                      {"l": login, "h": hash_senha, "p": perfil, "a": aluno, "pr": prof, "c": curso})

    banco._engine = engine
    from app.main import app
    with TestClient(app, raise_server_exceptions=False) as tc:
        yield tc


@pytest.fixture(autouse=True)
def _limpar_limites():
    limitador.limpar()


def entrar(cliente, login, senha=SENHA):
    r = cliente.post("/api/v1/auth/token", json={"login": login, "senha": senha})
    assert r.status_code == 200, r.text
    return {"Authorization": f"Bearer {r.json()['access_token']}"}


def contar(sql, **params):
    with banco._engine.connect() as c:
        return c.execute(text(sql), params).scalar()


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
    a = cliente.post("/api/v1/auth/token", json={"login": "ALU0001", "senha": "errada"})
    b = cliente.post("/api/v1/auth/token", json={"login": "ALU9999", "senha": "errada"})
    assert a.status_code == b.status_code == 401
    assert a.json()["detalhe"] == b.json()["detalhe"]
    with banco._engine.begin() as c:
        c.execute(text("UPDATE usuarios SET falhas_login = 0 WHERE login = 'ALU0001'"))


def test_bloqueio_apos_cinco_falhas(cliente):
    with banco._engine.begin() as c:
        c.execute(text("INSERT INTO usuarios (login, senha_hash, perfil, id_aluno) VALUES ('bloq.teste', :h, 'ALUNO', 'ALU0003')"),
                  {"h": gerar_hash_senha(SENHA)})
    for _ in range(5):
        assert cliente.post("/api/v1/auth/token", json={"login": "bloq.teste", "senha": "errada"}).status_code == 401
    # Mesmo com a senha certa, continua bloqueado.
    assert cliente.post("/api/v1/auth/token", json={"login": "bloq.teste", "senha": SENHA}).status_code == 401
    assert contar("SELECT COUNT(*) FROM auditoria_acessos WHERE operacao='LOGIN' AND resultado='BLOQUEADO'") >= 1


def test_limite_de_tentativas_de_login_por_ip(cliente):
    codigos = [cliente.post("/api/v1/auth/token", json={"login": f"nao.existe{i}", "senha": "x"}).status_code
               for i in range(11)]
    assert codigos[-1] == 429


def test_erro_de_validacao_nao_ecoa_a_senha(cliente):
    r = cliente.post("/api/v1/auth/token", json={"login": "a", "senha": "MinhaSenhaSecreta!"})
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
                         "x" * 48, algorithm="HS256")
    r = cliente.get("/api/v1/alunos/ALU0001/score", headers={"Authorization": f"Bearer {vencido}"})
    assert r.status_code == 401


def test_sair_revoga_o_token(cliente):
    cab = entrar(cliente, "ALU0001")
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
    assert contar("SELECT COUNT(*) FROM alunos") > 0


@pytest.mark.parametrize("params", [
    {"ordem": "nome; DROP TABLE alunos"}, {"semestre": "1 OR 1=1"}, {"limite": "1000"}, {"pagina": "-1"},
])
def test_filtros_maliciosos_sao_rejeitados(cliente, params):
    cab = entrar(cliente, "coord.ia")
    assert cliente.get("/api/v1/alunos", params=params, headers=cab).status_code == 422


def test_login_com_sql_e_rejeitado(cliente):
    r = cliente.post("/api/v1/auth/token", json={"login": "' OR 1=1 --", "senha": "x"})
    assert r.status_code == 422


def test_campo_extra_e_recusado(cliente):
    r = cliente.post("/api/v1/auth/token", json={"login": "ALU0001", "senha": SENHA, "perfil": "ADMIN"})
    assert r.status_code == 422


# ---------------------------------------------------------------------------
# Isolamento e permissoes (RN07, RN17, CA14, CA19)
# ---------------------------------------------------------------------------

def test_aluno_ve_o_proprio_score_com_explicacao(cliente):
    r = cliente.get("/api/v1/alunos/ALU0001/score", headers=entrar(cliente, "ALU0001"))
    assert r.status_code == 200
    corpo = r.json()
    assert corpo["nivel"] in ("BAIXO", "MODERADO", "ALTO", "CRITICO", "INDETERMINADO")
    assert corpo["explicacao"] and corpo["aviso"]
    assert all(f["risco"] is not None for f in corpo["detalhamento"])  # CA08: numero concreto


def test_aluno_nao_ve_outro_aluno_e_fica_registrado(cliente):
    cab = entrar(cliente, "ALU0001")
    outro = cliente.get("/api/v1/alunos/ALU0002/score", headers=cab)
    inexistente = cliente.get("/api/v1/alunos/ALU9999/score", headers=cab)
    assert outro.status_code == inexistente.status_code == 403
    assert outro.json()["detalhe"] == inexistente.json()["detalhe"] == MSG_ACESSO_NEGADO
    assert contar("SELECT COUNT(*) FROM auditoria_acessos WHERE id_aluno_alvo='ALU0002' AND resultado='NEGADO'") >= 1


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
    nomes = set(score["fatores_principais"]) | {f["fator"] for f in score["detalhamento"]}
    assert not nomes & {"financeiro", "trabalho", "deslocamento", "moradia", "dependentes", "saude_mental", "saude_fisica"}


def test_coordenacao_ve_so_faixa_socioeconomica(cliente):
    perfil = cliente.get("/api/v1/alunos/ALU0001", headers=entrar(cliente, "coord.ia")).json()
    assert perfil["vulnerabilidade_socioeconomica"] in ("baixa", "media", "alta")
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

    def _quebra(_):
        raise RuntimeError("SELECT * FROM socioeconomico -- detalhe interno")

    monkeypatch.setattr(rotas, "calcular_score_aluno", _quebra)
    r = cliente.get("/api/v1/alunos/ALU0001/score", headers=entrar(cliente, "coord.ia"))
    assert r.status_code == 500
    assert "Traceback" not in r.text and "SELECT" not in r.text and "socioeconomico" not in r.text
    assert r.json()["requisicao"]


# ---------------------------------------------------------------------------
# Guarda estatica contra SQL montado com texto
# ---------------------------------------------------------------------------

def test_nenhum_sql_montado_com_texto_fora_de_consultas():
    """Reprova text() com f-string, concatenacao ou % fora de consultas.py."""
    import ast
    import pathlib

    raiz = pathlib.Path(__file__).resolve().parents[1]
    for arquivo in list((raiz / "app").rglob("*.py")) + list((raiz / "scripts").rglob("*.py")):
        if arquivo.name == "consultas.py":
            continue
        for no in ast.walk(ast.parse(arquivo.read_text(encoding="utf-8"))):
            if isinstance(no, ast.Call) and getattr(no.func, "id", getattr(no.func, "attr", None)) == "text":
                assert no.args and isinstance(no.args[0], ast.Constant), f"{arquivo}:{no.lineno}"
