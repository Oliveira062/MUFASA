"""
Montagem de um servico HTTP do MUFASA (API ou chat) com as mesmas camadas
de seguranca, o mesmo formato de erro e um /saude que confere o banco.

Cada servico roda em processo proprio (app/main.py e app/main_chat.py):
se o chat cair, a API e o painel continuam; se a API cair, o chat, que
tem seu proprio processo, continua respondendo.
"""

import asyncio
import contextlib
import logging
from datetime import datetime, timezone

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.httpsredirect import HTTPSRedirectMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy import text

from app import __version__
from app.api.erros import registrar_tratadores
from app.api.seguranca import CabecalhosSeguranca
from app.config import obter_configuracao

log = logging.getLogger("mufasa.servico")

_PING = text("SELECT 1")
_LOG = text("""
    INSERT INTO logs_tecnicos (momento, servico, nivel, evento, mensagem, id_requisicao)
    VALUES (:agora, :servico, 'ERRO', :evento, '', :id_requisicao)
""")
_SINAL = text("""
    INSERT INTO servicos_status (servico, ultimo_sinal, detalhe) VALUES (:servico, :agora, :detalhe)
    ON CONFLICT (servico) DO UPDATE SET ultimo_sinal = EXCLUDED.ultimo_sinal, detalhe = EXCLUDED.detalhe
""")
INTERVALO_SINAL_S = 15


def criar_servico(nome: str, titulo: str, routers, obter_engine, sinal_de_vida: bool) -> FastAPI:
    """obter_engine: funcao que devolve o engine do banco deste servico (perfil proprio)."""
    cfg = obter_configuracao()
    docs = cfg.docs_habilitada and not cfg.em_producao

    def gravar_sinal():
        with obter_engine().begin() as conexao:
            conexao.execute(_SINAL, {"servico": nome, "agora": datetime.now(timezone.utc),
                                     "detalhe": f"{titulo} v{__version__}"})

    async def laco_sinal():
        while True:
            try:
                await asyncio.to_thread(gravar_sinal)
            except Exception:
                log.warning("sinal de vida de %s nao gravado (banco indisponivel?)", nome)
            await asyncio.sleep(INTERVALO_SINAL_S)

    @contextlib.asynccontextmanager
    async def ciclo(_app):
        tarefa = asyncio.create_task(laco_sinal()) if sinal_de_vida else None
        yield
        if tarefa:
            tarefa.cancel()

    app = FastAPI(title=titulo, version=__version__, lifespan=ciclo,
                  description="Todo endpoint exige token, exceto /saude e /api/v1/auth/token.",
                  docs_url="/docs" if docs else None, redoc_url=None, openapi_url="/openapi.json" if docs else None)

    def registrar_erro(evento: str, id_requisicao: str):
        with obter_engine().begin() as conexao:
            conexao.execute(_LOG, {"agora": datetime.now(timezone.utc), "servico": nome, "evento": evento[:60],
                                   "id_requisicao": id_requisicao[:32]})

    registrar_tratadores(app, registrar_erro)

    # Ordem: o ultimo adicionado e o primeiro a rodar.
    app.add_middleware(CabecalhosSeguranca, hsts=cfg.forcar_https)
    if cfg.origens_cors:
        app.add_middleware(CORSMiddleware, allow_origins=cfg.origens_cors, allow_credentials=False,
                           allow_methods=["GET", "POST", "PATCH", "PUT"],
                           allow_headers=["Authorization", "Content-Type"], max_age=600)
    app.add_middleware(TrustedHostMiddleware, allowed_hosts=cfg.hosts_permitidos)
    if cfg.forcar_https:
        app.add_middleware(HTTPSRedirectMiddleware)

    for router in routers:
        app.include_router(router)

    @app.get("/saude", tags=["saude"])
    def verificar_saude():
        """Publico e sem detalhe interno: so diz se o servico e o banco respondem."""
        try:
            with obter_engine().connect() as conexao:
                conexao.execute(_PING)
            return {"status": "no ar", "servico": nome, "versao": __version__, "banco": "ok"}
        except Exception:
            return JSONResponse({"status": "degradado", "servico": nome, "versao": __version__, "banco": "indisponível"},
                                status_code=503)

    return app
