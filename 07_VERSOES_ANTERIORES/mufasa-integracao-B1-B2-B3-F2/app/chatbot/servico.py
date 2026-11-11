"""
Executa a intencao classificada e monta o resultado com os dados REAIS.

Fluxo de cada intencao de dados:
1. Confere se o perfil pode usar a intencao (servidor, nunca o texto).
2. Escolhe UMA consulta de consultas_chat.py e preenche os parametros com
   o escopo do usuario logado (o aluno so consulta o proprio id_aluno).
3. Monta tres coisas:
   - dados:     a lista estruturada que o painel mostra (valores do banco);
   - rascunho:  o texto padrao, com marcadores [[...]] no lugar dos valores;
   - sinais:    informacoes qualitativas, sem numero e sem identificacao,
                que a IA pode usar para deixar o texto mais acolhedor.
4. Se a consulta nao devolve nada, a resposta diz que nao ha dado.
   Nenhum valor e completado, estimado ou inventado (Anexo E.2).
"""

from dataclasses import dataclass, field

from fastapi import HTTPException, Request
from sqlalchemy.engine import Connection

from app.api.auth import Usuario
from app.api.esquemas import AVISO_METODOLOGICO
from app.api.integracao import NIVEL_DO_BANCO
from app.api.permissoes import (ALUNO, COORDENACAO, DOCENTE, NUCLEO_APOIO, verificar_escopo_aluno)
from app.chatbot import consultas_chat as sql
from app.chatbot import intencoes as it
from app.chatbot.config_chat import obter_configuracao_chat
from app.chatbot.texto import data_br, normalizar, numero_br

# Auditoria 4.5-D: o B1 grava as notas das disciplinas de 0 a 100 e a media
# dos indicadores de 0 a 10. O chatbot mostra cada valor como esta no banco
# e diz a escala, sem converter.
ESCALA_NOTAS_DISCIPLINA = "0 a 100"
ESCALA_MEDIA_GERAL = "0 a 10"

NIVEL_CRITICO = "Crítico"
NIVEL_ALTO = "Alto"
NIVEIS_ORDEM = ("Crítico", "Alto", "Moderado", "Baixo")

ATALHOS = {
    it.RESUMO_ACADEMICO: "/painel/meu-desempenho",
    it.NOTAS: "/painel/meu-desempenho#notas",
    it.FREQUENCIA: "/painel/meu-desempenho#frequencia",
    it.MEDIA: "/painel/meu-desempenho",
    it.SITUACAO: "/painel/meu-desempenho#notas",
    it.PENDENCIAS: "/painel/meu-desempenho",
    it.MEU_RISCO: "/painel/meu-desempenho#risco",
    it.RESUMO_RISCO: "/painel/visao-geral",
    it.MAIOR_RISCO: "/painel/alertas?nivel=CRITICO,ALTO",
    it.ALUNO_ESPECIFICO: "/painel/alunos/{matricula}",
    it.PRIVACIDADE: "/painel/privacidade",
}

PERFIS_EQUIPE = (DOCENTE, COORDENACAO, NUCLEO_APOIO)

OPCOES_ALUNO = ["Minhas notas", "Minha frequência", "Meu nível de risco", "Falar com uma pessoa"]
OPCOES_EQUIPE = ["Resumo de risco", "Alunos de maior risco", "Como o risco é calculado"]

_PALAVRAS_VAZIAS = {"de", "da", "do", "das", "dos", "e", "em", "a", "o", "as", "os", "para", "com", "ao"}
_ROMANOS = {"i": "1", "ii": "2", "iii": "3", "iv": "4", "v": "5", "vi": "6"}


@dataclass
class Resultado:
    intencao: str
    rascunho: str
    rodape: str = ""  # texto obrigatorio (aviso metodologico, RN05) que a IA nao reescreve
    valores: dict[str, str] = field(default_factory=dict)
    detalhes: str = ""
    sinais: dict = field(default_factory=dict)
    dados: list[dict] = field(default_factory=list)
    consulta: str | None = None
    registros: int = 0
    referencia: str | None = None
    filtros: dict = field(default_factory=dict)
    atalho: str | None = None
    opcoes: list[str] = field(default_factory=list)
    recusa: bool = False
    tentativa_burla: bool = False
    pode_humanizar: bool = False
    id_aluno_alvo: str | None = None


