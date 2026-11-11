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
from app.api.permissoes import (ALUNO, COORDENACAO, DOCENTE, NUCLEO_APOIO, verificar_escopo_aluno)
from app.api.visibilidade import principais_visiveis
from app.calculo.score import ROTULOS as ROTULOS_FATOR
from app.chatbot import consultas_chat as sql
from app.chatbot import intencoes as it
from app.chatbot.filtros import CAMPOS, descrever, interpretar
from app.chatbot.config_chat import obter_configuracao_chat
from datetime import date, timedelta

from app.chatbot.texto import data_br, normalizar, numero_br

# A visao vw_chat_risco_atual entrega o nivel no rotulo do B1 ("Crítico");
# o JSON do chat devolve o codigo do SRS (CRITICO).
NIVEL_DO_BANCO = {"Baixo": "BAIXO", "Moderado": "MODERADO", "Alto": "ALTO", "Crítico": "CRITICO"}

# Auditoria 4.5-D: desde sql/b1_correcoes.sql, notas das disciplinas e medias
# estao na mesma escala, de 0 a 10. O chatbot mostra o valor como esta no
# banco e diz a escala.
ESCALA_NOTAS_DISCIPLINA = "0 a 10"
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

OPCOES_ALUNO = ["Minhas notas", "Minha frequência", "O que vence esta semana?", "Meu nível de risco",
                "Falar com uma pessoa"]
OPCOES_EQUIPE = ["Resumo de risco", "Alunos de maior risco", "Alunos com frequência abaixo de 70%",
                 "Como o risco é calculado"]
OPCOES_NAE = ["Resumo de risco", "Alunos de maior risco", "Alunos a mais de 20 km com frequência abaixo de 70%",
              "Como o risco é calculado"]

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
    livre: bool = False  # conversa sem dado (saudacao, ajuda, duvida geral): a IA escreve do zero
    id_aluno_alvo: str | None = None


# ---------------------------------------------------------------------------
# Textos fixos: recusas e respostas informativas nao passam pela IA.
# ---------------------------------------------------------------------------

def _janela() -> str:
    return obter_configuracao_chat().chat_janela_atendimento


def texto_abertura(perfil: str = ALUNO) -> str:
    oferta = ("Posso mostrar suas notas, sua frequência, o que vence nos próximos dias e seu nível de risco, "
              "sempre com os dados registrados no sistema." if perfil == ALUNO else
              "Posso buscar alunos combinando frequência, média, faltas e pendências, resumir o risco das suas "
              "turmas e mostrar a situação de um aluno pela matrícula, sempre dentro do que o seu perfil pode ver.")
    return ("Oi! Eu sou a Mufa, a assistente do MUFASA. " + oferta + "\n\nEstou disponível 24 horas; "
            f"o atendimento com uma pessoa da equipe acontece {_janela()}.\n\n"
            "Por segurança, não escreva aqui senha, CPF nem informações de saúde.")


