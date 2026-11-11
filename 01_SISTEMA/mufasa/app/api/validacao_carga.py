"""
Validacao de CSV de carga (RN08, RF06, Anexo C.2), antes de qualquer gravacao.

Ordem do pipeline (RN08): recepcao, formato, dominio, padronizacao,
duplicidade. A carga e tudo ou nada: com qualquer linha invalida, nenhuma
linha e aplicada, e o relatorio lista linha, campo, valor recebido e motivo.
"""

import csv
import io
import math
import re
from dataclasses import dataclass, field

TAMANHO_MAXIMO = 20 * 1024 * 1024
LINHAS_MAXIMAS = 200_000
PADRAO_ALUNO = re.compile(r"^(?:\d{7}|ALU\d{4})$")
PADRAO_TURMA = re.compile(r"^[A-Za-z0-9_-]{2,40}$")
PADRAO_PERIODO = re.compile(r"^\d{4}/[12]$")

COLUNAS = {
    "NOTAS": ["id_aluno", "id_turma", "va1", "va2", "va3", "nota_final", "frequencia_pct", "situacao"],
    "INDICADORES": ["id_aluno", "periodo_letivo", "faltas_total", "atividades_pendentes",
                    "disciplinas_reprovadas_historico", "media_semestre_anterior"],
}
SITUACOES = {"Aprovado", "Reprovado", "Cursando"}


class ArquivoInvalido(ValueError):
    """O arquivo inteiro e recusado (formato, tamanho, cabecalho)."""


@dataclass
class Resultado:
    validas: list = field(default_factory=list)       # (numero, dados)
    erros: list = field(default_factory=list)         # (numero, {campo, valor, motivo})
    total: int = 0


def _decimal(texto: str, minimo: float, maximo: float, obrigatorio: bool):
    texto = (texto or "").strip()
    if texto == "":
        if obrigatorio:
            raise ValueError("campo obrigatório vazio")
        return None
    try:
        valor = float(texto.replace(",", "."))
    except ValueError:
        raise ValueError("não é número")
    if not math.isfinite(valor) or valor < minimo or valor > maximo:
        raise ValueError(f"fora da faixa {minimo:g} a {maximo:g}")
    return round(valor, 2)


def _inteiro(texto: str, minimo: int, maximo: int):
    texto = (texto or "").strip()
    if texto == "":
        return None
    if not re.fullmatch(r"\d{1,6}", texto):
        raise ValueError("não é inteiro não negativo")
    valor = int(texto)
    if valor < minimo or valor > maximo:
        raise ValueError(f"fora da faixa {minimo} a {maximo}")
    return valor


def ler_csv(conteudo: bytes, tipo: str) -> list[dict]:
    if len(conteudo) == 0:
        raise ArquivoInvalido("Arquivo vazio.")
    if len(conteudo) > TAMANHO_MAXIMO:
        raise ArquivoInvalido("Arquivo acima de 20 MB.")
    try:
        texto = conteudo.decode("utf-8-sig")
    except UnicodeDecodeError:
        raise ArquivoInvalido("O arquivo precisa estar em UTF-8.")
    amostra = texto[:4096]
    separador = ";" if amostra.count(";") > amostra.count(",") else ","
    leitor = csv.DictReader(io.StringIO(texto, newline=""), delimiter=separador)
    cabecalho = [c.strip() for c in (leitor.fieldnames or [])]
    if cabecalho != COLUNAS[tipo]:
        raise ArquivoInvalido("Cabeçalho diferente do modelo. Esperado: " + separador.join(COLUNAS[tipo]))
    leitor.fieldnames = cabecalho
    linhas = []
    for linha in leitor:
        if len(linhas) >= LINHAS_MAXIMAS:
            raise ArquivoInvalido(f"Mais de {LINHAS_MAXIMAS} linhas.")
        if None in linha:
            linha["__sobra__"] = True
        linhas.append(linha)
    if not linhas:
        raise ArquivoInvalido("O arquivo não tem linhas de dados.")
    return linhas


