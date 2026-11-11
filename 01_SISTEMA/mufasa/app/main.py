"""
API do MUFASA (painel e integracoes). O chat roda em processo separado:
app/main_chat.py.

    uvicorn app.main:app --host 127.0.0.1 --port 8000
"""

from app.api.banco import obter_engine
from app.api.rotas import router
from app.api.rotas_admin import router_admin
from app.api.rotas_alertas import router_alertas
from app.api.rotas_aluno import router_aluno
from app.api.rotas_conta import router_conta
from app.api.rotas_paineis import router_paineis
from app.fabrica import criar_servico

from app.registro import configurar_registro

configurar_registro("api")

ROUTERS = (router, router_conta, router_alertas, router_paineis, router_aluno, router_admin)


def criar_app():
    return criar_servico("api", "MUFASA API", ROUTERS, obter_engine, sinal_de_vida=True)


app = criar_app()
