"""Telas usadas por varios perfis: ficha do aluno, notificacoes, conta e assistente."""

import html

import pandas as pd
import plotly.graph_objects as go
import streamlit as st

import casca
import cliente
import ui

ROTULO_TENDENCIA = {"MELHORA": "↘ melhora", "ESTAVEL": "→ estável", "PIORA": "↗ piora",
                    "PIORA_SUSTENTADA": "⇈ piora sustentada", None: "sem histórico suficiente"}


# ---------------------------------------------------------------------------
# Ficha do aluno (Figma Parte 4), recortada pelo perfil no servidor
# ---------------------------------------------------------------------------

def _escolher_matricula() -> str | None:
    atual = st.session_state.get("ficha_matricula") or st.query_params.get("m")
    digitada = st.text_input("Matrícula", value=atual or "", max_chars=7,
                             help="Abra pela fila de alertas, pela lista de alunos ou digite a matrícula.")
    matricula = (digitada or "").strip().upper()
    if matricula:
        st.session_state["ficha_matricula"] = matricula
        st.query_params["m"] = matricula
    return matricula or None


def grafico_historico(serie: list[dict], cortes=(25, 50, 75)):
    if not serie:
        st.caption("Sem histórico de cálculo.")
        return
    df = pd.DataFrame(serie)
    df["quando"] = pd.to_datetime(df["calculado_em"])
    fig = go.Figure()
    for corte, nome in zip(cortes, ("Baixo | Moderado", "Moderado | Alto", "Alto | Crítico")):
        fig.add_hline(y=corte, line_width=1, line_dash="dot", line_color=ui.COR["text3"],
                      annotation_text=nome, annotation_position="top left",
                      annotation_font_color=ui.COR["text3"], annotation_font_size=11)
    fig.add_trace(go.Scatter(x=df["quando"], y=df["score"], mode="lines+markers", name="Score",
                             line=dict(color=ui.COR["deep"], width=2), marker=dict(size=9, color=ui.COR["deep"],
                                                                                   line=dict(width=2, color="#FFFFFF")),
                             customdata=df[["nivel", "versao_parametros"]].fillna("").values,
                             hovertemplate="%{x|%d/%m/%Y %H:%M}<br>Score %{y}<br>Nível %{customdata[0]}"
                                           "<br>Parâmetros %{customdata[1]}<extra></extra>"))
    fig.update_layout(height=260, margin=dict(l=10, r=10, t=10, b=10), showlegend=False,
                      paper_bgcolor="rgba(0,0,0,0)", plot_bgcolor="rgba(0,0,0,0)",
                      yaxis=dict(range=[0, 100], gridcolor="#F0E5C8",
                                 title=None), xaxis=dict(title=None, showgrid=False),
                      font=dict(color=ui.COR["text"]), hoverlabel=dict(bgcolor="#FFFFFF"))
    st.plotly_chart(fig, use_container_width=True, config={"displayModeBar": False})
    with st.expander("Ver como tabela"):
        ui.grade(["Calculado em", ("Score", "c"), "Nível", "Origem do nível", "Versão dos parâmetros"],
                 [[ui.txt(ui.data_br(l["calculado_em"])), ui.cel_nota(l["score"], None, 0), ui.selo(l["nivel"]),
                   ui.txt((l.get("nivel_origem") or "").replace("_", " ").lower() or None),
                   ui.txt(l.get("versao_parametros"))] for l in serie], rotulo="Histórico do score")


CATEGORIA_FATOR = {"notas": "Acadêmico", "frequencia": "Acadêmico", "reprovacao": "Acadêmico",
                   "engajamento_ava": "Acadêmico", "financeiro": "Socioeconômico", "trabalho": "Socioeconômico",
                   "dependentes": "Socioeconômico", "deslocamento": "Contexto", "moradia": "Contexto",
                   "saude_mental": "Saúde", "saude_fisica": "Saúde"}
CORTES = (25, 50, 75)