def _fixo(intencao: str, usuario: Usuario) -> Resultado | None:
    e_aluno = usuario.perfil == ALUNO
    opcoes = OPCOES_ALUNO if e_aluno else OPCOES_NAE if usuario.perfil == NUCLEO_APOIO else OPCOES_EQUIPE
    textos = {
        it.BURLA: ("Não posso fazer isso. Sigo sempre as mesmas regras de segurança e só mostro os dados "
                   "que o seu perfil pode ver. Esta tentativa ficou registrada.\n\nPosso ajudar com suas notas, "
                   "frequência ou nível de risco?"),
        it.ALTERACAO: ("Eu só consulto informações; não altero notas, faltas nem cadastro. Para pedir uma "
                       "correção, procure a secretaria acadêmica.\n\nSe for um dado pessoal seu, você também pode "
                       "pedir a correção pela página de Privacidade do painel."),
        it.OUTRO_ALUNO: ("Não tenho permissão para mostrar informações de outros estudantes. "
                         "Posso mostrar as suas, se quiser."),
        it.JUIZO: ("Não faço julgamento sobre pessoas. O sistema só descreve indicadores, como notas e "
                   "frequência, e não diz nada sobre esforço ou capacidade de ninguém."),
        it.METODOLOGIA: ("O nível de risco é calculado a partir de indicadores registrados, como frequência, "
                         "notas e alguns fatores de contexto, cada um com um peso definido pela equipe. "
                         "Fatores sem dado ficam fora da conta, em vez de serem preenchidos.\n\n" + AVISO_METODOLOGICO),
        it.ATENDIMENTO: ("Posso registrar sua dúvida aqui a qualquer hora, mas o atendimento com uma pessoa da "
                         f"equipe acontece {_janela()}.\n\nSe você estiver passando por um momento difícil, "
                         "procure o núcleo de apoio da universidade. Ninguém precisa passar por isso sem apoio.\n\nEm caso de emergência, ligue para o CVV "
                         "no 188 (24 horas, gratuito) ou para o SAMU no 192."),
        it.PRIVACIDADE: ("Na página de Privacidade do painel você vê todos os dados que o MUFASA guarda sobre "
                         "você, pode exportá-los e pode pedir correção, eliminação ou revisão de uma decisão "
                         "automatizada (LGPD, arts. 18 e 20).\n\nA resposta chega em até 15 dias."),
        it.ACESSO: ("Por segurança, nunca digite sua senha no chat.\n\nSe esqueceu a senha ou o acesso foi "
                    "bloqueado após tentativas erradas, aguarde 15 minutos ou procure a secretaria "
                    "acadêmica para redefinir."),
        it.SAUDACAO: texto_abertura(usuario.perfil),
        it.AGRADECIMENTO: "Por nada! Se precisar de mais alguma coisa, é só chamar.",
        it.AJUDA: ("Você pode me perguntar, por exemplo:\n\n• \"Quais são minhas notas?\"\n"
                   "• \"Como está minha frequência em Cálculo I?\"\n• \"Qual é meu nível de risco?\"" if e_aluno else
                   "Você pode me perguntar, por exemplo:\n\n• \"Quantos alunos estão em risco alto?\"\n"
                   "• \"Quais alunos têm maior risco?\"\n• A situação de um aluno, informando a matrícula"),
        it.ESTUDOS: ("Boa pergunta! Algumas ideias que costumam ajudar:\n\n"
                     "• Estude em blocos curtos, com pausas, em vez de uma maratona na véspera\n"
                     "• Comece pelo conteúdo que mais pede atenção, quando a cabeça está descansada\n"
                     "• Refaça exercícios sem olhar a resposta e anote onde travou\n"
                     "• Leve as dúvidas para o professor ou para a monitoria antes da prova\n\n"
                     "Se quiser, posso mostrar suas notas para ver por onde começar."),
        it.FORA_DO_ESCOPO: ("Esse assunto foge um pouco do que eu sei fazer.\n\nEu ajudo com notas, "
                            "frequência, risco e com o uso do MUFASA. Quer tentar uma dessas?"),
        it.NAO_ENTENDI: ("Desculpe, não entendi bem a pergunta.\n\nVocê pode escrever de outro jeito ou escolher uma das "
                        "sugestões abaixo."),
    }
    if intencao not in textos:
        return None
    r = Resultado(intencao=intencao, rascunho=textos[intencao], opcoes=opcoes)
    # Conversa livre: com a IA ligada, ela responde do proprio jeito; o texto acima e o plano B.
    r.livre = intencao in it.INTENCOES_DE_CONVERSA
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


def _perfil_aluno(conexao_chat: Connection, id_aluno: str) -> dict | None:
    linha = conexao_chat.execute(sql.PERFIL_DO_ALUNO, {"id_aluno": id_aluno}).mappings().first()
    return None if linha is None else dict(linha)


def _primeiro_nome(perfil: dict | None) -> str | None:
    nome = (perfil or {}).get("nome_ficticio") or ""
    return nome.split()[0] if nome.strip() else None


def _com_nome(r: Resultado, perfil: dict | None, frase_com_nome: str, frase_sem_nome: str) -> str:
    """O nome entra como marcador: a IA nunca ve o nome, o servidor coloca depois."""
    nome = _primeiro_nome(perfil)
    if nome:
        r.valores["NOME"] = nome
        return frase_com_nome
    return frase_sem_nome


def _pl(n: int, singular: str, plural: str) -> str:
    return singular if n == 1 else plural


def _lista_pt(itens: list[str]) -> str:
    return itens[0] if len(itens) == 1 else ", ".join(itens[:-1]) + " e " + itens[-1]


