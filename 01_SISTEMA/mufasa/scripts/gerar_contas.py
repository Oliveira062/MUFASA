"""
Gera as contas de acesso: uma por aluno do B1 e uma de demonstracao por perfil.

    DATABASE_URL_ADMIN=postgresql+psycopg://<dono>@host/mufasa \
        python -m scripts.gerar_contas --saida credenciais.csv [--sem-demonstracao]

- Aluno: login = matricula, senha provisoria aleatoria, troca obrigatoria
  no primeiro acesso (deve_trocar_senha) e aceite do termo.
- Demonstracao: uma conta por perfil, marcada demonstracao = TRUE. A API
  recusa o login delas quando AMBIENTE=producao.
- Conta que ja existe nao e alterada (rodar de novo so cria as que faltam).

O arquivo de saida tem as senhas provisorias em texto: entregar por canal
institucional e apagar depois. O banco guarda so o hash bcrypt.
"""

import argparse
import csv
import os
import sys
from concurrent.futures import ProcessPoolExecutor

from sqlalchemy import create_engine, text

from app.api.auth import gerar_hash_senha
from app.api.senhas import gerar_senha_provisoria

ALUNOS_SEM_CONTA = text("""
    SELECT a.id_aluno, a.nome_ficticio, a.id_curso FROM alunos a
     WHERE NOT EXISTS (SELECT 1 FROM usuarios u WHERE u.id_aluno = a.id_aluno OR lower(u.login) = lower(a.id_aluno))
     ORDER BY a.id_aluno
""")

LOGIN_EXISTE = text("SELECT 1 FROM usuarios WHERE lower(login) = lower(:login)")

INSERIR = text("""
    INSERT INTO usuarios (login, senha_hash, perfil, id_aluno, id_professor, id_curso, nome, email,
                          deve_trocar_senha, demonstracao)
    VALUES (:login, :senha_hash, :perfil, :id_aluno, :id_professor, :id_curso, :nome, :email,
            :deve_trocar_senha, :demonstracao)
""")

PROFESSOR_COM_MAIS_ALUNOS = text("""
    SELECT t.id_professor FROM turmas t JOIN matriculas m ON m.id_turma = t.id_turma
     GROUP BY t.id_professor ORDER BY count(*) DESC, t.id_professor LIMIT 1
""")

CURSO_PRINCIPAL = text("SELECT id_curso FROM alunos GROUP BY id_curso ORDER BY count(*) DESC LIMIT 1")


def contas_de_demonstracao(id_curso: str, id_professor: str) -> list[dict]:
    base = {"id_aluno": None, "id_professor": None, "id_curso": None, "email": None,
            "deve_trocar_senha": False, "demonstracao": True}
    return [
        {**base, "login": "coordenacao.demo", "perfil": "COORDENACAO", "id_curso": id_curso,
         "nome": "Coordenação (demonstração)"},
        {**base, "login": "nae.demo", "perfil": "NUCLEO_APOIO", "id_curso": id_curso,
         "nome": "Núcleo de apoio (demonstração)"},
        {**base, "login": "nae2.demo", "perfil": "NUCLEO_APOIO", "id_curso": id_curso,
         "nome": "Núcleo de apoio 2 (demonstração)"},
        {**base, "login": "docente.demo", "perfil": "DOCENTE", "id_professor": id_professor,
         "nome": "Docente (demonstração)"},
        {**base, "login": "financeiro.demo", "perfil": "FINANCEIRO", "nome": "Setor financeiro (demonstração)"},
        {**base, "login": "gestao.demo", "perfil": "DIRECAO", "nome": "Gestão / direção (demonstração)"},
        {**base, "login": "admin.demo", "perfil": "ADMIN", "nome": "Administração técnica (demonstração)"},
        {**base, "login": "encarregado.demo", "perfil": "ENCARREGADO_DADOS",
         "nome": "Encarregado de dados (demonstração)"},
    ]


def _com_hash(conta: dict) -> dict:
    senha = gerar_senha_provisoria()
    return {**conta, "senha": senha, "senha_hash": gerar_hash_senha(senha)}


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--saida", required=True, help="CSV com login e senha provisoria")
    p.add_argument("--sem-demonstracao", action="store_true")
    args = p.parse_args()

    url = os.environ.get("DATABASE_URL_ADMIN")
    if not url:
        print("Defina DATABASE_URL_ADMIN (dono do banco).", file=sys.stderr)
        return 1
    engine = create_engine(url, hide_parameters=True)

    with engine.connect() as conexao:
        contas = [{"login": a["id_aluno"], "perfil": "ALUNO", "id_aluno": a["id_aluno"], "id_professor": None,
                   "id_curso": a["id_curso"], "nome": a["nome_ficticio"], "email": None, "deve_trocar_senha": True,
                   "demonstracao": False} for a in conexao.execute(ALUNOS_SEM_CONTA).mappings()]
        if not args.sem_demonstracao:
            curso = conexao.execute(CURSO_PRINCIPAL).scalar()
            professor = conexao.execute(PROFESSOR_COM_MAIS_ALUNOS).scalar()
            contas += [c for c in contas_de_demonstracao(curso, professor)
                       if not conexao.execute(LOGIN_EXISTE, {"login": c["login"]}).first()]

    if not contas:
        print("Nenhuma conta nova a criar.")
        return 0
    print(f"Gerando {len(contas)} conta(s) (bcrypt custo 12)...")
    with ProcessPoolExecutor() as grupo:
        prontas = list(grupo.map(_com_hash, contas, chunksize=20))

    with engine.begin() as conexao:
        for c in prontas:
            conexao.execute(INSERIR, {k: c[k] for k in ("login", "senha_hash", "perfil", "id_aluno", "id_professor",
                                                         "id_curso", "nome", "email", "deve_trocar_senha",
                                                         "demonstracao")})

    novo = not os.path.exists(args.saida)
    descritor = os.open(args.saida, os.O_WRONLY | os.O_CREAT | os.O_APPEND, 0o600)
    with os.fdopen(descritor, "a", newline="", encoding="utf-8") as arquivo:
        escritor = csv.writer(arquivo, delimiter=";")
        if novo:
            escritor.writerow(["perfil", "login", "senha_provisoria", "nome", "demonstracao", "troca_no_primeiro_acesso"])
        for c in prontas:
            escritor.writerow([c["perfil"], c["login"], c["senha"], c["nome"], "sim" if c["demonstracao"] else "não",
                               "sim" if c["deve_trocar_senha"] else "não"])
    print(f"{len(prontas)} conta(s) criadas. Credenciais em {args.saida}.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