def escala_score(score):
    """Barra 0-100 com as quatro faixas do SRS (RN02) e o marcador do score (Figma: Score de risco)."""
    limites = (0,) + CORTES + (100,)
    faixas = "".join(f'<div style="flex:{limites[i + 1] - limites[i]};background:{ui.SELO[n][0]}"></div>'
                     for i, n in enumerate(("BAIXO", "MODERADO", "ALTO", "CRITICO")))
    marca = "" if score is None else f'<div class="mf-escala-mk"><i style="left:calc({min(max(score, 0), 100)}% - {3 if score >= 100 else 1}px)"></i></div>'
    return (f'<div class="mf-escala">{faixas}</div>{marca}<div class="mf-escala-num">'
            + "".join(f"<span>{v}</span>" for v in limites) + "</div>")


def bloco_score(score: dict):
    valor = score.get("score")
    c1, c2 = st.columns([1, 2.4], vertical_alignment="center")
    c1.markdown(f'<div class="mf-score">{"—" if valor is None else valor}<small>/100</small></div>'
                f'<div style="color:{ui.COR["deep"]};font-weight:600;font-size:14px;margin-top:4px">Classificação: '
                f'{ui.NOME_NIVEL.get(score.get("nivel") or "PENDENTE")}</div>', unsafe_allow_html=True)
    partes = [f"Atualizado em {ui.data_br(score.get('calculado_em'))}",
              f"modelo {score.get('versao_modelo', '—')}", f"parâmetros {score.get('versao_parametros', '—')}",
              f"completude {ui.numero_br((score.get('completude') or 0) * 100, 0)}%",
              f"tendência {ROTULO_TENDENCIA.get(score.get('tendencia'), score.get('tendencia'))}"]
    c2.markdown(escala_score(valor) + f'<div class="mf-h3sub" style="margin-top:10px">{" · ".join(partes)}</div>',
                unsafe_allow_html=True)
    if score.get("explicacao"):
        st.markdown(f'<div style="font-size:14px;color:{ui.COR["text"]}">{html.escape(score["explicacao"])}</div>',
                    unsafe_allow_html=True)
    if score.get("nivel_origem") == "SOBREPOSICAO":
        st.info(f"Nível elevado por regra de sobreposição: {score.get('motivo_sobreposicao')}")
    if score.get("parcial"):
        st.warning("Score parcial: menos de 70% dos dados disponíveis.")
    if score.get("aviso"):
        st.caption(score["aviso"])


def lista_fatores(fatores: list[dict]):
    if not fatores:
        st.caption("Nenhum fator a exibir.")
        return
    maximo = max([f.get("contribuicao_pontos") or 0 for f in fatores] + [1])

    def _peso(f):
        pontos = f.get("contribuicao_pontos")
        categoria = CATEGORIA_FATOR.get(f.get("fator"))
        cat = ui.pilula(categoria) if categoria else ""
        if pontos is not None:
            return (f'{ui.barra(pontos, maximo, ui.COR["mustard"], "96px")}'
                    f'<span>+{ui.numero_br(pontos)} pts</span>{cat}')
        return (ui.pilula(f"faixa {f['faixa']}") if f.get("faixa") else "") + cat

    ui.cartoes_fatores([f for f in fatores if f.get("fator") != "encaminhado"], _peso)
    if any(f.get("fator") == "encaminhado" for f in fatores):
        ui.restrito("Fator de contexto encaminhado ao núcleo de apoio (detalhe restrito, LGPD). "
                    "A contribuição dele está incluída no score.")


def linha_do_tempo(serie: list[dict], limite: int = 6):
    if not serie:
        st.caption("Sem histórico de cálculo.")
        return
    recentes = list(reversed(serie))[:limite]
    st.markdown("".join(
        f'<div class="mf-tempo{" atual" if n == 0 else ""}"><div style="display:flex;justify-content:space-between;'
        f'gap:8px;align-items:center"><div><b>{ui.data_br(h["calculado_em"])[:10]}</b><small>Score {h["score"]}'
        f'</small></div>{ui.selo(h["nivel"])}</div></div>' for n, h in enumerate(recentes)), unsafe_allow_html=True)
    st.caption("Classificações antigas nunca são sobrescritas.")