def _nomes_fatores(fatores) -> list[str]:
    import json
    if isinstance(fatores, str):
        fatores = json.loads(fatores)
    return [ROTULOS_FATOR.get(f, f) for f in (fatores or [])]


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
            linha = f"• {l['disciplina']}: {_valor(l['frequencia_pct'], '%')} de presença"
            if l["frequencia_minima_pct"] is not None:
                linha += f"\n  mínimo {_valor(l['frequencia_minima_pct'], '%')}"
                if item["abaixo_frequencia_minima"]:
                    linha += " · abaixo do mínimo"
        elif intencao == it.SITUACAO:
            linha = f"• {l['disciplina']}: {_situacao_texto(l['situacao'])}"
        else:
            linha = (f"• {l['disciplina']}: nota final {_valor(l['nota_final'])} · {_situacao_texto(l['situacao'])}"
                     f"\n  VA1 {_valor(l['va1'])} · VA2 {_valor(l['va2'])} · VA3 {_valor(l['va3'])}")
            if intencao == it.RESUMO_ACADEMICO:
                linha += f" · frequência {_valor(l['frequencia_pct'], '%')}"
        detalhes.append(linha)

    r.detalhes = "\n".join(detalhes)
    reprovadas = sum(1 for d in r.dados if str(d["situacao"]).lower().startswith("reprov"))
    abaixo = sum(1 for d in r.dados if d["abaixo_frequencia_minima"])
    r.valores = {"QTD_DISCIPLINAS": str(len(linhas)), "QTD_REPROVADAS": str(reprovadas),
                 "QTD_ABAIXO_MINIMO": str(abaixo)}
    r.sinais = {"tem_reprovacao_registrada": reprovadas > 0, "tem_frequencia_abaixo_do_minimo": abaixo > 0,
                "consulta_de_uma_disciplina": bool(filtro)}

    perfil = _perfil_aluno(conexao_chat, id_aluno)
    if intencao == it.FREQUENCIA:
        abertura = _com_nome(r, perfil, "Claro, [[NOME]]! Esta é a sua frequência", "Claro! Esta é a sua frequência")
        if abaixo:
            nomes = [d["disciplina"] for d in r.dados if d["abaixo_frequencia_minima"]]
            r.valores["ABAIXO"] = _lista_pt(nomes)
            fecho = ("Fique de olho em [[ABAIXO]]: ali a presença está abaixo do mínimo exigido. Vale conversar "
                     "com o professor ou com a coordenação o quanto antes, para ver o que ainda dá para fazer.")
        else:
            fecho = "Tudo dentro do mínimo exigido. Continue assim!"
    elif intencao == it.SITUACAO:
        abertura = _com_nome(r, perfil, "Claro, [[NOME]]! Esta é a situação das suas disciplinas",
                             "Claro! Esta é a situação das suas disciplinas")
        fecho = (f"Em [[QTD_REPROVADAS]] {_pl(reprovadas, 'disciplina', 'disciplinas')} a situação ficou como reprovação. Se quiser, o núcleo de "
                 "apoio pode te ajudar a montar um plano de estudos." if reprovadas else
                 "Nenhuma reprovação registrada. Bom trabalho!")
    else:
        abertura = (_com_nome(r, perfil, "Claro, [[NOME]]! Estas são as suas notas", "Claro! Estas são as suas notas")
                    if intencao != it.RESUMO_ACADEMICO else
                    _com_nome(r, perfil, "Claro, [[NOME]]! Este é o resumo do seu desempenho",
                              "Claro! Este é o resumo do seu desempenho"))
        fecho = ""
        com_nota = [d for d, l in zip(r.dados, linhas) if l["nota_final"] is not None]
        if len(com_nota) >= 2 and not filtro:
            notas = {d["disciplina"]: float(l["nota_final"]) for d, l in zip(r.dados, linhas)
                     if l["nota_final"] is not None}
            melhor, pior = max(notas, key=notas.get), min(notas, key=notas.get)
            if notas[melhor] != notas[pior]:
                r.valores.update({"MELHOR": melhor, "PIOR": pior})
                r.sinais["tem_melhor_e_pior_disciplina"] = True
                fecho = ("Seu melhor resultado está em [[MELHOR]], e a disciplina que mais pede atenção agora é "
                         "[[PIOR]].\n\n")
        if (not filtro and perfil and perfil.get("media_atual") is not None
                and perfil.get("media_semestre_anterior") is not None):
            atual, anterior = float(perfil["media_atual"]), float(perfil["media_semestre_anterior"])
            r.valores.update({"MEDIA_ATUAL": _valor(perfil["media_atual"]),
                              "MEDIA_ANTERIOR": _valor(perfil["media_semestre_anterior"])})
            comparacao = "acima" if atual > anterior else "abaixo" if atual < anterior else "igual"
            r.sinais["media_geral_em_relacao_ao_semestre_anterior"] = comparacao
            fecho += ("Sua média geral está em [[MEDIA_ATUAL]], " +
                      ("igual à do semestre anterior." if comparacao == "igual" else
                       f"{comparacao} do semestre anterior ([[MEDIA_ANTERIOR]]).") + " ")
        fecho += f"As notas vão de {ESCALA_NOTAS_DISCIPLINA}, exatamente como estão no sistema acadêmico."
        if reprovadas:
            fecho += (f"\n\nEm [[QTD_REPROVADAS]] {_pl(reprovadas, 'disciplina', 'disciplinas')} a situação ficou como reprovação. Se quiser, o "
                      "núcleo de apoio pode te ajudar a montar um plano de estudos.")
    if filtro:  # "e em Calculo II?": a abertura diz de qual disciplina se trata
        r.valores["DISCIPLINAS"] = _lista_pt(filtro)
        abertura = (abertura.replace("Estas são as suas notas", "Estas são as suas notas de [[DISCIPLINAS]]")
                    .replace("Esta é a sua frequência", "Esta é a sua frequência em [[DISCIPLINAS]]")
                    .replace("Esta é a situação das suas disciplinas", "Esta é a sua situação em [[DISCIPLINAS]]"))
    periodo = f" em {r.referencia}" if r.referencia else ""
    r.rascunho = f"{abertura}{periodo}:\n\n[[DETALHES]]\n\n{fecho}"
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
            sentido, fecho = "subiu", "\n\nSua média subiu em relação ao semestre anterior. Que bom!"
        elif float(tendencia) < 0:
            sentido, fecho = "caiu", ("\n\nSua média caiu um pouco em relação ao semestre anterior. Se quiser "
                                      "entender o que mudou, o núcleo de apoio pode ajudar.")
        else:
            sentido, fecho = "estavel_ou_sem_dado", "\n\nSua média ficou igual à do semestre anterior."
        r.sinais = {"tendencia_da_media": sentido}
        abertura = _com_nome(r, _perfil_aluno(conexao_chat, id_aluno), "[[NOME]], sua", "Sua")
        r.rascunho = (f"{abertura} média atual em {r.referencia} é [[MEDIA_ATUAL]]. No semestre anterior, ela foi "
                      f"[[MEDIA_ANTERIOR]].{fecho}\n\nAs médias vão de {ESCALA_MEDIA_GERAL}.")
    else:  # PENDENCIAS
        r.valores = {"PENDENTES": _valor(ind["atividades_pendentes"])}
        pendentes = ind["atividades_pendentes"]
        r.sinais = {"tem_pendencias": bool(pendentes)}
        r.rascunho = (f"Em {r.referencia}, você tem [[PENDENTES]] {_pl(pendentes or 0, 'atividade pendente', 'atividades pendentes')}.\n\n"
                      + ("Que tal separar um horário na semana para colocá-las em dia? Se precisar, o núcleo de "
                         "apoio pode ajudar a organizar a rotina." if pendentes else
                         "Tudo em dia por aqui. Continue assim!"))
    return r


