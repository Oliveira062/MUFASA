"""
Conta do usuario logado: primeiro acesso (senha provisoria e termo),
renovacao da sessao e notificacoes.

Estas rotas usam obter_usuario_atual, e nao obter_usuario_liberado: sao
justamente o caminho para sair da pendencia de primeiro acesso.
"""

import re
from datetime import datetime, timezone
from typing import Annotated

from fastapi import APIRouter, Depends, Path, Query, Request
from pydantic import Field, field_validator
from sqlalchemy.engine import Connection

from app.api import auditoria, consultas as sql, consultas_painel as sqlp
from app.api.auth import (VERSAO_TERMO, Usuario, conferir_senha, emitir_token, gerar_hash_senha,
                          obter_carga_token, obter_usuario_atual)
from app.api.banco import obter_conexao
from app.api.erros import erro_http
from app.api.esquemas import Fechado, RespostaToken
from app.api.util import agora, valor_json

router_conta = APIRouter(prefix="/api/v1", tags=["conta"])

TAMANHO_MINIMO_SENHA = 10


class PedidoTermo(Fechado):
    versao: str = Field(pattern=r"^\d+\.\d+$", max_length=10)
    aceito: bool


class PedidoSenha(Fechado):
    senha_atual: str = Field(min_length=1, max_length=72)
    senha_nova: str = Field(min_length=TAMANHO_MINIMO_SENHA, max_length=72)

    @field_validator("senha_nova")
    @classmethod
    def _forca(cls, v: str) -> str:
        if len(v.encode("utf-8")) > 72:
            raise ValueError("senha acima de 72 bytes")
        if not re.search(r"[A-Za-z]", v) or not re.search(r"\d", v):
            raise ValueError("a senha precisa ter letras e números")
        return v


def problema_da_senha(nova: str, login: str) -> str | None:
    """Regras que dependem da conta (o formato ja foi conferido no esquema)."""
    if login.lower() in nova.lower():
        return "A nova senha não pode conter o seu login."
    if len(set(nova)) < 5:
        return "A nova senha repete caracteres demais."
    return None


@router_conta.get("/conta/eu")
def minha_conta(usuario: Usuario = Depends(obter_usuario_atual), conexao: Connection = Depends(obter_conexao)):
    linha = conexao.execute(sqlp.CONTA, {"id_usuario": usuario.id_usuario}).mappings().first()
    return {
        "id_usuario": linha["id_usuario"], "login": linha["login"], "nome": linha["nome"], "perfil": linha["perfil"],
        "matricula": linha["id_aluno"], "curso": linha["curso"], "id_curso": linha["id_curso"],
        "deve_trocar_senha": bool(linha["deve_trocar_senha"]),
        "termo_pendente": linha["termo_versao"] != VERSAO_TERMO, "versao_termo_vigente": VERSAO_TERMO,
        "termo_aceito_em": valor_json(linha["termo_aceito_em"]), "ultimo_login": valor_json(linha["ultimo_login"]),
        "notificacoes_nao_lidas": int(linha["notificacoes_nao_lidas"]),
    }


@router_conta.post("/conta/termo", status_code=204)
def aceitar_termo(pedido: PedidoTermo, request: Request, usuario: Usuario = Depends(obter_usuario_atual),
                  conexao: Connection = Depends(obter_conexao)):
    """Aceite do termo de uso e privacidade do primeiro acesso (LGPD art. 9)."""
    if pedido.versao != VERSAO_TERMO:
        raise erro_http(409, f"A versão vigente do termo é {VERSAO_TERMO}. Recarregue a página.")
    if not pedido.aceito:
        auditoria.registrar(request, "TERMO_RECUSADO", "NEGADO", usuario=usuario)
        raise erro_http(403, "Sem aceitar o termo não é possível usar o sistema. Em caso de dúvida, procure o "
                             "encarregado de dados da instituição.")
    conexao.execute(sqlp.ACEITAR_TERMO, {"versao": VERSAO_TERMO, "agora": agora(), "id_usuario": usuario.id_usuario})
    conexao.commit()
    auditoria.registrar(request, "TERMO_ACEITO", "PERMITIDO", usuario=usuario)


