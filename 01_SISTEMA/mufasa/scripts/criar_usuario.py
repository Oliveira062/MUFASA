"""
Cria um usuario do MUFASA. A senha e digitada sem eco e so o hash bcrypt
vai para o banco. Nao existe usuario nem senha padrao no sistema.

Usa DATABASE_URL_ADMIN (dono do banco), porque o perfil mufasa_api nao
pode inserir usuarios.

    python -m scripts.criar_usuario --login ALU0001 --perfil ALUNO --aluno ALU0001
    python -m scripts.criar_usuario --login prof.ricardo --perfil DOCENTE --professor PROF001
"""

import argparse
import getpass
import os
import sys

from sqlalchemy import create_engine, text

from app.api.auth import gerar_hash_senha
from app.api.permissoes import PERFIS

INSERIR = text("""
    INSERT INTO usuarios (login, senha_hash, perfil, id_aluno, id_professor, id_curso)
    VALUES (:login, :senha_hash, :perfil, :id_aluno, :id_professor, :id_curso)
""")

TAMANHO_MINIMO_SENHA = 12


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--login", required=True)
    p.add_argument("--perfil", required=True, choices=PERFIS)
    p.add_argument("--aluno")
    p.add_argument("--professor")
    p.add_argument("--curso")
    args = p.parse_args()

    url = os.environ.get("DATABASE_URL_ADMIN")
    if not url:
        print("Defina DATABASE_URL_ADMIN no ambiente.", file=sys.stderr)
        return 1

    senha = getpass.getpass("Senha: ")
    if senha != getpass.getpass("Repita a senha: "):
        print("As senhas nao conferem.", file=sys.stderr)
        return 1
    if len(senha) < TAMANHO_MINIMO_SENHA or senha.lower() == args.login.lower():
        print(f"Use ao menos {TAMANHO_MINIMO_SENHA} caracteres, diferente do login.", file=sys.stderr)
        return 1

    with create_engine(url, hide_parameters=True).begin() as conexao:
        conexao.execute(INSERIR, {
            "login": args.login, "senha_hash": gerar_hash_senha(senha), "perfil": args.perfil,
            "id_aluno": args.aluno, "id_professor": args.professor, "id_curso": args.curso,
        })
    print("Usuario criado.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