def _quando(prazo: date, hoje: date) -> str:
    dias = (prazo - hoje).days
    if dias < -1:
        return f"atrasada desde {data_br(prazo)}"
    if dias == -1:
        return "venceu ontem"
    if dias == 0:
        return "vence hoje"
    if dias == 1:
        return "vence amanhã"
    if dias <= 6:
        return f"vence em {dias} dias ({data_br(prazo)})"
    return f"vence em {data_br(prazo)}"


def _intencao_atividades(conexao_chat: Connection, id_aluno: str, pergunta: str,
                         hoje: date | None = None) -> Resultado:
    hoje = hoje or date.today()
    linhas = _linhas(conexao_chat, sql.ATIVIDADES_PENDENTES_DO_ALUNO, {"id_aluno": id_aluno, "limite": sql.LIMITE_LINHAS})
    r = Resultado(intencao=it.PENDENCIAS, rascunho="", consulta="ATIVIDADES_PENDENTES_DO_ALUNO", registros=len(linhas),
                  atalho=ATALHOS[it.PENDENCIAS], opcoes=OPCOES_ALUNO, pode_humanizar=True)
    perfil = _perfil_aluno(conexao_chat, id_aluno)
    t = normalizar(pergunta)
    if "hoje" in t.split() or "amanha" in t.split():
        janela, recorte = 1, "até amanhã"
    elif "semana" in t:
        janela, recorte = 6, "nesta semana"
    elif "mes" in t.split():
        janela, recorte = 30, "neste mês"
    else:
        janela, recorte = None, ""
    so_atrasadas = "atrasad" in t

    atrasadas = [l for l in linhas if l["prazo_em"] < hoje]
    proximas = [l for l in linhas if l["prazo_em"] >= hoje and (janela is None or (l["prazo_em"] - hoje).days <= janela)]
    depois = [l for l in linhas if l["prazo_em"] >= hoje and l not in proximas]
    r.dados = [{"disciplina": l["disciplina"], "titulo": l["titulo"], "tipo": l["tipo"],
                "prazo_em": data_br(l["prazo_em"]), "atrasada": l["prazo_em"] < hoje} for l in linhas]
    r.valores = {"QTD_PENDENTES": str(len(linhas)), "QTD_ATRASADAS": str(len(atrasadas)),
                 "QTD_PROXIMAS": str(len(proximas))}
    r.sinais = {"tem_atrasadas": bool(atrasadas), "tem_vencendo_logo": bool(proximas),
                "pediu_so_atrasadas": so_atrasadas, "recorte_de_tempo": recorte or "todas"}
    r.filtros = {"recorte": recorte or "todas as pendentes"}

    if not linhas:
        r.rascunho = _com_nome(r, perfil, "Boa notícia, [[NOME]]: ", "Boa notícia: ") + \
            "você não tem nenhuma atividade pendente no momento. Tudo em dia!"
        return r

    def item(l):
        return f"• {l['titulo']}: {_quando(l['prazo_em'], hoje)}\n  {l['disciplina']}"

    blocos, partes = [], []
    if atrasadas:
        blocos.append("\n".join(item(l) for l in atrasadas))
    mostrar = [] if so_atrasadas and atrasadas else proximas
    if mostrar:
        blocos.append("\n".join(item(l) for l in mostrar))
    r.detalhes = "\n\n".join(blocos)

    abertura = (_com_nome(r, perfil, "[[NOME]], você", "Você") + " tem [[QTD_PENDENTES]] "
                + _pl(len(linhas), "atividade", "atividades") + " para entregar.")
    if so_atrasadas and not atrasadas:
        partes.append("nenhuma está atrasada, que ótimo")
    if atrasadas:
        partes.append("[[QTD_ATRASADAS]] " + _pl(len(atrasadas), "já passou do prazo, então vale começar por ela",
                                                 "já passaram do prazo, então vale começar por elas"))
    if not so_atrasadas:
        if proximas and recorte and len(proximas) == len(linhas):
            partes.append(_pl(len(proximas), "ela vence ", "todas vencem ") + recorte)
        elif proximas:
            partes.append(f"[[QTD_PROXIMAS]] {_pl(len(proximas), 'vence', 'vencem')} {recorte}" if recorte else
                          ("a outra tem" if len(proximas) == 1 else "as outras têm") + " prazo nas próximas semanas"
                          if atrasadas else "nenhuma está atrasada")
        elif recorte:
            partes.append(f"nenhuma vence {recorte}")
    resumo = (" " + partes[0][0].upper() + partes[0][1:] + (", e " + partes[1] if len(partes) > 1 else "") + ".") \
        if partes else ""
    fecho = ("Se ajudar, separe um horário fixo na semana para cada uma. Quando o prazo apertar, conversar com o "
             "professor antes costuma abrir mais portas do que depois.")
    if depois and janela is not None and not so_atrasadas:
        r.valores["QTD_DEPOIS"] = str(len(depois))
        fecho = (f"Depois disso, {_pl(len(depois), 'ainda tem [[QTD_DEPOIS]] atividade', 'ainda tem [[QTD_DEPOIS]] atividades')} "
                 "com prazo mais para frente. " + fecho)
    if r.detalhes:
        r.rascunho = f"{abertura}{resumo}\n\n[[DETALHES]]\n\n{fecho}"
    else:
        r.rascunho = f"{abertura}{resumo}\n\n{fecho}"
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
            ":\n\n[[DETALHES]]", ". No geral, você está com [[FREQ_GERAL]] de presença e [[FALTAS_TOTAL]] "
            + _pl(ind["faltas_total"] or 0, "falta", "faltas") + ". Veja por disciplina:\n\n[[DETALHES]]", 1)
        r.rascunho += ("\n\nAinda não consigo dizer quantas faltas restam, porque o sistema não tem o total de "
                       "aulas previstas.")
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
    perfil = _perfil_aluno(conexao_chat, id_aluno)
    abertura = _com_nome(r, perfil, "[[NOME]], na sua", "Na sua")
    mudanca = ""
    anterior = (perfil or {}).get("nivel_anterior")
    if anterior and anterior != nivel:
        r.valores["NIVEL_ANTERIOR"] = anterior
        piorou = NIVEIS_ORDEM.index(nivel) < NIVEIS_ORDEM.index(anterior)
        r.sinais["nivel_em_relacao_a_avaliacao_anterior"] = "piorou" if piorou else "melhorou"
        mudanca = (" Na avaliação anterior ele estava [[NIVEL_ANTERIOR]]" +
                   (", então vale olhar com carinho o que mudou." if piorou else ". Que bom ver essa melhora!"))
    fatores = _nomes_fatores((perfil or {}).get("fatores_principais"))[:3]
    if fatores:
        r.valores["FATORES"] = _lista_pt(fatores)
        explicacao = ("Os pontos que mais pesaram foram [[FATORES]]. Na página Meus indicadores você vê a "
                      "explicação de cada um e o que pode ajudar.")
    else:
        explicacao = "Os fatores que mais pesaram aparecem na página Meus indicadores, com uma explicação de cada um."
    apoio = ("Isso não é um julgamento sobre você. É um sinal de que um apoio extra agora pode fazer "
             "diferença, e a equipe pedagógica acompanha esses casos para ajudar.\n\n"
             if nivel in (NIVEL_ALTO, NIVEL_CRITICO) else "")
    r.rascunho = (f"{abertura} última avaliação, feita em [[DATA]], o nível de risco ficou [[NIVEL]].{mudanca}\n\n"
                  f"{apoio}{explicacao}")
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
    r.detalhes = "\n".join(f"• {n}: {por_nivel[n]} {_pl(por_nivel[n], 'aluno', 'alunos')}" for n in NIVEIS_ORDEM
                           if n in por_nivel)
    r.valores = {"TOTAL": str(r.registros)}
    r.sinais = {"ha_alunos_criticos": NIVEL_CRITICO in por_nivel}
    r.pode_humanizar = True
    r.rascunho = (f"Este é o retrato de risco de {r.filtros['escopo']}, pela última avaliação de cada aluno "
                  f"([[TOTAL]] {_pl(r.registros, 'aluno', 'alunos')} no total):\n\n[[DETALHES]]")
    if NIVEL_CRITICO in por_nivel:
        r.rascunho += "\n\nOs casos críticos aparecem primeiro nos alertas do painel."
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
                   "que costumam anteceder a evasão. Com essa ressalva, estes são os alunos de maior risco atual.\n\n")
    if not linhas:
        r.rascunho = prefixo + f"Não há alunos com risco Alto ou Crítico em {r.filtros['escopo']}."
        return r
    r.referencia = data_br(max(str(l["data_avaliacao"]) for l in linhas))
    r.dados = [{"matricula": l["id_aluno"], "nome": l["nome_ficticio"], "semestre": l["semestre_atual"],
                "nivel": NIVEL_DO_BANCO.get(l["nivel_risco"], l["nivel_risco"]),
                "data_avaliacao": data_br(l["data_avaliacao"])} for l in linhas]
    r.detalhes = "\n".join(f"• {l['nome_ficticio']} ({l['id_aluno']}): {l['nivel_risco']}\n"
                           f"  semestre {_valor(l['semestre_atual'])}" for l in linhas)
    r.valores = {"QTD": str(len(linhas))}
    r.pode_humanizar = True
    r.rascunho = (prefixo + f"Encontrei [[QTD]] {_pl(len(linhas), 'aluno', 'alunos')} com risco Crítico ou Alto em {r.filtros['escopo']}, "
                  f"começando pelos críticos (mostro até {sql.LIMITE_LISTA_RISCO}):\n\n[[DETALHES]]\n\n"
                  "Para ver os detalhes e registrar uma ação, abra a ficha de cada aluno no painel.")
    r.rodape = AVISO_METODOLOGICO
    return r