@router_conta.post("/conta/senha", status_code=204)
def trocar_senha(pedido: PedidoSenha, request: Request, usuario: Usuario = Depends(obter_usuario_atual),
                 conexao: Connection = Depends(obter_conexao)):
    linha = conexao.execute(sqlp.SENHA_DO_USUARIO, {"id_usuario": usuario.id_usuario}).mappings().first()
    if not conferir_senha(pedido.senha_atual, linha["senha_hash"]):
        auditoria.registrar(request, "TROCA_SENHA", "NEGADO", usuario=usuario)
        raise erro_http(403, "A senha atual não confere.")
    if conferir_senha(pedido.senha_nova, linha["senha_hash"]):
        raise erro_http(422, "A nova senha precisa ser diferente da atual.")
    problema = problema_da_senha(pedido.senha_nova, linha["login"])
    if problema:
        raise erro_http(422, problema)
    conexao.execute(sqlp.TROCAR_SENHA, {"senha_hash": gerar_hash_senha(pedido.senha_nova), "agora": agora(),
                                        "id_usuario": usuario.id_usuario})
    conexao.commit()
    auditoria.registrar(request, "TROCA_SENHA", "PERMITIDO", usuario=usuario)


@router_conta.post("/auth/renovar", response_model=RespostaToken, tags=["autenticacao"])
def renovar_sessao(request: Request, usuario: Usuario = Depends(obter_usuario_atual),
                   carga: dict = Depends(obter_carga_token), conexao: Connection = Depends(obter_conexao)):
    """
    Troca um token ainda valido por um novo e revoga o antigo. O painel chama
    enquanto ha uso; parado por 30 minutos, a sessao expira (RN12).
    """
    conexao.execute(sql.REVOGAR_TOKEN, {"jti": carga["jti"],
                                        "expira_em": datetime.fromtimestamp(carga["exp"], tz=timezone.utc)})
    conexao.commit()
    token, segundos = emitir_token(usuario.id_usuario, usuario.perfil)
    auditoria.registrar(request, "RENOVAR_SESSAO", "PERMITIDO", usuario=usuario)
    return RespostaToken(access_token=token, expira_em_segundos=segundos, perfil=usuario.perfil,
                         deve_trocar_senha=usuario.deve_trocar_senha, termo_pendente=usuario.termo_pendente)


@router_conta.get("/conta/notificacoes")
def minhas_notificacoes(so_nao_lidas: bool = False,
                        limite: Annotated[int, Query(ge=1, le=100)] = 30,
                        pagina: Annotated[int, Query(ge=1, le=1000)] = 1,
                        usuario: Usuario = Depends(obter_usuario_atual),
                        conexao: Connection = Depends(obter_conexao)):
    linhas = conexao.execute(sqlp.NOTIFICACOES, {
        "id_usuario": usuario.id_usuario, "so_nao_lidas": so_nao_lidas, "limite": limite,
        "deslocamento": (pagina - 1) * limite}).mappings().all()
    return [{k: valor_json(v) for k, v in l.items()} for l in linhas]


@router_conta.post("/conta/notificacoes/{id_notificacao}/leitura", status_code=204)
def marcar_lida(id_notificacao: Annotated[int, Path(ge=1)], usuario: Usuario = Depends(obter_usuario_atual),
                conexao: Connection = Depends(obter_conexao)):
    conexao.execute(sqlp.MARCAR_LIDA, {"id_notificacao": id_notificacao, "id_usuario": usuario.id_usuario,
                                       "agora": agora()})
    conexao.commit()


@router_conta.post("/conta/notificacoes/leitura", status_code=204)
def marcar_todas_lidas(usuario: Usuario = Depends(obter_usuario_atual), conexao: Connection = Depends(obter_conexao)):
    conexao.execute(sqlp.MARCAR_TODAS_LIDAS, {"id_usuario": usuario.id_usuario, "agora": agora()})
    conexao.commit()
