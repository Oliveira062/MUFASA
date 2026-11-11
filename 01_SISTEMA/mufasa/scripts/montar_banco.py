"""
Monta o banco do MUFASA do zero (Windows, Linux e macOS).

    python -m scripts.montar_banco                 # usa o .env e o dump em banco/
    python -m scripts.montar_banco --sim           # sem a pergunta de confirmacao
    python -m scripts.montar_banco --contas-novas  # gera senhas novas em vez das da entrega
    python -m scripts.montar_banco --sim --se-nao-existir   # usado pelo docker: monta na primeira vez;
                                                            # depois so aplica as migracoes pendentes

O que faz, nesta ordem:
 1. apaga e recria o banco (nome tirado de DATABASE_URL_ADMIN);
 2. carrega o dump do B1 (banco/Parte Samuel BackEnd B1 - limpo.sql);
 3. aplica sql/b1_correcoes, b3_complemento, painel, b1_recalculo_indicadores, chatbot;
 4. define as senhas dos perfis mufasa_api, mufasa_chat e mufasa_calculo com as
    senhas que estao em DATABASE_URL, CHAT_DATABASE_URL e CALCULO_DATABASE_URL;
 5. cifra os dados de apoio (scripts/migrar_apoio, usa APOIO_CHAVE);
 6. aplica as migracoes de sql/migracoes e cria as atividades simuladas
    (scripts/simular_atividades: o B1 so traz a quantidade de pendentes);
 7. cria as contas: carrega banco/contas_iniciais.sql (mesmas senhas de
    banco/credenciais_iniciais.csv) ou, com --contas-novas, gera senhas novas
    em credenciais.csv.
O score de todos os alunos e calculado pelo servico de calculo assim que ele sobe.

Nao precisa do psql: o SQL roda direto pelo driver do Python (psycopg).
"""

import argparse
import os
import subprocess
import sys
from pathlib import Path

import psycopg
from psycopg import sql
from sqlalchemy.engine import make_url

from scripts._ambiente import RAIZ, carregar_env

ARQUIVOS_SQL = ["b1_correcoes", "b3_complemento", "painel", "b1_recalculo_indicadores", "chatbot"]
DUMP_PADRAO = RAIZ / "banco" / "Parte Samuel BackEnd B1 - limpo.sql"
PERFIS = {"mufasa_api": "DATABASE_URL", "mufasa_chat": "CHAT_DATABASE_URL", "mufasa_calculo": "CALCULO_DATABASE_URL"}


class ErroMontagem(RuntimeError):
    pass


def falhar(msg: str) -> None:
    raise ErroMontagem(msg)


class Executor:
    """
    Roda SQL direto pelo driver (psycopg), sem precisar do psql instalado.
    Entende o formato do pg_dump: varios comandos por arquivo e blocos
    COPY ... FROM stdin terminados por \\. ; meta-comandos do psql sao ignorados.
    """

    def __init__(self, url_admin: str):
        u = make_url(url_admin)
        self.params = {"host": u.host or "localhost", "port": u.port or 5432, "user": u.username or "postgres",
                       "password": u.password or "", "connect_timeout": 10}

    def _conectar(self, banco: str):
        try:
            return psycopg.connect(dbname=banco, autocommit=True, **self.params)
        except psycopg.OperationalError as exc:
            falhar(f"nao foi possivel conectar ao PostgreSQL em {self.params['host']}:{self.params['port']} "
                   f"como {self.params['user']}: {str(exc).strip().splitlines()[-1]}")

    def comando(self, banco: str, consulta) -> None:
        with self._conectar(banco) as c:
            self._executar(c, consulta)

    def arquivo(self, banco: str, caminho: Path) -> None:
        self.script(banco, caminho.read_text(encoding="utf-8"), caminho.name)

    def script(self, banco: str, texto: str, nome: str = "script") -> None:
        with self._conectar(banco) as c:
            pendente: list[str] = []
            linhas = iter(texto.splitlines(keepends=True))
            for l in linhas:
                if l.startswith("\\"):
                    continue
                if l.startswith("COPY ") and l.rstrip().endswith("FROM stdin;"):
                    self._executar(c, "".join(pendente), nome)
                    pendente = []
                    try:
                        with c.cursor().copy(l.rstrip().rstrip(";")) as copia:
                            for dado in linhas:
                                if dado.startswith("\\."):
                                    break
                                copia.write(dado)
                    except psycopg.Error as exc:
                        falhar(f"{nome}: erro ao carregar dados ({l[:60].strip()}...): {exc}")
                    continue
                pendente.append(l)
            self._executar(c, "".join(pendente), nome)

    @staticmethod
    def _executar(conexao, consulta, nome: str = "comando") -> None:
        if isinstance(consulta, str) and not consulta.strip():
            return
        try:
            conexao.execute(consulta)
        except psycopg.Error as exc:
            falhar(f"{nome}: {str(exc).strip()}")


def ler_dump(dump: Path, apenas_esquema: bool = False) -> str:
    """Texto do dump pronto para o Executor. apenas_esquema: tira os dados (usado pelos testes)."""
    saida, em_dados = [], False
    for l in dump.read_text(encoding="utf-8").splitlines(keepends=True):
        # \restrict e \unrestrict sao meta-comandos do psql 16.10+ (nao mudam os dados).
        if l.startswith(("\\restrict", "\\unrestrict")):
            continue
        if apenas_esquema:
            if em_dados:
                em_dados = not l.startswith("\\.")
                continue
            if l.startswith("COPY ") and l.rstrip().endswith("FROM stdin;"):
                em_dados = True
                continue
        saida.append(l)
    return "".join(saida)


