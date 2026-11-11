"""Nucleo de apoio (NAE): meus alertas (hub) e alunos atribuidos."""

import streamlit as st

import cliente
import ui
from paginas import alertas


def hub():
    esq, dir_ = st.columns([3, 1.4], vertical_alignment="top")
    with esq:
        ui.cabecalho("Meus alertas", "Alunos com alerta atribuído a você (Anexo E) · Crítico: primeira ação em até "
                     "48 horas", "Núcleo de apoio")
    dir_.markdown(f'<div style="text-align:right;margin-top:18px">{ui.selo_decisao()}</div>', unsafe_allow_html=True)
    with st.container(horizontal=True):
        ui.link("Alunos atribuídos", "alunos", "n_alunos", "users")
        ui.link("Fila completa", "alertas", "n_fila", "list", alerta_aberto=None)
        ui.link("Assistente", "assistente", "n_assist", "sparkles")

    @st.fragment(run_every="20s")
    def _meus():
        with ui.secao():
            r = cliente.get("/api/v1/alertas", limite=50)
            k = st.columns(3)
            with k[0]:
                ui.card("Atribuídos a mim", r["total"], "alertas ativos", "inbox")
            with k[1]:
                ui.card("Críticos", sum(1 for i in r["itens"] if i["nivel"] == "CRITICO"), "atender em até 48 horas",
                        "triangle-alert")
            with k[2]:
                ui.card("Prazo vencido", sum(1 for i in r["itens"] if i["vencido"]), "primeira ação atrasada", "clock")
            if not r["itens"]:
                st.info("Nenhum alerta atribuído a você agora.")
                return
            alertas.tabela_fila(r["itens"], r["total"], chave="meus")

    _meus()


def alunos():
    ui.cabecalho("Alunos atribuídos", "Estudantes com alerta sob a sua responsabilidade", "Núcleo de apoio")
    with ui.secao():
        r = cliente.get("/api/v1/alunos", ordem="risco", limite=100)
        alertas.tabela_alunos(r["itens"], r.get("total"))
