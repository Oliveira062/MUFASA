"""
Atividades SIMULADAS para o banco de demonstracao (pedido do João, 28/10/2026).

O B1 so traz a QUANTIDADE de atividades pendentes de cada aluno
(indicadores_academicos.atividades_pendentes). Para o assistente responder
"o que vence esta semana?", este script cria atividades com prazo em
atividades_aluno, marcadas com simulada = TRUE, coerentes com o B1:

- cada aluno fica com exatamente atividades_pendentes atividades sem entrega,
  parte ja atrasada e parte vencendo nos proximos dias;
- as demais (duas por turma) ja venceram e foram entregues.

Os prazos sao contados a partir do dia em que o script roda. Nada do B1 e
alterado. Quando a instituicao carregar as atividades reais, apague as
simuladas:  DELETE FROM atividades_aluno WHERE simulada;

    python -m scripts.simular_atividades            # so se ainda nao houver atividades
    python -m scripts.simular_atividades --refazer  # apaga as simuladas e gera de novo (prazos atuais)
"""

import argparse
import os
import random
import sys
from datetime import date, timedelta

from sqlalchemy import create_engine, text

from scripts._ambiente import carregar_env

TIPOS = (("Lista de exercícios", "lista"), ("Trabalho prático", "trabalho"), ("Questionário", "questionario"),
         ("Relatório", "relatorio"), ("Seminário", "seminario"))

TURMAS_DO_ALUNO = text("""
    SELECT m.id_aluno, m.id_turma
      FROM matriculas m
     WHERE m.id_aluno IS NOT NULL
     ORDER BY m.id_aluno, m.id_turma
""")
PENDENTES = text("""
    SELECT DISTINCT ON (id_aluno) id_aluno, COALESCE(atividades_pendentes, 0) AS pendentes
      FROM indicadores_academicos
     ORDER BY id_aluno, periodo_letivo DESC
""")
INSERIR = text("""
    INSERT INTO atividades_aluno (id_aluno, id_turma, titulo, tipo, prazo_em, entregue_em, simulada)
    VALUES (:id_aluno, :id_turma, :titulo, :tipo, :prazo_em, :entregue_em, TRUE)
""")


def gerar(id_aluno: str, turmas: list[str], pendentes: int, hoje: date) -> list[dict]:
    sorteio = random.Random(id_aluno)  # mesmo aluno, mesmas atividades
    linhas, numero = [], {}

    def nova(turma: str, prazo: date, entregue: date | None) -> dict:
        titulo, tipo = sorteio.choice(TIPOS)
        numero[(turma, titulo)] = numero.get((turma, titulo), 0) + 1
        if tipo in ("lista", "questionario"):
            titulo = f"{titulo} {numero[(turma, titulo)]}"
        return {"id_aluno": id_aluno, "id_turma": turma, "titulo": titulo, "tipo": tipo,
                "prazo_em": prazo, "entregue_em": entregue}

    for turma in turmas:
        for _ in range(2):
            prazo = hoje - timedelta(days=sorteio.randint(8, 60))
            linhas.append(nova(turma, prazo, prazo - timedelta(days=sorteio.randint(0, 3))))
    for i in range(pendentes):
        turma = sorteio.choice(turmas)
        # Cerca de um terco ja atrasada; o resto vence nas proximas tres semanas.
        dias = -sorteio.randint(1, 10) if i % 3 == 2 else sorteio.randint(0, 21)
        linhas.append(nova(turma, hoje + timedelta(days=dias), None))
    return linhas


def simular(url: str, refazer: bool = False, hoje: date | None = None, falar=print) -> int:
    hoje = hoje or date.today()
    engine = create_engine(url, hide_parameters=True)
    with engine.begin() as c:
        if c.execute(text("SELECT to_regclass('public.atividades_aluno')")).scalar() is None:
            falar("tabela atividades_aluno ausente: rode python -m scripts.migrar antes")
            return 1
        if refazer:
            c.execute(text("DELETE FROM atividades_aluno WHERE simulada"))
        elif c.execute(text("SELECT EXISTS (SELECT 1 FROM atividades_aluno)")).scalar():
            falar("atividades ja existem: nada a fazer (use --refazer para gerar de novo)")
            return 0
        turmas: dict[str, list[str]] = {}
        for l in c.execute(TURMAS_DO_ALUNO).mappings():
            turmas.setdefault(l["id_aluno"], []).append(l["id_turma"])
        pendentes = {l["id_aluno"]: int(l["pendentes"]) for l in c.execute(PENDENTES).mappings()}
        linhas = [a for aluno, ts in turmas.items() for a in gerar(aluno, ts, pendentes.get(aluno, 0), hoje)]
        if linhas:
            c.execute(INSERIR, linhas)
    engine.dispose()
    falar(f"{len(linhas)} atividades simuladas criadas para {len(turmas)} alunos")
    return 0


def main() -> int:
    carregar_env()
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--refazer", action="store_true", help="apaga as simuladas e gera de novo")
    args = ap.parse_args()
    url = os.environ.get("DATABASE_URL_ADMIN")
    if not url:
        print("Defina DATABASE_URL_ADMIN no .env (conexao do dono do banco).", file=sys.stderr)
        return 2
    return simular(url, args.refazer)


if __name__ == "__main__":
    raise SystemExit(main())
