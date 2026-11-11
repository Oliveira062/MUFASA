"""
Conexao do chatbot com o banco (RN06, Anexo D.2).

O chatbot usa o perfil mufasa_chat, que so enxerga as visoes vw_chat_*
(sem dado socioeconomico, sem saude, sem senha) e as tabelas chat_*.
Mesmo que alguem consiga mudar o que o chatbot consulta, o banco recusa
tudo o que esta fora dessas visoes.
"""

from collections.abc import Iterator

from sqlalchemy import create_engine
from sqlalchemy.engine import Connection, Engine

from app.api import banco
from app.chatbot.config_chat import obter_configuracao_chat
from app.config import obter_configuracao

_engine_chat: Engine | None = None


def obter_engine_chat() -> Engine:
    global _engine_chat
    url = obter_configuracao_chat().chat_database_url
    if url is None:
        if obter_configuracao().em_producao:
            raise RuntimeError("CHAT_DATABASE_URL e obrigatoria em producao (perfil mufasa_chat)")
        return banco.obter_engine()
    if _engine_chat is None:
        _engine_chat = create_engine(url.get_secret_value(), pool_pre_ping=True, pool_size=3,
                                     max_overflow=2, echo=False, hide_parameters=True)
    return _engine_chat


def obter_conexao_chat() -> Iterator[Connection]:
    with obter_engine_chat().connect() as conexao:
        yield conexao
