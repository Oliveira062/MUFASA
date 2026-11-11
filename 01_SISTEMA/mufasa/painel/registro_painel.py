"""
Log do painel em logs/painel.log (mesma pasta e formato dos outros servicos;
pasta mudavel por MUFASA_LOG_DIR). Sem dado pessoal: so o tipo do erro, a
secao da tela e o codigo mostrado ao usuario.
"""

import logging
import os
from logging.handlers import RotatingFileHandler
from pathlib import Path

log = logging.getLogger("mufasa.painel")

if not log.handlers:  # o Streamlit reexecuta a pagina; o modulo e importado uma vez
    log.setLevel(getattr(logging, os.environ.get("MUFASA_LOG_NIVEL", "INFO").upper(), logging.INFO))
    log.propagate = False
    formato = logging.Formatter("%(asctime)s %(levelname)-7s [painel] %(name)s: %(message)s")
    console = logging.StreamHandler()
    console.setFormatter(formato)
    log.addHandler(console)
    try:
        pasta = Path(os.environ.get("MUFASA_LOG_DIR", Path(__file__).resolve().parents[1] / "logs"))
        pasta.mkdir(parents=True, exist_ok=True)
        arquivo = RotatingFileHandler(pasta / "painel.log", maxBytes=5_000_000, backupCount=5, encoding="utf-8")
        arquivo.setFormatter(formato)
        log.addHandler(arquivo)
    except OSError:
        log.warning("sem permissao para gravar logs em arquivo; so no console")