def ficha():
    perfil = st.session_state.get("perfil")
    topo, _ = st.columns([1, 3])
    with topo:
        matricula = _escolher_matricula()
    if not matricula:
        ui.cabecalho("Ficha do aluno", "Abra pela fila de alertas, pela lista de alunos ou digite a matrícula.",
                     "Acompanhamento")
        return

    dados = None
    with ui.secao():
        dados = cliente.get(f"/api/v1/alunos/{matricula}")
        a = dados.get("alerta")
        meta = [("id-card", f"Matrícula {dados['matricula']}"),
                ("graduation-cap", f"{dados.get('curso') or ''} · {dados.get('semestre') or '—'}º semestre")]
        if a:
            meta.append(("bell-ring", f"Alerta {a['situacao'].replace('_', ' ').lower()} · prazo "
                                      f"{ui.data_br(a['prazo_em'])}"))
        acoes = ui.heroi(dados["nome"], ui.selo(a["nivel"]) if a else "", meta)
        with acoes:
            if a and st.button("Abrir o alerta", key="abrir_alerta_ficha", type="primary"):
                ui.ir("alertas", alerta_aberto=a["id_alerta"])
    if dados is None:
        return

    lateral = perfil != "FINANCEIRO"
    # a coluna lateral fica com a altura do proprio conteudo (nao estica ate o fim da coluna principal)
    ui.css("[data-testid='stLayoutWrapper']:has(> .st-key-pn_s_historico_de_classificacoes),"
           " .st-key-pn_s_historico_de_classificacoes { height:auto !important; }")
    if lateral:
        principal, lado = st.columns([1.7, 1], gap="medium")
    else:
        principal, lado = st.container(), None

    with principal:
        @st.fragment(run_every="30s")
        def _score_ao_vivo():
            with ui.secao("Score de risco", chave="score"):
                score = cliente.get(f"/api/v1/alunos/{matricula}/score")
                st.markdown(f'<div style="margin:-6px 0 8px 0">{ui.selo_decisao()}</div>', unsafe_allow_html=True)
                bloco_score(score)
            with ui.secao("Fatores que explicam a classificação",
                          "Contribuição de cada fator para o score", chave="fatores"):
                lista_fatores(score.get("fatores", []))
                if score.get("modificadores"):
                    st.caption("Modificadores: " + "; ".join(
                        f"{m['id']} {m['descricao']} ({'+' if m['delta'] >= 0 else ''}{ui.numero_br(m['delta'], 0)})"
                        for m in score["modificadores"]))

        _score_ao_vivo()

    if lado is not None:
        with lado:
            if perfil in ("COORDENACAO", "NUCLEO_APOIO"):
                with ui.secao("Recomendações de ação"):
                    rec = cliente.get(f"/api/v1/alunos/{matricula}/recomendacoes")
                    st.markdown(
                        "".join(f'<div class="mf-card" style="height:auto;margin-bottom:10px;padding:14px 16px">'
                                f'<b style="font-size:14px;color:{ui.COR["text"]}">{html.escape(r["texto"])}</b>'
                                f'<div class="leg" style="display:flex;justify-content:space-between;gap:8px">'
                                f'<span>{ui.icone("link-2", 12)} Fator: {html.escape(r.get("fator_rotulo") or "—")}</span>'
                                f'<span>{html.escape(r["perfil_atendimento"])}</span></div></div>'
                                for r in rec["recomendacoes"]), unsafe_allow_html=True)
                    if not rec["recomendacoes"]:
                        st.caption(rec.get("observacao", ""))
                    st.caption("A recomendação é um apoio: quem decide e registra a ação é a equipe.")
            with ui.secao("Histórico de classificações"):
                serie = cliente.get(f"/api/v1/alunos/{matricula}/historico")
                linha_do_tempo(serie)
                with st.expander("Ver gráfico da evolução"):
                    grafico_historico(serie)

    if perfil != "FINANCEIRO":
        with ui.secao("Indicadores acadêmicos"):
            ac = (dados or {}).get("academico")
            if ac:
                a1, a2 = st.columns(2)
                with a1:
                    ui.card("Média do período", ui.numero_br(ac["media_atual"], 2), "ponderada pela carga horária",
                            "book-open")
                with a2:
                    ui.card("Frequência", f"{ui.numero_br(ac['frequencia_pct'])}%", "mínimo de 75%", "calendar-check")
            else:
                st.caption("Sem indicadores acadêmicos.")

        with ui.secao("Disciplinas"):
            disc = cliente.get(f"/api/v1/alunos/{matricula}/disciplinas")
            ui.grade(["Disciplina", ("Nota final", "c"), "Frequência", "Situação"],
                     [[ui.cel_dupla(d["disciplina"], d["periodo_letivo"]), ui.cel_nota(d["nota_final"], 6.0),
                       ui.cel_freq(d["frequencia_pct"], 75.0), ui.cel_situacao(d["situacao"])]
                      for d in disc["disciplinas"]],
                     "Em vermelho, abaixo da nota mínima (6,0) ou da frequência mínima (75%). Faltas restantes (RF17): "
                     "sem dado, porque o banco não registra aulas previstas nem faltas por disciplina.",
                     "Disciplinas do aluno")

    if perfil in ("COORDENACAO", "NUCLEO_APOIO", "FINANCEIRO") and dados:
        with ui.secao("Contexto socioeconômico"):
            if perfil == "COORDENACAO":
                st.write(f"Vulnerabilidade socioeconômica: **{dados.get('vulnerabilidade_socioeconomica') or 'sem dado'}**")
                ui.restrito("Valores de renda, trabalho e saúde ficam com o NAE (Anexo E).")
            elif perfil == "FINANCEIRO":
                fin = dados.get("financeiro") or {}
                st.write(f"Renda por pessoa: **{ui.numero_br(fin.get('renda_per_capita_sm'), 2)} salário(s) mínimo(s)** · "
                         f"auxílio: **{fin.get('auxilio_bolsa') or 'sem dado'}**")
                ui.restrito("Saúde e desempenho detalhado não aparecem para o setor financeiro.")
            else:
                soc = dados.get("socioeconomico") or {}
                st.write(f"Renda por pessoa: R$ {ui.numero_br(soc.get('renda_per_capita'), 2)} · "
                         f"trabalho: {soc.get('trabalha') or 'sem dado'} ({soc.get('horas_trabalho_dia') or 0} h/dia) · "
                         f"deslocamento: {soc.get('tempo_deslocamento_min') or 'sem dado'} min · "
                         f"auxílio: {soc.get('auxilio_bolsa') or 'sem dado'}")
                apoio = dados.get("apoio") or {}
                if apoio.get("disponivel") is False:
                    st.warning(apoio.get("motivo"))
                else:
                    st.write(f"Apoio psicossocial solicitado: {apoio.get('apoio_psicossocial_solicitado') or 'sem dado'} · "
                             f"necessidade de acessibilidade: {apoio.get('necessidade_acessibilidade') or 'sem dado'}")
                    st.caption("Dado sensível (LGPD, art. 11): esta leitura ficou registrada na trilha de auditoria.")

    with ui.secao("Acompanhamento"):
        hist = cliente.get(f"/api/v1/alunos/{matricula}/acompanhamento")
        if not hist["alertas"]:
            st.caption("Nenhum alerta registrado.")
        for a in hist["alertas"]:
            with st.expander(f"Alerta {a['id_alerta']} · {ui.NOME_NIVEL.get(a['nivel'], a['nivel'])} · "
                             f"{a['situacao'].replace('_', ' ').lower()} · criado {ui.data_br(a['criado_em'])}"):
                st.markdown("".join(
                    f'<div class="mf-tempo"><b>{e["tipo"].replace("_", " ").capitalize()}'
                    f'{" · " + e["tipo_acao"].replace("_", " ").lower() if e.get("tipo_acao") else ""}</b>'
                    f'<small>{ui.data_br(e["momento"])} · {html.escape(e["autor"])}</small>'
                    f'{"<p>" + html.escape(e["descricao"]) + "</p>" if e.get("descricao") else ""}</div>'
                    for e in a["eventos"]), unsafe_allow_html=True)
        for g in hist.get("agendamentos", []):
            st.markdown(f'<div class="mf-linha"><div><b>{ui.icone("calendar", 14)} {ui.data_br(g["inicio"])}</b>'
                        f'<small>{html.escape(g["situacao"].lower())}'
                        f'{" · exceção: " + html.escape(g["motivo_excecao"]) if g.get("motivo_excecao") else ""}'
                        '</small></div></div>', unsafe_allow_html=True)

    if perfil == "DOCENTE":
        ui.restrito("Você vê indicadores acadêmicos. Renda, trabalho, saúde e moradia ficam com o NAE.")


