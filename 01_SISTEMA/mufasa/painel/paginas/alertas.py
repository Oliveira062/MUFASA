"""Fila de alertas e acompanhamento (Figma Parte 3), para coordenacao, NAE, docente e financeiro."""

import html

import streamlit as st

import cliente
import ui

SITUACOES = {"Ativos": None, "Abertos": "ABERTO", "Em atendimento": "EM_ATENDIMENTO", "Encerrados": "ENCERRADO"}
NIVEIS = {"Todos": None, "Crítico": "CRITICO", "Alto": "ALTO", "Moderado": "MODERADO",
          "Indeterminado (dados)": "INDETERMINADO"}
TIPOS_ACAO = {"Conversa": "CONVERSA", "Orientação acadêmica": "ORIENTACAO_ACADEMICA",
              "Encaminhamento ao NAE": "ENCAMINHAMENTO_NAE", "Encaminhamento ao financeiro": "ENCAMINHAMENTO_FINANCEIRO",
              "Contato sem retorno": "CONTATO_SEM_RETORNO", "Outro": "OUTRO"}
CAUSAS = {"Financeira": "FINANCEIRA", "Acadêmica": "ACADEMICA", "Trabalho": "TRABALHO", "Saúde": "SAUDE",
          "Familiar": "FAMILIAR", "Transporte": "TRANSPORTE", "Escolha de curso": "ESCOLHA_DE_CURSO",
          "Institucional": "INSTITUCIONAL", "Não identificada": "NAO_IDENTIFICADA"}
DESFECHOS = {"Permaneceu": "PERMANECEU", "Em acompanhamento": "EM_ACOMPANHAMENTO", "Trancou": "TRANCOU",
             "Evadiu": "EVADIU", "Transferiu": "TRANSFERIU", "Dados corrigidos (tarefa de dados)": "DADOS_CORRIGIDOS"}
ROTULO_FATOR = {"notas": "notas", "frequencia": "frequência", "reprovacao": "reprovações",
                "engajamento_ava": "ambiente virtual", "financeiro": "financeiro", "trabalho": "trabalho",
                "deslocamento": "deslocamento", "saude_mental": "saúde", "saude_fisica": "saúde",
                "moradia": "moradia", "dependentes": "dependentes", "encaminhado": "encaminhado ao NAE"}
CANAIS = {"Ambiente virtual": "AMBIENTE_VIRTUAL", "Presencial": "PRESENCIAL",
          "E-mail institucional": "EMAIL_INSTITUCIONAL", "Emergência (RN19)": "EMERGENCIA_RN19"}


SITUACAO_ROTULO = {"ABERTO": "Novo", "EM_ATENDIMENTO": "Em andamento", "ENCERRADO": "Encerrado"}
# Colunas da tabela da fila (Figma P3: Estudante, Risco, Prazo, Responsavel, Status, Acoes)
COLUNAS_FILA = [2.6, 1.5, 1.4, 1.9, 1.3, 0.9]


def _prazo(item) -> str:
    if item["situacao"] == "ENCERRADO":
        return "encerrado"
    horas = item.get("horas_para_prazo")
    if horas is None:
        return "—"
    if horas < 0:
        return f"vencido há {ui.numero_br(-horas / 24, 0)} d" if -horas >= 24 else f"vencido há {int(-horas)} h"
    return f"{ui.numero_br(horas / 24, 0)} d" if horas >= 24 else f"{int(horas)} h"


def _pilula_prazo(item) -> str:
    texto = _prazo(item)
    if item.get("vencido") and item["situacao"] != "ENCERRADO":
        return ui.pilula(texto.capitalize(), ui.COR["text"], "#FFFFFF", "clock")
    return ui.pilula(texto.capitalize(), ui.COR["goldSoft"], ui.COR["text"], "clock")


def _situacao(item) -> str:
    rotulo = SITUACAO_ROTULO.get(item["situacao"], item["situacao"].replace("_", " ").lower())
    if item["situacao"] == "ABERTO" and item.get("responsavel"):
        rotulo = "Atribuído"
    return ui.pilula(rotulo, contorno=True)


