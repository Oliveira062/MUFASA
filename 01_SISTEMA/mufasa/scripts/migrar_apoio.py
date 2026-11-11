"""
Move apoio psicossocial e acessibilidade da tabela alunos para apoio_aluno,
cifrados, e remove as colunas antigas. Rodar UMA vez, como dono do banco,
depois de sql/b1_correcoes.sql:

    DATABASE_URL=postgresql+psycopg://<dono>@host/mufasa APOIO_CHAVE=<chave> \\
        python -m scripts.migrar_apoio

A copia e a remocao das colunas sao uma transacao so: se algo falhar no meio,
nada muda. Rodar de novo depois de concluido nao faz nada.
"""

import os
import sys

from sqlalchemy import create_engine, text

from app.api.cifra import cifrar

COLUNAS_EXISTEM = text("""
    SELECT COUNT(*) FROM information_schema.columns
     WHERE table_name = 'alunos'
       AND column_name IN ('apoio_psicossocial_solicitado', 'necessidade_acessibilidade')
""")
LER_APOIO = text("""
    SELECT id_aluno, apoio_psicossocial_solicitado, necessidade_acessibilidade FROM alunos ORDER BY id_aluno
""")
GRAVAR = text("""
    INSERT INTO apoio_aluno (id_aluno, dados_cifrados) VALUES (:id_aluno, :dados)
    ON CONFLICT (id_aluno) DO UPDATE SET dados_cifrados = EXCLUDED.dados_cifrados, atualizado_em = now()
""")
REMOVER_COLUNAS = text("""
    ALTER TABLE alunos DROP COLUMN apoio_psicossocial_solicitado, DROP COLUMN necessidade_acessibilidade
""")


def _sim_nao(valor) -> bool | None:
    if valor is None:
        return None
    return str(valor).strip().lower() in ("sim", "s", "true", "1")


def main() -> int:
    url = os.environ.get("DATABASE_URL")
    chave = os.environ.get("APOIO_CHAVE")
    if not url or not chave:
        print("Defina DATABASE_URL (dono do banco) e APOIO_CHAVE.", file=sys.stderr)
        return 2
    with create_engine(url, hide_parameters=True).begin() as conexao:
        if conexao.execute(COLUNAS_EXISTEM).scalar() != 2:
            print("Nada a fazer: as colunas de apoio ja foram migradas.")
            return 0
        total = 0
        for linha in conexao.execute(LER_APOIO).mappings().all():
            conexao.execute(GRAVAR, {"id_aluno": linha["id_aluno"], "dados": cifrar(chave=chave, dados={
                "apoio_psicossocial_solicitado": _sim_nao(linha["apoio_psicossocial_solicitado"]),
                "necessidade_acessibilidade": _sim_nao(linha["necessidade_acessibilidade"]),
            })})
            total += 1
        conexao.execute(REMOVER_COLUNAS)
    print(f"{total} registros de apoio cifrados; colunas removidas de alunos.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
