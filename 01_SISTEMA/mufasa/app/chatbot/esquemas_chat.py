"""Contratos do chatbot. Mesmo padrao do B3: campos fechados (extra="forbid")."""

from datetime import datetime
from typing import Annotated, Any

from fastapi import Query
from pydantic import BaseModel, Field

from app.api.esquemas import Fechado


class PedidoChat(Fechado):
    # So o texto. Quem pergunta e o perfil vem do token, nunca do corpo:
    # um corpo com usuario_id ou perfil e recusado com 422.
    texto: str = Field(min_length=1, max_length=500, description="Pergunta em português")


class RespostaChat(BaseModel):
    conversa: int
    intencao: str
    resposta: str = Field(description="Texto para exibir como TEXTO (textContent), nunca como HTML")
    dados: list[dict[str, Any]] = Field(description="Os mesmos valores da resposta, como estão no banco")
    filtros_aplicados: dict[str, Any]
    registros_considerados: int
    referencia: str | None = Field(description="Período ou data do cálculo usado")
    atalho_painel: str | None
    opcoes: list[str]
    aviso: str | None = Field(default=None, description="Encerramento por inatividade (RN13)")
    redigida_por_ia: bool
    recusa: bool


class Abertura(BaseModel):
    mensagem: str
    disponibilidade: str
    atendimento_humano: str
    opcoes: list[str]


class MensagemHistorico(BaseModel):
    conversa: int
    momento: datetime | str
    pergunta: str
    intencao: str
    resposta: str


def limite_historico(limite: Annotated[int, Query(ge=1, le=200)] = 50) -> int:
    return limite