def _kpis_fila(perfil: str):
    """Cartoes do topo da fila (Figma P3): totais do perfil, sem os filtros da tabela."""
    def total(**filtros):
        return cliente.get("/api/v1/alertas", limite=1, **filtros)["total"]
    with ui.secao():
        cols = st.columns(4)
        with cols[0]:
            ui.card("Total de alertas", total(), "ativos no seu recorte", "bell-ring")
        with cols[1]:
            ui.card("Nível crítico", total(nivel="CRITICO"), "atender em até 48 horas", "triangle-alert")
        with cols[2]:
            if perfil == "COORDENACAO":
                ui.card("Sem responsável", total(sem_responsavel="true"), "aguardando atribuição", "user-plus")
            else:
                ui.card("Nível alto", total(nivel="ALTO"), "atender em até 5 dias úteis", "circle-alert")
        with cols[3]:
            ui.card("Prazo vencido", total(so_vencidos="true"), "primeira ação atrasada", "clock")


def tabela_fila(itens: list[dict], total: int, chave: str = "fila"):
    """Tabela da fila (Figma P3): estudante, risco com score, prazo, responsavel, status e acao."""
    ui.css("".join(f".st-key-lin_{chave}_{i['id_alerta']} {{ border-left:3px solid {ui.COR['gold']}; }}"
                   for i in itens if i["vencido"] and i["situacao"] != "ENCERRADO"))
    linhas = []
    for i in itens:
        aviso = (ui.pilula("Prazo vencido", ui.COR["text"], "#FFFFFF", "triangle-alert") + "<br>"
                 if i["vencido"] and i["situacao"] != "ENCERRADO" else "")
        fundo = ui.SELO.get(i["nivel"] or "PENDENTE", ui.SELO["PENDENTE"])[0]
        resp = (f'<div class="mf-resp">{ui.avatar(i["responsavel"], 30)}{html.escape(i["responsavel"])}</div>'
                if i.get("responsavel") else
                f'<div class="mf-resp vazio">{ui.icone("user-plus", 18)}Não atribuído</div>')
        linhas.append((i["id_alerta"], [
            f'<div class="mf-est">{aviso}<b>{html.escape(i["nome"])}</b>'
            f'<small>{i["matricula"]} · {i["semestre"] or "—"}º semestre</small></div>',
            f'<div class="mf-risco">{ui.selo(i["nivel"])}<div>{ui.barra(i["score"], cor=fundo, largura="88px")}'
            f'{"" if i["score"] is None else i["score"]}</div></div>',
            f'<div class="mf-prazo">{_pilula_prazo(i)}<small>{ui.data_br(i["prazo_em"])[:10]}</small></div>',
            resp, _situacao(i)]))
    clicado = ui.tabela(chave, ["Estudante", "Risco", "Prazo", "Responsável", "Status"], COLUNAS_FILA[:5], linhas,
                        "Abrir", primario=True,
                        rodape=f'<span>Exibindo {len(itens)} de {total} alertas · ordenados por risco e prazo · '
                               f'atualiza a cada 20 s</span><span>{ui.icone("lock", 13)}Cada ação fica registrada '
                               'no histórico</span>')
    if clicado is not None:
        ui.ir("alertas", alerta_aberto=clicado)
        st.rerun()


