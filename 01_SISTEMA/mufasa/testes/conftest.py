"""
Base dos testes de API, chat e servicos: um PostgreSQL de verdade.

Os testes montam um banco proprio, mufasa_teste, com a MESMA estrutura da
producao (dump do B1 sem os dados + sql/*.sql + migracoes) e um conjunto
pequeno de dados controlados, para que cada resultado esperado seja
conhecido. O banco principal (mufasa) nunca e tocado.

Configuracao (no .env ou no ambiente):
    DATABASE_URL_ADMIN   conexao do dono (postgres); o nome do banco e trocado por mufasa_teste
    DATABASE_URL, CHAT_DATABASE_URL, CALCULO_DATABASE_URL   perfis restritos (senhas)
    APOIO_CHAVE          chave Fernet
    MUFASA_DUMP          opcional: caminho do dump do B1
Sem essas variaveis, os testes que precisam de banco sao pulados com aviso;
os testes de calculo (teste_calculo.py) rodam sempre.

    pytest                      # tudo
    pytest -m "not banco"       # so o que nao precisa de PostgreSQL
"""

import os
from pathlib import Path

import pytest

from scripts._ambiente import RAIZ, carregar_env

carregar_env()

BANCO_TESTE = "mufasa_teste"
SENHA = "senha-de-teste-123"
JWT_TESTE = "x" * 48


def _trocar_banco(url: str | None) -> str | None:
    if not url:
        return None
    from sqlalchemy.engine import make_url
    return make_url(url).set(database=BANCO_TESTE).render_as_string(hide_password=False)


URLS = {nome: _trocar_banco(os.environ.get(nome)) for nome in
        ("DATABASE_URL_ADMIN", "DATABASE_URL", "CHAT_DATABASE_URL", "CALCULO_DATABASE_URL")}
URLS["DATABASE_URL_ADMIN"] = os.environ.get("MUFASA_TESTE_ADMIN_URL") or URLS["DATABASE_URL_ADMIN"]
_DUMP_CANDIDATOS = [os.environ.get("MUFASA_DUMP"), RAIZ / "banco" / "Parte Samuel BackEnd B1 - limpo.sql",
                    RAIZ.parent / "banco" / "Parte Samuel BackEnd B1 - limpo.sql"]
DUMP = next((Path(c) for c in _DUMP_CANDIDATOS if c and Path(c).exists()), None)
FALTANDO = [n for n, u in URLS.items() if not u] + ([] if os.environ.get("APOIO_CHAVE") else ["APOIO_CHAVE"]) \
    + ([] if DUMP else ["dump do B1 (banco/Parte Samuel BackEnd B1 - limpo.sql)"])

# Os modulos da aplicacao leem a configuracao do ambiente: aponta tudo para o
# banco de teste ANTES de qualquer import de app.*.
for _nome, _url in URLS.items():
    if _url:
        os.environ[_nome] = _url
os.environ.update({"JWT_SECRET": JWT_TESTE, "AMBIENTE": "desenvolvimento", "SALARIO_MINIMO": "1518",
                   "MUFASA_LOG_DIR": str(RAIZ / "logs" / "testes")})


def pytest_configure(config):
    config.addinivalue_line("markers", "banco: precisa do PostgreSQL de teste")


def pytest_collection_modifyitems(config, items):
    for item in items:
        if "banco_teste" in getattr(item, "fixturenames", ()):
            item.add_marker(pytest.mark.banco)