# ---------------------------------------------------------------------------
# Notificacoes e conta
# ---------------------------------------------------------------------------

def notificacoes():
    ui.cabecalho("Notificações", "Avisos de alertas, prazos e parâmetros · atualiza a cada 20 s")

    @st.fragment(run_every="20s")
    def _lista():
        with ui.secao():
            itens = cliente.get("/api/v1/conta/notificacoes", limite=50)
            with ui.painel("notificacoes"):
                e, d = st.columns([3, 1], vertical_alignment="center")
                e.markdown('<div class="mf-h3">Notificações</div>', unsafe_allow_html=True)
                if not itens:
                    st.caption("Nada por aqui. Avisos de alertas, prazos e parâmetros aparecem nesta tela.")
                    return
                with d:
                    if ui.texto_link("Marcar todas como lidas", "ler_todas"):
                        cliente.post("/api/v1/conta/notificacoes/leitura")
                        st.rerun()
                for n in itens:
                    nova = not n["lida_em"]
                    icone = "clock" if "prazo" in n["titulo"].lower() else (
                        "sliders-horizontal" if "parâmetro" in n["titulo"].lower() else "bell")
                    with st.container(key=f"lin_not_{n['id_notificacao']}"):
                        st.markdown(
                            f'<div style="display:flex;gap:14px;align-items:flex-start">'
                            f'<span class="mf-icbox" style="width:36px;height:36px;border-radius:10px">{ui.icone(icone, 18)}</span>'
                            f'<div style="flex:1"><b style="font-size:14px">{html.escape(n["titulo"])}</b>'
                            f'<div style="font-size:13px;color:{ui.COR["text"]};margin-top:4px">{html.escape(n["texto"])}</div>'
                            f'<small style="font-size:12px;color:{ui.COR["text2"]}">{ui.data_br(n["criada_em"])}</small></div>'
                            + (f'<span style="width:8px;height:8px;border-radius:999px;background:{ui.COR["gold"]};'
                               'margin-top:6px" aria-label="não lida"></span>' if nova else "")
                            + "</div>", unsafe_allow_html=True)
                        if n.get("id_alerta") and st.session_state.get("perfil") in ("COORDENACAO", "NUCLEO_APOIO",
                                                                                     "DOCENTE", "FINANCEIRO"):
                            if ui.texto_link("Abrir alerta", f"n{n['id_notificacao']}"):
                                cliente.post(f"/api/v1/conta/notificacoes/{n['id_notificacao']}/leitura")
                                ui.ir("alertas", alerta_aberto=n["id_alerta"])
                    if nova:
                        ui.css(f".st-key-lin_not_{n['id_notificacao']} {{ background:{ui.COR['creamSoft']}; }}")

    _lista()


