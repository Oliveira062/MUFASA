"""Portal do aluno (Figma Parte 5): situacao de acompanhamento, sem numero de score (RN17)."""

import html
import json
from datetime import datetime, time, timedelta
from zoneinfo import ZoneInfo

import streamlit as st

import cliente
import ui

FUSO = ZoneInfo("America/Sao_Paulo")
VERSAO_TERMO = "1.0"
TIPOS_PEDIDO = {"Confirmar que tratam meus dados e ver quais": "CONFIRMACAO_ACESSO",
                "Corrigir um dado": "CORRECAO", "Anonimizar ou eliminar dados": "ANONIMIZACAO_ELIMINACAO",
                "Portabilidade dos meus dados": "PORTABILIDADE",
                "Revisão de decisão automatizada (art. 20)": "REVISAO_DECISAO_AUTOMATIZADA",
                "Saber com quem meus dados são compartilhados": "INFORMACAO_COMPARTILHAMENTO",
                "Revogar consentimento": "REVOGACAO_CONSENTIMENTO", "Opor-me a um tratamento": "OPOSICAO"}


def _ponderada(disciplinas: list[dict], campo: str):
    """Media ponderada pela carga horaria, a mesma regra do calculo (indicadores.calcular_media_ponderada)."""
    pares = [(d[campo], d["carga_horaria_h"] or 0) for d in disciplinas if d[campo] is not None]
    peso = sum(p for _, p in pares)
    return None if not pares or peso == 0 else sum(v * p for v, p in pares) / peso


def hub():
    conta = st.session_state.get("conta", {})
    ui.cabecalho(f"Olá, {(conta.get('nome') or conta.get('login') or '').split(' ')[0]}!",
                 "Que bom te ver por aqui. Este é o resumo do seu semestre: só você vê estes dados.")

    @st.fragment(run_every="30s")
    def _resumo():
        situacao = disc = None
        with ui.secao():
            situacao = cliente.get("/api/v1/aluno/situacao")
        with ui.secao():
            disc = cliente.get("/api/v1/aluno/disciplinas")
        c = st.columns(3)
        if disc is not None:
            lista = disc["disciplinas"]
            freq, media = _ponderada(lista, "frequencia_pct"), _ponderada(lista, "nota_final")
            with c[0]:
                ui.card("Frequência", "sem dado" if freq is None else f"{ui.numero_br(freq)}%",
                        f"mínimo de {disc['frequencia_minima']:g}%", "calendar-check")
            with c[1]:
                ui.card("Média parcial", ui.numero_br(media),
                        f"em {len(lista)} disciplinas · mínimo {disc['nota_minima']:g}", "book-open")
        if situacao is not None:
            with c[2]:
                ui.card("Situação de acompanhamento", situacao["situacao"],
                        f"atualizado {ui.data_br(situacao.get('atualizado_em'))}", "heart-handshake")
            ui.aviso("Sua situação", situacao["mensagem"], "info")
            if situacao.get("canal_imediato"):
                if st.button(situacao["canal_imediato"]["texto"], type="primary"):
                    ui.ir("assistente")
    _resumo()

    ui.titulo_painel("Atalhos")
    a, b, c = st.columns(3)
    with a:
        ui.atalho("apoio", "apoio", "Apoio", "NAE, coordenação e auxílios", "hand-heart")
    with b:
        ui.atalho("assistente", "assistente", "Assistente", "Tire dúvidas sobre seus dados", "message-circle")
    with c:
        ui.atalho("indicadores", "indicadores", "Meus indicadores", "Notas, frequência e acompanhamento", "chart-line")
    with ui.secao():
        consent = cliente.get("/api/v1/privacidade/consentimentos")
        atual = next((x for x in consent if x["finalidade"] == "DADOS_SAUDE"), None)
        e, d = st.columns([5, 1], vertical_alignment="center")
        with e:
            ui.aviso("Consentimento de dados de saúde: " + ("autorizado" if atual and atual["concedido"]
                                                             else "não autorizado"),
                     "É opcional e você pode revogar quando quiser.", "heart-pulse")
        with d:
            if ui.texto_link("Gerenciar", "consent_gerenciar"):
                ui.ir("privacidade")
    with ui.secao("Registros da equipe para você"):
        acomp = cliente.get("/api/v1/aluno/acompanhamento")
        if not acomp["registros"]:
            st.caption("Nenhum registro compartilhado com você ainda.")
        st.markdown("".join(
            f'<div class="mf-tempo"><b>{html.escape((r.get("tipo_acao") or "registro").replace("_", " ").capitalize())}'
            f'</b><small>{ui.data_br(r["momento"])}</small><p>{html.escape(r.get("descricao") or "")}</p></div>'
            for r in acomp["registros"][:5]), unsafe_allow_html=True)


