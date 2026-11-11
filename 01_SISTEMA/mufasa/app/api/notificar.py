"""
Notificacoes internas geradas pela API (atribuicao, divergencia, parametro).

O texto nunca leva dado sensivel: no maximo matricula e nivel (RN03). O
detalhe fica atras do login, na tela do alerta.
"""

from sqlalchemy.engine import Connection

from app.api import consultas_painel as sqlp
from app.api.util import agora


def notificar(conexao: Connection, ids_usuario, tipo: str, titulo: str, texto: str, id_alerta=None) -> None:
    momento = agora()
    for id_usuario in dict.fromkeys(ids_usuario):
        conexao.execute(sqlp.CRIAR_NOTIFICACAO, {"id_usuario": id_usuario, "agora": momento, "tipo": tipo,
                                                 "titulo": titulo[:120], "texto": texto[:300],
                                                 "id_alerta": id_alerta})


def usuarios_do_perfil(conexao: Connection, perfil: str, id_curso: str | None = None) -> list[int]:
    return list(conexao.execute(sqlp.USUARIOS_ATIVOS_DO_PERFIL, {"perfil": perfil, "id_curso": id_curso}).scalars())
