"""Encarregado de dados (Figma Parte 6): trilha de auditoria e pedidos dos titulares (LGPD art. 18 e 37)."""

from datetime import datetime, time
from zoneinfo import ZoneInfo

import streamlit as st

import cliente
import ui

FUSO = ZoneInfo("America/Sao_Paulo")
PERFIS = ["Todos", "ALUNO", "DOCENTE", "COORDENACAO", "NUCLEO_APOIO", "FINANCEIRO", "DIRECAO", "ADMIN",
          "ENCARREGADO_DADOS"]
RESPOSTAS = {"Em análise": "EM_ANALISE", "Atendida": "ATENDIDA", "Negada": "NEGADA"}


def hub():
    ui.cabecalho("Trilha de auditoria LGPD", "Quem acessou o quê e quando · somente leitura · ler esta trilha também "
                 "fica registrado", "Encarregado de dados")
    c1, c2, c3 = st.columns(3)
    matricula = c1.text_input("Matrícula do aluno", max_chars=7).strip().upper() or None
    perfil = c2.selectbox("Perfil de quem acessou", PERFIS)
    resultado = c3.selectbox("Resultado", ["Todos", "PERMITIDO", "NEGADO", "BLOQUEADO"])
    c4, c5, c6, c7 = st.columns(4)
    operacao = c4.text_input("Operação (ex.: LOGIN)", max_chars=40).strip().upper() or None
    de = c5.date_input("De", value=None, format="DD/MM/YYYY")
    ate = c6.date_input("Até", value=None, format="DD/MM/YYYY")
    pagina = c7.number_input("Página", 1, 10_000, 1)
    with ui.secao():
        linhas = cliente.get("/api/v1/auditoria", matricula=matricula, perfil=perfil, resultado=resultado,
                             operacao=operacao, limite=100, pagina=int(pagina),
                             de=datetime.combine(de, time.min, FUSO).isoformat() if de else None,
                             ate=datetime.combine(ate, time.max, FUSO).isoformat() if ate else None)
        if not linhas:
            st.caption("Nenhum registro neste recorte.")
            return
        negados = sum(1 for l in linhas if l["resultado"] != "PERMITIDO")
        a, b = st.columns(2)
        with a:
            ui.card("Registros nesta página", len(linhas), "até 100 por página", "files")
        with b:
            ui.card("Negados ou bloqueados", negados, "nesta página", "shield-x")
        tabela = [{"Momento": ui.data_br(l["momento"]), "Usuário": l["id_usuario"], "Perfil": l["perfil"],
                   "Operação": l["operacao"], "Recurso": l["recurso"], "Aluno": l["id_aluno_alvo"] or "—",
                   "Resultado": l["resultado"], "Requisição": l["id_requisicao"]} for l in linhas]
        with ui.painel("auditoria"):
            ui.titulo_painel("Registros", "Momento, quem acessou, operação, recurso e resultado")
            tom = {"PERMITIDO": ("okBg", "okFg", "check"), "NEGADO": ("errBg", "errFg", "shield-x"),
                   "BLOQUEADO": ("errBg", "errFg", "lock"), "ERRO": ("errBg", "errFg", "circle-x")}
            ui.grade(["Momento", "Quem", "Operação", "Aluno", "Resultado"],
                     [[ui.cel_dupla(ui.data_br(l["momento"]), l["id_requisicao"]),
                       ui.cel_dupla(f'Usuário {l["id_usuario"]}', (l["perfil"] or "").replace("_", " ").capitalize()),
                       ui.cel_dupla((l["operacao"] or "").replace("_", " ").capitalize(), l["recurso"]),
                       ui.txt(l["id_aluno_alvo"]),
                       ui.pilula((l["resultado"] or "—").capitalize(), *[ui.COR[k] for k in tom.get(l["resultado"], ("infoBg", "infoFg"))[:2]],
                                 tom.get(l["resultado"], (None, None, "info"))[2])]
                      for l in linhas], rotulo="Trilha de auditoria")
        ui.botao_exportar(tabela, list(tabela[0]), "Trilha de auditoria", "auditoria.csv")


def solicitacoes():
    ui.cabecalho("Pedidos dos titulares", "Prazo de resposta: 15 dias (LGPD, art. 19, II)", "Encarregado de dados")
    with ui.secao():
        pedidos = cliente.get("/api/v1/privacidade/solicitacoes", limite=100)
        if not pedidos:
            st.caption("Nenhum pedido registrado.")
            return
        abertos = [p for p in pedidos if p["situacao"] in ("ABERTA", "EM_ANALISE")]
        k, _ = st.columns([1, 2])
        with k:
            ui.card("Pedidos em aberto", len(abertos), "nesta página", "inbox")
        pesos = [0.6, 2.2, 1.4, 1.2, 1.6, 0.9]
        with ui.painel("pedidos"):
            st.markdown('<div class="mf-cab-tabela" style="grid-template-columns:' + " ".join(f"{p}fr" for p in pesos)
                        + '"><span>Nº</span><span>Pedido</span><span>Registrado em</span><span>Situação</span>'
                        '<span>Responder</span><span></span></div>', unsafe_allow_html=True)
            for p in pedidos:
                with st.container(key=f"lin_ped_{p['id_solicitacao']}"):
                    col = st.columns(pesos, vertical_alignment="center")
                    col[0].markdown(f"#{p['id_solicitacao']}")
                    col[1].markdown(f'<div class="mf-est"><b>{p["tipo"].replace("_", " ").capitalize()}</b>'
                                    f'<small>aluno {p["id_aluno"]}</small></div>', unsafe_allow_html=True)
                    col[2].markdown(ui.data_br(p["registrada_em"]))
                    col[3].markdown(ui.pilula(p["situacao"].replace("_", " ").capitalize(), contorno=True),
                                    unsafe_allow_html=True)
                    if p["situacao"] in ("ATENDIDA", "NEGADA"):
                        continue
                    nova = col[4].selectbox("Responder", list(RESPOSTAS), key=f"sr{p['id_solicitacao']}",
                                            label_visibility="collapsed")
                    if col[5].button("Salvar", key=f"ss{p['id_solicitacao']}", type="primary"):
                        cliente.patch(f"/api/v1/privacidade/solicitacoes/{p['id_solicitacao']}",
                                      {"situacao": RESPOSTAS[nova]})
                        st.rerun()
