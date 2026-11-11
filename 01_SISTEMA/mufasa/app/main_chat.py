"""
Servico do chatbot (F2), em processo proprio.

    uvicorn app.main_chat:app --host 127.0.0.1 --port 8001

Usa o mesmo login JWT e a mesma checagem de escopo da API, e le o banco com
o perfil mufasa_chat (so as visoes vw_chat_*). Se este processo cair, a
API e o painel continuam; o painel mostra o chat como indisponivel.
"""

from app.chatbot.banco_chat import obter_engine_chat
from app.chatbot.rotas_chat import router_chat
from app.fabrica import criar_servico

from app.registro import configurar_registro

configurar_registro("chat")


def criar_app():
    return criar_servico("chat", "MUFASA Chat", (router_chat,), obter_engine_chat, sinal_de_vida=True)


app = criar_app()
