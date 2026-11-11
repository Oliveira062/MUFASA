"""Painel analitico comum a coordenacao (curso) e gestao (instituicao) - Figma Parte 2."""

import streamlit as st

import cliente
import graficos
import ui
from paginas.alertas import CAUSAS

NOME_CAUSA = {v: k for k, v in CAUSAS.items()}

TURNOS = ["Todos", "Matutino", "Vespertino", "Noturno"]
TENDENCIAS = {"Todas": None, "Piora sustentada": "PIORA_SUSTENTADA", "Piora": "PIORA", "Estável": "ESTAVEL",
              "Melhora": "MELHORA"}
FATORES = {"Todos": None, "Desempenho acadêmico": "notas", "Frequência": "frequencia",
           "Histórico de reprovações": "reprovacao", "Situação financeira": "financeiro", "Trabalho": "trabalho",
           "Deslocamento": "deslocamento"}
ROTULO_ALERTA = {"abertos": "Alertas ativos", "vencidos": "Prazo vencido", "sem_responsavel": "Sem responsável",
                 "em_atendimento": "Em atendimento", "tarefas_dados": "Tarefas de dados", "encerrados": "Encerrados"}


def _pct(valor) -> str:
    return "sem dado" if valor is None else f"{ui.numero_br(valor)}%"


def filtros() -> dict:
    """Filtros combinaveis, refletidos na URL (RF07). Botao "Filtros" do Figma, em janela suspensa."""
    qp = st.query_params
    ativos = sum(k in qp for k in ("semestre", "turno", "tendencia", "fator"))
    with st.container(key="filtros"):
        with st.popover("Filtros" + (f" · {ativos}" if ativos else ""), width="stretch"):
            semestre = st.selectbox("Semestre atual", ["Todos"] + list(range(1, 11)),
                                    index=int(qp["semestre"]) if qp.get("semestre", "").isdigit() else 0)
            turno = st.selectbox("Turno", TURNOS, index=TURNOS.index(qp["turno"]) if qp.get("turno") in TURNOS else 0)
            tendencia = st.selectbox("Tendência", list(TENDENCIAS),
                                     index=list(TENDENCIAS).index(qp["tendencia"]) if qp.get("tendencia") in TENDENCIAS
                                     else 0)
            fator = st.selectbox("Fator predominante", list(FATORES),
                                 index=list(FATORES).index(qp["fator"]) if qp.get("fator") in FATORES else 0)
    for chave, valor in (("semestre", semestre), ("turno", turno), ("tendencia", tendencia), ("fator", fator)):
        if valor in ("Todos", "Todas"):
            st.query_params.pop(chave, None)
        else:
            st.query_params[chave] = str(valor)
    return {"semestre": None if semestre == "Todos" else semestre, "turno": turno,
            "tendencia": TENDENCIAS[tendencia], "fator": FATORES[fator]}


def css_painel():
    c = ui.COR
    regras = [f"""
  .st-key-filtros {{ margin-top:18px; }}
  .st-key-filtros button {{ height:44px; border:1px solid {c['gold']} !important; color:{c['deep']} !important;
      padding-left:40px; position:relative; }}
  .st-key-filtros button::before {{ content:""; position:absolute; left:16px; top:13px; width:16px; height:16px;
      background-color:{c['deep']}; -webkit-mask:{ui.icone_url('sliders-horizontal', '#000')} no-repeat center/contain;
      mask:{ui.icone_url('sliders-horizontal', '#000')} no-repeat center/contain; }}
  .mf-curso {{ margin-top:18px; display:flex; gap:10px; align-items:center; height:44px; padding:0 16px; border:1px solid {c['line']};
              border-radius:10px; font-size:14px; font-weight:500; color:{c['text']}; white-space:nowrap; overflow:hidden; }}
  [class*="st-key-chip_"] button {{ border-radius:10px; min-height:44px; padding:4px 12px 4px 6px; justify-content:flex-start;
      gap:10px; font-weight:600; white-space:nowrap; }}
  [class*="st-key-chip_"] button p {{ white-space:nowrap; }}
  [class*="st-key-chip_"] button:disabled {{ opacity:1; cursor:default; background:#FFFFFF; color:{c['text']}; }}
  [class*="st-key-chip_"] button::before {{ border-radius:999px; padding:3px 12px 3px 30px; font-size:13px; font-weight:600;
      background-repeat:no-repeat; background-position:10px center; background-size:14px; }}
  [class*="st-key-chip_"] button::after {{ content:""; width:14px; height:14px; margin-left:auto; background-color:{c['text2']};
      -webkit-mask:{ui.icone_url('chevron-right', '#000')} no-repeat center/contain;
      mask:{ui.icone_url('chevron-right', '#000')} no-repeat center/contain; flex:none; }}
  [class*="st-key-abrir_"] button {{ border:none; background:transparent; width:36px; min-height:36px; padding:0; }}
  [class*="st-key-abrir_"] button p {{ font-size:0 !important; }}
  [class*="st-key-abrir_"] button::before {{ content:""; width:16px; height:16px; background-color:{c['text2']};
      -webkit-mask:{ui.icone_url('chevron-right', '#000')} no-repeat center/contain;
      mask:{ui.icone_url('chevron-right', '#000')} no-repeat center/contain; }}
  .st-key-link_criticos {{ align-items:flex-end; margin-top:2px; }}
  .st-key-link_todos button, .st-key-link_criticos button {{ border:none; background:transparent; color:{c['deep']};
      padding:0; min-height:24px; font-weight:600; }}
"""]
    for n in ("BAIXO", "MODERADO", "ALTO", "CRITICO"):
        fundo, texto, _, nome = ui.SELO[n]
        regras.append(f".st-key-chip_{n} button::before {{ content:'{nome}'; background-color:{fundo}; color:{texto};"
                      f" background-image:{ui.icone_url(ui.ICONE_NIVEL[n], texto)}; }}")
    ui.css("".join(regras))