def indicadores():
    ui.cabecalho("Meus indicadores", "Notas, frequência e o que influencia a sua situação", "Portal do aluno")
    with ui.secao("Disciplinas do semestre"):
        disc = cliente.get("/api/v1/aluno/disciplinas")
        linhas = disc["disciplinas"]
        if not linhas:
            st.caption("Nenhuma disciplina registrada.")
        else:
            nmin, fmin = disc["nota_minima"], disc["frequencia_minima"]
            aprovadas = sum(1 for d in linhas if "APROVAD" in (d["situacao"] or "").upper())
            ui.resumo([("disciplinas no semestre", len(linhas), "neutro"),
                       ("aprovadas", aprovadas, "ok" if aprovadas else "neutro"),
                       ("abaixo da nota mínima", sum(1 for d in linhas if d["nota_abaixo_do_minimo"]),
                        "alerta" if any(d["nota_abaixo_do_minimo"] for d in linhas) else "ok"),
                       ("abaixo da frequência mínima", sum(1 for d in linhas if d["frequencia_abaixo_do_minimo"]),
                        "alerta" if any(d["frequencia_abaixo_do_minimo"] for d in linhas) else "ok")])
            ui.grade([("Disciplina", "e"), ("VA1", "c"), ("VA2", "c"), ("VA3", "c"), ("Nota final", "c"),
                      ("Frequência", "e"), ("Situação", "e"), ("Atenção", "e")],
                     [[ui.cel_dupla(d["disciplina"], d["professor"]),
                       ui.cel_nota(d["va1"], None), ui.cel_nota(d["va2"], None), ui.cel_nota(d["va3"], None),
                       ui.cel_nota(d["nota_final"], nmin), ui.cel_freq(d["frequencia_pct"], fmin),
                       ui.cel_situacao(d["situacao"]),
                       ui.cel_alertas([x for x, ok in (("Nota", d["nota_abaixo_do_minimo"]),
                                                       ("Frequência", d["frequencia_abaixo_do_minimo"])) if ok])]
                      for d in linhas],
                     legenda=f"Nota mínima {ui.numero_br(nmin)} e frequência mínima {ui.numero_br(fmin, 0)}%. "
                             "Em vermelho, o que está abaixo do mínimo. " + linhas[0]["observacao_faltas"],
                     rotulo="Disciplinas do semestre")
    with ui.secao("O que influencia sua situação"):
        sit = cliente.get("/api/v1/aluno/situacao")
        ui.nota_metodologica(sit["aviso"])
        if not sit["fatores"]:
            st.caption("Nenhum fator em atenção.")
        ui.cartoes_fatores(sit["fatores"])
        if sit.get("pode_contestar") and sit["fatores"]:
            with st.form("contestar"):
                ui.titulo_painel("Algum dado está errado?", "Peça a verificação (RN17)")
                opcoes = {f["nome"].capitalize(): f["fator"] for f in sit["fatores"]}
                fator = st.selectbox("Fator", list(opcoes))
                desc = st.text_area("O que está errado", max_chars=1000)
                if st.form_submit_button("Enviar contestação"):
                    try:
                        r = cliente.post("/api/v1/aluno/contestacoes", {"fator": opcoes[fator], "descricao": desc})
                        st.success(f"Contestação registrada. {r['prazo']}")
                    except cliente.ErroAPI as e:
                        st.error(e.mensagem + (" " + "; ".join(c["mensagem"] for c in e.campos) if e.campos else ""))


