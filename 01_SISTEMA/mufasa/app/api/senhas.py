"""Senha provisoria de primeiro acesso: aleatoria, com letras e numeros, trocada no primeiro login."""

import secrets
import string

# Sem caracteres que se confundem na leitura (0/O, 1/l/I).
_LETRAS = "abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ"
_DIGITOS = "23456789"


def gerar_senha_provisoria(tamanho: int = 12) -> str:
    while True:
        senha = "".join(secrets.choice(_LETRAS + _DIGITOS) for _ in range(tamanho))
        if any(c in _DIGITOS for c in senha) and any(c in string.ascii_letters for c in senha):
            return senha
