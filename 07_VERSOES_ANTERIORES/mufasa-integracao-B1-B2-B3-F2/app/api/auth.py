"""
Autenticacao: hash de senha, emissao e leitura do JWT, usuario atual.

- Senha: bcrypt custo 12 (SRS RN18). Biblioteca bcrypt direta, sem passlib,
  que esta sem manutencao.
- JWT: PyJWT, algoritmo fixo na leitura (impede o ataque "alg: none" e a
  troca de algoritmo), exp/iat/sub/jti obrigatorios, emissor e publico
  conferidos, validade de 30 minutos (encerramento por inatividade, RN12).
- Token so no cabecalho Authorization: Bearer. A API nao usa cookie de
  sessao, o que elimina CSRF por construcao.
- Perfil e escopo sao lidos do BANCO a cada requisicao, nao do token: um
  usuario desativado perde o acesso na hora.
"""

import uuid
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone

import bcrypt
import jwt
from fastapi import Depends, Request
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.engine import Connection

from app.api import auditoria
from app.api.banco import obter_conexao
from app.api.consultas import TOKEN_REVOGADO, USUARIO_POR_ID
from app.api.erros import erro_http
from app.api.seguranca import limitador
from app.config import obter_configuracao

CUSTO_BCRYPT = 12
LIMITE_BYTES_BCRYPT = 72

# Hash valido de uma senha aleatoria, usado quando o login nao existe, para
# que o tempo de resposta nao revele quais logins estao cadastrados.
_HASH_FICTICIO = bcrypt.hashpw(uuid.uuid4().bytes, bcrypt.gensalt(CUSTO_BCRYPT))

_bearer = HTTPBearer(auto_error=False)


@dataclass(frozen=True)
class Usuario:
    id_usuario: int
    login: str
    perfil: str
    id_aluno: str | None
    id_professor: str | None
    id_curso: str | None


def gerar_hash_senha(senha: str) -> str:
    dados = senha.encode("utf-8")
    if len(dados) > LIMITE_BYTES_BCRYPT:
        raise ValueError("Senha acima de 72 bytes")
    return bcrypt.hashpw(dados, bcrypt.gensalt(CUSTO_BCRYPT)).decode("ascii")


def conferir_senha(senha: str, senha_hash: str | None) -> bool:
    dados = senha.encode("utf-8")
    if len(dados) > LIMITE_BYTES_BCRYPT:
        return False
    if not senha_hash:
        bcrypt.checkpw(dados, _HASH_FICTICIO)
        return False
    try:
        return bcrypt.checkpw(dados, senha_hash.encode("ascii"))
    except ValueError:
        return False


def emitir_token(usuario_id: int, perfil: str) -> tuple[str, int]:
    cfg = obter_configuracao()
    agora = datetime.now(timezone.utc)
    validade = timedelta(minutes=cfg.jwt_expira_minutos)
    carga = {
        "sub": str(usuario_id),
        "perfil": perfil,  # informativo para a interface; a API confere no banco
        "iat": agora,
        "nbf": agora,
        "exp": agora + validade,
        "jti": uuid.uuid4().hex,
        "iss": cfg.jwt_emissor,
        "aud": cfg.jwt_publico,
    }
    token = jwt.encode(carga, cfg.jwt_secret.get_secret_value(), algorithm=cfg.jwt_algoritmo)
    return token, int(validade.total_seconds())


def ler_token(token: str) -> dict:
    cfg = obter_configuracao()
    return jwt.decode(
        token,
        cfg.jwt_secret.get_secret_value(),
        algorithms=[cfg.jwt_algoritmo],
        audience=cfg.jwt_publico,
        issuer=cfg.jwt_emissor,
        options={"require": ["exp", "iat", "nbf", "sub", "jti", "iss", "aud"]},
        leeway=10,
    )


_NAO_AUTENTICADO = {"WWW-Authenticate": "Bearer"}


def obter_carga_token(credenciais: HTTPAuthorizationCredentials | None = Depends(_bearer)) -> dict:
    if credenciais is None or credenciais.scheme.lower() != "bearer":
        raise erro_http(401, "Envie o token no cabeçalho Authorization: Bearer.", _NAO_AUTENTICADO)
    try:
        return ler_token(credenciais.credentials)
    except jwt.ExpiredSignatureError:
        raise erro_http(401, "Sessão expirada. Entre novamente.", _NAO_AUTENTICADO)
    except jwt.PyJWTError:
        raise erro_http(401, "Token inválido.", _NAO_AUTENTICADO)


def obter_usuario_atual(
    request: Request,
    carga: dict = Depends(obter_carga_token),
    conexao: Connection = Depends(obter_conexao),
) -> Usuario:
    if conexao.execute(TOKEN_REVOGADO, {"jti": carga["jti"]}).first():
        raise erro_http(401, "Sessão encerrada. Entre novamente.", _NAO_AUTENTICADO)

    try:
        id_usuario = int(carga["sub"])
    except (TypeError, ValueError):
        raise erro_http(401, "Token inválido.", _NAO_AUTENTICADO)

    linha = conexao.execute(USUARIO_POR_ID, {"id_usuario": id_usuario}).mappings().first()
    if linha is None or not linha["ativo"]:
        raise erro_http(401, "Usuário inativo ou inexistente.", _NAO_AUTENTICADO)

    usuario = Usuario(
        id_usuario=linha["id_usuario"], login=linha["login"], perfil=linha["perfil"],
        id_aluno=linha["id_aluno"], id_professor=linha["id_professor"], id_curso=linha["id_curso"],
    )

    # 120 requisicoes por minuto por usuario (SRS Anexo D.1).
    permitido, espera = limitador.permitir(f"usuario:{usuario.id_usuario}", obter_configuracao().limite_req_minuto)
    if not permitido:
        auditoria.registrar(request, "LIMITE_EXCEDIDO", "NEGADO", usuario=usuario)
        raise erro_http(429, "Limite de requisições excedido. Aguarde e tente de novo.",
                        {"Retry-After": str(espera)})

    request.state.carga_token = carga
    return usuario


def exigir_perfis(*perfis: str):
    """Dependencia que barra, NO SERVIDOR, qualquer perfil fora da lista."""

    def _verificar(request: Request, usuario: Usuario = Depends(obter_usuario_atual)) -> Usuario:
        if usuario.perfil not in perfis:
            auditoria.registrar(request, "PERFIL_NAO_AUTORIZADO", "NEGADO", usuario=usuario)
            raise erro_http(403, "Seu perfil não tem acesso a este recurso.")
        return usuario

    return _verificar
