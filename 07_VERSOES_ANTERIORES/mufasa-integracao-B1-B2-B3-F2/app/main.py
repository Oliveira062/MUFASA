"""
Aplicacao FastAPI do MUFASA: registra rotas, tratadores de erro e as
camadas de seguranca HTTP.
"""

import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.httpsredirect import HTTPSRedirectMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware

from app.api.erros import registrar_tratadores
from app.api.rotas import router
from app.api.seguranca import CabecalhosSeguranca
from app.chatbot.rotas_chat import router_chat
from app.config import obter_configuracao

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s %(message)s")


def criar_app() -> FastAPI:
    cfg = obter_configuracao()
    docs = cfg.docs_habilitada and not cfg.em_producao

    app = FastAPI(
        title="MUFASA",
        version="0.3.0",
        description="API do sistema de alerta precoce de evasao. Todo endpoint exige token, exceto /saude e /api/v1/auth/token.",
        docs_url="/docs" if docs else None,
        redoc_url=None,
        openapi_url="/openapi.json" if docs else None,
    )

    registrar_tratadores(app)

    # Ordem: o ultimo adicionado e o primeiro a rodar.
    app.add_middleware(CabecalhosSeguranca, hsts=cfg.forcar_https)
    if cfg.origens_cors:
        app.add_middleware(
            CORSMiddleware,
            allow_origins=cfg.origens_cors,          # lista explicita, nunca "*"
            allow_credentials=False,                 # token vai no cabecalho, nao em cookie
            allow_methods=["GET", "POST", "PATCH", "PUT"],
            allow_headers=["Authorization", "Content-Type"],
            max_age=600,
        )
    app.add_middleware(TrustedHostMiddleware, allowed_hosts=cfg.hosts_permitidos)
    if cfg.forcar_https:
        app.add_middleware(HTTPSRedirectMiddleware)

    app.include_router(router)
    app.include_router(router_chat)  # chatbot (F2): mesma autenticacao e escopo da API

    @app.get("/saude", tags=["saude"])
    def verificar_saude():
        return {"status": "no ar", "sistema": "MUFASA"}

    return app


app = criar_app()
