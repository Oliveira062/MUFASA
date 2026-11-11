"""
Aplica cargas confirmadas pela administracao (RN08: uma carga nunca e
aplicada pela metade). A API ja validou cada linha; aqui as linhas validas
sao gravadas numa transacao so. Se qualquer uma falhar, nada e gravado e a
carga fica como FALHOU.

Gravar notas dispara os gatilhos do banco: indicadores do aluno refeitos,
aluno na fila de recalculo, score novo e painel atualizado.
"""

import json
from datetime import datetime, timezone

from sqlalchemy.engine import Engine

from app.servico_calculo import consultas_calculo as sql

COMANDO_POR_TIPO = {"NOTAS": sql.APLICAR_NOTAS, "INDICADORES": sql.APLICAR_INDICADORES}


def aplicar_proxima_carga(engine: Engine) -> int | None:
    """Aplica uma carga confirmada, se houver. Devolve o id da carga ou None."""
    with engine.begin() as conexao:
        carga = conexao.execute(sql.CARGA_CONFIRMADA).mappings().first()
        if carga is None:
            return None
        id_carga = carga["id_carga"]
        try:
            with conexao.begin_nested():
                comando = COMANDO_POR_TIPO[carga["tipo"]]
                total = 0
                for linha in conexao.execute(sql.LINHAS_DA_CARGA, {"id_carga": id_carga}).mappings().all():
                    dados = linha["dados"] if isinstance(linha["dados"], dict) else json.loads(linha["dados"])
                    conexao.execute(comando, dados)
                    total += 1
            situacao, resultado = "APLICADA", f"{total} linha(s) aplicadas."
        except Exception as exc:  # o savepoint ja desfez as linhas
            situacao, resultado = "FALHOU", f"Nenhuma linha aplicada: {type(exc).__name__}."
        conexao.execute(sql.FINALIZAR_CARGA, {"id_carga": id_carga, "situacao": situacao, "resultado": resultado,
                                              "agora": datetime.now(timezone.utc)})
        conexao.execute(sql.CRIAR_NOTIFICACAO, {"id_usuario": carga["enviado_por"], "agora": datetime.now(timezone.utc),
                                                "tipo": "CARGA", "titulo": f"Carga {id_carga}: {situacao.lower()}",
                                                "texto": resultado, "id_alerta": None})
        return id_carga
