"""
O que cada perfil ve de um score ja calculado (SRS Anexo E, RN07, RN17).

O score e gravado inteiro pelo servico de calculo (fatores com valor e
frase, modificadores, recomendacoes). Aqui ele e recortado por perfil ANTES
de sair da API: o que o perfil nao pode ver nao chega ao navegador.

- Aluno e nucleo de apoio: tudo.
- Docente: so fatores academicos; os de contexto viram "fator encaminhado
  ao nucleo de apoio", sem nome nem numero.
- Coordenacao: fatores academicos completos; socioeconomicos em faixa
  qualitativa, sem valor; saude nunca (vira o mesmo rotulo do docente).
- Financeiro: score, nivel e o fator financeiro; o resto nao.
"""

import json

from app.api.permissoes import (ALUNO, COORDENACAO, DOCENTE, FATORES_SAUDE, FATORES_SOCIOECONOMICOS,
                                FINANCEIRO, NUCLEO_APOIO, ROTULO_ENCAMINHADO, faixa_qualitativa)

FATORES_ACADEMICOS = {"notas", "frequencia", "reprovacao", "engajamento_ava"}
MODIFICADORES_DE_CONTEXTO = {"M1", "M3"}  # citam renda ou deslocamento


def _lista(valor):
    if valor is None:
        return []
    return json.loads(valor) if isinstance(valor, str) else valor


def recortar_fator(perfil: str, fator: dict) -> dict | None:
    nome = fator["fator"]
    if perfil in (ALUNO, NUCLEO_APOIO):
        return fator
    if perfil == FINANCEIRO:
        return fator if nome == "financeiro" else None
    if nome in FATORES_ACADEMICOS:
        return fator
    if perfil == COORDENACAO and nome in FATORES_SOCIOECONOMICOS:
        return {"id": fator["id"], "fator": nome, "nome": fator["nome"], "faixa": faixa_qualitativa(fator["pontuacao"]),
                "peso": fator["peso"], "acionavel": fator["acionavel"],
                "explicacao": f"Vulnerabilidade em faixa {faixa_qualitativa(fator['pontuacao'])}; o detalhe fica com o "
                              "núcleo de apoio."}
    # Docente (contexto) e coordenacao (saude): sem nome do fator e sem numero.
    return {"id": None, "fator": "encaminhado", "nome": ROTULO_ENCAMINHADO, "explicacao": ROTULO_ENCAMINHADO}


def principais_visiveis(perfil: str, fatores_principais) -> list[str]:
    """Nomes dos fatores principais que o perfil pode ler (fila de alertas, listas)."""
    principais = []
    for nome in _lista(fatores_principais):
        visivel = recortar_fator(perfil, {"fator": nome, "id": None, "nome": nome, "pontuacao": 0, "peso": 0,
                                          "acionavel": False, "explicacao": ""})
        if visivel is None:
            continue
        rotulo = ROTULO_ENCAMINHADO if visivel["fator"] == "encaminhado" else nome
        if rotulo not in principais:
            principais.append(rotulo)
    return principais


def recomendacoes_visiveis(perfil: str, recomendacoes) -> list[dict]:
    recomendacoes = _lista(recomendacoes)
    if perfil == DOCENTE:
        return [r for r in recomendacoes if r["perfil_atendimento"] == "Acadêmico"]
    if perfil == FINANCEIRO:
        return [r for r in recomendacoes if r["perfil_atendimento"] == "Financeiro"]
    if perfil == COORDENACAO:
        return [r for r in recomendacoes if r["fator"] not in FATORES_SAUDE]
    return recomendacoes


def recortar_score(perfil: str, linha) -> dict:
    """Recebe a linha de vw_score_atual e devolve o que o perfil pode receber."""
    fatores = []
    vistos_encaminhado = False
    for fator in _lista(linha["fatores"]):
        recortado = recortar_fator(perfil, fator)
        if recortado is None:
            continue
        if recortado["fator"] == "encaminhado":
            if vistos_encaminhado:
                continue
            vistos_encaminhado = True
        fatores.append(recortado)

    principais = principais_visiveis(perfil, linha["fatores_principais"])

    modificadores = _lista(linha["modificadores"])
    if perfil not in (ALUNO, NUCLEO_APOIO):
        modificadores = [m if m["id"] not in MODIFICADORES_DE_CONTEXTO else
                         {"id": m["id"], "descricao": "Modificador de contexto (detalhe com o núcleo de apoio)",
                          "delta": m["delta"]} for m in modificadores]
    if perfil == FINANCEIRO:
        modificadores = []

    recomendacoes = recomendacoes_visiveis(perfil, linha["recomendacoes"])

    motivo = linha["motivo_sobreposicao"]
    return {
        "score": linha["score"],
        "nivel": linha["nivel"],
        "nivel_origem": linha["nivel_origem"],
        "motivo_sobreposicao": motivo,
        "parcial": bool(linha["parcial"]),
        "completude": float(linha["completude"]),
        "fatores": fatores,
        "fatores_principais": principais,
        "modificadores": modificadores,
        "recomendacoes": recomendacoes,
        "recomendacao_nivel": linha["recomendacao"],
        "tendencia": linha["tendencia"],
        "score_anterior": linha["score_anterior"],
        "nivel_anterior": linha["nivel_anterior"],
        "versao_modelo": linha["versao_modelo"],
        "versao_parametros": f"param-v{linha['versao_parametros']}",
        "calculado_em": linha["calculado_em"],
    }