# ---------------------------------------------------------------------------
# Dados controlados. Notas de 0 a 10 (escala apos sql/b1_correcoes.sql).
# ALU0001 tem um zero de verdade na VA2 de Calculo I: o zero tem de aparecer.
# ALU0002 tem 17 anos (menor). ALU0003 e de outro curso. ALU0004 nao tem dados.
# ALU0010..15 (semestre 5) formam grupo visivel; ALU0016..17 (semestre 6), grupo suprimido.
# ---------------------------------------------------------------------------
DADOS = """
INSERT INTO universidades VALUES ('UNI01','Universidade Teste','Anapolis','GO');
INSERT INTO cursos VALUES ('CUR01','UNI01','Inteligencia Artificial','Bacharelado',8,6,75),
                          ('CUR02','UNI01','Outro Curso','Bacharelado',8,6,75);
INSERT INTO professores (id_professor, nome) VALUES ('PROF001','Prof Um'),('PROF002','Prof Dois'),('PROF003','Prof Tres');
INSERT INTO alunos VALUES ('ALU0001','Julia Araujo Silva','CUR01',2,23,'Centro','Regular'),
                          ('ALU0002','Camila Mendes','CUR01',1,17,'Centro','Regular'),
                          ('ALU0003','Isabela Ribeiro','CUR02',3,20,'Centro','Regular'),
                          ('ALU0004','Sem Dados','CUR01',1,19,'Centro','Regular');
INSERT INTO materias VALUES ('IA101','CUR01','Lógica de Programação',1,60,6,75),
                            ('IA103','CUR01','Cálculo I',1,80,6,75),
                            ('IA202','CUR01','Cálculo II',2,80,6,75),
                            ('IA203','CUR01','Álgebra Linear',2,60,6,75),
                            ('IA501','CUR01','Tópicos',5,60,6,75),
                            ('IA999','CUR02','Algoritmos',1,80,6,75);
INSERT INTO turmas VALUES ('IA101-A','IA101','PROF001','2026/2','A','Matutino'),
                          ('IA103-A','IA103','PROF001','2026/2','A','Matutino'),
                          ('IA202-A','IA202','PROF002','2026/2','A','Matutino'),
                          ('IA203-A','IA203','PROF002','2026/2','A','Matutino'),
                          ('IA501-A','IA501','PROF002','2026/2','A','Noturno'),
                          ('IA999-A','IA999','PROF003','2026/2','A','Matutino');
INSERT INTO indicadores_academicos VALUES ('ALU0001','2026/2',5,72,0,2,6.9,7.7,0.8),
                                          ('ALU0002','2026/2',6,69,0,4,2.8,2.9,0.1);
INSERT INTO matriculas VALUES ('MAT1','ALU0001','IA101-A',7.467,77,'Aprovado',7.7,6.6,8.1),
                              ('MAT2','ALU0001','IA103-A',1.733,37,'Reprovado',2.7,0,2.4),
                              ('MAT3','ALU0001','IA202-A',6.15,92,'Aprovado',6.0,6.2,6.25),
                              ('MAT4','ALU0002','IA101-A',8.8,95,'Aprovado',9.0,8.5,8.9),
                              ('MAT5','ALU0003','IA999-A',7.0,80,'Aprovado',7.0,7.0,7.0);
INSERT INTO socioeconomico VALUES ('ALU0001',3000,5,600,'nao','Tempo integral',8,4,0,10,65,'Onibus','nao','nao','nao');
INSERT INTO avaliacoes_risco VALUES ('AVR0001','ALU0001','2026/2','Inicial','2026-08-17',26.1,'Moderado'),
                                    ('AVR0002','ALU0002','2026/2','Inicial','2026-08-17',73.3,'Crítico'),
                                    ('AVR0003','ALU0003','2026/2','Inicial','2026-08-17',60,'Alto');
"""

USUARIOS = [
    ("ALU0001", "ALUNO", "ALU0001", None, "CUR01"),
    ("ALU0002", "ALUNO", "ALU0002", None, "CUR01"),
    ("ALU0004", "ALUNO", "ALU0004", None, "CUR01"),
    ("prof.um", "DOCENTE", None, "PROF001", None),
    ("coord.ia", "COORDENACAO", None, None, "CUR01"),
    ("coord2.ia", "COORDENACAO", None, None, "CUR01"),
    ("nucleo.ia", "NUCLEO_APOIO", None, None, "CUR01"),
    ("financeiro", "FINANCEIRO", None, None, None),
    ("direcao", "DIRECAO", None, None, None),
    ("admin", "ADMIN", None, None, None),
    ("encarregado", "ENCARREGADO_DADOS", None, None, None),
]


def calcular_tudo(url_calculo: str) -> int:
    """O mesmo que o servico de calculo faz ao subir: score de todos, alertas e prazos."""
    from sqlalchemy import create_engine

    from app.servico_calculo import consultas_calculo as sqlc
    from app.servico_calculo.__main__ import carregar_parametros
    from app.servico_calculo.recalculo import processar_lote
    engine = create_engine(url_calculo, hide_parameters=True)
    p = carregar_parametros(engine)
    with engine.begin() as c:
        c.execute(sqlc.ENFILEIRAR_SEM_SCORE)
        c.execute(sqlc.ENFILEIRAR_VERSAO_ANTIGA, {"versao": p.versao})
    total, feito = 0, 1
    while feito:
        with engine.begin() as c:
            feito = processar_lote(c, p)
        total += feito
    engine.dispose()
    return total


