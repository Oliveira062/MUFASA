"""
Cliente HTTP do painel. O painel nao fala com o banco: tudo passa pela API
(perfil, escopo e recorte aplicados no servidor) e pelo servico do chat.

Isolamento de falhas:
- tempo limite curto em toda chamada;
- disjuntor por servico: depois de 3 falhas seguidas, o servico fica
  "aberto" por 20 s e as telas que dependem dele mostram aviso, sem travar
  as demais (o chat fora do ar nao derruba o painel, e vice-versa);
- erro vira excecao com mensagem clara, tratada por secao (ver ui.secao).
"""

import os
import threading
import time
from dataclasses import dataclass

import httpx
import streamlit as st

from registro_painel import log

URL_API = os.environ.get("MUFASA_API_URL", "http://127.0.0.1:8000").rstrip("/")
URL_CHAT = os.environ.get("MUFASA_CHAT_URL", "http://127.0.0.1:8001").rstrip("/")
TEMPO_LIMITE = httpx.Timeout(10.0, connect=3.0)
FALHAS_PARA_ABRIR = 3
TEMPO_ABERTO_S = 20
RENOVAR_FALTANDO_S = 600


class ErroAPI(Exception):
    def __init__(self, status: int, mensagem: str, campos=None, pendencia=None, requisicao=None):
        super().__init__(mensagem)
        self.status, self.mensagem, self.campos, self.pendencia = status, mensagem, campos or [], pendencia
        # Codigo da requisicao na API: o mesmo que esta no log do servidor.
        self.requisicao = requisicao


class ServicoIndisponivel(ErroAPI):
    pass


@dataclass
class _Disjuntor:
    falhas: int = 0
    aberto_ate: float = 0.0


_disjuntores = {"api": _Disjuntor(), "chat": _Disjuntor()}
_trava = threading.Lock()


def _antes(servico: str):
    with _trava:
        d = _disjuntores[servico]
        if d.aberto_ate > time.monotonic():
            raise ServicoIndisponivel(503, f"O serviço {'do assistente' if servico == 'chat' else 'de dados'} "
                                           "está indisponível. Tentando de novo em instantes.")


def _resultado(servico: str, ok: bool):
    with _trava:
        d = _disjuntores[servico]
        if ok:
            d.falhas, d.aberto_ate = 0, 0.0
        else:
            d.falhas += 1
            if d.falhas >= FALHAS_PARA_ABRIR:
                d.aberto_ate = time.monotonic() + TEMPO_ABERTO_S


def servico_disponivel(servico: str) -> bool:
    return _disjuntores[servico].aberto_ate <= time.monotonic()


def _cabecalhos() -> dict:
    token = st.session_state.get("token")
    return {"Authorization": f"Bearer {token}"} if token else {}


def chamar(metodo: str, caminho: str, *, servico: str = "api", json=None, params=None, data=None, files=None,
           autenticado: bool = True):
    _antes(servico)
    base = URL_CHAT if servico == "chat" else URL_API
    if autenticado:
        _renovar_se_preciso()
    try:
        r = httpx.request(metodo, base + caminho, json=json, params=_limpar(params), data=data, files=files,
                          headers=_cabecalhos() if autenticado else {}, timeout=TEMPO_LIMITE)
    except httpx.HTTPError as exc:
        log.warning("sem resposta do servico %s em %s: %s", servico, metodo, type(exc).__name__)
        _resultado(servico, False)
        raise ServicoIndisponivel(503, "Não foi possível falar com o servidor. Tente de novo em instantes.")
    _resultado(servico, r.status_code < 500)
    if r.status_code == 204:
        return None
    try:
        corpo = r.json()
    except ValueError:
        corpo = {}
    if r.status_code >= 400:
        detalhe = corpo.get("detalhe") if isinstance(corpo, dict) else None
        if r.status_code == 401 and autenticado:
            encerrar_sessao_local("Sua sessão expirou. Entre novamente.")
        if r.status_code >= 500:
            log.warning("API respondeu %s em %s %s (req=%s)", r.status_code, metodo, caminho.split("?")[0],
                        r.headers.get("X-Request-ID") or (corpo.get("requisicao") if isinstance(corpo, dict) else None))
        raise ErroAPI(r.status_code, detalhe or "Não foi possível concluir a operação.",
                      corpo.get("campos") if isinstance(corpo, dict) else None, r.headers.get("X-Pendencia"),
                      r.headers.get("X-Request-ID") or (corpo.get("requisicao") if isinstance(corpo, dict) else None))
    return corpo


def _limpar(params):
    if not params:
        return None
    return {k: v for k, v in params.items() if v not in (None, "", "Todos", "Todas")}


def get(caminho, **params):
    return chamar("GET", caminho, params=params)


def post(caminho, json=None, **kw):
    return chamar("POST", caminho, json=json, **kw)


def patch(caminho, json=None):
    return chamar("PATCH", caminho, json=json)


def put(caminho, json=None):
    return chamar("PUT", caminho, json=json)


def entrar(login: str, senha: str, perfil: str) -> dict:
    t = chamar("POST", "/api/v1/auth/token", json={"login": login, "senha": senha, "perfil": perfil},
               autenticado=False)
    guardar_token(t)
    return t


def guardar_token(t: dict):
    st.session_state["token"] = t["access_token"]
    st.session_state["token_expira"] = time.time() + int(t["expira_em_segundos"])
    st.session_state["perfil"] = t["perfil"]


def _renovar_se_preciso():
    """Sessao ativa e renovada; parada por 30 min, expira (RN12)."""
    expira = st.session_state.get("token_expira")
    if not expira or st.session_state.get("_renovando"):
        return
    if expira - time.time() < RENOVAR_FALTANDO_S:
        st.session_state["_renovando"] = True
        try:
            guardar_token(chamar("POST", "/api/v1/auth/renovar"))
        except ErroAPI:
            pass
        finally:
            st.session_state["_renovando"] = False


def encerrar_sessao_local(motivo: str | None = None):
    for chave in list(st.session_state.keys()):
        del st.session_state[chave]
    if motivo:
        st.session_state["aviso_login"] = motivo


def sair():
    try:
        chamar("POST", "/api/v1/auth/sair")
    except ErroAPI:
        pass
    encerrar_sessao_local("Você saiu do sistema.")