def minha_conta():
    conta = st.session_state.get("conta", {})
    ui.cabecalho("Minha conta", "Seus dados de acesso e a troca de senha")
    ui.heroi(conta.get("nome") or conta.get("login") or "", ui.pilula(casca.NOME_PERFIL.get(conta.get("perfil"), "")),
             [("user", f"Login {conta.get('login')}"),
              ("shield-check", f"Termo aceito em {ui.data_br(conta.get('termo_aceito_em'))}"),
              ("clock", f"Último acesso {ui.data_br(conta.get('ultimo_login'))}")])
    esq, _ = st.columns([1.4, 1])
    with esq:
        with st.form("trocar"):
            ui.titulo_painel("Trocar senha", "Pelo menos 10 caracteres, com letras e números, sem o seu login")
            atual = st.text_input("Senha atual", type="password", max_chars=72)
            nova = st.text_input("Nova senha", type="password", max_chars=72)
            repetir = st.text_input("Repita a nova senha", type="password", max_chars=72)
            if st.form_submit_button("Salvar", type="primary"):
                if nova != repetir:
                    st.error("As senhas novas não conferem.")
                else:
                    try:
                        cliente.post("/api/v1/conta/senha", {"senha_atual": atual, "senha_nova": nova})
                        st.success("Senha alterada.")
                    except cliente.ErroAPI as e:
                        st.error(e.mensagem + " " + "; ".join(c["mensagem"] for c in e.campos or []))


