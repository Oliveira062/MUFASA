"""
Conexao com o PostgreSQL do B1.

REGRA DESTE PROJETO CONTRA SQL INJECTION: todo SQL e uma constante com
parametros nomeados (:nome), executada com sqlalchemy.text() e um dicionario
de valores. O driver envia os valores separados do comando, entao nenhuma
entrada do usuario vira codigo SQL.

Proibido em qualquer arquivo, com qualquer valor vindo de fora:
    text(f"... {valor} ...")        # f-string
    text("... " + valor)            # concatenacao
    text("... %s" % valor)          # formatacao
O unico texto que se junta ao SQL sao fragmentos CONSTANTES de consultas.py.
Ordenacao variavel so por lista branca (ver consultas.ORDENACOES).
"""

from collections.abc import Iterator

from sqlalchemy import create_engine
from sqlalchemy.engine import Connection, Engine

from app.config import obter_configuracao

_engine: Engine | None = None


def obter_engine() -> Engine:
    global _engine
    if _engine is None:
        cfg = obter_configuracao()
        _engine = create_engine(
            cfg.database_url.get_secret_value(),
            pool_pre_ping=True,
            pool_size=5,
            max_overflow=5,
            # Nao registra SQL nem parametros no log: os parametros contem dado pessoal.
            echo=False,
            hide_parameters=True,
        )
    return _engine


def obter_conexao() -> Iterator[Connection]:
    """
    Dependencia do FastAPI: uma conexao por requisicao.

    Leitura nao precisa de commit. Endpoint que grava chama conexao.commit();
    se der erro antes, a conexao fecha e o PostgreSQL desfaz a transacao.
    """
    with obter_engine().connect() as conexao:
        yield conexao
