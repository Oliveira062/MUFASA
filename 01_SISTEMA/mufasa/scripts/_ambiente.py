"""
Leitura do arquivo .env para os scripts (sem dependencia extra).

Regras do formato: uma variavel por linha (NOME=valor), linhas com # sao
comentario, aspas simples ou duplas em volta do valor sao removidas. Uma
variavel ja definida no sistema vale mais que a do arquivo.
"""

import os
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]


def carregar_env(caminho: Path | None = None) -> dict:
    caminho = caminho or RAIZ / ".env"
    lidas = {}
    if caminho.exists():
        for linha in caminho.read_text(encoding="utf-8").splitlines():
            linha = linha.strip()
            if not linha or linha.startswith("#") or "=" not in linha:
                continue
            nome, valor = linha.split("=", 1)
            valor = valor.strip()
            if len(valor) >= 2 and valor[0] == valor[-1] and valor[0] in "'\"":
                valor = valor[1:-1]
            lidas[nome.strip()] = valor
    for nome, valor in lidas.items():
        os.environ.setdefault(nome, valor)
    return lidas
