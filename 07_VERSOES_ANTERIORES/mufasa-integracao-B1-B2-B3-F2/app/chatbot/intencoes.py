"""
Catalogo FECHADO de intencoes do chatbot (RN06, Anexo D.2 e E.2).

A pergunta e classificada em uma destas intencoes por regras fixas. Se as
regras nao reconhecem e a IA esta ligada, a IA pode sugerir uma intencao,
mas so da lista INTENCOES_QUE_A_IA_PODE_SUGERIR, e o servidor confere.
A IA nunca decide escopo, nunca escolhe consulta e nunca libera recusa.

Ordem de verificacao: primeiro as recusas (burla, alteracao, outro aluno,
juizo), depois as consultas de dados, por ultimo as informativas.
"""

import re
from dataclasses import dataclass, field

from app.chatbot.texto import matriculas_citadas, normalizar

# Recusas obrigatorias (E.2)
BURLA = "TENTATIVA_DE_BURLA"
ALTERACAO = "PEDIDO_DE_ALTERACAO"
OUTRO_ALUNO = "DADO_DE_OUTRO_ALUNO"
JUIZO = "JUIZO_SOBRE_PESSOA"
PREVISAO_INDIVIDUAL = "QUEM_VAI_DESISTIR"

# Dados do proprio aluno
RESUMO_ACADEMICO = "RESUMO_ACADEMICO"
NOTAS = "NOTAS"
FREQUENCIA = "FREQUENCIA_E_FALTAS"
MEDIA = "MEDIA"
SITUACAO = "SITUACAO_NAS_DISCIPLINAS"
PENDENCIAS = "ATIVIDADES_PENDENTES"
MEU_RISCO = "MEU_NIVEL_DE_RISCO"

# Equipe (docente, coordenacao, nucleo de apoio)
RESUMO_RISCO = "RESUMO_DE_RISCO"
MAIOR_RISCO = "ALUNOS_DE_MAIOR_RISCO"
ALUNO_ESPECIFICO = "SITUACAO_DE_UM_ALUNO"

# Informativas
SAUDACAO = "SAUDACAO"
AGRADECIMENTO = "AGRADECIMENTO"
AJUDA = "AJUDA"
METODOLOGIA = "METODOLOGIA"
ATENDIMENTO = "ATENDIMENTO_HUMANO"
PRIVACIDADE = "PRIVACIDADE"
ACESSO = "ACESSO_E_SENHA"
FORA_DO_ESCOPO = "FORA_DO_ESCOPO"
NAO_ENTENDI = "NAO_ENTENDI"

RECUSAS = {BURLA, ALTERACAO, OUTRO_ALUNO, JUIZO}
INTENCOES_DE_ALUNO = {RESUMO_ACADEMICO, NOTAS, FREQUENCIA, MEDIA, SITUACAO, PENDENCIAS, MEU_RISCO}
INTENCOES_DE_EQUIPE = {RESUMO_RISCO, MAIOR_RISCO, ALUNO_ESPECIFICO}

INTENCOES_QUE_A_IA_PODE_SUGERIR = (
    INTENCOES_DE_ALUNO | INTENCOES_DE_EQUIPE
    | {SAUDACAO, AGRADECIMENTO, AJUDA, METODOLOGIA, ATENDIMENTO, PRIVACIDADE, ACESSO, FORA_DO_ESCOPO}
)


def _re(*termos: str) -> re.Pattern:
    return re.compile(r"\b(?:" + "|".join(termos) + r")")


# Tudo aqui e comparado com o texto normalizado (minusculo, sem acento).
_BURLA = _re(
    r"ignor\w*\s+(?:\w+\s+){0,3}(?:regra|instruc|restric|limite|ordem|comando)",
    r"esquec\w*\s+(?:\w+\s+){0,3}(?:regra|instruc|restric)", r"desconsider\w*\s+(?:\w+\s+){0,3}regra",
    r"finj\w*", r"fing\w*", r"aja como", r"atue como", r"faca de conta", r"act as", r"pretend",
    r"voce agora e", r"a partir de agora voce", r"modo (?:desenvolvedor|dev|deus|admin|irrestrito)",
    r"developer mode", r"jailbreak", r"dan\b", r"sem (?:restric|filtro|regra|limite)",
    r"system prompt", r"prompt (?:do|de) sistema", r"suas (?:instrucoes|regras internas)",
    r"revel\w* (?:\w+\s+){0,3}(?:prompt|instruc|codigo|regra|senha|chave)", r"codigo fonte",
    r"senha d[oa] (?:admin|administrador|sistema|banco|professor|coordenador|outr)", r"chave (?:da|de) api", r"api key", r"\bsql\b", r"select\s+(?:\w+\s+)?from",
    r"drop\s+table", r"union\s+select", r"sou (?:o )?(?:admin|administrador|coordenador|professor|diretor)",
    r"meu perfil e (?:admin|administrador|coordenacao|docente)", r"base64",
)