@pytest.fixture(scope="session")
def banco_teste():
    if FALTANDO:
        pytest.skip("PostgreSQL de teste nao configurado: falta " + ", ".join(FALTANDO))
    from sqlalchemy import create_engine, text

    from app.api.auth import gerar_hash_senha
    from app.api.cifra import cifrar
    from scripts.montar_banco import construir

    admin = URLS["DATABASE_URL_ADMIN"]
    construir(admin, DUMP, apenas_esquema=True, falar=lambda *_: None)
    engine = create_engine(admin, hide_parameters=True)
    with engine.begin() as c:
        c.exec_driver_sql(DADOS)
        for i in range(10, 18):
            aluno = f"ALU00{i}"
            c.execute(text("INSERT INTO alunos VALUES (:id,'Agregado','CUR01',:s,20,'X','Y')"),
                      {"id": aluno, "s": 5 if i < 16 else 6})
            c.execute(text("INSERT INTO indicadores_academicos VALUES (:id,'2026/2',0,98,0,0,9.5,9.5,0)"), {"id": aluno})
            c.execute(text("INSERT INTO matriculas VALUES (:m,:id,'IA501-A',9.5,98,'Aprovado',9.5,9.5,9.5)"),
                      {"m": f"MATX{i}", "id": aluno})
            c.execute(text("INSERT INTO socioeconomico (id_aluno, renda_familiar_mensal, moradores_domicilio, "
                           "renda_per_capita, trabalha, horas_trabalho_dia, tempo_deslocamento_min) "
                           "VALUES (:id, 20000, 2, 10000, 'Nao', 0, 10)"), {"id": aluno})
        chave = os.environ["APOIO_CHAVE"]
        c.execute(text("INSERT INTO apoio_aluno (id_aluno, dados_cifrados) VALUES ('ALU0001', :d)"),
                  {"d": cifrar(chave=chave, dados={"apoio_psicossocial_solicitado": True,
                                                   "necessidade_acessibilidade": False})})
        senha_hash = gerar_hash_senha(SENHA)
        for login, perfil, aluno, prof, curso in USUARIOS:
            c.execute(text("INSERT INTO usuarios (login, senha_hash, perfil, id_aluno, id_professor, id_curso, nome, "
                           "deve_trocar_senha, termo_versao, termo_aceito_em) "
                           "VALUES (:l, :h, :p, :a, :pr, :c, :n, FALSE, '1.0', now())"),
                      {"l": login, "h": senha_hash, "p": perfil, "a": aluno, "pr": prof, "c": curso,
                       "n": f"Teste {login}"})
    calcular_tudo(URLS["CALCULO_DATABASE_URL"])
    yield {"admin": engine, "urls": URLS}
    engine.dispose()


def _reiniciar_configuracao():
    from app.api import banco
    from app.chatbot import banco_chat, config_chat
    from app.config import obter_configuracao
    obter_configuracao.cache_clear()
    config_chat.obter_configuracao_chat.cache_clear()
    banco._engine = None
    banco_chat._engine_chat = None


@pytest.fixture(scope="session")
def cliente(banco_teste):
    """API (app.main) ligada ao banco de teste com o perfil mufasa_api."""
    from fastapi.testclient import TestClient
    _reiniciar_configuracao()
    from app.main import app
    with TestClient(app, raise_server_exceptions=False) as tc:
        tc.engine = banco_teste["admin"]
        yield tc


@pytest.fixture(scope="session")
def cliente_chat(banco_teste):
    """Servico do chat (app.main_chat), processo separado na producao."""
    from fastapi.testclient import TestClient
    from app.main_chat import app
    with TestClient(app, raise_server_exceptions=False) as tc:
        tc.engine = banco_teste["admin"]
        yield tc


@pytest.fixture(autouse=True)
def _limpar_limites():
    try:
        from app.api.seguranca import limitador
        limitador.limpar()
    except Exception:
        pass


_TOKENS: dict[str, dict] = {}


def entrar(cliente, login, senha=SENHA, perfil=None, novo=False):
    """Cabecalho de autorizacao. Reaproveita o token, salvo novo=True."""
    if novo or login not in _TOKENS or senha != SENHA:
        perfil = perfil or next(u[1] for u in USUARIOS if u[0] == login)
        r = cliente.post("/api/v1/auth/token", json={"login": login, "senha": senha, "perfil": perfil})
        assert r.status_code == 200, r.text
        cab = {"Authorization": f"Bearer {r.json()['access_token']}"}
        if novo or senha != SENHA:
            return cab
        _TOKENS[login] = cab
    return _TOKENS[login]


def sql(cliente, consulta: str, params: dict | None = None):
    """Consulta direta como dono do banco (so para conferir efeitos nos testes)."""
    from sqlalchemy import text
    with cliente.engine.begin() as c:
        r = c.execute(text(consulta), params or {})
        return r.mappings().all() if r.returns_rows else []