def _intencao_busca(conexao_chat: Connection, usuario: Usuario, pergunta: str) -> Resultado:
    escopo = _escopo_equipe(usuario)
    opcoes = OPCOES_NAE if usuario.perfil == NUCLEO_APOIO else OPCOES_EQUIPE
    if escopo is None:
        return _sem_permissao(it.BUSCA_ALUNOS, "Seu usuário não está vinculado a turmas ou a um curso.")
    tipo, params = escopo
    busca = interpretar(pergunta)
    avisos = []
    # Distancia e dado socioeconomico: so o nucleo de apoio ve o valor (app/api/visibilidade.py).
    if any(f.campo == "distancia" for f in busca.filtros) and usuario.perfil != NUCLEO_APOIO:
        busca.filtros = [f for f in busca.filtros if f.campo != "distancia"]
        avisos.append("A distância de casa é um dado socioeconômico que só o núcleo de apoio consulta, por isso "
                      "deixei esse filtro de fora.")
    if busca.descartados:
        avisos.append("Ignorei o valor de " + _lista_pt(busca.descartados) + " porque ficou fora da escala "
                      "(frequência vai de 0 a 100% e média de 0 a 10).")
    niveis = list(busca.niveis)
    if usuario.perfil == NUCLEO_APOIO:  # o nucleo ve so alunos com alerta (Anexo E)
        niveis = [n for n in (niveis or [NIVEL_CRITICO, NIVEL_ALTO]) if n in (NIVEL_CRITICO, NIVEL_ALTO)]
        if not niveis:
            niveis = [NIVEL_CRITICO, NIVEL_ALTO]
    r = Resultado(intencao=it.BUSCA_ALUNOS, rascunho="", consulta="BUSCA_ALUNOS", opcoes=opcoes,
                  atalho=ATALHOS[it.MAIOR_RISCO], pode_humanizar=True)
    descricoes = [descrever(f) for f in busca.filtros]
    if busca.niveis:
        descricoes.append("risco " + _lista_pt(busca.niveis).replace(" e ", " ou "))
    if busca.media_caiu:
        descricoes.append("média em queda")
    r.filtros = {"escopo": "nas suas turmas" if tipo == "DOCENTE" else "no seu curso", "criterios": descricoes,
                 "campos": [f.campo for f in busca.filtros]}
    if not descricoes and avisos:
        r.rascunho = " ".join(avisos) + ("\n\nPosso buscar por frequência, média, faltas, atividades pendentes, "
                                         "semestre e nível de risco. Por exemplo: \"alunos com frequência abaixo de "
                                         "70% e média abaixo de 5\".")
        r.pode_humanizar = False
        return r
    if not descricoes:
        r.rascunho = ("Não consegui entender o filtro da busca. Você pode escrever, por exemplo: \"alunos com "
                      "frequência abaixo de 70% e média abaixo de 5\"." + ("\n\n" + " ".join(avisos) if avisos else ""))
        r.pode_humanizar = False
        return r

    com_distancia = usuario.perfil == NUCLEO_APOIO
    todos = sql.parametros_busca(busca.filtros, niveis, busca.media_caiu, com_distancia,
                                 id_professor=params.get("id_professor"), id_curso=params.get("id_curso"))
    linhas = _linhas(conexao_chat, sql.BUSCA_ALUNOS, {**todos, "limite": sql.LIMITE_BUSCA})
    conta = conexao_chat.execute(sql.CONTAGEM_BUSCA_ALUNOS, todos).mappings().first()
    total = int(conta["total"]) if conta else 0
    r.registros = total
    # "morando a mais de 20 km, com frequencia abaixo de 70% e media abaixo de 5"
    moradia = [d for d in descricoes if d.startswith(("morando", "do ", "depois do", "a partir do", "antes do", "até o"))]
    outros = [d for d in descricoes if d not in moradia]
    criterios = ", ".join(moradia + (["com " + _lista_pt(outros)] if outros else []))
    r.valores = {"QTD": str(total), "MOSTRADOS": str(len(linhas)), "CRITERIOS": criterios}
    r.sinais = {"encontrou_alunos": total > 0, "lista_cortada": total > len(linhas),
                "usou_valor_aproximado": any(f.aproximado for f in busca.filtros)}
    escopo_txt = r.filtros["escopo"]
    if not total:
        r.rascunho = (f"Procurei {escopo_txt} alunos [[CRITERIOS]] e não encontrei ninguém. Se quiser, "
                      "posso tentar com um critério um pouco mais amplo.")
        if avisos:
            r.rascunho += "\n\n" + " ".join(avisos)
        return r

    campos = [f.campo for f in busca.filtros]

    def principal(l) -> str:
        valores = []
        mapa = {"frequencia": ("frequência", l["frequencia_pct"], "%"), "media": ("média", l["media_atual"], ""),
                "faltas": ("faltas", l["faltas_total"], ""), "pendencias": ("pendências", l["atividades_pendentes"], ""),
                "semestre": ("semestre", l["semestre_atual"], ""), "distancia": ("", l["distancia_km"], " km")}
        ordem = campos + [c for c in ("frequencia", "media") if c not in campos]
        for c in ordem[:3]:
            nome, v, un = mapa[c]
            valores.append((f"{nome} " if nome else "") + _valor(v, un))
        return " · ".join(valores)

    r.dados = [{"matricula": l["id_aluno"], "nome": l["nome_ficticio"], "nivel": NIVEL_DO_BANCO.get(l["nivel_risco"]),
                "frequencia_pct": numero_br(l["frequencia_pct"]), "media_atual": numero_br(l["media_atual"]),
                "faltas_total": l["faltas_total"], "atividades_pendentes": l["atividades_pendentes"],
                "semestre": l["semestre_atual"],
                **({"distancia_km": numero_br(l["distancia_km"])} if com_distancia else {})} for l in linhas]
    r.detalhes = "\n".join(f"• {l['nome_ficticio']} ({l['id_aluno']}): {principal(l)}\n"
                           f"  risco {l['nivel_risco'] or 'sem avaliação'}"
                           + ("" if "semestre" in campos else f" · semestre {_valor(l['semestre_atual'])}")
                           for l in linhas)
    corte = (f" Mostro os [[MOSTRADOS]] que pedem mais atenção primeiro (risco mais alto e menor frequência)."
             if total > len(linhas) else "")
    criticos = int(conta["criticos"] or 0)
    analise = []
    if criticos and usuario.perfil != NUCLEO_APOIO:
        r.valores["QTD_CRITICOS"] = str(criticos)
        analise.append(f"Desses, [[QTD_CRITICOS]] {_pl(criticos, 'está', 'estão')} em risco Crítico, então eu "
                       f"começaria {_pl(criticos, 'por ele', 'por eles')}.")
    if any(f.aproximado for f in busca.filtros):
        analise.append("Para \"perto de\", considerei uma pequena margem para mais e para menos.")
    analise.extend(avisos)
    analise.append("Para ver os fatores e registrar uma ação, abra a ficha de cada aluno no painel.")
    r.rascunho = (f"Encontrei [[QTD]] {_pl(total, 'aluno', 'alunos')} {escopo_txt} [[CRITERIOS]].{corte}"
                  "\n\n[[DETALHES]]\n\n" + " ".join(analise))
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
        partes.append(f"• Nível de risco: {r.valores['NIVEL']}\n  avaliação de {r.valores['DATA']}")
    if ind is not None:
        r.valores.update({"FREQ": _valor(ind["frequencia_pct"], "%"), "FALTAS": _valor(ind["faltas_total"]),
                          "MEDIA": _valor(ind["media_atual"]), "PENDENTES": _valor(ind["atividades_pendentes"])})
        v = r.valores
        partes.append(f"• Frequência em {ind['periodo_letivo']}: {v['FREQ']}\n  {v['FALTAS']} {_pl(ind['faltas_total'] or 0, 'falta', 'faltas')}")
        partes.append(f"• Média atual: {v['MEDIA']}\n  escala de {ESCALA_MEDIA_GERAL}")
        partes.append(f"• Atividades pendentes: {v['PENDENTES']}")
    r.valores["ALUNO"] = f"{nome} ({matricula})"
    r.dados = [{"matricula": matricula, "nome": nome,
                "nivel": NIVEL_DO_BANCO.get(risco["nivel_risco"], risco["nivel_risco"]) if risco else None,
                "indicadores": None if ind is None else
                {k: (numero_br(v) if k != "periodo_letivo" else v) for k, v in dict(ind).items()}}]
    r.sinais = {"nivel_alto_ou_critico": bool(risco and risco["nivel_risco"] in (NIVEL_ALTO, NIVEL_CRITICO))}
    r.pode_humanizar = True
    perfil = _perfil_aluno(conexao_chat, matricula)
    if perfil and perfil.get("nivel_anterior") and risco is not None and perfil["nivel_anterior"] != risco["nivel_risco"]:
        partes[0] += f" · antes {perfil['nivel_anterior']}"
    fatores = principais_visiveis(usuario.perfil, (perfil or {}).get("fatores_principais"))
    if fatores:
        partes.append("• Fatores que mais pesaram: " + _lista_pt([ROTULOS_FATOR.get(f, f) for f in fatores[:3]]))
    pendentes = _linhas(conexao_chat, sql.ATIVIDADES_PENDENTES_DO_ALUNO, {"id_aluno": matricula, "limite": sql.LIMITE_LINHAS})
    atrasadas = [l for l in pendentes if l["prazo_em"] < date.today()]
    if atrasadas:
        partes = [p if not p.startswith("• Atividades pendentes") else
                  p + f"\n  {len(atrasadas)} {_pl(len(atrasadas), 'já atrasada', 'já atrasadas')}" for p in partes]
    r.detalhes = "\n".join(partes)
    r.rascunho = "Este é o resumo de [[ALUNO]]:\n\n[[DETALHES]]"
    if r.sinais["nivel_alto_ou_critico"]:
        r.rascunho += "\n\nNa ficha do aluno você vê os fatores que mais pesaram e pode registrar uma ação."
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
        if intencao == it.PENDENCIAS:
            return _intencao_atividades(conexao_chat, id_aluno, pergunta)
        if intencao == it.MEDIA:
            return _intencao_indicadores(intencao, conexao_chat, id_aluno)
        if intencao == it.MEU_RISCO:
            return _intencao_meu_risco(conexao_chat, id_aluno)
        return _fixo(it.NAO_ENTENDI, usuario)

    if usuario.perfil in PERFIS_EQUIPE:
        if intencao == it.ALUNO_ESPECIFICO and matriculas:
            return _intencao_aluno_especifico(request, conexao_api, conexao_chat, usuario, matriculas[0])
        if intencao == it.BUSCA_ALUNOS:
            return _intencao_busca(conexao_chat, usuario, pergunta)
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
