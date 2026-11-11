"""
Configuracao do MUFASA, lida SOMENTE de variaveis de ambiente (.env).

Nenhum segredo tem valor padrao no codigo. Se JWT_SECRET ou DATABASE_URL
faltarem, a API nao sobe: falhar cedo e melhor do que subir com uma chave
previsivel (OWASP A02/A05, SRS RN18).
"""

from decimal import Decimal
from functools import lru_cache

from pydantic import Field, SecretStr, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Configuracao(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    # Banco. A API conecta com o usuario mufasa_api (sql/b3_complemento.sql),
    # nunca com o superusuario postgres.
    database_url: SecretStr

    # JWT. HS256 com chave de no minimo 32 bytes aleatorios.
    jwt_secret: SecretStr
    jwt_algoritmo: str = "HS256"
    jwt_expira_minutos: int = Field(default=30, ge=5, le=120)
    jwt_emissor: str = "mufasa-api"
    jwt_publico: str = "mufasa-interface"

    # Ambiente: "desenvolvimento" ou "producao".
    ambiente: str = "desenvolvimento"
    forcar_https: bool = False
    hosts_permitidos: list[str] = ["localhost", "127.0.0.1", "testserver"]
    origens_cors: list[str] = []
    docs_habilitada: bool = True

    # Login (RN12): bloqueio apos 5 falhas.
    login_max_falhas: int = 5
    login_bloqueio_minutos: int = 15

    # Limites de requisicao (SRS Anexo D.1).
    limite_req_minuto: int = 120
    limite_login_minuto: int = 10

    # Salario minimo vigente, para converter renda per capita em SM.
    # Sem valor configurado, o fator financeiro fica ausente (nunca inventado).
    salario_minimo: Decimal | None = None

    @field_validator("jwt_secret")
    @classmethod
    def _chave_forte(cls, v: SecretStr) -> SecretStr:
        if len(v.get_secret_value().encode()) < 32:
            raise ValueError("JWT_SECRET precisa de pelo menos 32 bytes aleatorios")
        return v

    @field_validator("jwt_algoritmo")
    @classmethod
    def _algoritmo_permitido(cls, v: str) -> str:
        # "none" e algoritmos assimetricos sem chave publica configurada ficam de fora.
        if v not in ("HS256", "HS384", "HS512"):
            raise ValueError("JWT_ALGORITMO deve ser HS256, HS384 ou HS512")
        return v

    @property
    def em_producao(self) -> bool:
        return self.ambiente == "producao"


@lru_cache
def obter_configuracao() -> Configuracao:
    return Configuracao()
