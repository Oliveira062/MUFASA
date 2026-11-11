"""
Exporta as contas do banco para banco/contas_iniciais.sql (so hashes bcrypt),
para que outra instalacao tenha os mesmos logins e senhas iniciais.

    python -m scripts.exportar_contas

O arquivo nao tem senha em texto; as senhas iniciais ficam so no CSV gerado
por scripts.gerar_contas, que deve ser entregue por canal seguro.
"""

import os
import sys

from psycopg import sql
from sqlalchemy import create_engine, text

from scripts._ambiente import RAIZ, carregar_env

CONTAS = text("""
    SELECT login, senha_hash, perfil, id_aluno, id_professor, id_curso, nome, email, deve_trocar_senha, demonstracao
      FROM usuarios ORDER BY perfil, login
""")
COLUNAS = ("login", "senha_hash", "perfil", "id_aluno", "id_professor", "id_curso", "nome", "email",
           "deve_trocar_senha", "demonstracao")


def main() -> int:
    carregar_env()
    url = os.environ.get("DATABASE_URL_ADMIN")
    if not url:
        print("Defina DATABASE_URL_ADMIN.", file=sys.stderr)
        return 2
    engine = create_engine(url)
    with engine.connect() as c:
        linhas = c.execute(CONTAS).mappings().all()
        conexao_psycopg = c.connection.driver_connection
        valores = [sql.SQL("({})").format(sql.SQL(", ").join(sql.Literal(l[k]) for k in COLUNAS)).as_string(conexao_psycopg)
                   for l in linhas]
    destino = RAIZ / "banco" / "contas_iniciais.sql"
    destino.write_text(
        "-- Contas iniciais do MUFASA (gerado por scripts/exportar_contas.py). So hashes bcrypt.\n"
        "-- Senhas iniciais: banco/credenciais_iniciais.csv (entregar por canal seguro).\n"
        "-- Todas as contas pedem troca de senha e aceite do termo no primeiro acesso,\n"
        "-- exceto as de demonstracao, que nao entram quando AMBIENTE=producao.\n"
        f"INSERT INTO usuarios ({', '.join(COLUNAS)}) VALUES\n" + ",\n".join(valores)
        + "\nON CONFLICT DO NOTHING;\n", encoding="utf-8")
    print(f"{len(linhas)} conta(s) exportadas para {destino}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