# ---------------------------------------------------------------------------
# Textos fixos: recusas e respostas informativas nao passam pela IA.
# ---------------------------------------------------------------------------

def _janela() -> str:
    return obter_configuracao_chat().chat_janela_atendimento


def texto_abertura() -> str:
    return ("Oi! Eu sou a Mufa, a assistente do MUFASA. Posso mostrar suas notas, sua frequência e "
            "seu nível de risco, sempre com os dados registrados no sistema. Estou disponível 24 horas; "
            f"o atendimento com uma pessoa da equipe acontece {_janela()}. "
            "Não escreva aqui senha, CPF nem informações de saúde.")


def _fixo(intencao: str, usuario: Usuario) -> Resultado | None:
    e_aluno = usuario.perfil == ALUNO
    opcoes = OPCOES_ALUNO if e_aluno else OPCOES_EQUIPE
    textos = {
        it.BURLA: ("Não posso fazer isso. Sigo sempre as mesmas regras de segurança e só mostro os dados "
                   "que o seu perfil pode ver. Esta tentativa ficou registrada. Posso ajudar com suas notas, "
                   "frequência ou nível de risco?"),
        it.ALTERACAO: ("Eu só consulto informações; não altero notas, faltas nem cadastro. Para pedir uma "
                       "correção, procure a secretaria acadêmica. Se for um dado pessoal seu, você também pode "
                       "pedir a correção pela página de Privacidade do painel."),
        it.OUTRO_ALUNO: ("Não tenho permissão para mostrar informações de outros estudantes. "
                         "Posso mostrar as suas, se quiser."),
        it.JUIZO: ("Não faço julgamento sobre pessoas. O sistema só descreve indicadores, como notas e "
                   "frequência, e não diz nada sobre esforço ou capacidade de ninguém."),
        it.METODOLOGIA: ("O nível de risco é calculado a partir de indicadores registrados, como frequência, "
                         "notas e alguns fatores de contexto, cada um com um peso definido pela equipe. "
                         "Fatores sem dado ficam fora da conta, em vez de serem preenchidos. " + AVISO_METODOLOGICO),
        it.ATENDIMENTO: ("Posso registrar sua dúvida aqui a qualquer hora, mas o atendimento com uma pessoa da "
                         f"equipe acontece {_janela()}. Se você estiver passando por um momento difícil, "
                         "procure o núcleo de apoio da universidade. Em caso de emergência, ligue para o CVV "
                         "no 188 (24 horas, gratuito) ou para o SAMU no 192."),
        it.PRIVACIDADE: ("Na página de Privacidade do painel você vê todos os dados que o MUFASA guarda sobre "
                         "você, pode exportá-los e pode pedir correção, eliminação ou revisão de uma decisão "
                         "automatizada (LGPD, arts. 18 e 20). A resposta chega em até 15 dias."),
        it.ACESSO: ("Por segurança, nunca digite sua senha no chat. Se esqueceu a senha ou o acesso foi "
                    "bloqueado após tentativas erradas, aguarde 15 minutos ou procure a secretaria "
                    "acadêmica para redefinir."),
        it.SAUDACAO: texto_abertura(),
        it.AGRADECIMENTO: "Por nada! Se precisar de mais alguma coisa, é só chamar.",
        it.AJUDA: ("Você pode me perguntar, por exemplo: \"quais são minhas notas?\", \"como está minha "
                   "frequência em Cálculo I?\" ou \"qual é meu nível de risco?\"." if e_aluno else
                   "Você pode me perguntar, por exemplo: \"quantos alunos estão em risco alto?\", "
                   "\"quais alunos têm maior risco?\" ou a situação de um aluno pela matrícula."),
        it.FORA_DO_ESCOPO: ("Esse assunto foge do que eu sei fazer. Eu ajudo com notas, frequência, risco "
                            "e com o uso do MUFASA."),
        it.NAO_ENTENDI: ("Não entendi bem a pergunta. Você pode reformular ou escolher uma das opções abaixo."),
    }
    if intencao not in textos:
        return None
    r = Resultado(intencao=intencao, rascunho=textos[intencao], opcoes=opcoes)
    r.recusa = intencao in it.RECUSAS
    r.tentativa_burla = intencao == it.BURLA
    if intencao == it.PRIVACIDADE:
        r.atalho = ATALHOS[it.PRIVACIDADE]
    return r