_VERBO_ALTERAR = _re(
    r"altere", r"alterar", r"altera\b", r"mude", r"mudar", r"muda\b", r"troque", r"trocar", r"troca\b",
    r"corrija", r"corrigir", r"apague", r"apagar", r"apaga\b", r"delete", r"deletar", r"exclua",
    r"excluir", r"remova", r"remover", r"atualize", r"atualizar", r"edite", r"editar", r"aumente",
    r"aumentar", r"diminua", r"diminuir", r"zere", r"zerar", r"abone", r"abonar", r"lance a",
    r"cadastre", r"cadastrar", r"modifique", r"modificar",
)
_OBJETO_ALTERAR = _re(r"nota", r"falta", r"frequencia", r"presenca", r"cadastro", r"dado", r"media",
                      r"score", r"risco", r"matricula", r"historico", r"situacao", r"registro")

_OUTRA_PESSOA = _re(
    r"colega", r"outr[oa]s? alun", r"outr[oa]s? estudante", r"de todos", r"da turma", r"meus colegas",
    r"meu amigo", r"minha amiga", r"namorad", r"ranking", r"lista de alunos", r"quem tirou",
    r"quem tem a maior", r"quem tem a menor", r"nota d[oa] (?:fulan|ciclan|beltran)", r"dados d[oa] (?:fulan|outr)",
)
_JUIZO = _re(r"preguicos", r"vagabund", r"burr[oa]", r"incompetente", r"irresponsavel", r"burro",
             r"nao (?:se )?esforca", r"desinteressad", r"culpa d")
_PREVISAO = _re(r"quem vai (?:desistir|evadir|abandonar|largar|sair|trancar)",
                r"(?:vai|vao|irao|ira) (?:desistir|evadir|abandonar|largar|trancar)")

_METODOLOGIA = _re(r"como (?:e|foi|eh) calculad", r"como (?:voces )?calcula", r"como funciona (?:o|a) (?:risco|score|nivel|calculo)",
                   r"metodologia", r"o que (?:significa|quer dizer) (?:o |a |meu |minha )?(?:risco|score|nivel|alerta)",
                   r"de onde vem", r"por que (?:estou|eu estou|to) (?:em|no|com) (?:risco|alerta)")
_ATENDIMENTO = _re(r"falar com (?:alguem|uma pessoa|um humano|atendente|a secretaria|o nucleo|psicolog)",
                   r"atendente", r"atendimento", r"humano", r"psicolog", r"apoio emocional", r"nucleo de apoio",
                   r"preciso de ajuda", r"estou mal", r"ansios", r"depressa?o")
_PRIVACIDADE = _re(r"lgpd", r"privacidade", r"meus dados pessoais", r"quais dados", r"o que voces guardam",
                   r"exportar meus dados", r"consentimento")

_ACESSO = _re(r"senha", r"login", r"nao consigo entrar", r"acesso bloqueado", r"bloqueou")

_RISCO = _re(r"risco", r"evasao", r"evadir", r"score", r"alerta", r"nivel de")
_FREQUENCIA = _re(r"frequencia", r"presenca", r"falta", r"faltei", r"faltar", r"faltando")
_NOTAS = _re(r"nota", r"va ?[123]\b", r"prova", r"avaliac", r"boletim", r"tirei")
_MEDIA = _re(r"media", r"coeficiente", r"\bcr\b", r"rendimento")
_SITUACAO = _re(r"aprovad", r"reprovad", r"passei", r"passar", r"situacao", r"dependencia", r"\bdp\b")
_PENDENCIAS = _re(r"pendent", r"pendenc", r"atividade", r"entrega", r"tarefa")
_RESUMO = _re(r"como (?:eu )?(?:estou|to|tou|vou|anda|andam|esta|estao)", r"meu desempenho", r"minha situacao geral",
              r"resumo", r"panorama", r"visao geral", r"como esta(?:o)? (?:meu|minha|meus|minhas)")