# ---------------------------------------------------------------------------
# Assistente (chat em servico separado)
# ---------------------------------------------------------------------------

def _css_chat():
    c = ui.COR
    ui.css(f"""
  .st-key-pn_chat {{ background:#FFFFFF; border:1px solid {c['line']}; border-radius:16px; padding:16px 18px; }}
  .st-key-pn_chat [data-testid="stVerticalBlock"] {{ gap:14px; }}
  [data-testid="stChatMessage"] {{ background:#FFFFFF; border:1px solid {c['line']}; border-radius:16px;
      box-shadow:0 1px 3px rgba(61,43,31,.06); padding:14px 18px; gap:12px; box-sizing:border-box; width:auto; max-width:92%; min-width:0;
      align-self:flex-start; }}
  [data-testid="stChatMessage"] > div:last-child {{ min-width:0; }}
  [data-testid="stChatMessage"]:has([data-testid="stChatMessageAvatarUser"]) {{ background:{c['text']};
      border-color:{c['text']}; flex-direction:row-reverse; max-width:78%; margin-left:auto;
      align-self:flex-end; border-bottom-right-radius:4px; }}
  [data-testid="stChatMessage"]:has([data-testid="stChatMessageAvatarAssistant"]) {{ border-bottom-left-radius:4px; }}
  [data-testid="stChatMessage"]:has([data-testid="stChatMessageAvatarUser"]) * {{ color:#FFFFFF; }}
  .mf-msg {{ font-size:14.5px; line-height:1.6; color:{c['text']}; overflow-wrap:anywhere; }}
  .mf-msg p {{ margin:0 0 10px 0; }}
  .mf-msg p:last-child, .mf-msg ul:last-child {{ margin-bottom:0; }}
  .mf-msg ul {{ list-style:none; margin:2px 0 12px 0; padding:0; display:flex; flex-direction:column; gap:6px; }}
  .mf-msg li {{ background:#FFFFFF; border:1px solid {c['lineSoft']}; border-radius:10px; padding:8px 12px; }}
  .mf-msg li b {{ font-weight:600; }}
  .mf-msg li small {{ display:block; color:{c['text2']}; font-size:12.5px; margin-top:1px; }}
  .mf-msg .mf-msg-nota {{ font-size:12.5px; color:{c['text3']}; border-top:1px solid {c['line']}; padding-top:8px;
      margin-top:4px; }}
  [data-testid="stChatMessageAvatarUser"], [data-testid="stChatMessageAvatarAssistant"] {{
      background:{c['goldSoft']}; color:{c['deep']}; }}
  /* Cabecalho da conversa */
  .mf-chat-cab {{ display:flex; align-items:center; gap:12px; padding:2px 2px 14px 2px; border-bottom:1px solid {c['lineSoft']};
      margin-bottom:4px; }}
  .mf-chat-cab .av {{ width:40px; height:40px; border-radius:12px; background:{c['gold']}; color:{c['text']};
      display:flex; align-items:center; justify-content:center; flex:none; }}
  .mf-chat-cab b {{ display:block; font-size:15px; font-weight:700; color:{c['text']}; }}
  .mf-chat-cab small {{ display:flex; align-items:center; gap:6px; font-size:12.5px; color:{c['text2']}; }}
  .mf-chat-cab small i {{ width:8px; height:8px; border-radius:999px; background:{c['okFg']}; display:inline-block; }}
  /* Caixa de escrever: maior, com borda clara e botao de enviar visivel */
  .mf-chat-rotulo {{ display:flex; justify-content:space-between; align-items:baseline; gap:12px; margin:6px 2px 6px 2px; }}
  .mf-chat-rotulo b {{ font-size:14px; font-weight:600; color:{c['text']}; }}
  .mf-chat-rotulo small {{ font-size:12px; color:{c['text3']}; }}
  [data-testid="stChatInput"] {{ border:2px solid {c['gold']} !important; border-radius:16px !important;
      background:#FFFFFF !important; box-shadow:0 4px 14px rgba(140,100,16,.12); padding:6px 8px 6px 12px; }}
  [data-testid="stChatInput"] > div {{ background:transparent !important; border:none !important; height:auto !important;
      min-height:64px; align-items:flex-end !important; }}
  [data-testid="stChatInput"] > div > div:first-child, [data-testid="stChatInput"] > div > div:first-child div {{
      background:transparent !important; }}
  [data-testid="stChatInput"]:focus-within {{ border-color:{c['deep']} !important;
      box-shadow:0 0 0 4px rgba(201,151,32,.25); }}
  [data-testid="stChatInput"] textarea {{ font-size:15.5px !important; line-height:1.5 !important; min-height:64px !important;
      padding:10px 6px !important; color:{c['text']} !important; }}
  [data-testid="stChatInput"] textarea::placeholder {{ color:{c['text3']} !important; }}
  [data-testid="stChatInputSubmitButton"] {{ background:{c['gold']} !important; border-radius:12px !important;
      width:44px !important; height:44px !important; color:{c['text']} !important; align-self:flex-end; }}
  [data-testid="stChatInputSubmitButton"]:hover {{ background:{c['mustard']} !important; }}
  [data-testid="stChatInputSubmitButton"] svg {{ width:20px; height:20px; }}
  [data-testid="stChatInputSubmitButton"]:disabled {{ opacity:.45; }}
  /* Sugestoes */
  .mf-sug-rot {{ font-size:12px; font-weight:700; color:{c['deep']}; letter-spacing:.02em; margin:8px 2px 2px 2px; }}
  [class*="st-key-sug_"] {{ gap:8px !important; }}
  [class*="st-key-sug_"] button {{ border-radius:999px; border:1px solid {c['line']}; background:{c['creamSoft']};
      min-height:34px; padding:4px 14px; }}
  [class*="st-key-sug_"] button:hover {{ border-color:{c['gold']}; background:{c['goldSoft']}; }}
  [class*="st-key-sug_"] button p {{ font-size:13px; }}
  .mf-pode div {{ display:flex; gap:8px; align-items:center; font-size:13px; color:{c['text']}; margin:8px 0; }}
""")