def _sem_permissao(intencao: str, mensagem: str) -> Resultado:
    return Resultado(intencao=intencao, rascunho=mensagem, recusa=True)


# ---------------------------------------------------------------------------
# Disciplinas citadas na pergunta
# ---------------------------------------------------------------------------

def _tokens(nome: str) -> tuple[set[str], str | None]:
    partes = [_ROMANOS.get(p, p) for p in normalizar(nome).split()]
    numeral = next((p for p in partes if p.isdigit()), None)
    principais = {p for p in partes if p not in _PALAVRAS_VAZIAS and not p.isdigit() and len(p) >= 4}
    return principais, numeral


def disciplinas_citadas(pergunta: str, nomes: list[str]) -> list[str]:
    palavras = [_ROMANOS.get(p, p) for p in normalizar(pergunta).split()]
    conjunto = set(palavras)
    numerais = {p for p in palavras if p.isdigit() and len(p) == 1}
    melhores, melhor_pontuacao = [], 0
    for nome in nomes:
        principais, numeral = _tokens(nome)
        pontos = len(principais & conjunto)
        if pontos == 0:
            continue
        if numeral and numerais and numeral not in numerais:
            continue
        if pontos > melhor_pontuacao:
            melhores, melhor_pontuacao = [nome], pontos
        elif pontos == melhor_pontuacao:
            melhores.append(nome)
    return melhores


# ---------------------------------------------------------------------------
# Intencoes do aluno
# ---------------------------------------------------------------------------

def _linhas(conexao: Connection, consulta, params: dict) -> list[dict]:
    return [dict(l) for l in conexao.execute(consulta, params).mappings().all()]


def _disciplinas_do_aluno(conexao_chat: Connection, id_aluno: str, pergunta: str):
    """Devolve (linhas filtradas, filtro aplicado, disciplina citada sem matricula)."""
    linhas = _linhas(conexao_chat, sql.DISCIPLINAS_DO_ALUNO, {"id_aluno": id_aluno, "limite": sql.LIMITE_LINHAS})
    minhas = [l["disciplina"] for l in linhas]
    citadas = disciplinas_citadas(pergunta, minhas)
    if citadas:
        return [l for l in linhas if l["disciplina"] in citadas], citadas, None
    catalogo = [l["nome"] for l in conexao_chat.execute(sql.NOMES_DAS_DISCIPLINAS).mappings().all()]
    fora = disciplinas_citadas(pergunta, catalogo)
    if fora:
        return [], fora, fora
    return linhas, [], None


def _abaixo_minimo(linha: dict) -> bool:
    freq, minimo = linha.get("frequencia_pct"), linha.get("frequencia_minima_pct")
    return freq is not None and minimo is not None and float(freq) < float(minimo)


def _situacao_texto(valor) -> str:
    return str(valor) if valor not in (None, "") else "sem situação registrada"


def _valor(v, sufixo: str = "") -> str:
    texto = numero_br(v)
    return "sem registro" if texto is None else texto + sufixo


