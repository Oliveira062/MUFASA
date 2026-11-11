"""
Buscas da equipe com filtros combinados (pedido do João, 28/10/2026).

Exemplos que o leitor entende:
    "alunos que moram a mais de 20 km com frequência abaixo de 70%"
    "alunos com frequência próxima de 60% e média abaixo de 5"
    "quem tem mais de 3 atividades pendentes no 2º semestre"
    "alunos em risco alto com média entre 4 e 6"

Como e seguro:
- O texto vira uma lista de Filtro(campo, operador, valores). Campo e
  operador so podem ser os da lista abaixo (CAMPOS, OPERADORES).
- O SQL e montado em consultas_chat.montar_busca so com pedacos fixos do
  codigo; os numeros entram como parametros. Nenhum texto do usuario entra
  no SQL.
- Valor fora da escala do campo (frequencia 150%, media 12) e descartado e
  a resposta avisa.
"""

import re
from dataclasses import dataclass

from app.chatbot.texto import sem_acentos

# campo -> (descricao na resposta, unidade, margem para "proximo de", minimo, maximo)
CAMPOS = {
    "frequencia": ("frequência", "%", 5, 0, 100),
    "media": ("média", "", 0.5, 0, 10),
    "faltas": ("faltas", "", 2, 0, 500),
    "pendencias": ("atividades pendentes", "", 1, 0, 100),
    "semestre": ("semestre", "", 0, 1, 20),
    "distancia": ("distância", " km", 3, 0, 1000),
}
OPERADORES = {">", ">=", "<", "<=", "=", "entre"}
NIVEIS = {"critico": "Crítico", "alto": "Alto", "moderado": "Moderado", "baixo": "Baixo"}


@dataclass(frozen=True)
class Filtro:
    campo: str
    operador: str
    valor: float
    valor2: float | None = None
    aproximado: bool = False
    centro: float | None = None  # o valor citado em "proximo de X"


@dataclass
class Busca:
    filtros: list[Filtro]
    niveis: list[str]
    media_caiu: bool = False
    descartados: list[str] = None

    @property
    def vazia(self) -> bool:
        return not self.filtros and not self.niveis and not self.media_caiu


# Palavras que indicam o campo (texto ja sem acento e minusculo).
_CAMPO_POR_PALAVRA = (
    ("distancia", r"distancia|moram?|morando|reside\w*|longe|perto da (?:universidade|faculdade)|desloca\w*|km\b|quilometro"),
    ("frequencia", r"frequencia|presenca"),
    ("faltas", r"faltas?"),
    ("pendencias", r"pendente|pendencia|atividades?|tarefas?|entregas?"),
    ("media", r"medias?|cr\b|coeficiente"),
    ("semestre", r"semestre|periodo"),
)
_COMPARADORES = (
    ("entre", r"entre"),
    ("~", r"proxim[ao]s? (?:de|a|dos|das)|perto de|cerca de|em torno de|por volta de|aproximadamente|uns|umas|~"),
    (">=", r"pelo menos|no minimo|a partir de|>="),
    ("<=", r"no maximo|ate|<="),
    (">", r"acima de|mais de|maior(?:es)? que|maior(?:es)? de|superior(?:es)? a|passa(?:m|ndo)? de|>"),
    ("<", r"abaixo de|menos de|menor(?:es)? que|menor(?:es)? de|inferior(?:es)? a|<"),
)
_NUMERO = re.compile(
    r"(?P<entre>entre\s+)?(?P<n1>\d+(?:[.,]\d+)?)(?:\s*(?:o|a|º|ª)\b)?"
    r"(?:\s*(?:%|km|quilometros?))?(?(entre)\s*(?:e|a)\s*(?P<n2>\d+(?:[.,]\d+)?))"
    r"\s*(?P<un>%|km\b|quilometros?|faltas?|atividades?|pendencias?|tarefas?|semestres?|periodos?)?")
# "2o semestre", "3 periodo", "do 5"
_ORDINAL_SEMESTRE = re.compile(r"\b(\d{1,2})\s*(?:o|a|º|ª)?\s+(?:semestre|periodo)")


def _preparar(texto: str) -> str:
    t = sem_acentos(texto).lower()
    t = re.sub(r"(\d)\s*%", r"\1 %", t)
    t = re.sub(r"[^\w%,.<>=~\s]", " ", t)
    return re.sub(r"\s+", " ", t).strip()


def _numero(v: str) -> float:
    return float(v.replace(",", "."))


def _ultimo(padroes, trecho: str):
    """O padrao que aparece mais perto do fim do trecho (o mais proximo do numero)."""
    melhor, pos = None, -1
    for nome, padrao in padroes:
        for m in re.finditer(r"(?:^|\b|\s)(?:" + padrao + r")(?:\b|\s|$)", trecho):
            if m.end() > pos:
                melhor, pos = nome, m.end()
    return melhor