_INICIO_AVISO_METODOLOGICO = "O nível de risco indica que o padrão"


def _item_html(linha: str, sublinhas: list[str]) -> str:
    texto = linha[2:].strip()
    rotulo, sep, resto = texto.partition(": ")
    corpo = (f"<b>{html.escape(rotulo)}</b>: {html.escape(resto)}" if sep and len(rotulo) <= 60
             else html.escape(texto))
    corpo += "".join(f"<small>{html.escape(s.strip())}</small>" for s in sublinhas)
    return f"<li>{corpo}</li>"


def formatar_resposta(texto: str) -> str:
    """
    Resposta do assistente em HTML seguro: todo trecho passa por html.escape.
    Paragrafos separados por linha em branco; linhas com "• " viram itens,
    e a linha recuada logo abaixo de um item vira o detalhe dele.
    """
    blocos = []
    for bloco in (b for b in texto.strip().split("\n\n") if b.strip()):
        linhas = bloco.split("\n")
        if linhas[0].lstrip().startswith("• "):
            itens, atual, subs = [], None, []
            for l in linhas:
                if l.lstrip().startswith("• "):
                    if atual is not None:
                        itens.append(_item_html(atual, subs))
                    atual, subs = l.lstrip(), []
                elif atual is not None and l.strip():
                    subs.append(l)
            if atual is not None:
                itens.append(_item_html(atual, subs))
            blocos.append("<ul>" + "".join(itens) + "</ul>")
        elif bloco.startswith(_INICIO_AVISO_METODOLOGICO):
            blocos.append(f'<p class="mf-msg-nota">{html.escape(bloco)}</p>')
        else:
            blocos.append("<p>" + "<br>".join(html.escape(l) for l in linhas) + "</p>")
    return '<div class="mf-msg">' + "".join(blocos) + "</div>"