def _intencao_disciplinas(intencao: str, conexao_chat: Connection, id_aluno: str, pergunta: str) -> Resultado:
    linhas, filtro, fora = _disciplinas_do_aluno(conexao_chat, id_aluno, pergunta)
    r = Resultado(intencao=intencao, rascunho="", consulta="DISCIPLINAS_DO_ALUNO", registros=len(linhas),
                  atalho=ATALHOS[intencao], filtros={"disciplina": filtro} if filtro else {},
                  opcoes=OPCOES_ALUNO, pode_humanizar=True)

    if fora:
        r.rascunho = ("Não encontrei matrícula sua em " + ", ".join(fora) + " no período registrado. "
                      "Posso mostrar as disciplinas em que você está matriculado.")
        r.pode_humanizar = False
        return r
    if not linhas:
        r.rascunho = "Não encontrei disciplinas registradas para você no sistema."
        r.pode_humanizar = False
        return r

    r.referencia = linhas[0].get("periodo_letivo")
    detalhes = []
    for l in linhas:
        item = {
            "disciplina": l["disciplina"], "periodo_letivo": l["periodo_letivo"],
            "va1": numero_br(l["va1"]), "va2": numero_br(l["va2"]), "va3": numero_br(l["va3"]),
            "nota_final": numero_br(l["nota_final"]), "frequencia_pct": numero_br(l["frequencia_pct"]),
            "frequencia_minima_pct": numero_br(l["frequencia_minima_pct"]),
            "situacao": l["situacao"], "abaixo_frequencia_minima": _abaixo_minimo(l),
        }
        r.dados.append(item)
        if intencao == it.FREQUENCIA:
            linha = f"• {l['disciplina']}: frequência {_valor(l['frequencia_pct'], '%')}"
            if l["frequencia_minima_pct"] is not None:
                linha += f" (mínimo {_valor(l['frequencia_minima_pct'], '%')})"
        elif intencao == it.SITUACAO:
            linha = f"• {l['disciplina']}: {_situacao_texto(l['situacao'])}"
        else:
            linha = (f"• {l['disciplina']}: VA1 {_valor(l['va1'])}, VA2 {_valor(l['va2'])}, "
                     f"VA3 {_valor(l['va3'])}, nota final {_valor(l['nota_final'])}"
                     f" ({_situacao_texto(l['situacao'])})")
            if intencao == it.RESUMO_ACADEMICO:
                linha += f", frequência {_valor(l['frequencia_pct'], '%')}"
        detalhes.append(linha)

    r.detalhes = "\n".join(detalhes)
    reprovadas = sum(1 for d in r.dados if str(d["situacao"]).lower().startswith("reprov"))
    abaixo = sum(1 for d in r.dados if d["abaixo_frequencia_minima"])
    r.valores = {"QTD_DISCIPLINAS": str(len(linhas)), "QTD_REPROVADAS": str(reprovadas),
                 "QTD_ABAIXO_MINIMO": str(abaixo)}
    r.sinais = {"tem_reprovacao_registrada": reprovadas > 0, "tem_frequencia_abaixo_do_minimo": abaixo > 0,
                "consulta_de_uma_disciplina": bool(filtro)}

    if intencao == it.FREQUENCIA:
        abertura = "Esta é a sua frequência registrada"
        if abaixo:
            fecho = ("Atenção: em [[QTD_ABAIXO_MINIMO]] disciplina(s) a frequência está abaixo do mínimo exigido. "
                     "Vale conversar com o professor ou com a coordenação o quanto antes.")
        else:
            fecho = "Todas estão dentro do mínimo exigido. Continue acompanhando por aqui!"
    elif intencao == it.SITUACAO:
        abertura = "Esta é a situação registrada nas suas disciplinas"
        fecho = ("Em [[QTD_REPROVADAS]] disciplina(s) a situação registrada é de reprovação. Se quiser, o núcleo "
                 "de apoio pode ajudar a montar um plano de estudos." if reprovadas else
                 "Nenhuma reprovação registrada. Bom trabalho!")
    else:
        abertura = "Estas são as suas notas registradas" if intencao != it.RESUMO_ACADEMICO else \
            "Este é o resumo do seu desempenho registrado"
        fecho = (f"As notas das disciplinas estão na escala de {ESCALA_NOTAS_DISCIPLINA}, como estão no sistema "
                 "acadêmico.")
        if reprovadas:
            fecho += (" Em [[QTD_REPROVADAS]] disciplina(s) a situação é de reprovação; o núcleo de apoio pode "
                      "ajudar a montar um plano de estudos.")
    periodo = f" no período {r.referencia}" if r.referencia else ""
    r.rascunho = f"{abertura}{periodo}:\n[[DETALHES]]\n{fecho}"
    return r