def validar(linhas: list[dict], tipo: str, alunos: set, matriculas: dict) -> Resultado:
    """
    alunos: matriculas de aluno existentes. matriculas: (id_aluno, id_turma) -> id_matricula.
    Numero da linha conta o cabecalho como linha 1, como no editor de planilha.
    """
    r = Resultado(total=len(linhas))
    vistos = {}
    for indice, bruta in enumerate(linhas, start=2):
        erros = []

        def campo(nome, conversor):
            try:
                return conversor(bruta.get(nome))
            except ValueError as exc:
                erros.append({"campo": nome, "valor": str(bruta.get(nome) or "")[:60], "motivo": str(exc)})
                return None

        if bruta.get("__sobra__"):
            erros.append({"campo": "-", "valor": "", "motivo": "linha com mais colunas que o cabeçalho"})
        aluno = (bruta.get("id_aluno") or "").strip()
        if not PADRAO_ALUNO.fullmatch(aluno):
            erros.append({"campo": "id_aluno", "valor": aluno[:60], "motivo": "matrícula em formato inválido"})
        elif aluno not in alunos:
            erros.append({"campo": "id_aluno", "valor": aluno, "motivo": "aluno não cadastrado"})

        if tipo == "NOTAS":
            turma = (bruta.get("id_turma") or "").strip()
            id_matricula = None
            if not PADRAO_TURMA.fullmatch(turma):
                erros.append({"campo": "id_turma", "valor": turma[:60], "motivo": "turma em formato inválido"})
            else:
                id_matricula = matriculas.get((aluno, turma))
                if id_matricula is None and aluno in alunos:
                    erros.append({"campo": "id_turma", "valor": turma, "motivo": "aluno não matriculado nesta turma"})
            chave = (aluno, turma)
            dados = {
                "va1": campo("va1", lambda v: _decimal(v, 0, 10, False)),
                "va2": campo("va2", lambda v: _decimal(v, 0, 10, False)),
                "va3": campo("va3", lambda v: _decimal(v, 0, 10, False)),
                "nota_final": campo("nota_final", lambda v: _decimal(v, 0, 10, True)),
                "frequencia_pct": campo("frequencia_pct", lambda v: _decimal(v, 0, 100, True)),
                "situacao": (bruta.get("situacao") or "").strip() or None,
                "id_matricula": id_matricula,
            }
            if dados["situacao"] not in SITUACOES:
                erros.append({"campo": "situacao", "valor": str(dados["situacao"] or "")[:60],
                              "motivo": "use Aprovado, Reprovado ou Cursando"})
        else:
            periodo = (bruta.get("periodo_letivo") or "").strip()
            if not PADRAO_PERIODO.fullmatch(periodo):
                erros.append({"campo": "periodo_letivo", "valor": periodo[:60], "motivo": "use o formato AAAA/1 ou AAAA/2"})
            chave = (aluno, periodo)
            dados = {
                "id_aluno": aluno, "periodo_letivo": periodo,
                "faltas_total": campo("faltas_total", lambda v: _inteiro(v, 0, 10_000)),
                "atividades_pendentes": campo("atividades_pendentes", lambda v: _inteiro(v, 0, 1_000)),
                "disciplinas_reprovadas_historico": campo("disciplinas_reprovadas_historico",
                                                          lambda v: _inteiro(v, 0, 100)),
                "media_semestre_anterior": campo("media_semestre_anterior", lambda v: _decimal(v, 0, 10, False)),
            }

        if chave in vistos:
            erros.append({"campo": "id_aluno", "valor": aluno, "motivo": f"duplicada com a linha {vistos[chave]}"})
        else:
            vistos[chave] = indice

        if erros:
            r.erros.extend((indice, e) for e in erros)
        else:
            r.validas.append((indice, dados))
    return r
