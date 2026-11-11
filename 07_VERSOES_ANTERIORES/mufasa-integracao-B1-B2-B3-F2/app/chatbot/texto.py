"""
Tratamento do texto digitado: normalizacao para classificar, remocao de
dado pessoal antes de qualquer envio externo e formatacao dos valores.
"""

import re
import unicodedata
from decimal import Decimal, InvalidOperation

# Mesmo formato aceito pela API (app/api/esquemas.PADRAO_MATRICULA).
RE_MATRICULA = re.compile(r"\b(?:\d{7}|ALU\d{4})\b", re.IGNORECASE)

# Ordem importa: CPF e telefone antes da matricula, para nao sobrar pedaco.
_REDACOES = (
    (re.compile(r"\b\d{3}\.?\d{3}\.?\d{3}-?\d{2}\b"), "[CPF removido]"),
    (re.compile(r"[\w.+-]+@[\w-]+(?:\.[\w-]+)+"), "[e-mail removido]"),
    (re.compile(r"(?:\+?55\s?)?\(?\d{2}\)?\s?9?\d{4}[-\s]?\d{4}\b"), "[telefone removido]"),
    (RE_MATRICULA, "[matrícula removida]"),
)
_QUALQUER_NUMERO = re.compile(r"\d+(?:[.,]\d+)?")


def sem_acentos(texto: str) -> str:
    decomposto = unicodedata.normalize("NFKD", texto)
    return "".join(c for c in decomposto if not unicodedata.combining(c))


def normalizar(texto: str) -> str:
    """Minusculas, sem acento, sem pontuacao e com espacos simples."""
    t = sem_acentos(texto).lower()
    t = re.sub(r"[^a-z0-9\s]", " ", t)
    return re.sub(r"\s+", " ", t).strip()


def limpar_entrada(texto: str) -> str:
    """Remove caracteres de controle e invisiveis usados para esconder instrucoes."""
    texto = unicodedata.normalize("NFKC", texto)
    texto = "".join(c for c in texto if unicodedata.category(c)[0] != "C" or c in "\n\t")
    return re.sub(r"\s+", " ", texto).strip()


def redigir_dados_pessoais(texto: str) -> str:
    """Versao da pergunta gravada no historico: sem CPF, e-mail, telefone e matricula."""
    for padrao, troca in _REDACOES:
        texto = padrao.sub(troca, texto)
    return texto


_PALAVRA_MAIUSCULA = re.compile(r"(?<!^)(?<![.!?]\s)\b[A-ZÀ-Ý][a-zà-ÿ]+")


def texto_para_ia(texto: str) -> str:
    """
    Versao da pergunta que pode sair do servidor (so na classificacao
    opcional): alem do dado pessoal, sai qualquer numero (nota, idade,
    endereco) e qualquer palavra com inicial maiuscula fora do inicio da
    frase, que costuma ser nome proprio.
    """
    t = _QUALQUER_NUMERO.sub("#", redigir_dados_pessoais(texto))
    return _PALAVRA_MAIUSCULA.sub("[nome]", t)


def matriculas_citadas(texto: str) -> list[str]:
    return [m.upper() for m in RE_MATRICULA.findall(texto)]


def numero_br(valor) -> str | None:
    """
    Formata o valor EXATAMENTE como esta no banco, so trocando ponto por
    virgula. Zero continua zero; vazio continua vazio (None).
    """
    if valor is None:
        return None
    try:
        d = Decimal(str(valor))
    except (InvalidOperation, ValueError):
        return str(valor)
    if d == d.to_integral_value():
        return str(int(d))
    return format(d.normalize(), "f").replace(".", ",")


def data_br(valor) -> str | None:
    if valor is None:
        return None
    texto = str(valor)[:10]
    partes = texto.split("-")
    if len(partes) == 3 and all(p.isdigit() for p in partes):
        return f"{partes[2]}/{partes[1]}/{partes[0]}"
    return texto