def _intencao_indicadores(intencao: str, conexao_chat: Connection, id_aluno: str) -> Resultado:
    ind = conexao_chat.execute(sql.INDICADORES_DO_ALUNO, {"id_aluno": id_aluno}).mappings().first()
    r = Resultado(intencao=intencao, rascunho="", consulta="INDICADORES_DO_ALUNO",
                  registros=0 if ind is None else 1, atalho=ATALHOS[intencao], opcoes=OPCOES_ALUNO)
    if ind is None:
        r.rascunho = "Ainda não há indicadores registrados para você no sistema."
        return r
    r.referencia = ind["periodo_letivo"]
    r.pode_humanizar = True
    r.dados = [{k: (numero_br(v) if k != "periodo_letivo" else v) for k, v in dict(ind).items()}]

    if intencao == it.MEDIA:
        tendencia = ind["tendencia_media"]
        r.valores = {"MEDIA_ATUAL": _valor(ind["media_atual"]),
                     "MEDIA_ANTERIOR": _valor(ind["media_semestre_anterior"])}
        if tendencia is None:
            sentido = "estavel_ou_sem_dado"
            fecho = ""
        elif float(tendencia) > 0:
            sentido, fecho = "subiu", " Sua média subiu em relação ao semestre anterior. Que bom!"
        elif float(tendencia) < 0:
            sentido, fecho = "caiu", (" Sua média caiu em relação ao semestre anterior; o núcleo de apoio "
                                      "pode ajudar a entender o que mudou.")
        else:
            sentido, fecho = "estavel_ou_sem_dado", " Sua média ficou igual à do semestre anterior."
        r.sinais = {"tendencia_da_media": sentido}
        r.rascunho = (f"No período {r.referencia}, sua média atual é [[MEDIA_ATUAL]] e a do semestre anterior "
                      f"foi [[MEDIA_ANTERIOR]] (escala de {ESCALA_MEDIA_GERAL}).{fecho}")
    else:  # PENDENCIAS
        r.valores = {"PENDENTES": _valor(ind["atividades_pendentes"])}
        pendentes = ind["atividades_pendentes"]
        r.sinais = {"tem_pendencias": bool(pendentes)}
        r.rascunho = (f"No período {r.referencia}, você tem [[PENDENTES]] atividade(s) pendente(s) registrada(s)."
                      + (" Que tal organizar um horário para colocá-las em dia?" if pendentes else
                         " Tudo em dia!"))
    return r


def _intencao_frequencia(conexao_chat: Connection, id_aluno: str, pergunta: str) -> Resultado:
    r = _intencao_disciplinas(it.FREQUENCIA, conexao_chat, id_aluno, pergunta)
    if r.filtros or not r.dados:
        return r
    ind = conexao_chat.execute(sql.INDICADORES_DO_ALUNO, {"id_aluno": id_aluno}).mappings().first()
    if ind is not None:
        r.consulta = "DISCIPLINAS_DO_ALUNO, INDICADORES_DO_ALUNO"
        r.valores["FREQ_GERAL"] = _valor(ind["frequencia_pct"], "%")
        r.valores["FALTAS_TOTAL"] = _valor(ind["faltas_total"])
        r.rascunho = r.rascunho.replace(
            ":\n[[DETALHES]]", ". No geral, sua frequência é [[FREQ_GERAL]], com [[FALTAS_TOTAL]] falta(s):\n[[DETALHES]]", 1)
        r.rascunho += (" O número de faltas que ainda restam não aparece porque o sistema não tem o total de aulas "
                       "previstas.")
    return r


