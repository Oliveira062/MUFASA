"""Conversoes pequenas usadas por todas as rotas."""

import json
from datetime import date, datetime, timezone
from decimal import Decimal


def agora() -> datetime:
    return datetime.now(timezone.utc)


def como_datetime(valor) -> datetime | None:
    if valor is None:
        return None
    if isinstance(valor, datetime):
        return valor if valor.tzinfo else valor.replace(tzinfo=timezone.utc)
    convertido = datetime.fromisoformat(str(valor))
    return convertido if convertido.tzinfo else convertido.replace(tzinfo=timezone.utc)


def sim_nao(valor) -> bool | None:
    if valor is None:
        return None
    if isinstance(valor, bool):
        return valor
    return str(valor).strip().lower() in ("sim", "s", "true", "1")


def numero(valor) -> float | None:
    return None if valor is None else float(valor)


def valor_json(valor):
    if isinstance(valor, Decimal):
        return float(valor)
    if isinstance(valor, (date, datetime)):
        return valor.isoformat()
    return valor


def linha_json(linha) -> dict | None:
    return None if linha is None else {k: valor_json(v) for k, v in dict(linha).items()}


def lista_json(valor) -> list:
    """Coluna JSONB chega como lista (PostgreSQL) ou texto (SQLite dos testes)."""
    if not valor:
        return []
    return json.loads(valor) if isinstance(valor, str) else list(valor)
