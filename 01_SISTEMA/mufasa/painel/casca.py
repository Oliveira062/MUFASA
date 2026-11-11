"""
Casca (shell) do painel no padrao do Figma (Parte 1 · Shell de cada perfil).

Menu lateral: logo e marca, cartao "Perfil ativo", itens de navegacao com os
icones do Figma e contador, "Decisao humana" e "Acesso restrito · LGPD" no
rodape. Barra superior: caminho da pagina, sino com notificacoes, iniciais e
nome do usuario e botao de sair.

Os itens sao st.page_link (navegacao sem recarregar, a sessao continua); o
icone e o contador entram por CSS em cada item, pela chave do container.
"""

import html

import streamlit as st

import cliente
import ui

NOME_PERFIL = {"ALUNO": "Aluno", "DOCENTE": "Docente", "COORDENACAO": "Coordenação", "NUCLEO_APOIO": "NAE",
               "FINANCEIRO": "Setor financeiro", "DIRECAO": "Gestão", "ADMIN": "Administração técnica",
               "ENCARREGADO_DADOS": "Encarregado de dados"}
# Area do caminho (breadcrumb) de cada perfil
AREA = {"COORDENACAO": "Coordenação", "NUCLEO_APOIO": "NAE", "DOCENTE": "Docente", "FINANCEIRO": "Setor financeiro",
        "DIRECAO": "Gestão", "ADMIN": "Administração técnica", "ENCARREGADO_DADOS": "Encarregado de dados",
        "ALUNO": "Portal do aluno"}
# Perfis com fila de alertas: contador no item de alertas
CONTA_ALERTAS = {"COORDENACAO": "alertas", "NUCLEO_APOIO": "inicio"}
SEM_DECISAO = ("ALUNO", "DIRECAO", "ADMIN", "ENCARREGADO_DADOS")