def construir(url_admin: str, dump: Path, apenas_esquema: bool = False, falar=print) -> None:
    """Passos 1 a 6 (tudo menos as contas). Os testes usam com apenas_esquema=True."""
    banco = make_url(url_admin).database or "mufasa"
    if not banco.replace("_", "").isalnum():
        falhar("Nome de banco invalido em DATABASE_URL_ADMIN.")
    ex = Executor(url_admin)

    falar(f"1/7 recriando o banco {banco}")
    ex.comando("postgres", sql.SQL("DROP DATABASE IF EXISTS {} WITH (FORCE)").format(sql.Identifier(banco)))
    ex.comando("postgres", sql.SQL("CREATE DATABASE {} ENCODING 'UTF8' TEMPLATE template0")
               .format(sql.Identifier(banco)))

    falar("2/7 carregando o dump do B1" + (" (so a estrutura)" if apenas_esquema else ""))
    ex.script(banco, ler_dump(dump, apenas_esquema), dump.name)

    falar("3/7 aplicando os scripts do sistema")
    for nome in ARQUIVOS_SQL:
        falar(f"    sql/{nome}.sql")
        ex.arquivo(banco, RAIZ / "sql" / f"{nome}.sql")

    falar("4/7 definindo as senhas dos perfis de banco")
    for perfil, var in PERFIS.items():
        ex.comando(banco, sql.SQL("ALTER ROLE {} PASSWORD {}").format(
            sql.Identifier(perfil), sql.Literal(make_url(os.environ[var]).password)))

    falar("5/7 cifrando os dados de apoio")
    ambiente = {**os.environ, "DATABASE_URL": url_admin}
    subprocess.run([sys.executable, "-m", "scripts.migrar_apoio"], cwd=RAIZ, env=ambiente, check=True,
                   capture_output=not apenas_esquema)

    falar("6/7 aplicando migracoes")
    from scripts.migrar import migrar
    if migrar(url_admin) != 0:
        falhar("migracoes nao aplicadas")
    if not apenas_esquema:
        falar("    atividades simuladas (scripts/simular_atividades)")
        from scripts.simular_atividades import simular
        simular(url_admin, falar=lambda m: falar("    " + m))


def conferir_configuracao(url_admin: str | None) -> None:
    if not url_admin:
        falhar("Defina DATABASE_URL_ADMIN no .env (ex.: postgresql+psycopg://postgres:SENHA@localhost:5432/mufasa).")
    for perfil, var in PERFIS.items():
        u = os.environ.get(var)
        if not u or not make_url(u).password or "TROQUE" in u:
            falhar(f"Defina {var} no .env com a senha do perfil {perfil}.")
    if not os.environ.get("APOIO_CHAVE"):
        falhar("Defina APOIO_CHAVE no .env (veja .env.example).")


def _ja_montado(url_admin: str) -> bool:
    from sqlalchemy import create_engine, text
    try:
        with create_engine(url_admin).connect() as c:
            if not c.execute(text("SELECT to_regclass('public.usuarios') IS NOT NULL")).scalar():
                return False
            # Montagem interrompida antes das contas conta como nao montado.
            return bool(c.execute(text("SELECT EXISTS (SELECT 1 FROM usuarios)")).scalar())
    except Exception:
        return False


def montar(args) -> None:
    url_admin = os.environ.get("DATABASE_URL_ADMIN")
    conferir_configuracao(url_admin)
    banco = make_url(url_admin).database or "mufasa"
    dump = Path(args.dump or os.environ.get("MUFASA_DUMP") or DUMP_PADRAO)
    if not dump.exists():
        falhar(f"Dump do B1 nao encontrado em {dump}. Informe com --dump.")
    if args.se_nao_existir and _ja_montado(url_admin):
        # Banco existente (docker compose up depois de uma atualizacao): so o que falta.
        print(f"Banco {banco} ja montado: aplicando so as migracoes pendentes.")
        from scripts.migrar import migrar
        from scripts.simular_atividades import simular
        if migrar(url_admin) != 0:
            falhar("migracoes nao aplicadas")
        simular(url_admin)
        return
    if not args.sim:
        resp = input(f"Isto APAGA o banco '{banco}' e monta de novo. Continuar? [s/N] ")
        if resp.strip().lower() not in ("s", "sim"):
            print("Nada foi feito.")
            return
    construir(url_admin, dump)

    print("7/7 criando as contas")
    contas = RAIZ / "banco" / "contas_iniciais.sql"
    if contas.exists() and not args.contas_novas:
        Executor(url_admin).arquivo(banco, contas)
        print("    contas da entrega carregadas: senhas em banco/credenciais_iniciais.csv")
    else:
        saida = os.environ.get("MUFASA_CREDENCIAIS", "credenciais.csv")
        subprocess.run([sys.executable, "-m", "scripts.gerar_contas", "--saida", saida], cwd=RAIZ,
                       env={**os.environ, "DATABASE_URL_ADMIN": url_admin}, check=True)
        print(f"    senhas novas em {saida} (guarde e apague depois)")
    print(f"\nBanco {banco} pronto. Proximo passo: python -m scripts.iniciar")


def main() -> int:
    carregar_env()
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--dump", help="caminho do dump do B1")
    ap.add_argument("--sim", action="store_true", help="nao pedir confirmacao")
    ap.add_argument("--contas-novas", action="store_true", help="gerar senhas novas (credenciais.csv)")
    ap.add_argument("--se-nao-existir", action="store_true", help="so monta se o banco ainda nao existir (docker)")
    try:
        montar(ap.parse_args())
    except ErroMontagem as exc:
        print(f"\nERRO: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
