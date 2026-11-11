"""
Conversa e historico (RN13 e auditoria do Anexo D.2).

- Uma conversa aberta por usuario. Sem mensagem por 2 horas, ela encerra
  na proxima interacao, o usuario e avisado e o historico continua salvo.
- Cada mensagem grava: usuario, pergunta SEM dado pessoal, intencao,
  consulta executada, quantidade de registros, resposta, se a IA redigiu e
  se foi tentativa de burla. Senha, token e CPF nunca sao gravados.
"""

from datetime import datetime, timedelta, timezone

from sqlalchemy.engine import Connection

from app.chatbot import consultas_chat as sql
from app.chatbot.config_chat import obter_configuracao_chat

AVISO_ENCERRAMENTO = ("Sua conversa anterior foi encerrada depois de 2 horas sem mensagens. As mensagens "
                      "continuam salvas no seu histórico; esta é uma nova conversa.")


def agora() -> datetime:
    return datetime.now(timezone.utc)


def _como_datetime(valor) -> datetime | None:
    if valor is None:
        return None
    if isinstance(valor, datetime):
        return valor if valor.tzinfo else valor.replace(tzinfo=timezone.utc)
    convertido = datetime.fromisoformat(str(valor))
    return convertido if convertido.tzinfo else convertido.replace(tzinfo=timezone.utc)


def obter_ou_abrir(conexao: Connection, id_usuario: int) -> tuple[int, str | None]:
    """Devolve (id da conversa, aviso de encerramento por inatividade ou None)."""
    momento = agora()
    limite = timedelta(minutes=obter_configuracao_chat().chat_inatividade_minutos)
    aviso = None
    aberta = conexao.execute(sql.CONVERSA_ABERTA, {"id_usuario": id_usuario}).mappings().first()
    if aberta is not None:
        ultima = _como_datetime(aberta["ultima_interacao"])
        if ultima is not None and momento - ultima <= limite:
            conexao.execute(sql.TOCAR_CONVERSA, {"agora": momento, "id_conversa": aberta["id_conversa"],
                                                 "id_usuario": id_usuario})
            return aberta["id_conversa"], None
        conexao.execute(sql.ENCERRAR_CONVERSA, {"agora": momento, "motivo": "INATIVIDADE",
                                                "id_conversa": aberta["id_conversa"], "id_usuario": id_usuario})
        aviso = AVISO_ENCERRAMENTO
    nova = conexao.execute(sql.NOVA_CONVERSA, {"id_usuario": id_usuario, "agora": momento}).scalar_one()
    return nova, aviso


def encerrar(conexao: Connection, id_usuario: int) -> bool:
    aberta = conexao.execute(sql.CONVERSA_ABERTA, {"id_usuario": id_usuario}).mappings().first()
    if aberta is None:
        return False
    conexao.execute(sql.ENCERRAR_CONVERSA, {"agora": agora(), "motivo": "USUARIO",
                                            "id_conversa": aberta["id_conversa"], "id_usuario": id_usuario})
    return True


def registrar(conexao: Connection, *, id_conversa: int, id_usuario: int, pergunta_redigida: str,
              intencao: str, consulta: str | None, registros: int, resposta: str, redigida_por_ia: bool,
              tentativa_burla: bool) -> None:
    conexao.execute(sql.REGISTRAR_MENSAGEM, {
        "id_conversa": id_conversa, "id_usuario": id_usuario, "momento": agora(),
        "pergunta_redigida": pergunta_redigida[:600], "intencao": intencao,
        "consulta_executada": consulta, "registros": registros, "resposta": resposta[:4000],
        "redigida_por_ia": redigida_por_ia, "tentativa_burla": tentativa_burla,
    })