def _intencao_meu_risco(conexao_chat: Connection, id_aluno: str) -> Resultado:
    linha = conexao_chat.execute(sql.RISCO_DO_ALUNO, {"id_aluno": id_aluno}).mappings().first()
    r = Resultado(intencao=it.MEU_RISCO, rascunho="", consulta="RISCO_DO_ALUNO",
                  registros=0 if linha is None else 1, atalho=ATALHOS[it.MEU_RISCO], opcoes=OPCOES_ALUNO)
    if linha is None or linha["nivel_risco"] is None:
        r.rascunho = "Ainda não há avaliação de risco registrada para você."
        return r
    nivel = linha["nivel_risco"]
    r.referencia = data_br(linha["data_avaliacao"])
    r.dados = [{"nivel": NIVEL_DO_BANCO.get(nivel, nivel), "data_avaliacao": r.referencia,
                "periodo_letivo": linha["periodo_letivo"]}]
    r.valores = {"NIVEL": nivel, "DATA": r.referencia or "data não registrada"}
    r.sinais = {"nivel_alto_ou_critico": nivel in (NIVEL_ALTO, NIVEL_CRITICO)}
    r.pode_humanizar = True
    apoio = (" A equipe pedagógica já acompanha casos assim e pode entrar em contato para ajudar."
             if nivel in (NIVEL_ALTO, NIVEL_CRITICO) else "")
    r.rascunho = (f"Na avaliação de [[DATA]], seu nível de risco ficou [[NIVEL]].{apoio} Os fatores que mais "
                  "pesaram aparecem no painel.")
    r.rodape = AVISO_METODOLOGICO
    return r


# ---------------------------------------------------------------------------
# Intencoes da equipe
# ---------------------------------------------------------------------------

def _escopo_equipe(usuario: Usuario) -> tuple[str, dict] | None:
    if usuario.perfil == DOCENTE and usuario.id_professor:
        return "DOCENTE", {"id_professor": usuario.id_professor}
    if usuario.perfil in (COORDENACAO, NUCLEO_APOIO) and usuario.id_curso:
        return "CURSO", {"id_curso": usuario.id_curso}
    return None


def _intencao_resumo_risco(conexao_chat: Connection, usuario: Usuario) -> Resultado:
    escopo = _escopo_equipe(usuario)
    if escopo is None:
        return _sem_permissao(it.RESUMO_RISCO, "Seu usuário não está vinculado a turmas ou a um curso.")
    tipo, params = escopo
    consulta = sql.RESUMO_RISCO_DOCENTE if tipo == "DOCENTE" else sql.RESUMO_RISCO_CURSO
    linhas = _linhas(conexao_chat, consulta, params)
    if usuario.perfil == NUCLEO_APOIO:  # o nucleo ve so alunos com alerta (Anexo E)
        linhas = [l for l in linhas if l["nivel_risco"] in (NIVEL_CRITICO, NIVEL_ALTO)]
    por_nivel = {l["nivel_risco"]: int(l["total"]) for l in linhas if l["nivel_risco"]}
    r = Resultado(intencao=it.RESUMO_RISCO, rascunho="", registros=sum(por_nivel.values()),
                  consulta="RESUMO_RISCO_DOCENTE" if tipo == "DOCENTE" else "RESUMO_RISCO_CURSO",
                  filtros={"escopo": "suas turmas" if tipo == "DOCENTE" else "seu curso"},
                  atalho=ATALHOS[it.RESUMO_RISCO], opcoes=OPCOES_EQUIPE)
    if not por_nivel:
        r.rascunho = "Não há avaliações de risco registradas no seu escopo."
        return r
    r.dados = [{"nivel": NIVEL_DO_BANCO.get(n, n), "total": por_nivel[n]} for n in NIVEIS_ORDEM if n in por_nivel]
    r.detalhes = "\n".join(f"• {n}: {por_nivel[n]} aluno(s)" for n in NIVEIS_ORDEM if n in por_nivel)
    r.valores = {"TOTAL": str(r.registros)}
    r.sinais = {"ha_alunos_criticos": NIVEL_CRITICO in por_nivel}
    r.pode_humanizar = True
    r.rascunho = (f"Distribuição pela última avaliação de cada aluno em {r.filtros['escopo']} "
                  "([[TOTAL]] aluno(s) considerados):\n[[DETALHES]]")
    r.rodape = AVISO_METODOLOGICO
    return r


