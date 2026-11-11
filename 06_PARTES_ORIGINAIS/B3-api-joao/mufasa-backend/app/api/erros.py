"""
Formato padronizado de erro (SRS Secao 3.3 e Anexo D.1).

Nenhuma resposta de erro leva rastreamento de pilha, nome de tabela,
consulta SQL ou o valor que o usuario enviou. O detalhe tecnico fica so
no log do servidor, ligado pelo identificador da requisicao.
"""

import logging

from fastapi import FastAPI, HTTPException, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

log = logging.getLogger("mufasa.erros")

TITULOS = {
    400: "Requisição inválida",
    401: "Autenticação necessária",
    403: "Permissão insuficiente",
    404: "Recurso não encontrado",
    405: "Método não permitido",
    409: "Conflito",
    413: "Conteúdo grande demais",
    422: "Dados inválidos",
    423: "Acesso bloqueado temporariamente",
    429: "Muitas requisições",
    500: "Erro interno",
}

# Mensagem unica para "nao existe" e "nao pode ver": quem pergunta por outro
# aluno nao descobre se a matricula existe (RN07).
MSG_ACESSO_NEGADO = "Você não tem permissão para acessar os dados deste aluno, ou ele não existe."


# Mensagens de validacao em portugues claro (RN10). O Pydantic responde em ingles.
MENSAGENS_VALIDACAO = {
    "missing": "Campo obrigatório.",
    "extra_forbidden": "Campo não permitido.",
    "string_too_short": "Texto curto demais.",
    "string_too_long": "Texto longo demais.",
    "string_pattern_mismatch": "Formato inválido.",
    "string_type": "Precisa ser texto.",
    "int_parsing": "Precisa ser um número inteiro.",
    "int_type": "Precisa ser um número inteiro.",
    "greater_than_equal": "Valor abaixo do mínimo permitido.",
    "less_than_equal": "Valor acima do máximo permitido.",
    "enum": "Valor fora da lista permitida.",
    "bool_parsing": "Precisa ser verdadeiro ou falso.",
    "json_invalid": "JSON inválido.",
}


def _id_requisicao(request: Request) -> str:
    return getattr(request.state, "id_requisicao", "-")


def resposta_erro(request: Request, status: int, detalhe: str, extra: dict | None = None,
                  cabecalhos: dict | None = None) -> JSONResponse:
    corpo = {
        "titulo": TITULOS.get(status, "Erro"),
        "status": status,
        "detalhe": detalhe,
        "requisicao": _id_requisicao(request),
    }
    if extra:
        corpo.update(extra)
    return JSONResponse(corpo, status_code=status, headers=cabecalhos)


def registrar_tratadores(app: FastAPI) -> None:
    @app.exception_handler(StarletteHTTPException)
    async def _http(request: Request, exc: StarletteHTTPException):
        detalhe = exc.detail if isinstance(exc.detail, str) else TITULOS.get(exc.status_code, "Erro")
        return resposta_erro(request, exc.status_code, detalhe, cabecalhos=getattr(exc, "headers", None))

    @app.exception_handler(RequestValidationError)
    async def _validacao(request: Request, exc: RequestValidationError):
        # O tratador padrao do FastAPI devolve o campo "input", que repete o valor
        # enviado - inclusive a senha de um login mal formatado. Aqui so vao
        # o nome do campo e a mensagem.
        campos = [
            {"campo": ".".join(str(p) for p in erro.get("loc", ()) if p != "body"),
             "mensagem": MENSAGENS_VALIDACAO.get(erro.get("type"), "Valor inválido.")}
            for erro in exc.errors()
        ]
        return resposta_erro(request, 422, "Um ou mais campos estão inválidos.", {"campos": campos})

    @app.exception_handler(Exception)
    async def _inesperado(request: Request, exc: Exception):
        # Pilha completa so no log do servidor.
        log.exception("Erro nao tratado na requisicao %s", _id_requisicao(request))
        return resposta_erro(request, 500, "Ocorreu um erro inesperado. Informe o código da requisição ao suporte.")


def erro_http(status: int, detalhe: str, cabecalhos: dict | None = None) -> HTTPException:
    return HTTPException(status_code=status, detail=detalhe, headers=cabecalhos)
