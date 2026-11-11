"""
Diagnostico do MUFASA: confere tudo o que o sistema precisa e diz o que esta errado.

    python -m scripts.diagnostico                      # relatorio completo
    python -m scripts.diagnostico --requisicao 3f9a1c0b2d4e   # acha um erro pelo codigo da tela
    python -m scripts.diagnostico --saida relatorio.txt       # salva para enviar a quem vai corrigir

Confere, em ordem: Python e pacotes; variaveis do .env (so se existem, nunca
o valor); conexao de cada perfil de banco; tabelas, parametros e migracoes;
servicos no ar (/saude e sinal de vida); fila de calculo; erros recentes nos
registros tecnicos e nos arquivos de log. Termina com codigo 0 se nada
falhou, 1 se algo falhou (serve para automacao).

O relatorio nao contem senha, token nem dado de aluno.
"""

import argparse
import importlib.metadata as md
import io
import os
import re
import sys
from contextlib import redirect_stdout
from datetime import datetime, timedelta, timezone
from pathlib import Path

from scripts._ambiente import RAIZ, carregar_env

MINIMOS = {"fastapi": "0.115.6", "starlette": "0.40.0", "uvicorn": "0.32.0", "pydantic": "2.9",
           "pydantic-settings": "2.6", "SQLAlchemy": "2.0.36", "psycopg": "3.2.3", "PyJWT": "2.10.1",
           "bcrypt": "4.2.0", "httpx": "0.28", "cryptography": "43.0", "python-multipart": "0.0.18",
           "streamlit": "1.50.0", "plotly": "5.24", "pandas": "2.2", "pytest": "8.3"}
TABELAS = ["alunos", "matriculas", "indicadores_academicos", "socioeconomico", "usuarios", "scores_risco",
           "alertas", "alerta_eventos", "parametros", "parametros_versoes", "fila_recalculo", "servicos_status",
           "logs_tecnicos", "auditoria_acessos", "agendamentos", "cargas", "notificacoes"]

CONTAGENS = {t: f"SELECT count(*) FROM {t}" for t in ("alunos", "usuarios", "scores_risco")}
BUSCA_CODIGO = {
    "logs_tecnicos": "SELECT momento, servico, nivel, evento, mensagem FROM logs_tecnicos "
                     "WHERE id_requisicao = :c ORDER BY momento LIMIT 20",
    "auditoria_acessos": "SELECT momento, perfil, operacao, recurso, resultado FROM auditoria_acessos "
                         "WHERE id_requisicao = :c ORDER BY momento LIMIT 20",
}

resultado = {"FALHA": 0, "AVISO": 0}


def linha(estado: str, texto: str, dica: str = ""):
    if estado in resultado:
        resultado[estado] += 1
    marca = {"OK": "  ok   ", "AVISO": " AVISO ", "FALHA": " FALHA ", "INFO": "  --   "}[estado]
    print(f"[{marca}] {texto}" + (f"\n          -> {dica}" if dica else ""))


def _versao(texto: str) -> tuple:
    return tuple(int(x) for x in re.findall(r"\d+", texto)[:3])


def secao(titulo: str):
    print(f"\n== {titulo} ==")


def conferir_python():
    secao("Python e pacotes")
    v = sys.version_info
    linha("OK" if v >= (3, 11) else "FALHA", f"Python {v.major}.{v.minor}.{v.micro}",
          "" if v >= (3, 11) else "Instale Python 3.11 ou mais novo (testado com 3.13).")
    for pacote, minimo in MINIMOS.items():
        try:
            instalada = md.version(pacote)
        except md.PackageNotFoundError:
            linha("FALHA", f"{pacote} nao instalado", "pip install -r requirements.txt")
            continue
        ok = _versao(instalada) >= _versao(minimo)
        linha("OK" if ok else "FALHA", f"{pacote} {instalada} (minimo {minimo})",
              "" if ok else "pip install -U -r requirements.txt")


def conferir_env():
    secao("Configuracao (.env)")
    linha("OK" if (RAIZ / ".env").exists() else "FALHA", "arquivo .env",
          "" if (RAIZ / ".env").exists() else "Copie .env.example para .env e preencha.")
    for nome in ("DATABASE_URL", "CHAT_DATABASE_URL", "CALCULO_DATABASE_URL", "DATABASE_URL_ADMIN", "JWT_SECRET",
                 "APOIO_CHAVE"):
        valor = os.environ.get(nome, "")
        if not valor or "TROQUE" in valor:
            linha("FALHA" if nome != "DATABASE_URL_ADMIN" else "AVISO", f"{nome} nao definida",
                  "Veja .env.example; DATABASE_URL_ADMIN so e necessaria para montar o banco e migrar.")
        else:
            linha("OK", f"{nome} definida")
    if len(os.environ.get("JWT_SECRET", "")) and len(os.environ["JWT_SECRET"]) < 32:
        linha("FALHA", "JWT_SECRET curta demais (minimo 32 caracteres)",
              'python -c "import secrets; print(secrets.token_hex(32))"')
    if os.environ.get("APOIO_CHAVE"):
        try:
            from cryptography.fernet import Fernet
            Fernet(os.environ["APOIO_CHAVE"].encode())
            linha("OK", "APOIO_CHAVE e uma chave Fernet valida")
        except Exception:
            linha("FALHA", "APOIO_CHAVE invalida", "Gere com o comando do .env.example.")
    linha("INFO", f"AMBIENTE={os.environ.get('AMBIENTE', 'desenvolvimento')}")