def _intencao_maior_risco(conexao_chat: Connection, usuario: Usuario, intencao: str) -> Resultado:
    escopo = _escopo_equipe(usuario)
    if escopo is None:
        return _sem_permissao(intencao, "Seu usuário não está vinculado a turmas ou a um curso.")
    tipo, params = escopo
    consulta = sql.MAIOR_RISCO_DOCENTE if tipo == "DOCENTE" else sql.MAIOR_RISCO_CURSO
    linhas = _linhas(conexao_chat, consulta, {**params, "critico": NIVEL_CRITICO, "alto": NIVEL_ALTO,
                                              "limite": sql.LIMITE_LISTA_RISCO})
    r = Resultado(intencao=intencao, rascunho="", registros=len(linhas),
                  consulta="MAIOR_RISCO_DOCENTE" if tipo == "DOCENTE" else "MAIOR_RISCO_CURSO",
                  filtros={"escopo": "suas turmas" if tipo == "DOCENTE" else "seu curso",
                           "nivel": ["CRITICO", "ALTO"], "limite": sql.LIMITE_LISTA_RISCO},
                  atalho=ATALHOS[it.MAIOR_RISCO], opcoes=OPCOES_EQUIPE)
    prefixo = ""
    if intencao == it.PREVISAO_INDIVIDUAL:
        prefixo = ("O sistema não prevê quem vai desistir: ele aponta padrões de indicadores parecidos com os "
                   "que costumam anteceder a evasão. Com essa ressalva, estes são os alunos de maior risco atual. ")
    if not linhas:
        r.rascunho = prefixo + f"Não há alunos com risco Alto ou Crítico em {r.filtros['escopo']}."
        return r
    r.referencia = data_br(max(str(l["data_avaliacao"]) for l in linhas))
    r.dados = [{"matricula": l["id_aluno"], "nome": l["nome_ficticio"], "semestre": l["semestre_atual"],
                "nivel": NIVEL_DO_BANCO.get(l["nivel_risco"], l["nivel_risco"]),
                "data_avaliacao": data_br(l["data_avaliacao"])} for l in linhas]
    r.detalhes = "\n".join(f"• {l['nome_ficticio']} ({l['id_aluno']}), semestre {_valor(l['semestre_atual'])}: "
                           f"{l['nivel_risco']}" for l in linhas)
    r.valores = {"QTD": str(len(linhas))}
    r.pode_humanizar = True
    r.rascunho = (prefixo + f"Alunos com risco Crítico ou Alto em {r.filtros['escopo']}, Crítico primeiro "
                  f"(até {sql.LIMITE_LISTA_RISCO}, [[QTD]] encontrado(s)):\n[[DETALHES]]")
    r.rodape = AVISO_METODOLOGICO
    return r


def _intencao_aluno_especifico(request: Request, conexao_api: Connection, conexao_chat: Connection,
                               usuario: Usuario, matricula: str) -> Resultado:
    try:
        verificar_escopo_aluno(request, conexao_api, usuario, matricula, "CHAT_LER_ALUNO")
    except HTTPException:
        r = _sem_permissao(it.ALUNO_ESPECIFICO, "Você não tem permissão para acessar os dados deste aluno, "
                                                "ou ele não existe.")
        r.id_aluno_alvo = matricula
        return r
    risco = conexao_chat.execute(sql.RISCO_DO_ALUNO, {"id_aluno": matricula}).mappings().first()
    ind = conexao_chat.execute(sql.INDICADORES_DO_ALUNO, {"id_aluno": matricula}).mappings().first()
    r = Resultado(intencao=it.ALUNO_ESPECIFICO, rascunho="", consulta="RISCO_DO_ALUNO, INDICADORES_DO_ALUNO",
                  registros=int(risco is not None) + int(ind is not None), id_aluno_alvo=matricula,
                  atalho=ATALHOS[it.ALUNO_ESPECIFICO].format(matricula=matricula), opcoes=OPCOES_EQUIPE,
                  filtros={"matricula": matricula})
    if risco is None and ind is None:
        r.rascunho = "Não há indicadores nem avaliação de risco registrados para este aluno."
        return r
    nome = risco["nome_ficticio"] if risco else matricula
    partes = []
    if risco is not None and risco["nivel_risco"]:
        r.valores["NIVEL"] = risco["nivel_risco"]
        r.valores["DATA"] = data_br(risco["data_avaliacao"]) or "data não registrada"
        r.referencia = r.valores["DATA"]
        partes.append("• Nível de risco: [[NIVEL]] (avaliação de [[DATA]])")
    if ind is not None:
        r.valores.update({"FREQ": _valor(ind["frequencia_pct"], "%"), "FALTAS": _valor(ind["faltas_total"]),
                          "MEDIA": _valor(ind["media_atual"]), "PENDENTES": _valor(ind["atividades_pendentes"])})
        partes.append(f"• Período {ind['periodo_letivo']}: frequência [[FREQ]], [[FALTAS]] falta(s), média "
                      f"[[MEDIA]] (escala de {ESCALA_MEDIA_GERAL}), [[PENDENTES]] atividade(s) pendente(s)")
    r.valores["ALUNO"] = f"{nome} ({matricula})"
    r.dados = [{"matricula": matricula, "nome": nome,
                "nivel": NIVEL_DO_BANCO.get(risco["nivel_risco"], risco["nivel_risco"]) if risco else None,
                "indicadores": None if ind is None else
                {k: (numero_br(v) if k != "periodo_letivo" else v) for k, v in dict(ind).items()}}]
    r.sinais = {"nivel_alto_ou_critico": bool(risco and risco["nivel_risco"] in (NIVEL_ALTO, NIVEL_CRITICO))}
    r.pode_humanizar = True
    r.rascunho = "Situação registrada de [[ALUNO]]:\n" + "\n".join(partes)
    r.rodape = AVISO_METODOLOGICO
    return r


