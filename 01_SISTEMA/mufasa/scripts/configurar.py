"""
Cria o arquivo .env com senhas e chaves novas, geradas na hora.

    python -m scripts.configurar            # instalacao local (PostgreSQL na maquina)
    python -m scripts.configurar --docker   # para o docker compose
    python -m scripts.configurar --chaves   # copia as chaves do groq.env para o .env existente

Pergunta so o que a maquina precisa: endereco e senha do usuario postgres
(local). Gera: senhas dos tres perfis de banco (mufasa_api, mufasa_chat,
mufasa_calculo), JWT_SECRET de 64 caracteres e a chave Fernet dos dados de
apoio. Nao sobrescreve um .env existente sem --sobrescrever (as senhas do
banco ja montado deixariam de bater).

Chave da Groq: fica no arquivo groq.env, ao lado do .env (ignorado pelo Git e
pelo Docker). Este script copia para o .env so as linhas GROQ_*; o resto do
.env nao muda. O INICIAR_MUFASA.bat roda --chaves a cada inicio.
"""

import argparse
import getpass
import secrets
import sys
from urllib.parse import quote

from scripts._ambiente import RAIZ


def _senha() -> str:
    return secrets.token_urlsafe(24)


def montar_env(host: str, porta: int, senha_postgres: str, banco: str, docker: bool) -> str:
    from cryptography.fernet import Fernet
    s_api, s_chat, s_calc = _senha(), _senha(), _senha()
    u = lambda perfil, senha: f"postgresql+psycopg://{perfil}:{quote(senha, safe='')}@{host}:{porta}/{banco}"
    hosts = '["localhost","127.0.0.1","api","chat"]' if docker else '["localhost","127.0.0.1"]'
    return f"""# Gerado por scripts/configurar.py. NUNCA versionar nem enviar este arquivo.
# Para trocar uma senha de banco, mude aqui e rode: python -m scripts.montar_banco

# Conexao do dono do banco (so para montar o banco e aplicar migracoes)
DATABASE_URL_ADMIN={u("postgres", senha_postgres)}
{"POSTGRES_SENHA=" + senha_postgres if docker else ""}

# Perfis restritos, um por servico
DATABASE_URL={u("mufasa_api", s_api)}
CHAT_DATABASE_URL={u("mufasa_chat", s_chat)}
CALCULO_DATABASE_URL={u("mufasa_calculo", s_calc)}

JWT_SECRET={secrets.token_hex(32)}
JWT_ALGORITMO=HS256
JWT_EXPIRA_MINUTOS=30

# Chave dos dados de apoio (apoio psicossocial e acessibilidade, cifrados no banco).
# Perder esta chave = perder esses dados. Guarde uma copia em local seguro.
APOIO_CHAVE={Fernet.generate_key().decode()}

AMBIENTE=desenvolvimento
FORCAR_HTTPS=false
HOSTS_PERMITIDOS={hosts}
ORIGENS_CORS=[]
DOCS_HABILITADA=true

# Enderecos que o painel usa
MUFASA_API_URL={"http://api:8000" if docker else "http://127.0.0.1:8000"}
MUFASA_CHAT_URL={"http://chat:8001" if docker else "http://127.0.0.1:8001"}

# Registros (logs): pasta e nivel (DEBUG, INFO, WARNING, ERROR)
MUFASA_LOG_NIVEL=INFO

# Chatbot: Groq opcional. Vazio = respostas prontas, nada sai do servidor.
GROQ_API_KEY=
GROQ_MODELO=openai/gpt-oss-20b
CHAT_IA_CLASSIFICAR=false
CHAT_JANELA_ATENDIMENTO=no horário de funcionamento da secretaria acadêmica

"""


CHAVES_PERMITIDAS = ("GROQ_API_KEY", "GROQ_MODELO", "GROQ_TEMPERATURA", "CHAT_IA_CONVERSA", "CHAT_IA_CLASSIFICAR")


def ler_chaves(origem) -> dict:
    """Linhas CHAVE=valor do groq.env, so das chaves permitidas (o resto e ignorado)."""
    chaves = {}
    if not origem.exists():
        return chaves
    for linha in origem.read_text(encoding="utf-8-sig").splitlines():
        linha = linha.strip()
        if not linha or linha.startswith("#") or "=" not in linha:
            continue
        nome, _, valor = linha.partition("=")
        nome, valor = nome.strip(), valor.strip().strip('"').strip("'")
        if nome in CHAVES_PERMITIDAS and valor:
            chaves[nome] = valor
    return chaves


def aplicar_chaves(destino, chaves: dict) -> list[str]:
    """Troca ou acrescenta as chaves no .env, sem mexer nas outras linhas. Devolve os nomes alterados."""
    linhas = destino.read_text(encoding="utf-8").splitlines()
    pendentes, alteradas = dict(chaves), []
    for i, linha in enumerate(linhas):
        nome = linha.split("=", 1)[0].strip()
        if nome in pendentes:
            novo = f"{nome}={pendentes.pop(nome)}"
            if linha != novo:
                linhas[i], alteradas = novo, alteradas + [nome]
    for nome, valor in pendentes.items():
        linhas.append(f"{nome}={valor}")
        alteradas.append(nome)
    if alteradas:
        destino.write_text("\n".join(linhas) + "\n", encoding="utf-8")
    return alteradas


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--docker", action="store_true", help="banco no container 'db' do docker compose")
    ap.add_argument("--sobrescrever", action="store_true")
    ap.add_argument("--banco", default="mufasa")
    ap.add_argument("--chaves", action="store_true", help="so copia as chaves do groq.env para o .env existente")
    args = ap.parse_args()
    destino = RAIZ / ".env"
    if args.chaves:
        if not destino.exists():
            print(".env ainda nao existe: rode primeiro sem --chaves.")
            return 1
        alteradas = aplicar_chaves(destino, ler_chaves(RAIZ / "groq.env"))
        print("Chaves atualizadas no .env: " + ", ".join(alteradas) if alteradas else "Chaves do .env ja estao em dia.")
        return 0
    if destino.exists() and not args.sobrescrever:
        print(".env ja existe. Use --sobrescrever para gerar outro (depois monte o banco de novo).")
        return 1
    if args.docker:
        host, porta, senha_pg = "db", 5432, _senha()
    else:
        host = input("Endereco do PostgreSQL [localhost]: ").strip() or "localhost"
        porta = int(input("Porta [5432]: ").strip() or 5432)
        senha_pg = getpass.getpass("Senha do usuario postgres (definida na instalacao do PostgreSQL): ")
        if not senha_pg:
            print("Senha vazia: informe a senha do usuario postgres.", file=sys.stderr)
            return 1
    destino.write_text(montar_env(host, porta, senha_pg, args.banco, args.docker), encoding="utf-8")
    aplicar_chaves(destino, ler_chaves(RAIZ / "groq.env"))
    try:
        destino.chmod(0o600)
    except OSError:
        pass
    print(f".env criado em {destino}. Proximo passo: python -m scripts.montar_banco")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