def chips_niveis(distribuicao: list[dict], perfil: str):
    """Um botao por nivel (Figma: chips abaixo da faixa): abre a fila ou a lista ja filtrada."""
    por = {d["nivel"]: d for d in distribuicao}
    linha = st.container(horizontal=True, gap="small")
    for n in ("BAIXO", "MODERADO", "ALTO", "CRITICO"):
        v = (por.get(n) or {}).get("total")
        rotulo = "suprimido" if v is None and n in por else f"{v or 0} alunos"
        with linha:
            clicou = st.button(rotulo, key=f"chip_{n}", disabled=perfil != "COORDENACAO")
        if clicou:
            if n in ("ALTO", "CRITICO"):
                ui.ir("alertas", alerta_aberto=None, filtro_fila_nivel=ui.NOME_NIVEL[n])
            else:
                ui.ir("alunos", filtro_alunos_nivel=ui.NOME_NIVEL[n])


def cabecalho_calculo(calculo: dict):
    texto = f"Atualizado em {ui.data_br(calculo.get('ultimo_calculo'))}"
    if calculo.get("alunos_na_fila"):
        texto += f" · {calculo['alunos_na_fila']} aluno(s) sendo recalculados"
    st.caption(texto + " · atualização automática a cada 20 s")
    if calculo.get("aviso"):
        st.warning(calculo["aviso"])


def kpis(visao: dict, perfil: str):
    al = visao["alertas"]
    critico = next((d["total"] for d in visao["distribuicao"] if d["nivel"] == "CRITICO"), None)
    c = st.columns(4)
    with c[0]:
        ui.card("Total de alunos", visao["alunos"] if visao["alunos"] is not None else "—",
                "no recorte" if visao["alunos"] is not None else "oculto: há grupo suprimido", "users")
    with c[1]:
        ui.card("Alertas ativos", al["abertos"], f"{critico if critico is not None else 'suprimido'} em nível crítico",
                "bell-ring")
    with c[2]:
        ui.card("Prazo vencido", al["vencidos"], "alertas sem primeira ação no prazo", "clock")
    with c[3]:
        ui.card("Sem responsável", al["sem_responsavel"], "aguardando atribuição", "user-x")
    v = visao.get("variacao_7_dias")
    st.caption(("Variação em 7 dias (alunos em Alto ou Crítico): " + (f"{v['diferenca']:+d}" if v else
                "sem dado (ainda não há cálculo de 7 dias atrás)")) + " · " + visao["observacao_periodo_anterior"])