def fila():
    perfil = st.session_state.get("perfil")
    if st.session_state.get("alerta_aberto"):
        detalhe(st.session_state["alerta_aberto"])
        return
    esq, dir_ = st.columns([3, 1.4], vertical_alignment="top")
    with esq:
        ui.cabecalho("Fila de alertas", "Lista priorizada · Crítico antes de Alto, depois prazo, score, tendência e "
                     "tempo sem contato (RN03, RF18) · prazos: Crítico 48 horas, Alto 5 dias úteis", "Acompanhamento")
    dir_.markdown(f'<div style="text-align:right;margin-top:18px">{ui.selo_decisao()}</div>', unsafe_allow_html=True)
    _kpis_fila(perfil)

    qp = st.query_params
    c1, c2, c3, c4, c5 = st.columns([1.2, 1.2, 1, 1, 0.8], vertical_alignment="bottom")
    situacao = c1.selectbox("Situação", list(SITUACOES), index=list(SITUACOES).index(qp.get("situacao", "Ativos"))
                            if qp.get("situacao") in SITUACOES else 0)
    nivel_inicial = st.session_state.pop("filtro_fila_nivel", None) or qp.get("nivel")
    nivel = c2.selectbox("Risco", list(NIVEIS), index=list(NIVEIS).index(nivel_inicial) if nivel_inicial in NIVEIS else 0)
    vencidos = c3.toggle("Só prazo vencido", value=qp.get("vencidos") == "1")
    sem_resp = c4.toggle("Sem responsável", value=qp.get("sem_resp") == "1") if perfil == "COORDENACAO" else False
    # Filtros refletidos na URL (RF07): o mesmo recorte pode ser compartilhado.
    st.query_params.update({"situacao": situacao, "nivel": nivel, "vencidos": "1" if vencidos else "0",
                            "sem_resp": "1" if sem_resp else "0"})
    pagina = c5.number_input("Página", min_value=1, value=1, step=1)

    @st.fragment(run_every="20s")
    def _tabela():
        with ui.secao():
            r = cliente.get("/api/v1/alertas", situacao=SITUACOES[situacao], nivel=NIVEIS[nivel],
                            so_vencidos=str(vencidos).lower(), sem_responsavel=str(sem_resp).lower(),
                            limite=25, pagina=int(pagina))
            itens = r["itens"]
            if not itens:
                with ui.painel("fila_vazia"):
                    st.markdown(f'<div style="text-align:center;padding:24px 0">{ui.icone("inbox", 28, ui.COR["deep"])}'
                                '<div class="mf-h3" style="margin-top:8px">Nenhum alerta neste recorte</div>'
                                '<div class="mf-h3sub">Mude os filtros acima para ver outros alertas.</div></div>',
                                unsafe_allow_html=True)
                return
            tabela_fila(itens, r["total"])
            if perfil in ("COORDENACAO", "NUCLEO_APOIO"):
                ui.botao_exportar(itens, ["matricula", "nome", "nivel", "score", "situacao", "prazo_em", "responsavel"],
                                  "Fila de alertas", "fila_alertas.csv")

    _tabela()


