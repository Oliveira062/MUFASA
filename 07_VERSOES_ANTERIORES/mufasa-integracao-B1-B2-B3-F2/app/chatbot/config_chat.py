"""
Configuracao do chatbot (F2), lida so de variaveis de ambiente (.env).

A chave da Groq e opcional: sem ela o chatbot responde com os textos
prontos de redacao.py, sem chamar nenhum servico externo. Nenhuma chave
tem valor padrao no codigo.
"""

from functools import lru_cache

from pydantic import Field, SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict


class ConfiguracaoChat(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    # Conexao com o perfil mufasa_chat (sql/chatbot.sql): le so as visoes
    # vw_chat_* e grava so nas tabelas chat_*. Vazio em desenvolvimento usa a
    # conexao da API; em producao e obrigatorio.
    chat_database_url: SecretStr | None = None

    # Groq (opcional). A IA so reescreve o texto; nunca recebe dado do aluno.
    groq_api_key: SecretStr | None = None
    groq_modelo: str = "openai/gpt-oss-20b"
    # Classificar pela IA as perguntas que as regras nao reconhecem. Desligado
    # por padrao: e o unico caso em que o texto digitado (redigido) sai do servidor.
    chat_ia_classificar: bool = False
    groq_timeout_segundos: float = Field(default=4.0, ge=1.0, le=10.0)  # SRS: chat em ate 5 s

    # SRS Anexo D.1: 20 mensagens por minuto por usuario no chat.
    chat_limite_minuto: int = Field(default=20, ge=1, le=120)
    # RN13: conversa encerra apos 2 horas sem interacao.
    chat_inatividade_minutos: int = Field(default=120, ge=1, le=1440)
    chat_tamanho_maximo: int = Field(default=500, ge=50, le=2000)

    # RF13: o chat funciona 24 h; o atendimento humano, nao. Texto definido pela instituicao.
    chat_janela_atendimento: str = "no horário de funcionamento da secretaria acadêmica"

    @property
    def ia_habilitada(self) -> bool:
        return self.groq_api_key is not None and bool(self.groq_api_key.get_secret_value().strip())


@lru_cache
def obter_configuracao_chat() -> ConfiguracaoChat:
    return ConfiguracaoChat()
