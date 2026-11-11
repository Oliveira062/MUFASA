"""
Contratos de entrada e saida (Pydantic).

Toda entrada tem tipo, tamanho e formato fechados, e campos desconhecidos
sao recusados (extra="forbid"): o FastAPI rejeita com 422 antes de o dado
chegar perto do banco (SRS RN08, RN11).
"""

from datetime import date, datetime
from enum import Enum
from typing import Annotated

from fastapi import Path, Query
from pydantic import BaseModel, ConfigDict, Field, field_validator

# SRS RN12: matricula e texto com exatamente 7 digitos. O banco simulado do
# B1 usa o formato ALU0000; a segunda alternativa sai quando o B1 migrar
# para a matricula oficial.
PADRAO_MATRICULA = r"^(?:\d{7}|ALU\d{4})$"

Matricula = Annotated[str, Path(pattern=PADRAO_MATRICULA, description="Matricula do aluno (7 digitos)")]


class Fechado(BaseModel):
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)


# ---------------------------------------------------------------------------
# Autenticacao
# ---------------------------------------------------------------------------

class PedidoLogin(Fechado):
    login: str = Field(min_length=3, max_length=64, pattern=r"^[A-Za-z0-9._@-]+$",
                       description="Matricula, para aluno; login institucional, para os demais perfis")
    senha: str = Field(min_length=1, max_length=72)

    @field_validator("senha")
    @classmethod
    def _limite_bcrypt(cls, v: str) -> str:
        if len(v.encode("utf-8")) > 72:
            raise ValueError("senha acima do limite de 72 bytes")
        return v


class RespostaToken(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expira_em_segundos: int
    perfil: str


# ---------------------------------------------------------------------------
# Alunos e score
# ---------------------------------------------------------------------------

class Ordem(str, Enum):
    nome = "nome"
    semestre = "semestre"
    matricula = "matricula"


class FiltrosLista(Fechado):
    semestre: int | None = Field(default=None, ge=1, le=12)
    ordem: Ordem = Ordem.nome
    limite: int = Field(default=25, ge=1, le=200)
    pagina: int = Field(default=1, ge=1, le=10_000)


def filtros_lista(
    semestre: Annotated[int | None, Query(ge=1, le=12)] = None,
    ordem: Ordem = Ordem.nome,
    limite: Annotated[int, Query(ge=1, le=200)] = 25,
    pagina: Annotated[int, Query(ge=1, le=10_000)] = 1,
) -> FiltrosLista:
    return FiltrosLista(semestre=semestre, ordem=ordem, limite=limite, pagina=pagina)


class AlunoResumo(BaseModel):
    matricula: str
    nome: str
    semestre: int | None
    nivel_risco: str | None


class PaginaAlunos(BaseModel):
    pagina: int
    limite: int
    itens: list[AlunoResumo]


class FatorScore(BaseModel):
    fator: str
    risco: float | None = Field(description="0 = sem risco, 100 = risco maximo; vazio quando o perfil ve so a faixa")
    faixa: str | None = None


AVISO_METODOLOGICO = (
    "O nível de risco indica que o padrão de indicadores deste estudante se assemelha a padrões que "
    "costumam anteceder a evasão. Não é previsão sobre a pessoa, não é julgamento de esforço ou "
    "capacidade e não pode ser usado em decisão de avaliação, seleção ou concessão de benefício."
)


class RespostaScore(BaseModel):
    matricula: str
    score: int | None
    nivel: str
    completude: float
    fatores_principais: list[str]
    detalhamento: list[FatorScore]
    faltas_restantes: int | None
    sobreposicao_frequencia: bool
    recomendacao: str
    explicacao: str
    aviso: str = AVISO_METODOLOGICO
    dados_ausentes: list[str] = Field(description="Fatores sem dado no banco; nao entram na conta")


class AvaliacaoHistorica(BaseModel):
    periodo_letivo: str | None
    tipo: str | None
    data_avaliacao: str | None
    risco_evasao_pct: float | None
    nivel_risco: str | None


class GrupoAgregado(BaseModel):
    semestre: int | None
    nivel_risco: str | None
    total: int


class RespostaAgregados(BaseModel):
    minimo_por_grupo: int
    grupos: list[GrupoAgregado]
    observacao: str = "Grupos com menos alunos que o mínimo foram suprimidos para impedir reidentificação."


# ---------------------------------------------------------------------------
# LGPD: consentimento e direitos do titular
# ---------------------------------------------------------------------------

class Finalidade(str, Enum):
    DADOS_SAUDE = "DADOS_SAUDE"  # art. 11, I: consentimento especifico e destacado


class PedidoConsentimento(Fechado):
    finalidade: Finalidade
    concedido: bool
    versao_termo: str = Field(pattern=r"^\d+\.\d+$", max_length=10)


class Consentimento(BaseModel):
    finalidade: str
    concedido: bool
    concedido_por: str
    versao_termo: str
    registrado_em: datetime | str


class TipoSolicitacao(str, Enum):
    CONFIRMACAO_ACESSO = "CONFIRMACAO_ACESSO"      # art. 18, I e II
    CORRECAO = "CORRECAO"                          # art. 18, III
    ANONIMIZACAO_ELIMINACAO = "ANONIMIZACAO_ELIMINACAO"  # art. 18, IV e VI
    PORTABILIDADE = "PORTABILIDADE"                # art. 18, V
    INFORMACAO_COMPARTILHAMENTO = "INFORMACAO_COMPARTILHAMENTO"  # art. 18, VII
    REVOGACAO_CONSENTIMENTO = "REVOGACAO_CONSENTIMENTO"  # art. 18, IX
    REVISAO_DECISAO_AUTOMATIZADA = "REVISAO_DECISAO_AUTOMATIZADA"  # art. 20
    OPOSICAO = "OPOSICAO"                          # art. 18, par. 2


class PedidoSolicitacao(Fechado):
    tipo: TipoSolicitacao
    descricao: str = Field(default="", max_length=1000)


class SolicitacaoRegistrada(BaseModel):
    protocolo_registrado: bool = True
    prazo: str = "Resposta em até 15 dias (LGPD, art. 19, II)."


class Solicitacao(BaseModel):
    id_solicitacao: int
    id_aluno: str
    tipo: str
    situacao: str
    registrada_em: datetime | str


class RegistroAuditoria(BaseModel):
    momento: datetime | str
    id_requisicao: str | None
    id_usuario: int | None
    perfil: str | None
    operacao: str
    recurso: str
    id_aluno_alvo: str | None
    resultado: str


class FiltroPagina(Fechado):
    limite: int = Field(default=25, ge=1, le=200)
    pagina: int = Field(default=1, ge=1, le=10_000)


def filtro_pagina(
    limite: Annotated[int, Query(ge=1, le=200)] = 25,
    pagina: Annotated[int, Query(ge=1, le=10_000)] = 1,
) -> FiltroPagina:
    return FiltroPagina(limite=limite, pagina=pagina)


def converter_data(valor) -> str | None:
    if valor is None:
        return None
    if isinstance(valor, (date, datetime)):
        return valor.isoformat()
    return str(valor)