def assistente():
    _css_chat()
    principal, lado = st.columns([2.3, 1], gap="medium")
    with lado:
        with ui.painel("chat_pode"):
            ui.titulo_painel("O assistente pode")
            pode = (("Mostrar suas notas, frequência e risco", "Avisar o que vence e o que está atrasado",
                     "Conversar sobre rotina e dicas de estudo") if st.session_state.get("perfil") == "ALUNO" else
                    ("Buscar alunos combinando frequência, média, faltas e pendências", "Resumir o risco das turmas",
                     "Mostrar a situação de um aluno pela matrícula"))
            st.markdown('<div class="mf-pode">' + "".join(
                f'<div>{ui.icone("check", 14, ui.COR["deep"])}{t}</div>' for t in pode)
                + "</div>", unsafe_allow_html=True)
            ui.titulo_painel("O assistente não pode")
            st.markdown('<div class="mf-pode">' + "".join(
                f'<div>{ui.icone("x", 14, ui.COR["errFg"])}{t}</div>' for t in
                ("Mostrar dados restritos a outro perfil", "Tomar decisões ou alterar registros")) + "</div>",
                unsafe_allow_html=True)
    with principal:
        ui.cabecalho("Assistente", "Pergunte em linguagem natural sobre os dados que o seu perfil pode ver.")
        if not cliente.servico_disponivel("chat"):
            st.warning("O assistente está fora do ar no momento. O restante do painel continua funcionando.")
            return
        with ui.secao():
            if "chat_abertura" not in st.session_state:
                st.session_state["chat_abertura"] = cliente.chamar("GET", "/api/v1/chat/abertura", servico="chat")
                st.session_state["chat_msgs"] = []
            ab = st.session_state["chat_abertura"]
            ui.aviso("Responde só com os dados que o seu perfil pode ver e não altera nada no sistema",
                     f"{ab['disponibilidade']} {ab['atendimento_humano']}", "info")
            st.markdown(f'<div class="mf-chat-cab"><span class="av">{ui.icone("sparkles", 20)}</span><div>'
                        '<b>Mufa</b><small><i></i>Assistente do MUFASA · responde na hora</small></div></div>',
                        unsafe_allow_html=True)
            with st.container(key="pn_chat", height=520, border=False):
                # A abertura da Mufa e a primeira mensagem da conversa, no mesmo formato das respostas.
                for papel, texto in [("assistant", ab["mensagem"])] + st.session_state["chat_msgs"]:
                    with st.chat_message(papel):
                        # Todo texto (pergunta e resposta) e escapado antes de virar HTML.
                        st.markdown(formatar_resposta(texto), unsafe_allow_html=True)
            sugestao = None
            if ab.get("opcoes"):
                st.markdown('<div class="mf-sug-rot">SUGESTÕES PARA COMEÇAR</div>', unsafe_allow_html=True)
                with st.container(horizontal=True, key="sug_opcoes"):
                    for i, op in enumerate(ab["opcoes"][:5]):
                        if st.button(op, key=f"op{i}"):
                            sugestao = op
            exemplo = ("Ex.: o que vence esta semana? Como estão minhas notas?" if st.session_state.get("perfil") == "ALUNO"
                       else "Ex.: alunos com frequência abaixo de 70% e média abaixo de 5")
            st.markdown('<div class="mf-chat-rotulo"><b>Escreva sua pergunta</b>'
                        '<small>Enter envia · Shift + Enter pula linha</small></div>', unsafe_allow_html=True)
            pergunta = st.chat_input(exemplo, max_chars=500) or sugestao
            if pergunta:
                st.session_state["chat_msgs"].append(("user", pergunta))
                try:
                    r = cliente.chamar("POST", "/api/v1/chat/consultas", servico="chat", json={"texto": pergunta})
                    resposta = r["resposta"] + (f"\n\n{r['aviso']}" if r.get("aviso") else "")
                except cliente.ErroAPI as e:
                    resposta = e.mensagem
                st.session_state["chat_msgs"].append(("assistant", resposta))
                st.rerun()
