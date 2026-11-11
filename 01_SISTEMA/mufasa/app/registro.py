"""
Registro (log) em arquivo, igual para todos os servicos.

Cada servico escreve em logs/<servico>.log (pasta mudavel por MUFASA_LOG_DIR),
com rotacao: 5 arquivos de 5 MB. Uma linha por evento, com data, nivel,
servico e o codigo da requisicao quando houver. O codigo e o mesmo que o
usuario ve na tela de erro, entao "deu erro, codigo 3f9a1c..." vira uma
busca direta:  python -m scripts.diagnostico --requisicao 3f9a1c...

Nenhum dado pessoal vai para o log: as rotas registram so o tipo do erro.
Nivel por MUFASA_LOG_NIVEL (DEBUG, INFO, WARNING, ERROR; padrao INFO).
"""

import logging
import os
from logging.handlers import RotatingFileHandler
from pathlib import Path

FORMATO = "%(asctime)s %(levelname)-7s [%(servico)s] %(name)s: %(message)s"
_configurado: set[str] = set()


class _ComServico(logging.Filter):
    def __init__(self, servico: str):
        super().__init__()
        self.servico = servico

    def filter(self, registro: logging.LogRecord) -> bool:
        registro.servico = self.servico
        return True


def pasta_de_logs() -> Path:
    return Path(os.environ.get("MUFASA_LOG_DIR", Path(__file__).resolve().parents[1] / "logs"))


def configurar_registro(servico: str) -> None:
    """Chame uma vez no inicio do processo. Repetir nao duplica as saidas."""
    if servico in _configurado:
        return
    _configurado.add(servico)
    nivel = getattr(logging, os.environ.get("MUFASA_LOG_NIVEL", "INFO").upper(), logging.INFO)
    raiz = logging.getLogger()
    raiz.setLevel(nivel)
    for h in list(raiz.handlers):
        raiz.removeHandler(h)
    formato = logging.Formatter(FORMATO)
    filtro = _ComServico(servico)
    console = logging.StreamHandler()
    console.setFormatter(formato)
    console.addFilter(filtro)
    raiz.addHandler(console)
    try:
        pasta = pasta_de_logs()
        pasta.mkdir(parents=True, exist_ok=True)
        arquivo = RotatingFileHandler(pasta / f"{servico}.log", maxBytes=5_000_000, backupCount=5, encoding="utf-8")
        arquivo.setFormatter(formato)
        arquivo.addFilter(filtro)
        raiz.addHandler(arquivo)
    except OSError:
        logging.getLogger("mufasa.registro").warning("sem permissao para gravar logs em arquivo; so no console")
