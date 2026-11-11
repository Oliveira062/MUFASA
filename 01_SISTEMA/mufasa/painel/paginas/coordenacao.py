"""Coordenacao: hub (painel do curso), alunos do curso e aprovacao de parametros."""

import html

import streamlit as st

import cliente
import ui
from paginas import alertas, paineis
from paginas.admin import tabela_parametros


def _atencao():
    """Figma P2: "Precisam de atencao agora" - os 4 alertas mais prioritarios da fila."""
    ui.titulo_painel("Precisam de atenção agora", "Somente a Coordenação e o NAE responsável veem nomes nesta visão")
    r = cliente.get("/api/v1/alertas", limite=4)
    if not r["itens"]:
        st.caption("Nenhum alerta ativo no curso.")
    for i in r["itens"]:
        prazo = "prazo vencido" if i["vencido"] else f"prazo {ui.data_br(i['prazo_em'])[:5]}"
        a, b, c = st.columns([5, 1.7, 0.5], vertical_alignment="center")
        a.markdown(f'<div class="mf-lista-l"><span class="mf-avatar">{html.escape(ui.iniciais(i["nome"]))}</span>'
                   f'<div><b>{html.escape(i["nome"])}</b><small>{i["matricula"]} · {i["semestre"]}º semestre · '
                   f'{prazo}</small></div></div>', unsafe_allow_html=True)
        b.markdown(f'<div style="text-align:right">{ui.selo(i["nivel"])}</div>', unsafe_allow_html=True)
        with c:
            with st.container(key=f"abrir_{i['id_alerta']}"):
                if st.button("Abrir", key=f"h{i['id_alerta']}", help=f"Abrir o alerta de {i['nome']}"):
                    ui.ir("alertas", alerta_aberto=i["id_alerta"])
    with st.container(key="link_todos"):
        if st.button("Ver todos os alunos do curso  →"):
            ui.ir("alunos")


def hub():
    conta = st.session_state.get("conta", {})
    curso = conta.get("curso") or "Curso"
    esq, meio, dir_ = st.columns([2.4, 1.3, 0.6], vertical_alignment="top")
    with esq:
        ui.cabecalho("Painel do curso", f"{curso} · indicadores do curso, atualizados automaticamente",
                     "Coordenação acadêmica")
    meio.markdown(f'<div class="mf-curso">{ui.icone("graduation-cap", 16, ui.COR["deep"])}{html.escape(curso)}</div>',
                  unsafe_allow_html=True)
    with dir_:
        f = paineis.filtros()
    paineis.painel("COORDENACAO", f=f, atencao=_atencao)
    with st.container(key="banner"):
        a, b = st.columns([3, 1], vertical_alignment="center")
        with a:
            ui.banner("Atalho para intervenções prioritárias",
                      "Os alertas críticos têm prazo de 48 horas; os altos, de 5 dias úteis.")
        with b:
            if st.button("Ver alertas críticos  →", type="primary", width="stretch", key="banner_criticos"):
                ui.ir("alertas", alerta_aberto=None, filtro_fila_nivel="Crítico")


def alunos():
    esq, dir_ = st.columns([3, 1.4], vertical_alignment="top")
    with esq:
        ui.cabecalho("Alunos acompanhados", "Estudantes do curso com classificação ativa · vulnerabilidade exibida "
                     "apenas como faixa qualitativa", "Coordenação acadêmica")
    dir_.markdown(f'<div style="text-align:right;margin-top:18px">{ui.selo_decisao()}</div>', unsafe_allow_html=True)
    c1, c2, c3, c4 = st.columns([2.2, 1, 1, 0.7], vertical_alignment="bottom")
    busca = c1.text_input("Buscar por nome ou matrícula", max_chars=60, placeholder="Buscar por nome ou matrícula…")
    opcoes = ["Todos", "Crítico", "Alto", "Moderado", "Baixo", "Indeterminado"]
    vindo = st.session_state.pop("filtro_alunos_nivel", None)
    nivel = c2.selectbox("Nível", opcoes, index=opcoes.index(vindo) if vindo in opcoes else 0)
    ordem = c3.selectbox("Ordenar por", ["risco", "nome", "semestre", "matricula"])
    pagina = c4.number_input("Página", min_value=1, value=1)
    codigo = {"Crítico": "CRITICO", "Alto": "ALTO", "Moderado": "MODERADO", "Baixo": "BAIXO",
              "Indeterminado": "INDETERMINADO"}.get(nivel)
    with ui.secao():
        r = cliente.get("/api/v1/alunos", busca=busca or None, nivel=codigo, ordem=ordem, limite=50, pagina=int(pagina))
        alertas.tabela_alunos(r["itens"], r["total"])
        ui.botao_exportar([{"matricula": i["matricula"], "nome": i["nome"], "semestre": i["semestre"],
                            "nivel": i["nivel_risco"], "score": i["score"]} for i in r["itens"]],
                          ["matricula", "nome", "semestre", "nivel", "score"], "Alunos do curso", "alunos_curso.csv")


def parametros():
    ui.cabecalho("Parâmetros do modelo", "Nota mínima e cortes de risco mudam só com aprovação da coordenação; "
                 "intervalo entre atendimentos e teto de alertas são definidos pela coordenação (Anexo B).",
                 "Coordenação acadêmica")
    with ui.secao("Propostas aguardando aprovação"):
        dados = cliente.get("/api/v1/parametros")
        pendentes = [p for p in dados["propostas"] if p["situacao"] == "PENDENTE"]
        if not pendentes:
            st.caption("Nenhuma proposta pendente.")
        for p in pendentes:
            st.markdown(f'<div class="mf-linha"><div><b>{html.escape(p["chave"])}: {p["valor_anterior"]:g} → '
                        f'{p["valor_novo"]:g}</b><small>Proposta por {html.escape(p["proposto_por"])} em '
                        f'{ui.data_br(p["proposto_em"])} · justificativa: {html.escape(p["justificativa"])}</small></div>'
                        f'{ui.pilula("Aguardando aprovação", contorno=True)}</div>', unsafe_allow_html=True)
            a, b = st.columns(2)
            if a.button("Aprovar", key=f"ap{p['id_proposta']}", type="primary"):
                r = cliente.post(f"/api/v1/parametros/propostas/{p['id_proposta']}/decisao", {"aprovar": True})
                st.success(f"Aprovada: versão {r['versao']} criada. Os alunos serão recalculados.")
            if b.button("Rejeitar", key=f"rj{p['id_proposta']}"):
                cliente.post(f"/api/v1/parametros/propostas/{p['id_proposta']}/decisao", {"aprovar": False})
                st.info("Proposta rejeitada.")
    with ui.secao("Parâmetros da coordenação"):
        for chave in ("INTERVALO_ATENDIMENTOS", "TETO_ALERTAS_RESPONSAVEL"):
            atual = next(p for p in dados["parametros"] if p["chave"] == chave)
            with st.form(f"f{chave}"):
                st.markdown(f"**{atual['descricao']}** (atual: {atual['valor']:g} {atual['unidade']})")
                valor = st.number_input("Novo valor", min_value=float(atual["minimo"]), max_value=float(atual["maximo"]),
                                        value=float(atual["valor"]), step=1.0)
                just = st.text_input("Justificativa", max_chars=500)
                if st.form_submit_button("Salvar nova versão"):
                    r = cliente.put(f"/api/v1/parametros/{chave}", {"valor": valor, "justificativa": just})
                    st.success(f"Versão {r.get('versao')} criada.")
    with ui.secao("Todos os parâmetros vigentes"):
        tabela_parametros(dados)