def _campo(unidade: str | None, antes: str, depois: str) -> str | None:
    if unidade:
        if unidade.startswith(("km", "quilometro")):
            return "distancia"
        if unidade.startswith("falta"):
            return "faltas"
        if unidade.startswith(("atividade", "pendencia", "tarefa")):
            return "pendencias"
        if unidade.startswith(("semestre", "periodo")):
            return "semestre"
        if unidade == "%":
            return "media" if _ultimo((("media", r"medias?"),), antes[-25:]) else "frequencia"
    if re.match(r"\s*(?:o|a|º|ª)?\s*(?:semestre|periodo)", depois):
        return "semestre"
    return _ultimo(_CAMPO_POR_PALAVRA, antes)


def interpretar(texto: str) -> Busca:
    t = _preparar(texto)
    filtros, descartados, usados = [], [], set()
    fim_anterior = 0
    for m in _NUMERO.finditer(t):
        if m.group("n1") is None:
            continue
        antes = t[max(fim_anterior, m.start() - 60):m.start()]
        depois = t[m.end():m.end() + 20]
        campo = _campo(m.group("un"), antes + (m.group("entre") or ""), depois)
        fim_anterior = m.end()
        if campo is None or campo in usados:
            continue
        v1 = _numero(m.group("n1"))
        v2 = _numero(m.group("n2")) if m.group("n2") else None
        if m.group("entre"):
            operador = "entre"
        else:
            operador = _ultimo(_COMPARADORES, antes[-30:]) or ("=" if campo == "semestre" else "~")
        nome, _, margem, minimo, maximo = CAMPOS[campo]
        if not all(minimo <= v <= maximo for v in (v1, v2) if v is not None):
            descartados.append(nome)
            continue
        aproximado, centro = operador == "~", v1
        if aproximado:
            operador, v1, v2 = "entre", max(minimo, v1 - margem), min(maximo, v1 + margem)
        elif operador == "entre" and v2 is not None and v2 < v1:
            v1, v2 = v2, v1
        if operador == "entre" and v2 is None:
            continue
        filtros.append(Filtro(campo, operador, v1, v2, aproximado, centro if aproximado else None))
        usados.add(campo)

    niveis = []
    for m in re.finditer(r"risco (?:e |ou )?((?:(?:critico|alto|moderado|baixo)(?: ou | e |, ?| )?)+)", t):
        for palavra in re.findall(r"critico|alto|moderado|baixo", m.group(1)):
            if NIVEIS[palavra] not in niveis:
                niveis.append(NIVEIS[palavra])
    for palavra in re.findall(r"\b(critico|criticos)\b", t):
        if "Crítico" not in niveis:
            niveis.append("Crítico")
    media_caiu = bool(re.search(r"media (?:caiu|caindo|em queda|piorou|diminuiu|baixou)|queda (?:na|da) media", t))
    return Busca(filtros, niveis, media_caiu, descartados)


def parece_busca(texto: str) -> bool:
    """A pergunta pede uma lista filtrada? (numero ligado a um campo, nivel + campo, media em queda)"""
    b = interpretar(texto)
    return bool(b.filtros or b.media_caiu or b.descartados)


def descrever(f: Filtro) -> str:
    nome, unidade, *_ = CAMPOS[f.campo]

    def v(x: float) -> str:
        texto = (f"{x:.1f}".rstrip("0").rstrip(".") if x != int(x) else str(int(x))).replace(".", ",")
        return texto + unidade

    if f.campo == "semestre":
        if f.operador == "=":
            return f"do {v(f.valor)}º semestre"
        limites = {">": "depois do", ">=": "a partir do", "<": "antes do", "<=": "até o"}
        if f.operador == "entre":
            return f"do {v(f.valor)}º ao {v(f.valor2)}º semestre"
        return f"{limites[f.operador]} {v(f.valor)}º semestre"
    if f.campo in ("faltas", "pendencias"):
        quantidade = {">": "mais de", ">=": "pelo menos", "<": "menos de", "<=": "até", "=": ""}
        if f.aproximado:
            return f"cerca de {v(f.centro)} {nome} (de {v(f.valor)} a {v(f.valor2)})"
        if f.operador == "entre":
            return f"entre {v(f.valor)} e {v(f.valor2)} {nome}"
        return f"{quantidade[f.operador]} {v(f.valor)} {nome}".strip()
    if f.campo == "distancia":
        prefixo = {">": "mais de ", ">=": "pelo menos ", "<": "menos de ", "<=": "até ", "=": ""}
        if f.aproximado:
            return f"morando a cerca de {v(f.centro)} (de {v(f.valor)[:-3]} a {v(f.valor2)})"
        if f.operador == "entre":
            return f"morando entre {v(f.valor)[:-3]} e {v(f.valor2)}"
        return f"morando a {prefixo[f.operador]}{v(f.valor)}"
    rotulo = {">": "acima de", ">=": "a partir de", "<": "abaixo de", "<=": "até", "=": "igual a"}
    if f.aproximado:
        return f"{nome} perto de {v(f.centro)} (de {v(f.valor)} a {v(f.valor2)})"
    if f.operador == "entre":
        return f"{nome} entre {v(f.valor)} e {v(f.valor2)}"
    return f"{nome} {rotulo[f.operador]} {v(f.valor)}"