def _conectar(nome_var: str):
    from sqlalchemy import create_engine, text
    url = os.environ.get(nome_var)
    if not url:
        return None
    engine = create_engine(url, hide_parameters=True, pool_pre_ping=True, connect_args={"connect_timeout": 5})
    try:
        with engine.connect() as c:
            c.execute(text("SELECT 1"))
        linha("OK", f"conexao {nome_var}")
        return engine
    except Exception as exc:
        dica = "Banco desligado? Senha do perfil diferente da do .env? Rode scripts.montar_banco."
        if "does not exist" in str(exc):
            dica = "O banco nao existe: python -m scripts.montar_banco"
        elif "password authentication failed" in str(exc):
            dica = "Senha errada no .env para este perfil (ALTER ROLE ... PASSWORD, ou monte o banco de novo)."
        elif "Connection refused" in str(exc) or "could not connect" in str(exc).lower():
            dica = "PostgreSQL desligado ou em outra porta/host."
        linha("FALHA", f"conexao {nome_var}: {type(exc).__name__}", dica)
        return None


def conferir_banco():
    from sqlalchemy import text
    secao("Banco de dados")
    api = _conectar("DATABASE_URL")
    _conectar("CHAT_DATABASE_URL")
    _conectar("CALCULO_DATABASE_URL")
    admin = _conectar("DATABASE_URL_ADMIN") if os.environ.get("DATABASE_URL_ADMIN") else None
    principal = admin or api
    if principal is None:
        return None
    with principal.connect() as c:
        existentes = set(c.execute(text("SELECT table_name FROM information_schema.tables "
                                        "WHERE table_schema = 'public'")).scalars())
        faltando = [t for t in TABELAS if t not in existentes]
        linha("OK" if not faltando else "FALHA", f"{len(TABELAS) - len(faltando)}/{len(TABELAS)} tabelas essenciais",
              f"Faltam: {', '.join(faltando)}. Monte o banco de novo." if faltando else "")
        if admin is not None:
            for t, minimo in (("alunos", 1), ("usuarios", 1), ("scores_risco", 1)):
                n = c.execute(text(CONTAGENS[t])).scalar()
                linha("OK" if n >= minimo else "AVISO", f"{t}: {n} linha(s)",
                      "" if n >= minimo else ("Suba o servico de calculo: ele calcula ao iniciar." if t == "scores_risco"
                                              else "Monte o banco (scripts.montar_banco)."))
            if "esquema_migracoes" in existentes:
                from scripts.migrar import arquivos
                feitas = set(c.execute(text("SELECT arquivo FROM esquema_migracoes")).scalars())
                pend = [p.name for p in arquivos() if p.name not in feitas]
                linha("OK" if not pend else "AVISO", f"migracoes: {len(feitas)} aplicada(s), {len(pend)} pendente(s)",
                      "python -m scripts.migrar" if pend else "")
            else:
                linha("AVISO", "tabela de migracoes ausente", "python -m scripts.migrar")
        try:
            versao = c.execute(text("SELECT max(versao) FROM parametros_versoes")).scalar()
            linha("OK", f"parametros: versao vigente {versao}")
        except Exception:
            linha("AVISO", "nao foi possivel ler a versao dos parametros")
    return principal


def conferir_servicos(engine):
    secao("Servicos")
    import httpx
    for nome, url in (("api", os.environ.get("MUFASA_API_URL", "http://127.0.0.1:8000")),
                      ("chat", os.environ.get("MUFASA_CHAT_URL", "http://127.0.0.1:8001"))):
        try:
            r = httpx.get(url.rstrip("/") + "/saude", timeout=3)
            corpo = r.json()
            linha("OK" if r.status_code == 200 else "FALHA",
                  f"{nome} em {url}: {corpo.get('status')} (versao {corpo.get('versao', '?')}, banco {corpo.get('banco')})")
        except Exception:
            linha("FALHA", f"{nome} em {url} nao responde", "Suba com: python -m scripts.iniciar "
                  f"(veja logs/{nome}.console.log)")
    try:
        r = httpx.get("http://127.0.0.1:8501/_stcore/health", timeout=3)
        linha("OK" if r.status_code == 200 else "FALHA", "painel em http://127.0.0.1:8501")
    except Exception:
        linha("FALHA", "painel nao responde em http://127.0.0.1:8501", "veja logs/painel.console.log")
    if engine is None:
        return
    from sqlalchemy import text
    with engine.connect() as c:
        agora = datetime.now(timezone.utc)
        for s in c.execute(text("SELECT servico, ultimo_sinal, detalhe FROM servicos_status ORDER BY servico")).mappings():
            idade = (agora - s["ultimo_sinal"]).total_seconds()
            linha("OK" if idade <= 60 else "FALHA", f"sinal de vida de {s['servico']}: ha {int(idade)} s ({s['detalhe']})",
                  "" if idade <= 60 else f"O servico {s['servico']} parou. Veja logs/{s['servico']}.log")
        fila = c.execute(text("SELECT count(*) FROM fila_recalculo")).scalar()
        linha("OK" if fila < 200 else "AVISO", f"fila de recalculo: {fila} aluno(s)",
              "" if fila < 200 else "Fila grande: o servico de calculo esta rodando? (logs/calculo.log)")


