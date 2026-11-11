"""Docente: minhas turmas (hub) e detalhe da turma - Figma Parte 5."""

import html

import streamlit as st

import cliente
import ui
from paginas.alertas import ROTULO_FATOR


def _cartao_turma(t: dict):
    total = t["alunos"] or 0
    demais = max(total - t["criticos"] - t["altos"], 0)
    partes = [("CRITICO", t["criticos"]), ("ALTO", t["altos"])]
    faixa = "".join(f'<div style="flex:{n};background:{ui.COR_GRAFICO[nv]}"></div>' for nv, n in partes if n)
    faixa += f'<div style="flex:{demais};background:{ui.COR["lineSoft"]}"></div>' if demais else ""
    chips = "".join(f'<span class="mf-chip">{ui.selo(nv)}{n}</span>' for nv, n in partes)
    chips += f'<span class="mf-chip"><span class="mf-selo" style="background:{ui.COR["lineSoft"]}">Demais</span>{demais}</span>'
    with ui.painel("turma_" + ui._slug(t["id_turma"])):
        st.markdown(f'<div style="display:flex;justify-content:space-between;gap:12px"><div>'
                    f'<div class="mf-h3">{html.escape(t["disciplina"])} — {html.escape(t["id_turma"])}</div>'
                    f'<div class="mf-h3sub">{html.escape(str(t["periodo_letivo"]))} · {html.escape(str(t["turno"]))} · '
                    f'{total} alunos · {t["carga_horaria_h"]} h</div></div>'
                    f'<span class="mf-icbox">{ui.icone("presentation", 20)}</span></div>'
                    f'<div class="mf-escala" style="height:8px;border-radius:999px">{faixa or ""}</div>'
                    f'<div class="mf-chips">{chips}</div>', unsafe_allow_html=True)
        esq, dir_ = st.columns([2, 1], vertical_alignment="center")
        esq.caption(f"Média {ui.numero_br(t['media_turma'], 2)} · frequência {ui.numero_br(t['frequencia_turma'])}%")
        with dir_:
            if ui.texto_link("Ver alunos", f"t{t['id_turma']}"):
                ui.ir("turma", turma_aberta=t["id_turma"])


def hub():
    ui.cabecalho("Minhas turmas", "Contagem de alunos por nível de risco em cada turma", "Docente")
    ui.aviso("Você vê indicadores acadêmicos", "Notas, frequência e reprovações. Dados de renda, trabalho, saúde e "
             "moradia ficam com o NAE.", "book-open")
    with st.container(horizontal=True):
        ui.link("Alertas dos meus alunos", "alertas", "d_fila", "bell-ring", alerta_aberto=None)
        ui.link("Assistente", "assistente", "d_assist", "sparkles")

    @st.fragment(run_every="30s")
    def _turmas():
        with ui.secao():
            turmas = cliente.get("/api/v1/turmas")
            if not turmas:
                st.info("Nenhuma turma vinculada ao seu cadastro.")
            colunas = st.columns(2)
            for n, t in enumerate(turmas):
                with colunas[n % 2]:
                    _cartao_turma(t)

    _turmas()


def turma():
    id_turma = st.session_state.get("turma_aberta")
    if ui.voltar("Voltar às turmas", "voltar_turmas"):
        ui.ir("turmas")
    if not id_turma:
        st.info("Escolha uma turma em Minhas turmas.")
        return
    with ui.secao():
        r = cliente.get(f"/api/v1/turmas/{id_turma}/alunos")
        t = r["turma"]
        ui.cabecalho(f"{t['materia']} — {t['id_turma']}",
                     f"{t['periodo_letivo']} · {t['turno']} · {len(r['alunos'])} alunos · indicadores acadêmicos",
                     "Docente")
        if not r["alunos"]:
            ui.aviso("Nenhum aluno matriculado ainda", "Quando houver matrículas, os alunos aparecem aqui.", "user-x")
            return
        linhas = [(a["matricula"], [
            ui.pessoa(a["nome"], a["matricula"]), ui.cel_nota(a["nota_final"], 6.0),
            ui.cel_freq(a["frequencia_pct"], 75.0), ui.cel_situacao(a["situacao"]), ui.selo(a["nivel"]),
            html.escape(", ".join(ROTULO_FATOR.get(f, f) for f in a["fatores_principais"][:3]) or "—")])
            for a in r["alunos"]]
        clicado = ui.tabela("turma", ["Aluno", "Nota final", "Frequência", "Situação", "Risco", "Fatores"],
                            [2.2, 0.8, 1.3, 1.1, 1.1, 1.5], linhas, "Abrir ficha")
        if clicado is not None:
            ui.ir("ficha", ficha_matricula=clicado)
