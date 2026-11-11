"""
Parametros vigentes lidos do banco (RN22), para a API.

O servico de calculo le a mesma tabela. Aqui a leitura serve para exibir
numeros com a mesma regra do score (salario minimo, minimo de grupo, prazos).
Se a tabela ainda nao existir (banco antigo), valem os padroes do SRS.
"""

from sqlalchemy import text
from sqlalchemy.engine import Connection
from sqlalchemy.exc import ProgrammingError

from app.calculo.parametros import PADRAO, Parametros

_VALORES = text("SELECT chave, valor FROM parametros")
_VERSAO = text("SELECT max(versao) FROM parametros_versoes")


def parametros_vigentes(conexao: Connection) -> Parametros:
    try:
        with conexao.begin_nested():
            valores = {l["chave"]: float(l["valor"]) for l in conexao.execute(_VALORES).mappings()}
            versao = conexao.execute(_VERSAO).scalar() or 0
    except ProgrammingError:
        return PADRAO
    return Parametros({**PADRAO.valores, **valores}, versao=int(versao))