def detalhe(id_alerta: int):
    perfil = st.session_state.get("perfil")
    esq, dir_ = st.columns([1, 1], vertical_alignment="center")
    with esq:
        if ui.voltar("Voltar à fila", "voltar_fila"):
            st.session_state.pop("alerta_aberto", None)
            st.rerun()
    dir_.markdown(f'<div style="text-align:right">{ui.selo_decisao()}</div>', unsafe_allow_html=True)
    a = None
    with ui.secao():
        a = cliente.get(f"/api/v1/alertas/{id_alerta}")
    if a is None:
        return
    vencido = ui.pilula("Prazo vencido", ui.COR["text"], "#FFFFFF", "clock") if a["vencido"] else ""
    acoes = ui.heroi(a["nome"], ui.selo(a["nivel"]) + " " + vencido, [
        ("id-card", f"Matrícula {a['matricula']}"), ("clock", f"Prazo {ui.data_br(a['prazo_em'])}"),
        ("user", f"Responsável: {a.get('responsavel') or 'não atribuído'}"),
        ("list-checks", SITUACAO_ROTULO.get(a["situacao"], a["situacao"]))])
    with acoes:
        ui.link("Abrir ficha do aluno", "ficha", "abrir_ficha_alerta", "file-user", ficha_matricula=a["matricula"])
    if a.get("menor_de_idade"):
        st.warning("Aluno menor de 18 anos: o contato segue o protocolo institucional com o responsável legal (RN16).")

    aba = st.tabs(["Histórico", "Registrar ação", "Atribuir", "Encerrar", "Classificação equivocada"])
    with aba[0]:
        eventos = list(reversed(a["eventos"]))
        st.markdown("".join(
            f'<div class="mf-tempo{" atual" if n == 0 else ""}"><b>{e["tipo"].replace("_", " ").capitalize()}'
            f'{" · " + e["tipo_acao"].replace("_", " ").lower() if e.get("tipo_acao") else ""}</b>'
            f'<small>{ui.data_br(e["momento"])} · {html.escape(e["autor"])}</small>'
            f'{"<p>" + html.escape(e["descricao"]) + "</p>" if e.get("descricao") else ""}</div>'
            for n, e in enumerate(eventos)) or "<small>Sem eventos.</small>", unsafe_allow_html=True)
        if a.get("encerramento"):
            enc = a["encerramento"]
            st.success(f"Encerrado em {ui.data_br(enc['encerrado_em'])}: causa {enc['causa']}, desfecho {enc['desfecho']}.")

    with aba[1]:
        if a["situacao"] == "ENCERRADO":
            st.caption("Alerta encerrado.")
        else:
            with st.form("acao"):
                tipo = st.selectbox("Tipo de ação", list(TIPOS_ACAO))
                descricao = st.text_area("O que foi feito", max_chars=1000)
                visivel = st.checkbox("Mostrar este registro ao aluno")
                if st.form_submit_button("Registrar ação", type="primary"):
                    with ui.secao():
                        cliente.post(f"/api/v1/alertas/{id_alerta}/acoes",
                                     {"tipo_acao": TIPOS_ACAO[tipo], "descricao": descricao, "visivel_aluno": visivel})
                        st.success("Registro salvo no histórico.")
                        st.rerun()

    with aba[2]:
        if not a.get("pode_atribuir"):
            if a.get("pode_gerenciar") and a["situacao"] == "ABERTO" and st.button("Assumir atendimento"):
                with ui.secao():
                    cliente.patch(f"/api/v1/alertas/{id_alerta}", {"assumir": True})
                    st.rerun()
            st.caption("Só a coordenação atribui alertas.")
        else:
            with ui.secao():
                resp = cliente.get("/api/v1/alertas/responsaveis")
                opcoes = {f"{r['nome']} ({'NAE' if r['perfil'] == 'NUCLEO_APOIO' else 'Coordenação'}) · "
                          f"{r['alertas_abertos']}/{r['teto']} alertas": r["id_usuario"] for r in resp}
                escolha = st.selectbox("Responsável", list(opcoes))
                if st.button("Atribuir", type="primary"):
                    cliente.patch(f"/api/v1/alertas/{id_alerta}", {"id_responsavel": opcoes[escolha]})
                    st.success("Alerta atribuído.")
                    st.rerun()

    with aba[3]:
        if not a.get("pode_gerenciar"):
            st.caption("Encerrar é da coordenação ou do responsável do NAE.")
        else:
            st.warning("Encerrar é irreversível. Causa e desfecho são obrigatórios (CA20).")
            with st.form("encerrar"):
                causa = st.selectbox("Causa identificada", list(CAUSAS))
                desfecho = st.selectbox("Desfecho", list(DESFECHOS))
                contato = st.radio("Houve contato com o aluno?", ["Sim", "Não"], horizontal=True)
                canal = st.selectbox("Canal do contato", list(CANAIS))
                acoes = st.text_area("Ações executadas", max_chars=1000)
                if st.form_submit_button("Encerrar alerta", type="primary"):
                    with ui.secao():
                        cliente.post(f"/api/v1/alertas/{id_alerta}/encerramento", {
                            "causa": CAUSAS[causa], "desfecho": DESFECHOS[desfecho], "houve_contato": contato == "Sim",
                            "canal_contato": CANAIS[canal] if contato == "Sim" else None, "acoes_executadas": acoes})
                        st.success("Alerta encerrado.")
                        st.rerun()

    with aba[4]:
        if perfil not in ("DOCENTE", "COORDENACAO"):
            st.caption("Docente e coordenação podem marcar a classificação como equivocada.")
        else:
            with st.form("divergencia"):
                just = st.text_area("Por que a classificação parece equivocada?", max_chars=1000)
                if st.form_submit_button("Registrar divergência"):
                    with ui.secao():
                        cliente.post(f"/api/v1/alertas/{id_alerta}/divergencia", {"justificativa": just})
                        st.success("Registrado. A marcação entra no relatório de qualidade do modelo (RF20).")


def tabela_alunos(itens: list[dict], total: int | None = None, chave: str = "alunos"):
    """Tabela de alunos (Figma P4: Alunos acompanhados); o botao abre a ficha."""
    linhas = []
    for i in itens:
        fundo = ui.SELO.get(i["nivel_risco"] or "PENDENTE", ui.SELO["PENDENTE"])[0]
        linhas.append((i["matricula"], [
            ui.pessoa(i["nome"], i["matricula"]), f'{i["semestre"] or "—"}º semestre', ui.selo(i["nivel_risco"]),
            f'<div class="mf-risco"><div>{ui.barra(i["score"], cor=fundo, largura="88px")}'
            f'{"—" if i["score"] is None else i["score"]}</div></div>']))
    if not linhas:
        st.info("Nenhum aluno neste recorte.")
        return
    clicado = ui.tabela(chave, ["Aluno", "Semestre", "Risco", "Score"], [2.6, 1, 1.2, 1.2], linhas, "Abrir ficha",
                        rodape=f"<span>Exibindo {len(itens)}" + (f" de {total}" if total is not None else "")
                               + " alunos · vulnerabilidade exibida apenas como faixa qualitativa na ficha</span>")
    if clicado is not None:
        ui.ir("ficha", ficha_matricula=clicado)