def _css_casca():
    c = ui.COR
    ui.css(f"""
  section[data-testid="stSidebar"] [data-testid="stSidebarContent"] {{ padding:0 !important; }}
  section[data-testid="stSidebar"] [data-testid="stSidebarUserContent"] {{ padding:16px !important; }}
  section[data-testid="stSidebar"] [data-testid="stSidebarUserContent"] > div {{ width:100% !important; max-width:100% !important; }}
  .mf-marca {{ display:flex; gap:12px; align-items:center; margin:0 0 18px 4px; }}
  .mf-marca img {{ width:44px; height:44px; border-radius:10px; }}
  .mf-marca b {{ display:block; font-size:15px; color:{c['text']}; }}
  .mf-marca span {{ font-size:13px; color:{c['text2']}; white-space:nowrap; }}
  .mf-perfil {{ background:{c['creamSoft']}; border:1px solid {c['line']}; border-radius:12px; padding:10px 14px;
               display:flex; gap:12px; align-items:center; margin-bottom:22px; }}
  .mf-perfil small {{ display:block; font-size:12px; color:{c['text2']}; }}
  .mf-perfil b {{ font-size:13px; color:{c['text']}; font-weight:600; }}
  .mf-rot-nav {{ font-size:12px; font-weight:600; color:{c['text2']}; margin:0 0 4px 12px; padding-bottom:6px; }}
  [data-testid="stSidebarUserContent"] > div > [data-testid="stVerticalBlock"] {{ min-height: calc(100vh - 44px); }}
  [data-testid="stLayoutWrapper"]:has(> .st-key-rodape_menu), .st-key-rodape_menu {{ margin-top:auto; }}
  .st-key-rodape_menu {{ padding-top:24px; }}
  .mf-lgpd {{ display:flex; gap:8px; align-items:center; font-size:12px; color:{c['text3']}; margin:12px 0 0 8px; }}
  [class*="st-key-nav_"] [data-testid="stPageLink"] a {{ padding:9px 12px 9px 42px; border-radius:10px; min-height:40px;
      position:relative; border-left:3px solid transparent; width:100%; box-sizing:border-box; }}
  [class*="st-key-nav_"] [data-testid="stPageLink"] a span, [class*="st-key-nav_"] [data-testid="stPageLink"] a p {{
      font-size:14px; font-weight:500; color:{c['text']}; white-space:normal; overflow:visible;
      text-overflow:clip; line-height:1.3; }}
  [class*="st-key-nav_"] [data-testid="stPageLink"] a:hover {{ background:{c['creamSoft']}; }}
  [class*="st-key-nav_"] [data-testid="stPageLink"] a::before {{ content:""; position:absolute; left:14px; top:50%;
      width:18px; height:18px; margin-top:-9px; background-color:{c['text2']}; -webkit-mask-size:contain; mask-size:contain;
      -webkit-mask-repeat:no-repeat; mask-repeat:no-repeat; }}
  [class*="st-key-nav_"] [data-testid="stPageLink"] a::after {{ position:absolute; right:12px; top:50%; margin-top:-11px;
      min-width:22px; height:22px; border-radius:999px; background:{c['gold']}; color:{c['text']}; font-size:12px;
      font-weight:700; display:flex; align-items:center; justify-content:center; padding:0 6px; }}
  [class*="st-key-nav_"] [data-testid="stPageLink"] a [data-testid="stIconMaterial"],
  [class*="st-key-nav_"] [data-testid="stPageLink"] a > span:first-child:empty {{ display:none; }}
  .st-key-topo {{ border-bottom:1px solid {c['lineSoft']}; padding-bottom:12px; margin-bottom:12px; }}
  .mf-migalha {{ display:flex; gap:10px; align-items:center; font-size:14px; color:{c['text2']}; min-height:40px; }}
  .mf-migalha b {{ color:{c['text']}; font-weight:600; }}
  .st-key-usuario {{ border-left:1px solid {c['line']}; padding-left:14px; }}
  .st-key-usuario [data-testid="stPageLink"] a {{ position:relative; padding:0 0 16px 46px; min-height:40px;
      display:flex; align-items:flex-start; }}
  .st-key-usuario [data-testid="stPageLink"] a span, .st-key-usuario [data-testid="stPageLink"] a p {{
      font-size:14px !important; font-weight:600; color:{c['text']}; white-space:nowrap; overflow:hidden;
      text-overflow:ellipsis; }}
  .st-key-usuario [data-testid="stPageLink"] a::before {{ position:absolute; left:0; top:2px; width:36px; height:36px;
      border-radius:999px; background:{c['goldSoft']}; color:{c['deep']}; font-size:12px; font-weight:700;
      display:flex; align-items:center; justify-content:center; }}
  .st-key-usuario [data-testid="stPageLink"] a::after {{ position:absolute; left:46px; top:21px; font-size:12px;
      color:{c['text2']}; }}
  .st-key-usuario [data-testid="stPageLink"] a:hover {{ background:transparent; }}
  .st-key-sino [data-testid="stPageLink"] a, .st-key-sair button {{ width:40px; height:40px; min-height:40px; padding:0;
      justify-content:center; position:relative; border:none; background:transparent; }}
  .st-key-sino [data-testid="stPageLink"] a span, .st-key-sino [data-testid="stPageLink"] a p,
  .st-key-sair button p {{ font-size:0 !important; }}
  .st-key-sino [data-testid="stPageLink"] a::before, .st-key-sair button::before {{ content:""; width:20px; height:20px;
      background-color:{c['text']}; -webkit-mask-size:contain; mask-size:contain; -webkit-mask-repeat:no-repeat;
      mask-repeat:no-repeat; }}
  .st-key-sino [data-testid="stPageLink"] a::before {{ -webkit-mask-image:{ui.icone_url('bell', '#000')};
      mask-image:{ui.icone_url('bell', '#000')}; }}
  .st-key-sair button::before {{ -webkit-mask-image:{ui.icone_url('log-out', '#000')};
      mask-image:{ui.icone_url('log-out', '#000')}; }}
  .st-key-sino [data-testid="stPageLink"] a::after {{ position:absolute; top:2px; right:2px; min-width:16px; height:16px;
      border-radius:999px; background:{c['gold']}; color:{c['text']}; font-size:10px; font-weight:700; display:flex;
      align-items:center; justify-content:center; padding:0 3px; }}
""")


