"""
Camadas de seguranca HTTP: identificador de requisicao, cabecalhos de
seguranca, limite de requisicoes e limite de tamanho de corpo.
"""

import threading
import time
import uuid
from collections import defaultdict, deque

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse, Response

# CSP da API: ela so devolve JSON, entao nada pode ser carregado nem embutido.
CSP_API = "default-src 'none'; frame-ancestors 'none'; base-uri 'none'; form-action 'none'"

# CSP do /docs (somente em desenvolvimento): o Swagger UI vem do jsDelivr.
CSP_DOCS = (
    "default-src 'none'; script-src 'self' https://cdn.jsdelivr.net 'unsafe-inline'; "
    "style-src 'self' https://cdn.jsdelivr.net 'unsafe-inline'; img-src 'self' data: https://fastapi.tiangolo.com; "
    "connect-src 'self'; frame-ancestors 'none'; base-uri 'none'"
)

TAMANHO_MAXIMO_CORPO = 64 * 1024  # 64 KB: nenhum endpoint atual recebe arquivo.


class CabecalhosSeguranca(BaseHTTPMiddleware):
    def __init__(self, app, hsts: bool):
        super().__init__(app)
        self.hsts = hsts

    async def dispatch(self, request: Request, call_next) -> Response:
        request.state.id_requisicao = uuid.uuid4().hex[:12]

        tamanho = request.headers.get("content-length")
        if tamanho is not None and (not tamanho.isdigit() or int(tamanho) > TAMANHO_MAXIMO_CORPO):
            return JSONResponse(
                {"titulo": "Conteúdo grande demais", "status": 413,
                 "detalhe": "O corpo da requisição excede o limite.", "requisicao": request.state.id_requisicao},
                status_code=413,
            )

        resposta = await call_next(request)

        caminho = request.url.path
        e_docs = caminho in ("/docs", "/redoc", "/openapi.json") or caminho.startswith("/docs/")
        resposta.headers["X-Request-ID"] = request.state.id_requisicao
        resposta.headers["X-Content-Type-Options"] = "nosniff"
        resposta.headers["X-Frame-Options"] = "DENY"
        resposta.headers["Referrer-Policy"] = "no-referrer"
        resposta.headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=(), interest-cohort=()"
        resposta.headers["Cross-Origin-Opener-Policy"] = "same-origin"
        resposta.headers["Content-Security-Policy"] = CSP_DOCS if e_docs else CSP_API
        # Dado pessoal nao fica em cache de navegador nem de proxy.
        resposta.headers["Cache-Control"] = "no-store"
        if self.hsts:
            resposta.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
        if "server" in resposta.headers:
            del resposta.headers["server"]
        return resposta


class LimitadorJanela:
    """
    Limite por janela deslizante de 60 segundos, em memoria.

    Serve para um unico processo (sprints e apresentacao). Com mais de um
    worker, cada um conta separado: em producao, trocar por Redis.
    """

    def __init__(self):
        self._eventos: dict[str, deque] = defaultdict(deque)
        self._trava = threading.Lock()

    def permitir(self, chave: str, limite: int, janela: float = 60.0) -> tuple[bool, int]:
        agora = time.monotonic()
        with self._trava:
            fila = self._eventos[chave]
            while fila and agora - fila[0] > janela:
                fila.popleft()
            if len(fila) >= limite:
                espera = int(janela - (agora - fila[0])) + 1
                return False, espera
            fila.append(agora)
            return True, 0

    def limpar(self) -> None:
        with self._trava:
            self._eventos.clear()


limitador = LimitadorJanela()


def ip_do_cliente(request: Request) -> str:
    # Atras de proxy reverso, rodar o uvicorn com --proxy-headers e
    # --forwarded-allow-ips=<ip do proxy>. Nunca ler X-Forwarded-For na mao:
    # o cliente escolhe o valor desse cabecalho.
    return request.client.host if request.client else "desconhecido"