_RESUMO_RISCO = _re(r"quantos", r"quantas", r"distribuicao", r"resumo", r"panorama", r"visao geral", r"total")
_LISTA_RISCO = _re(r"quais alunos", r"quais estudantes", r"lista", r"maior risco", r"mais risco", r"critic",
                   r"risco alto", r"em risco", r"prioridade", r"fila")

_SAUDACAO = _re(r"oi\b", r"ola\b", r"bom dia", r"boa tarde", r"boa noite", r"e ai", r"hey", r"opa\b", r"salve\b")
_AGRADECIMENTO = _re(r"obrigad", r"valeu", r"agradec", r"brigad")
_AJUDA = _re(r"menu", r"ajuda", r"o que voce (?:faz|sabe|pode)", r"opcoes", r"como (?:te )?uso", r"comandos")
_FORA = _re(r"receita", r"futebol", r"piada", r"filme", r"serie\b", r"namoro", r"politic", r"eleica",
            r"previsao do tempo", r"clima hoje", r"escrev\w* (?:um|uma) (?:codigo|redacao|poema|texto)",
            r"codigo em", r"programa em python", r"faca meu trabalho", r"resolva (?:a|minha) (?:prova|lista)",
            r"horoscopo", r"aposta")


@dataclass
class Classificacao:
    intencao: str
    matriculas: list[str] = field(default_factory=list)
    por_regra: bool = True


def classificar(texto: str, perfil: str, id_aluno_proprio: str | None) -> Classificacao:
    t = normalizar(texto)
    matriculas = matriculas_citadas(texto)

    if _BURLA.search(t):
        return Classificacao(BURLA, matriculas)
    if _VERBO_ALTERAR.search(t) and _OBJETO_ALTERAR.search(t):
        return Classificacao(ALTERACAO, matriculas)
    if _JUIZO.search(t):
        return Classificacao(JUIZO, matriculas)

    e_aluno = perfil == "ALUNO"
    if e_aluno:
        outra_matricula = any(m != (id_aluno_proprio or "").upper() for m in matriculas)
        if outra_matricula or _OUTRA_PESSOA.search(t):
            return Classificacao(OUTRO_ALUNO, matriculas)

    if _PREVISAO.search(t):
        return Classificacao(PREVISAO_INDIVIDUAL, matriculas)
    if _METODOLOGIA.search(t):
        return Classificacao(METODOLOGIA, matriculas)
    if _ATENDIMENTO.search(t):
        return Classificacao(ATENDIMENTO, matriculas)
    if _PRIVACIDADE.search(t):
        return Classificacao(PRIVACIDADE, matriculas)
    if _ACESSO.search(t):
        return Classificacao(ACESSO, matriculas)

    if not e_aluno:
        if matriculas:
            return Classificacao(ALUNO_ESPECIFICO, matriculas)
        if _RISCO.search(t) or _LISTA_RISCO.search(t):
            if _LISTA_RISCO.search(t) and not _RESUMO_RISCO.search(t):
                return Classificacao(MAIOR_RISCO, matriculas)
            return Classificacao(RESUMO_RISCO, matriculas)

    if _RISCO.search(t):
        return Classificacao(MEU_RISCO, matriculas)
    if _RESUMO.search(t) and not (_FREQUENCIA.search(t) or _NOTAS.search(t) or _MEDIA.search(t)):
        return Classificacao(RESUMO_ACADEMICO, matriculas)
    if _FREQUENCIA.search(t):
        return Classificacao(FREQUENCIA, matriculas)
    if _NOTAS.search(t):
        return Classificacao(NOTAS, matriculas)
    if _MEDIA.search(t):
        return Classificacao(MEDIA, matriculas)
    if _SITUACAO.search(t):
        return Classificacao(SITUACAO, matriculas)
    if _PENDENCIAS.search(t):
        return Classificacao(PENDENCIAS, matriculas)
    if _RESUMO.search(t):
        return Classificacao(RESUMO_ACADEMICO, matriculas)

    if _FORA.search(t):
        return Classificacao(FORA_DO_ESCOPO, matriculas)
    if _AGRADECIMENTO.search(t):
        return Classificacao(AGRADECIMENTO, matriculas)
    if _AJUDA.search(t):
        return Classificacao(AJUDA, matriculas)
    if _SAUDACAO.search(t):
        return Classificacao(SAUDACAO, matriculas)
    return Classificacao(NAO_ENTENDI, matriculas)