def apoio():
    ui.cabecalho("Apoio e agendamento", "Canais da instituição e conversa com o núcleo de apoio", "Portal do aluno")
    with ui.secao("Apoios indicados para você"):
        sit = cliente.get("/api/v1/aluno/situacao")
        st.markdown(f"Situação: {ui.pilula(sit['situacao'])}", unsafe_allow_html=True)
        if not sit["apoios"]:
            st.caption("Nenhuma indicação no momento. Você pode marcar uma conversa quando quiser.")
        st.markdown("".join(f'<div class="mf-linha"><div><b>{ui.icone("hand-heart", 14, ui.COR["deep"])} '
                            f'{html.escape(a["texto"])}</b></div></div>' for a in sit["apoios"]),
                    unsafe_allow_html=True)
    with ui.secao("Agendar atendimento"):
        ag = cliente.get("/api/v1/agendamentos")
        st.caption(f"Intervalo mínimo entre atendimentos: {ag['intervalo_minimo_dias']} dias (RN14)."
                   + (f" Próxima data livre: {ui.data_br(ag['proxima_data_livre'])[:10]}."
                      if ag.get("proxima_data_livre") else ""))
        with st.form("agendar"):
            amanha = datetime.now(FUSO).date() + timedelta(days=1)
            dia = st.date_input("Dia", value=amanha, min_value=amanha, max_value=amanha + timedelta(days=179),
                                format="DD/MM/YYYY")
            horarios = [time(h, m) for h in range(8, 21) for m in (0, 30)]
            hora = st.selectbox("Horário", horarios, format_func=lambda t: t.strftime("%H:%M"), index=4)
            if st.form_submit_button("Marcar", type="primary"):
                inicio = datetime.combine(dia, hora, tzinfo=FUSO)
                try:
                    r = cliente.post("/api/v1/agendamentos", {"inicio": inicio.isoformat()})
                    st.success("Atendimento marcado." + (f" {r['excecao']}" if r.get("excecao") else ""))
                except cliente.ErroAPI as e:
                    st.warning(e.mensagem)
        for g in ag["agendamentos"]:
            col = st.columns([3, 2, 1], vertical_alignment="center")
            col[0].markdown(f'{ui.icone("calendar", 14, ui.COR["deep"])} {ui.data_br(g["inicio"])}',
                            unsafe_allow_html=True)
            col[1].markdown(ui.pilula(g["situacao"].capitalize(), contorno=True), unsafe_allow_html=True)
            if g["situacao"] == "MARCADO" and col[2].button("Cancelar", key=f"cg{g['id_agendamento']}"):
                with ui.secao():
                    cliente.patch(f"/api/v1/agendamentos/{g['id_agendamento']}", {"situacao": "CANCELADO"})
                    st.rerun()


def privacidade():
    ui.cabecalho("Privacidade e meus dados", "Seus direitos pela LGPD (art. 18). Revogar um consentimento nunca "
                 "prejudica você.", "Portal do aluno")
    with ui.secao("Consentimento para dados de saúde"):
        consent = cliente.get("/api/v1/privacidade/consentimentos")
        atual = next((c for c in consent if c["finalidade"] == "DADOS_SAUDE"), None)
        concedido = bool(atual and atual["concedido"])
        st.markdown("Situação atual: " + ui.pilula("Concedido" if concedido else "Não concedido", contorno=True)
                    + (f" em {ui.data_br(atual['registrado_em'])}" if atual else ""), unsafe_allow_html=True)
        if st.button("Revogar consentimento" if concedido else "Conceder consentimento"):
            try:
                cliente.post("/api/v1/privacidade/consentimentos",
                             {"finalidade": "DADOS_SAUDE", "concedido": not concedido, "versao_termo": VERSAO_TERMO})
                st.rerun()
            except cliente.ErroAPI as e:
                st.warning(e.mensagem)
    with ui.secao("Meus dados"):
        st.caption("Uma cópia de tudo o que o MUFASA guarda sobre você, em formato aberto (JSON).")
        if st.button("Preparar cópia dos meus dados"):
            dados = cliente.get("/api/v1/privacidade/meus-dados")
            st.download_button("Baixar (JSON)", json.dumps(dados, ensure_ascii=False, indent=2).encode("utf-8"),
                               "meus_dados_mufasa.json", "application/json")
    with ui.secao("Fazer um pedido ao encarregado de dados"):
        with st.form("pedido"):
            tipo = st.selectbox("Pedido", list(TIPOS_PEDIDO))
            desc = st.text_area("Detalhes (opcional)", max_chars=1000)
            if st.form_submit_button("Enviar pedido"):
                try:
                    r = cliente.post("/api/v1/privacidade/solicitacoes", {"tipo": TIPOS_PEDIDO[tipo], "descricao": desc})
                    st.success(f"Pedido registrado. {r['prazo']}")
                except cliente.ErroAPI as e:
                    st.error(e.mensagem)
        acomp = cliente.get("/api/v1/aluno/acompanhamento")
        if acomp["pedidos"]:
            ui.grade(["Pedido", "Situação", "Registrado", "Respondido"],
                     [[ui.txt(p["tipo"].replace("_", " ").capitalize()), ui.cel_situacao(p["situacao"]),
                       ui.txt(ui.data_br(p["registrada_em"])), ui.txt(ui.data_br(p.get("respondida_em")) or None)]
                      for p in acomp["pedidos"]], rotulo="Meus pedidos")