def painel(perfil: str, curso: str | None = None, f: dict | None = None, atencao=None):
    """Painel analitico (Figma P2). atencao: funcao que desenha "Precisam de atencao agora" (coordenacao)."""
    css_painel()
    f = dict(f if f is not None else filtros())
    if perfil == "DIRECAO":
        f["curso"] = curso

    @st.fragment(run_every="30s")
    def _visao():
        with ui.secao():
            visao = cliente.get("/api/v1/paineis/visao-geral", **f)
            an = cliente.get("/api/v1/paineis/analises", **f)
            cabecalho_calculo(visao["calculo"])
            if visao.get("houve_supressao"):
                ui.restrito("Há grupo com menos de 5 alunos neste recorte: os valores pequenos, o total e os "
                            "percentuais foram suprimidos para impedir reidentificação (RN07, CA19).")
            kpis(visao, perfil)
            por = {d["nivel"]: d.get("total") for d in visao["distribuicao"]}
            em_risco = None if por.get("ALTO") is None or por.get("CRITICO") is None else por["ALTO"] + por["CRITICO"]
            col1, col2 = st.columns([1.6, 1], gap="medium")
            with col1:
                with ui.painel("distribuicao"):
                    t, l = st.columns([1.6, 1], vertical_alignment="top")
                    with t:
                        ui.titulo_painel("Distribuição por nível de risco",
                                         "Clique em um nível para abrir a fila de alertas já filtrada"
                                         if perfil == "COORDENACAO" else "Alunos do recorte por nível de risco")
                    if perfil == "COORDENACAO":
                        with l:
                            with st.container(key="link_criticos"):
                                if st.button(f"Ver alertas críticos ({por.get('CRITICO') or 0})  →"):
                                    ui.ir("alertas", alerta_aberto=None, filtro_fila_nivel="Crítico")
                    graficos.faixa_distribuicao(visao["distribuicao"])
                    chips_niveis(visao["distribuicao"], perfil)
            with col2:
                with ui.painel("fatores"):
                    ui.titulo_painel("Fatores mais frequentes", "Percentual dos alunos em Alto ou Crítico com o fator")
                    graficos.fatores_frequentes(an["fatores_frequentes"][:5], em_risco)
            col3, col4 = st.columns([1.1, 1] if atencao else [1, 1], gap="medium")
            with col3:
                with ui.painel("evolucao"):
                    ui.titulo_painel("Evolução dos alertas por período", "Alunos em Alto ou Crítico por dia, por nível")
                    graficos.evolucao_empilhada(an["evolucao"])
            with col4:
                if atencao:
                    with ui.painel("atencao"):
                        atencao()
                else:
                    with ui.painel("faixas"):
                        ui.titulo_painel("Faixas de score", "Cortes vigentes: Baixo até {baixo:g}, Moderado até "
                                         "{moderado:g}, Alto até {alto:g} (RN02)".format(**visao["cortes"]))
                        graficos.barras_simples([fx["faixa"] for fx in visao["faixas_score"]],
                                                [fx["total"] for fx in visao["faixas_score"]], cor=ui.COR["mustard"])
            _complementos(an, visao, atencao is not None)

    _visao()


def _complementos(an: dict, visao: dict, mostrar_faixas: bool):
    if mostrar_faixas:
        col1, col2 = st.columns(2, gap="medium")
        with col1:
            with ui.painel("faixas"):
                ui.titulo_painel("Faixas de score", "Cortes vigentes: Baixo até {baixo:g}, Moderado até {moderado:g}, "
                                 "Alto até {alto:g} (RN02)".format(**visao["cortes"]))
                graficos.barras_simples([fx["faixa"] for fx in visao["faixas_score"]],
                                        [fx["total"] for fx in visao["faixas_score"]], cor=ui.COR["mustard"])
        with col2:
            with ui.painel("atendimento"):
                _primeiro_atendimento(an)
    with ui.painel("comparacao"):
        ui.titulo_painel("Comparação entre cursos" if an["tipo_comparacao"] == "curso" else "Comparação por semestre",
                         "Alunos por nível em cada grupo; grupos com menos de 5 alunos aparecem suprimidos")
        graficos.empilhado_por_grupo(an["comparacao"])
    col3, col4 = st.columns(2, gap="medium")
    with col3:
        with ui.painel("eficacia"):
            ui.titulo_painel("Eficácia das intervenções", "Permanência de quem recebeu ou não contato (RF25)")
            ef = an["eficacia"]
            if not ef["disponivel"]:
                st.caption(ef["motivo"])
            else:
                a, b = st.columns(2)
                with a:
                    ui.card("Com contato", _pct(ef['com_intervencao']['permanencia_pct']),
                            f"{ef['com_intervencao']['alertas'] or 'poucos'} alertas encerrados", "hand-heart")
                with b:
                    ui.card("Sem contato", _pct(ef['sem_intervencao']['permanencia_pct']),
                            f"{ef['sem_intervencao']['alertas'] or 'poucos'} alertas encerrados", "user-x")
                st.caption(ef["nota"])
    with col4:
        if mostrar_faixas:
            with ui.painel("causas"):
                _causas(an)
        else:
            with ui.painel("atendimento"):
                _primeiro_atendimento(an)
    if not mostrar_faixas and an["causas_identificadas"]:
        with ui.painel("causas"):
            _causas(an)


def _primeiro_atendimento(an: dict):
    ui.titulo_painel("Primeiro atendimento", "Alertas com primeira ação dentro do prazo, por nível")
    if not an["primeiro_atendimento"]:
        st.caption("Sem dado: nenhum alerta teve ação registrada ainda.")
    for p in an["primeiro_atendimento"]:
        st.write(f"{ui.NOME_NIVEL.get(p['nivel'], p['nivel'])}: "
                 + ("suprimido" if p["total"] is None else
                    f"{p['no_prazo_pct']}% no prazo, média de {ui.numero_br(p['horas_media'])} h"))
    st.caption(f"Classificações marcadas como equivocadas (RF20): "
               f"{'suprimido' if an['divergencias_registradas'] is None else an['divergencias_registradas']}")


def _causas(an: dict):
    ui.titulo_painel("Causas identificadas nos encerramentos")
    if not an["causas_identificadas"]:
        st.caption("Sem dado: nenhum alerta encerrado com causa registrada ainda.")
        return
    graficos.barras_simples([NOME_CAUSA.get(c["causa"], c["causa"]) for c in an["causas_identificadas"]],
                            [c["alertas"] for c in an["causas_identificadas"]], sufixo=" alertas")
