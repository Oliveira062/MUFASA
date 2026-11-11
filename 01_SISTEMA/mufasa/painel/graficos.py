"""Graficos do painel (plotly), com a rampa de mostarda do Figma e rotulo direto em toda barra."""

import html

import pandas as pd
import plotly.graph_objects as go
import streamlit as st

import ui

_BASE = dict(paper_bgcolor="rgba(0,0,0,0)", plot_bgcolor="rgba(0,0,0,0)", font=dict(color=ui.COR["text"], size=13),
             margin=dict(l=10, r=10, t=10, b=10), hoverlabel=dict(bgcolor="#FFFFFF", font_color=ui.COR["text"]))
_CONFIG = {"displayModeBar": False}


def distribuicao_niveis(distribuicao: list[dict], altura=240):
    """Barras horizontais por nivel, na ordem Critico -> Baixo; suprimido aparece escrito."""
    linhas = [d for d in distribuicao if d["nivel"] in ui.ORDEM_NIVEIS]
    linhas.sort(key=lambda d: ui.ORDEM_NIVEIS.index(d["nivel"]), reverse=True)
    nomes = [ui.NOME_NIVEL[d["nivel"]] for d in linhas]
    valores = [d["total"] or 0 for d in linhas]
    textos = ["suprimido (< 5)" if d["total"] is None else
              (f"{d['total']} · {ui.numero_br(d['pct'])}%" if d.get("pct") is not None else str(d["total"]))
              for d in linhas]
    fig = go.Figure(go.Bar(x=valores, y=nomes, orientation="h", text=textos, textposition="outside",
                           cliponaxis=False, marker=dict(color=[ui.COR_GRAFICO[d["nivel"]] for d in linhas],
                                                         line=dict(color="#FFFFFF", width=2)),
                           hovertemplate="%{y}: %{text}<extra></extra>"))
    fig.update_layout(**_BASE, height=altura, showlegend=False, bargap=0.35,
                      xaxis=dict(visible=False, range=[0, max(valores + [1]) * 1.3]), yaxis=dict(title=None))
    st.plotly_chart(fig, use_container_width=True, config=_CONFIG)


def barras_simples(rotulos: list[str], valores: list, cor=None, altura=None, sufixo=""):
    altura = altura or 70 + 42 * max(len(rotulos), 1)
    texto = ["suprimido (< 5)" if v is None else f"{v}{sufixo}" for v in valores]
    fig = go.Figure(go.Bar(x=[v or 0 for v in valores], y=rotulos, orientation="h", text=texto, textposition="outside",
                           cliponaxis=False, marker=dict(color=cor or ui.COR["deep"]),
                           hovertemplate="%{y}: %{text}<extra></extra>"))
    fig.update_layout(**_BASE, height=altura, showlegend=False, bargap=0.4,
                      xaxis=dict(visible=False, range=[0, max([v or 0 for v in valores] + [1]) * 1.35]),
                      yaxis=dict(title=None, autorange="reversed"))
    st.plotly_chart(fig, use_container_width=True, config=_CONFIG)


def evolucao(serie: list[dict], altura=260):
    if not serie:
        st.caption("Sem dado: ainda não há scores calculados.")
        return
    df = pd.DataFrame(serie)
    # Um ponto por dia: eixo de categorias dd/mm, sem horas fantasmas quando ha poucos dias.
    df["dia"] = pd.to_datetime(df["dia"]).dt.strftime("%d/%m")
    fig = go.Figure()
    for coluna, nome, cor in (("em_risco", "Alto + Crítico", ui.COR_GRAFICO["ALTO"]),
                              ("criticos", "Crítico", ui.COR_GRAFICO["CRITICO"])):
        fig.add_trace(go.Scatter(x=df["dia"], y=df[coluna], mode="lines+markers", name=nome,
                                 line=dict(color=cor, width=2), marker=dict(size=8, line=dict(width=2, color="#FFFFFF")),
                                 hovertemplate="%{x}<br>" + nome + ": %{y}<extra></extra>"))
    fig.update_layout(**_BASE, height=altura, legend=dict(orientation="h", y=1.15, x=0),
                      yaxis=dict(rangemode="tozero", gridcolor="#F0E5C8", title=None), xaxis=dict(title=None, type="category"),
                      hovermode="x unified")
    st.plotly_chart(fig, use_container_width=True, config=_CONFIG)
    if len(df) == 1:
        st.caption("Só há um dia de cálculo até agora: a série cresce a cada dia de uso.")