# ---------------------------------------------------------------------------
# Ponto de entrada
# ---------------------------------------------------------------------------

def executar(intencao: str, matriculas: list[str], pergunta: str, usuario: Usuario, request: Request,
             conexao_api: Connection, conexao_chat: Connection) -> Resultado:
    fixo = _fixo(intencao, usuario)
    if fixo is not None:
        return fixo

    if usuario.perfil == ALUNO:
        id_aluno = usuario.id_aluno
        if not id_aluno:
            return _sem_permissao(intencao, "Seu usuário não está vinculado a uma matrícula.")
        if intencao == it.PREVISAO_INDIVIDUAL:
            return Resultado(intencao=intencao, opcoes=OPCOES_ALUNO, rascunho=(
                "O sistema não prevê o futuro de ninguém. Ele só compara indicadores, como frequência e notas, "
                "com padrões que costumam anteceder a evasão. Posso mostrar o seu nível de risco atual."))
        if intencao in (it.NOTAS, it.SITUACAO, it.RESUMO_ACADEMICO):
            return _intencao_disciplinas(intencao, conexao_chat, id_aluno, pergunta)
        if intencao == it.FREQUENCIA:
            return _intencao_frequencia(conexao_chat, id_aluno, pergunta)
        if intencao in (it.MEDIA, it.PENDENCIAS):
            return _intencao_indicadores(intencao, conexao_chat, id_aluno)
        if intencao == it.MEU_RISCO:
            return _intencao_meu_risco(conexao_chat, id_aluno)
        return _fixo(it.NAO_ENTENDI, usuario)

    if usuario.perfil in PERFIS_EQUIPE:
        if intencao == it.ALUNO_ESPECIFICO and matriculas:
            return _intencao_aluno_especifico(request, conexao_api, conexao_chat, usuario, matriculas[0])
        if intencao == it.RESUMO_RISCO:
            return _intencao_resumo_risco(conexao_chat, usuario)
        if intencao in (it.MAIOR_RISCO, it.PREVISAO_INDIVIDUAL):
            return _intencao_maior_risco(conexao_chat, usuario, intencao)
        if intencao in it.INTENCOES_DE_ALUNO:
            return Resultado(intencao=intencao, opcoes=OPCOES_EQUIPE, rascunho=(
                "Para ver a situação de um aluno, informe a matrícula dele na pergunta."))
        return _fixo(it.NAO_ENTENDI, usuario)

    return _sem_permissao(intencao, "Seu perfil não consulta dados de alunos pelo chat. Use os relatórios "
                                    "agregados do painel.")