def conferir_erros(engine, horas: int):
    secao(f"Erros nas ultimas {horas} h")
    if engine is not None:
        from sqlalchemy import text
        with engine.connect() as c:
            desde = datetime.now(timezone.utc) - timedelta(hours=horas)
            erros = c.execute(text("SELECT momento, servico, evento, mensagem, id_requisicao FROM logs_tecnicos "
                                   "WHERE nivel = 'ERRO' AND momento >= :desde ORDER BY momento DESC LIMIT 15"),
                              {"desde": desde}).mappings().all()
        linha("OK" if not erros else "AVISO", f"{len(erros)} erro(s) nos registros tecnicos do banco")
        for e in erros:
            print(f"          {e['momento']:%d/%m %H:%M:%S} {e['servico']:8} {e['evento']} {e['mensagem'] or ''} "
                  f"(codigo {e['id_requisicao'] or '-'})")
    pasta = Path(os.environ.get("MUFASA_LOG_DIR", RAIZ / "logs"))
    for arq in sorted(pasta.glob("*.log")) if pasta.exists() else []:
        ultimas = [l.rstrip() for l in arq.read_text(encoding="utf-8", errors="replace").splitlines()
                   if " ERROR " in l or "Traceback" in l][-5:]
        if ultimas:
            linha("AVISO", f"{arq.name}: ultimas linhas de erro")
            for l in ultimas:
                print("          " + l[:220])


def buscar_requisicao(codigo: str, engine):
    secao(f"Busca pelo codigo {codigo}")
    if not re.fullmatch(r"[0-9a-fA-FP-]{4,32}", codigo):
        linha("FALHA", "codigo em formato invalido")
        return
    achou = False
    pasta = Path(os.environ.get("MUFASA_LOG_DIR", RAIZ / "logs"))
    for arq in sorted(pasta.glob("*.log*")) if pasta.exists() else []:
        linhas = arq.read_text(encoding="utf-8", errors="replace").splitlines()
        for i, l in enumerate(linhas):
            if codigo in l:
                achou = True
                print(f"  {arq.name}:{i + 1}")
                for extra in linhas[i:i + 25]:  # inclui a pilha do erro, se houver
                    if extra is not l and re.match(r"^\d{4}-\d{2}-\d{2} ", extra):
                        break
                    print("    " + extra[:300])
    if engine is not None:
        from sqlalchemy import text
        with engine.connect() as c:
            for tabela in BUSCA_CODIGO:
                for r in c.execute(text(BUSCA_CODIGO[tabela]), {"c": codigo}).mappings():
                    achou = True
                    print(f"  {tabela}: " + " | ".join(str(v) for v in r.values()))
    if not achou:
        linha("AVISO", "codigo nao encontrado", "Confira o codigo; logs antigos podem ter sido rodados (5 x 5 MB).")


def main() -> int:
    carregar_env()
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--requisicao", help="codigo mostrado na tela de erro")
    ap.add_argument("--horas", type=int, default=24, help="janela dos erros recentes (padrao 24)")
    ap.add_argument("--saida", help="tambem grava o relatorio neste arquivo")
    args = ap.parse_args()
    buffer = io.StringIO()

    class Duplo(io.TextIOBase):
        def write(self, s):
            sys.__stdout__.write(s)
            buffer.write(s)
            return len(s)

    with redirect_stdout(Duplo()):
        from app import __version__
        print(f"MUFASA {__version__} - diagnostico em {datetime.now():%d/%m/%Y %H:%M:%S}")
        if args.requisicao:
            buscar_requisicao(args.requisicao.strip(), _conectar("DATABASE_URL_ADMIN") or _conectar("DATABASE_URL"))
        else:
            conferir_python()
            conferir_env()
            engine = conferir_banco()
            conferir_servicos(engine)
            conferir_erros(engine, args.horas)
            print(f"\nResumo: {resultado['FALHA']} falha(s), {resultado['AVISO']} aviso(s).")
    if args.saida:
        Path(args.saida).write_text(buffer.getvalue(), encoding="utf-8")
        print(f"Relatorio salvo em {args.saida}")
    return 1 if resultado["FALHA"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
