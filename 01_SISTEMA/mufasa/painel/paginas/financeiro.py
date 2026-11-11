"""Setor financeiro: alunos com fator financeiro no alerta (Anexo E)."""

import html

import streamlit as st

import cliente
import ui


def hub():
    esq, dir_ = st.columns([3, 1.4], vertical_alignment="top")
    with esq:
        ui.cabecalho("Alunos com fator financeiro", "Alunos cujo alerta aberto tem a situação financeira entre os "
                     "fatores principais", "Setor financeiro")
    dir_.markdown(f'<div style="text-align:right;margin-top:18px">{ui.selo_decisao()}</div>', unsafe_allow_html=True)
    ui.aviso("Você vê pendências e elegibilidade a auxílio", "Saúde e desempenho detalhado não aparecem para o setor "
             "financeiro (Anexo E).", "wallet")

    @st.fragment(run_every="30s")
    def _lista():
        with ui.secao():
            itens = cliente.get("/api/v1/financeiro/alunos", limite=100)
            if not itens:
                st.info("Nenhum aluno com fator financeiro em alerta aberto.")
                return
            linhas = [(i["id_alerta"], [
                ui.pessoa(i["nome"], i["matricula"]), ui.selo(i["nivel"]), ui.data_br(i["prazo_em"])[:10],
                "sem dado" if i["renda_per_capita_sm"] is None else f'{ui.numero_br(i["renda_per_capita_sm"], 2)} SM',
                {True: ui.pilula("Sim", ui.COR["okBg"], ui.COR["okFg"], "check"),
                 False: ui.pilula("Não", ui.COR["errBg"], ui.COR["errFg"], "x")}.get(i["auxilio_ativo"], ui.txt(None, "sem dado")),
                html.escape(" / ".join(i["recomendacoes"]) or "—")]) for i in itens]
            clicado = ui.tabela("financeiro", ["Aluno", "Risco", "Prazo", "Renda por pessoa", "Auxílio ativo",
                                               "Recomendação"], [2.2, 1.1, 1, 1.1, 0.9, 2.2], linhas, "Abrir",
                                primario=True, rodape=f"<span>Exibindo {len(itens)} alunos</span>")
            if clicado is not None:
                ui.ir("alertas", alerta_aberto=clicado)

    _lista()
