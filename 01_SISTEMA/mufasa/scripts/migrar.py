"""
Migracoes do banco: como evoluir o esquema sem montar tudo de novo.

    python -m scripts.migrar            # aplica as pendentes
    python -m scripts.migrar --listar   # mostra aplicadas e pendentes
    python -m scripts.migrar --nova "adicionar coluna x"   # cria o proximo arquivo

Cada mudanca de esquema vira um arquivo novo em sql/migracoes/, numerado:
    sql/migracoes/002_adicionar_coluna_x.sql
Os arquivos rodam em ordem de nome, cada um em uma transacao; o que ja foi
aplicado fica na tabela esquema_migracoes (nome e hash). Arquivo aplicado
nao se edita: se precisar corrigir, crie outro. Se alguem editar um arquivo
ja aplicado, o script avisa (hash diferente) e para.

Conecta como dono do banco: DATABASE_URL_ADMIN (no .env), por exemplo
postgresql+psycopg://postgres:SENHA@localhost:5432/mufasa
"""

import argparse
import hashlib
import os
import sys
from pathlib import Path

from sqlalchemy import create_engine, text

from scripts._ambiente import RAIZ, carregar_env

PASTA = RAIZ / "sql" / "migracoes"

CRIAR_TABELA = text("""
    CREATE TABLE IF NOT EXISTS esquema_migracoes (
        arquivo     VARCHAR(120) PRIMARY KEY,
        sha256      CHAR(64)     NOT NULL,
        aplicada_em TIMESTAMPTZ  NOT NULL DEFAULT now()
    )
""")
LER = text("SELECT arquivo, sha256, aplicada_em FROM esquema_migracoes ORDER BY arquivo")
REGISTRAR = text("INSERT INTO esquema_migracoes (arquivo, sha256) VALUES (:arquivo, :sha256)")


def arquivos() -> list[Path]:
    return sorted(p for p in PASTA.glob("*.sql") if p.name[:3].isdigit())


MODELO = """-- Migracao {numero}: {descricao}
-- Criada em {data}. Depois de aplicada, este arquivo nao se edita.
-- Roda numa transacao (tudo ou nada). Tabela nova precisa de GRANT para o
-- servico que a usa: mufasa_api, mufasa_chat e/ou mufasa_calculo.

"""


def nova(descricao: str) -> Path:
    import re
    from datetime import date
    numero = max((int(p.name[:3]) for p in arquivos()), default=0) + 1
    nome = re.sub(r"[^a-z0-9]+", "_", descricao.lower()).strip("_")[:60] or "migracao"
    destino = PASTA / f"{numero:03d}_{nome}.sql"
    destino.write_text(MODELO.format(numero=f"{numero:03d}", descricao=descricao,
                                     data=date.today().strftime("%d/%m/%Y")), encoding="utf-8")
    return destino


def resumo(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def migrar(url: str, listar: bool = False) -> int:
    engine = create_engine(url, hide_parameters=True)
    with engine.begin() as c:
        c.execute(CRIAR_TABELA)
        aplicadas = {l["arquivo"]: l for l in c.execute(LER).mappings()}
    pendentes = []
    for p in arquivos():
        feita = aplicadas.get(p.name)
        if feita is None:
            pendentes.append(p)
        elif feita["sha256"] != resumo(p):
            print(f"ERRO: {p.name} foi alterado depois de aplicado. Crie uma migracao nova em vez de editar.")
            return 1
    if listar:
        for nome, l in aplicadas.items():
            print(f"aplicada  {nome}  em {l['aplicada_em']:%d/%m/%Y %H:%M}")
        for p in pendentes:
            print(f"pendente  {p.name}")
        if not aplicadas and not pendentes:
            print("nenhuma migracao em sql/migracoes/")
        return 0
    for p in pendentes:
        print(f"aplicando {p.name} ...", end=" ")
        with engine.begin() as c:  # tudo ou nada por arquivo
            c.exec_driver_sql(p.read_text(encoding="utf-8"))
            c.execute(REGISTRAR, {"arquivo": p.name, "sha256": resumo(p)})
        print("ok")
    print(f"{len(pendentes)} migracao(oes) aplicada(s).")
    return 0


def main() -> int:
    carregar_env()
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--listar", action="store_true")
    ap.add_argument("--nova", metavar="DESCRICAO", help="cria o proximo arquivo de migracao, vazio")
    args = ap.parse_args()
    if args.nova:
        print(f"criado {nova(args.nova).relative_to(RAIZ)}: escreva o SQL e rode python -m scripts.migrar")
        return 0
    url = os.environ.get("DATABASE_URL_ADMIN")
    if not url:
        print("Defina DATABASE_URL_ADMIN no .env (conexao do dono do banco).", file=sys.stderr)
        return 2
    return migrar(url, args.listar)


if __name__ == "__main__":
    raise SystemExit(main())