def empilhado_por_grupo(comparacao: list[dict], altura=300):
    """Comparacao entre grupos (curso ou semestre), uma serie por nivel, mesma cor sempre."""
    if not comparacao:
        st.caption("Sem dado.")
        return
    grupos = [c["grupo"] for c in comparacao]
    fig = go.Figure()
    for nivel in ("BAIXO", "MODERADO", "ALTO", "CRITICO"):
        valores = [c["niveis"].get(nivel) for c in comparacao]
        fig.add_trace(go.Bar(name=ui.NOME_NIVEL[nivel], x=grupos, y=[v or 0 for v in valores],
                             marker=dict(color=ui.COR_GRAFICO[nivel], line=dict(color="#FFFFFF", width=2)),
                             customdata=["suprimido (< 5)" if v is None else v for v in valores],
                             hovertemplate="%{x} · " + ui.NOME_NIVEL[nivel] + ": %{customdata}<extra></extra>"))
    fig.update_layout(**_BASE, barmode="stack", height=altura, legend=dict(orientation="h", y=1.12, x=0),
                      yaxis=dict(gridcolor="#F0E5C8", title="alunos"), xaxis=dict(title=None))
    st.plotly_chart(fig, use_container_width=True, config=_CONFIG)
    with st.expander("Ver como tabela"):
        niveis = list(comparacao[0]["niveis"]) if comparacao else []
        ui.grade(["Grupo"] + [(ui.NOME_NIVEL[n], "d") for n in niveis],
                 [[ui.txt(c["grupo"])] + [ui.txt("suprimido" if c["niveis"].get(n) is None else c["niveis"][n])
                                          for n in niveis] for c in comparacao],
                 "Grupos com menos de 5 alunos aparecem como suprimido.", "Comparação entre grupos")


ORDEM_FAIXA = ["BAIXO", "MODERADO", "ALTO", "CRITICO"]


def faixa_distribuicao(distribuicao: list[dict]):
    """Barra unica 100% por nivel, Baixo -> Critico (Figma: Distribuicao por nivel de risco)."""
    por = {d["nivel"]: d for d in distribuicao}
    total = sum((por.get(n, {}).get("total") or 0) for n in ORDEM_FAIXA)
    if not total:
        st.caption("Sem dado: nenhum aluno com score neste recorte.")
        return
    partes = []
    for n in ORDEM_FAIXA:
        d = por.get(n) or {}
        fundo, texto, _, nome = ui.SELO[n]
        if d.get("total") is None and n in por:
            partes.append(f'<div class="mf-fx-sup" title="{nome}: suprimido (grupo menor que 5)">suprimido</div>')
            continue
        v = d.get("total") or 0
        if not v:
            continue
        pct = 100 * v / total
        rot = f"{ui.numero_br(pct, 0)}% {nome}" if pct >= 12 else f"{ui.numero_br(pct, 0)}%"
        partes.append(f'<div style="flex:{v} 1 0;background:{fundo};color:{texto}" title="{nome}: {v} alunos">'
                      f'{html.escape(rot) if pct >= 4 else ""}</div>')
    st.markdown(f'<div class="mf-faixa" role="img" aria-label="Distribuição por nível">{"".join(partes)}</div>',
                unsafe_allow_html=True)


def fatores_frequentes(fatores: list[dict], base: int | None):
    """Linhas com trilho e percentual (Figma: Fatores mais frequentes)."""
    if not fatores:
        st.caption("Sem dado.")
        return
    linhas = []
    for f in fatores:
        pct = (100 * f["alunos"] / base) if base else None
        largura = pct if pct is not None else 0
        valor = f"{ui.numero_br(pct, 0)}%" if pct is not None else f'{f["alunos"]}'
        linhas.append(f'<div class="mf-fator-l"><span class="n">{html.escape(f["fator"].capitalize())}</span>'
                      f'<span class="t"><i style="width:{largura:.1f}%"></i></span><span class="v">{valor}</span></div>')
    st.markdown("".join(linhas), unsafe_allow_html=True)


def evolucao_empilhada(serie: list[dict], altura=280):
    """Alertas em risco por dia, empilhado por nivel, legenda embaixo (Figma: Evolucao por periodo)."""
    if not serie:
        st.caption("Sem dado: ainda não há scores calculados.")
        return
    df = pd.DataFrame(serie)
    df["dia"] = pd.to_datetime(df["dia"]).dt.strftime("%d/%m")
    df["alto"] = df["em_risco"] - df["criticos"]
    fig = go.Figure()
    for coluna, nivel in (("alto", "ALTO"), ("criticos", "CRITICO")):
        fig.add_trace(go.Bar(x=df["dia"], y=df[coluna], name=ui.NOME_NIVEL[nivel],
                             width=[0.5] * len(df) if len(df) >= 6 else [0.5 * len(df) / 6] * len(df),
                             marker=dict(color=ui.COR_GRAFICO[nivel], line=dict(color="#FFFFFF", width=2)),
                             hovertemplate="%{x} · " + ui.NOME_NIVEL[nivel] + ": %{y}<extra></extra>"))
    fig.update_layout(**_BASE, barmode="stack", height=altura, bargap=0.45,
                      legend=dict(orientation="h", y=-0.18, x=0, traceorder="reversed", font=dict(size=13)),
                      yaxis=dict(visible=False), xaxis=dict(title=None, type="category", tickfont=dict(size=12,
                      color=ui.COR["text2"])))
    st.plotly_chart(fig, use_container_width=True, config=_CONFIG)
    if len(df) == 1:
        st.caption("Só há um dia de cálculo até agora: a série cresce a cada dia de uso.")