def _css_item(chave: str, icone: str, contador, ativo: bool):
    c = ui.COR
    regras = (f".st-key-{chave} [data-testid='stPageLink'] a::before {{ -webkit-mask-image:{ui.icone_url(icone, '#000')};"
              f" mask-image:{ui.icone_url(icone, '#000')}; }}")
    if contador:
        regras += f".st-key-{chave} [data-testid='stPageLink'] a::after {{ content:'{int(contador)}'; }}"
    if ativo:
        regras += (f".st-key-{chave} [data-testid='stPageLink'] a {{ background:{c['goldSoft']} !important;"
                   f" border-left-color:{c['gold']}; }}"
                   f".st-key-{chave} [data-testid='stPageLink'] a span, .st-key-{chave} [data-testid='stPageLink'] a p"
                   f" {{ font-weight:600 !important; }}"
                   f".st-key-{chave} [data-testid='stPageLink'] a::before {{ background-color:{c['deep']}; }}")
    return regras


def _contador_alertas(perfil: str):
    if perfil not in CONTA_ALERTAS or not cliente.servico_disponivel("api"):
        return None
    try:
        return cliente.get("/api/v1/alertas", limite=1).get("total") or None
    except cliente.ErroAPI:
        return None


def menu_lateral(conta: dict, menu: list, atual):
    """menu: lista de (pagina, icone do Figma). atual: pagina em exibicao."""
    perfil = conta["perfil"]
    _css_casca()
    contador = _contador_alertas(perfil)
    regras = []
    with st.sidebar:
        st.markdown(f'<div class="mf-marca"><img src="app/static/logo.png" alt="Logo do MUFASA">'
                    f'<div><b>MUFASA</b><span>Prevenção à evasão</span></div></div>'
                    f'<div class="mf-perfil">{ui.icone("badge-check", 18, ui.COR["deep"])}'
                    f'<div><small>Perfil ativo</small><b>{html.escape(NOME_PERFIL.get(perfil, perfil))}</b></div></div>'
                    f'<div class="mf-rot-nav">Navegação</div>', unsafe_allow_html=True)
        for pagina, icone in menu:
            chave = "nav_" + pagina.url_path
            n = contador if CONTA_ALERTAS.get(perfil) == pagina.url_path else None
            regras.append(_css_item(chave, icone, n, atual is not None and pagina.url_path == atual.url_path))
            with st.container(key=chave):
                st.page_link(pagina, label=pagina.title)
        with st.container(key="rodape_menu"):
            if not cliente.servico_disponivel("api"):
                st.warning("Servidor de dados instável: exibindo o que foi possível carregar.")
            if perfil not in SEM_DECISAO:
                ui.decisao_humana()
            st.markdown(f'<div class="mf-lgpd">{ui.icone("lock", 13)}Acesso restrito · LGPD</div>',
                        unsafe_allow_html=True)
    ui.css("".join(regras))


def barra_superior(conta: dict, titulo: str, pagina_notificacoes, pagina_conta):
    perfil = conta["perfil"]
    nao_lidas = conta.get("notificacoes_nao_lidas") or 0
    if nao_lidas:
        ui.css(f".st-key-sino [data-testid='stPageLink'] a::after {{ content:'{min(int(nao_lidas), 99)}'; }}")
    nome = conta.get("nome") or conta["login"]
    with st.container(key="topo"):
        esq, sino, usuario, sair = st.columns([5, 0.45, 3.6, 0.45], vertical_alignment="center")
        esq.markdown(f'<div class="mf-migalha">{html.escape(AREA.get(perfil, ""))}{ui.icone("chevron-right", 14)}'
                     f'<b>{html.escape(titulo)}</b></div>', unsafe_allow_html=True)
        with sino:
            with st.container(key="sino"):
                st.page_link(pagina_notificacoes, label=f"Notificações ({nao_lidas} novas)")
        # Iniciais e perfil entram por CSS; o nome leva a "Minha conta"
        ui.css(f".st-key-usuario [data-testid='stPageLink'] a::before {{ content:'{ui.iniciais(nome)}'; }}"
               f".st-key-usuario [data-testid='stPageLink'] a::after {{ content:'{NOME_PERFIL.get(perfil, perfil)}'; }}")
        with usuario:
            with st.container(key="usuario"):
                st.page_link(pagina_conta, label=nome)
        with sair:
            with st.container(key="sair"):
                if st.button("Sair", help="Sair do MUFASA"):
                    cliente.sair()
                    st.rerun()
