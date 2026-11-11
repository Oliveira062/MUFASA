"""
Componentes visuais do painel, com os tokens do Figma (MUFASA - Design System).

- Nivel de risco: mostarda nos niveis baixos, marrom no Alto e vermelho errFg no
  Critico (pedido do grupo, 28/10/2026); sempre cor + icone + texto.
- Cada secao da tela roda isolada (secao): se uma consulta falhar, so aquele
  bloco mostra o aviso; o resto da tela continua.
- Exportacao CSV sempre com rodape de versao e confidencialidade (RF21, RN23)
  e protegida contra injecao de formula em planilha.
"""

import contextlib
import csv
import html
import io
import json
import re
import unicodedata
import uuid
from pathlib import Path
from urllib.parse import quote
from datetime import datetime

import streamlit as st
import streamlit.components.v1 as componentes

from cliente import ErroAPI, ServicoIndisponivel
from registro_painel import log

COR = {
    "bg": "#FFFFFF", "cream": "#F5EBD3", "creamSoft": "#FBF6EA", "creamDeep": "#EEDFB8", "line": "#E6D5AC",
    "text": "#3D2B1F", "text2": "#6B5432", "text3": "#94805C", "gold": "#C99720", "goldSoft": "#F3E2B3",
    "deep": "#8C6410", "mustard": "#B8860B", "lineSoft": "#F0E5C8", "okBg": "#E6EFDF", "okFg": "#3F6B2E", "errBg": "#F6E1D3", "errFg": "#9A4A1E",
    "infoBg": "#EAE6DC", "infoFg": "#5B5141",
}
# Selos (Figma: riskLow/Mod/High/Crit), com texto em contraste AA sobre o fundo.
# Pedido do grupo (28/10/2026): Critico no vermelho errFg do Figma e Alto no marrom escuro.
SELO = {
    "BAIXO": ("#F7E9BF", "#5C4410", "○", "Baixo"),
    "MODERADO": ("#E9C35C", "#3D2B1F", "◐", "Moderado"),
    "ALTO": ("#523E1D", "#FFFFFF", "▲", "Alto"),
    "CRITICO": ("#9A4A1E", "#FFFFFF", "◆", "Crítico"),
    "INDETERMINADO": ("#EAE6DC", "#5B5141", "?", "Indeterminado"),
    "PENDENTE": ("#EAE6DC", "#5B5141", "…", "Pendente"),
}
# Rampa sequencial (claro -> escuro) para graficos; sempre com rotulo direto.
COR_GRAFICO = {"BAIXO": "#EBD79B", "MODERADO": "#C99720", "ALTO": "#523E1D", "CRITICO": "#9A4A1E",
               "INDETERMINADO": "#B8B2A4", "PENDENTE": "#D8D3C8"}
NOME_NIVEL = {k: v[3] for k, v in SELO.items()}
ORDEM_NIVEIS = ["CRITICO", "ALTO", "MODERADO", "BAIXO", "INDETERMINADO", "PENDENTE"]

AVISO_PESOS = ("Score calculado por modelo determinístico de pesos heurísticos, versão 1.1. Não constitui "
               "resultado de análise estatística sobre dados da instituição.")
AVISO_DECISAO = "O sistema recomenda; a equipe decide e registra cada ação."


_ICONES = json.loads((Path(__file__).with_name("icones.json")).read_text(encoding="utf-8"))
# Icone de cada nivel no selo (Figma: Selo de risco)
ICONE_NIVEL = {"BAIXO": "circle-check", "MODERADO": "info", "ALTO": "circle-alert", "CRITICO": "triangle-alert",
               "INDETERMINADO": "circle-question-mark", "PENDENTE": "hourglass"}


def icone(nome: str, tamanho: int = 16, cor: str = "currentColor") -> str:
    """Icone do Figma (biblioteca Lucide exportada do .fig) como SVG em linha."""
    svg = _ICONES.get(nome, "").replace('width="1em" height="1em"', f'width="{tamanho}" height="{tamanho}"')
    return f'<span class="mf-ic" style="width:{tamanho}px;height:{tamanho}px;color:{cor}">{svg}</span>'


def icone_url(nome: str, cor: str) -> str:
    """Icone como data URI (para CSS: fundo de campo, mascara de botao)."""
    svg = _ICONES.get(nome, "").replace("currentColor", cor)
    return "url(\"data:image/svg+xml;utf8," + quote(svg) + "\")"


def css(regras: str):
    st.markdown(f"<style>{regras}</style>", unsafe_allow_html=True)


_ACESSIBILIDADE_JS = (Path(__file__).parent / "acessibilidade.js").read_text(encoding="utf-8")


def acessibilidade():
    """Botao flutuante de acessibilidade em todas as telas (painel/acessibilidade.js).

    O componente (iframe de altura zero, mesma origem) coloca o script na pagina
    principal uma unica vez. O script so roda no navegador; o VLibras so carrega
    depois do aviso e da confirmacao da pessoa.
    """
    componentes.html(_carregador_acessibilidade(), height=0)


def _carregador_acessibilidade() -> str:
    codigo = json.dumps(_ACESSIBILIDADE_JS).replace("</", "<\\/")
    return ("<script>(function(){var p=window.parent;if(p.__mufasaAcessibilidade)return;"
            "var s=p.document.createElement('script');s.id='mf-a11y-script';s.textContent=" + codigo + ";"
            "p.document.head.appendChild(s);})();</script>")


def aplicar_tema():
    css(f"""
  html, body, .stApp, button, input, textarea, select {{ font-family: Inter, system-ui, sans-serif; }}
  [data-testid="stHeader"] {{ background: transparent; height: 0; }}
  [data-testid="stToolbar"], [data-testid="stDecoration"], [data-testid="stStatusWidget"] {{ display: none; }}
  [data-testid="stMainBlockContainer"], .block-container {{ padding: 16px 32px 40px 32px !important; max-width: 1480px; }}
  /* HTML proprio (sem <p> no fim) nao usa a margem negativa que o Streamlit poe no markdown */
  [data-testid="stMarkdownContainer"]:not(:has(> p:last-child)) {{ margin-bottom:0; }}
  [class*="st-key-lk_"], [data-testid="stLayoutWrapper"]:has(> [class*="st-key-lk_"]) {{ width:auto !important;
      flex:0 0 auto !important; }}
  /* Celulas das tabelas (fila, alunos) */
  .mf-est b {{ display:block; font-size:14px; font-weight:600; color:{COR['text']}; }}
  .mf-est small {{ display:block; font-size:12px; color:{COR['text2']}; margin-top:2px; }}
  .mf-risco {{ display:flex; flex-direction:column; gap:6px; align-items:flex-start; }}
  .mf-risco > div {{ display:flex; gap:8px; align-items:center; line-height:16px; font-size:12px; color:{COR['text']}; font-weight:600; }}
  .mf-prazo small {{ display:block; font-size:12px; color:{COR['text2']}; margin-top:4px; }}
  .mf-resp {{ display:flex; gap:10px; align-items:center; font-size:13px; font-weight:500; color:{COR['text']}; }}
  .mf-resp.vazio {{ color:{COR['text3']}; }}
  [class*="st-key-at_"] [data-testid="stElementContainer"], [class*="st-key-at_"] [data-testid="stPageLink"],
  [class*="st-key-at_"] [data-testid="stPageLink"] > div {{ width:100% !important; }}
  /* sem o aviso "Press Enter to submit form" (em ingles) dentro dos campos */
  [data-testid="InputInstructions"] {{ display:none; }}
  button p {{ font-weight:inherit !important; }}
  /* blocos que so carregam <style> nao ocupam espaco */
  [data-testid="stElementContainer"]:has(style) {{ display:none; }}
  [data-testid="stElementContainer"]:has(> iframe[height="0"]), [data-testid="stElementContainer"]:has(iframe[height="0"]) {{ display:none; }}
  [data-testid="stSidebarHeader"] {{ height: 0; min-height: 0; padding: 0; margin: 0; }}
  [data-testid="stSidebarUserContent"] {{ padding-top: 20px !important; }}
  section[data-testid="stSidebar"] [data-testid="stVerticalBlock"] {{ gap: 4px; }}
  section[data-testid="stSidebar"] {{ width: 264px !important; min-width: 264px !important; }}
  section[data-testid="stSidebar"] > div {{ padding-top: 8px; }}
  h1, h2, h3, h4 {{ color: {COR['text']}; letter-spacing: 0; }}
  [data-baseweb="input"], [data-baseweb="input"] > div, [data-baseweb="select"] > div, [data-baseweb="textarea"] {{
      background-color:#FFFFFF !important; }}
  [data-baseweb="input"] input {{ background-color:transparent; }}
  .mf-ic {{ display:inline-flex; align-items:center; justify-content:center; vertical-align:middle; flex:none; }}
  .mf-ic svg {{ display:block; }}
  /* Botoes: primario dourado com texto escuro (onGold), secundario em contorno */
  button[kind="primary"], button[data-testid="stBaseButton-primary"], [data-testid="stFormSubmitButton"] button[kind="primaryFormSubmit"] {{
      background:{COR['gold']} !important; border-color:{COR['gold']} !important; color:{COR['text']} !important;
      font-weight:600; }}
  button[kind="primary"]:hover, button[data-testid="stBaseButton-primary"]:hover {{ background:{COR['mustard']} !important; }}
  button[kind="secondary"], button[data-testid="stBaseButton-secondary"] {{ border-color:{COR['line']}; color:{COR['text']};
      font-weight:600; background:#FFFFFF; }}
  button[kind="secondary"]:hover {{ border-color:{COR['gold']}; color:{COR['deep']}; }}
  /* Paineis (st.container(border=True)): branco, borda creme, raio 16 */
  [data-testid="stVerticalBlockBorderWrapper"]:has(> div > [data-testid="stVerticalBlock"]) {{ border-radius:16px; }}
  .mf-cab {{ padding-bottom:10px; }}
  .mf-sobre {{ color:{COR['deep']}; font-size:12px; font-weight:700; letter-spacing:.02em; margin:0 0 6px 0; }}
  .mf-titulo {{ font-size:28px; line-height:36px; font-weight:700; color:{COR['text']}; margin:0; padding:0 !important; }}
  .mf-sub {{ color:{COR['text2']}; font-size:14px; margin:6px 0 0 0; }}
  .mf-h3 {{ font-size:18px; line-height:26px; font-weight:600; color:{COR['text']}; margin:0; }}
  .mf-h3sub {{ color:{COR['text2']}; font-size:13px; line-height:19px; margin:2px 0 6px 0; }}
  .mf-selo {{ display:inline-flex; align-items:center; gap:6px; padding:3px 12px; border-radius:999px; font-weight:600;
             font-size:13px; line-height:19px; white-space:nowrap; }}
  .mf-card {{ background:{COR['creamSoft']}; border:1px solid {COR['line']}; border-radius:12px; padding:18px 20px;
             height:100%; }}
  .mf-card .topo {{ display:flex; justify-content:space-between; align-items:center; }}
  .mf-card .rot {{ color:{COR['text']}; font-size:12px; font-weight:600; }}
  .mf-card .val {{ color:{COR['text']}; font-size:30px; font-weight:700; line-height:36px; margin-top:10px; }}
  .mf-card .leg {{ color:{COR['text2']}; font-size:12px; margin-top:6px; }}
  .mf-restrito {{ background:{COR['infoBg']}; color:{COR['infoFg']}; border-radius:12px; padding:12px 16px;
                  border:1px dashed {COR['text3']}; display:flex; gap:10px; align-items:flex-start; font-size:13px; }}
  .mf-decisao {{ background:{COR['creamSoft']}; color:{COR['text']}; border:1px solid {COR['line']}; border-radius:12px;
                 padding:14px 16px; font-size:13px; }}
  .mf-decisao b {{ display:flex; align-items:center; gap:8px; font-weight:600; margin-bottom:4px; }}
  .mf-rodape {{ color:{COR['text3']}; font-size:12px; margin-top:24px; border-top:1px solid {COR['line']};
                padding-top:8px; }}
  .mf-fator {{ border-left:4px solid {COR['gold']}; padding:6px 12px; margin:6px 0; background:{COR['creamSoft']};
               border-radius:0 8px 8px 0; }}
  [data-testid="stColumn"] [data-testid="stLayoutWrapper"]:has(> [class*="st-key-pn_"]):only-child,
  [data-testid="stColumn"] [data-testid="stLayoutWrapper"]:has(> [class*="st-key-pn_"]):only-child > [class*="st-key-pn_"] {{ height:100%; }}
  [class*="st-key-pn_"] {{ background:#FFFFFF; border:1px solid {COR['line']}; border-radius:16px; padding:24px; }}
  .st-key-banner {{ background:{COR['cream']}; border-radius:16px; padding:18px 20px; }}
  .mf-banner {{ display:flex; gap:16px; align-items:center; }}
  .mf-banner b {{ display:block; font-size:14px; font-weight:600; color:{COR['text']}; }}
  .mf-banner span {{ font-size:13px; color:{COR['text2']}; }}
  .mf-faixa {{ display:flex; height:44px; border-radius:8px; overflow:hidden; font-size:13px; font-weight:600; }}
  .mf-faixa > div {{ display:flex; align-items:center; justify-content:center; white-space:nowrap; overflow:hidden; }}
  .mf-fx-sup {{ flex:0 0 auto; padding:0 12px; background:repeating-linear-gradient(45deg,{COR['creamSoft']} 0 6px,{COR['line']} 6px 8px);
               color:{COR['text2']}; }}
  .mf-fator-l {{ display:grid; grid-template-columns: minmax(150px, 1.5fr) 1fr 48px; gap:16px; align-items:center; margin:0 0 16px 0; }}
  .mf-fator-l .n {{ font-size:14px; font-weight:500; color:{COR['text']}; }}
  .mf-fator-l .t {{ height:8px; border-radius:999px; background:{COR['lineSoft']}; overflow:hidden; }}
  .mf-fator-l .t i {{ display:block; height:100%; border-radius:999px; background:{COR['mustard']}; }}
  .mf-fator-l .v {{ font-size:14px; font-weight:600; color:{COR['text']}; text-align:right; }}
  .mf-lista-l {{ display:flex; gap:14px; align-items:center; min-height:56px; }}
  .mf-lista-l b {{ display:block; font-size:14px; font-weight:600; color:{COR['text']}; }}
  .mf-lista-l small {{ font-size:12px; color:{COR['text2']}; }}
  /* Abas no padrao do Figma: controle segmentado creme */
  [data-baseweb="tab-list"] {{ background:{COR['cream']}; border-radius:12px; padding:4px; gap:4px; width:fit-content;
      max-width:100%; flex-wrap:wrap; }}
  [data-baseweb="tab"] {{ border-radius:9px; padding:6px 14px !important; height:auto; background:transparent; }}
  [data-baseweb="tab"] p {{ font-size:14px; font-weight:500; color:{COR['text']}; }}
  [data-baseweb="tab"][aria-selected="true"] {{ background:#FFFFFF; box-shadow:0 1px 2px rgba(61,43,31,.12); }}
  [data-baseweb="tab"][aria-selected="true"] p {{ font-weight:600; }}
  [data-baseweb="tab-highlight"], [data-baseweb="tab-border"] {{ display:none; }}
  [data-testid="stForm"] {{ background:#FFFFFF; border:1px solid {COR['line']}; border-radius:16px; padding:24px; }}
  [class*="st-key-pn_"] [data-testid="stForm"] {{ border:none; padding:0; }}
  [data-testid="stExpander"] details {{ border:1px solid {COR['line']}; border-radius:12px; background:#FFFFFF; }}
  [data-testid="stExpander"] summary p {{ font-weight:500; }}
  [data-testid="stDataFrame"] {{ border:1px solid {COR['lineSoft']}; border-radius:12px; overflow:hidden; }}
  [data-testid="stAlert"] > div {{ border-radius:12px; }}
  [data-testid="stCaptionContainer"] {{ color:{COR['text2']}; }}
  /* Botoes com icone do Figma (atalhos, voltar, exportar) */
  [class*="st-key-lk_"] button {{ gap:8px; }}
  [class*="st-key-lk_"] button::before, [class*="st-key-vt_"] button::before {{ width:16px; height:16px;
      background-color:{COR['deep']}; -webkit-mask-size:contain; mask-size:contain; -webkit-mask-repeat:no-repeat;
      mask-repeat:no-repeat; flex:none; }}
  [class*="st-key-vt_"] button {{ border:none; background:transparent; padding:0; min-height:32px; gap:8px; }}
  [class*="st-key-vt_"] button p {{ color:{COR['deep']}; font-weight:600; }}
  [class*="st-key-vt_"] button::before {{ content:""; -webkit-mask-image:{icone_url('arrow-left', '#000')};
      mask-image:{icone_url('arrow-left', '#000')}; }}
  .mf-pilula {{ display:inline-flex; align-items:center; gap:6px; padding:2px 10px; border-radius:999px; font-size:12px;
               font-weight:600; line-height:18px; white-space:nowrap; }}
  .mf-pilula.contorno {{ background:#FFFFFF; border:1px solid {COR['gold']}; color:{COR['text']}; }}
  .mf-pilula.contorno::before {{ content:""; width:6px; height:6px; border-radius:999px; background:{COR['deep']}; }}
  .mf-cab-tabela {{ display:grid; background:{COR['cream']}; border-radius:10px; padding:10px 16px; font-size:12px;
                   font-weight:600; color:{COR['text']}; margin-bottom:4px; }}
  .st-key-heroi {{ background:{COR['creamSoft']}; border:1px solid {COR['line']}; border-radius:16px; padding:22px 24px; }}
  .st-key-heroi [data-testid="stColumn"]:last-child [data-testid="stVerticalBlock"] {{ align-items:flex-end; }}
  [class*="st-key-pn_tb_"] {{ background:#FFFFFF; border:1px solid {COR['line']}; border-radius:16px;
      padding:12px 8px 16px 8px; }}
  [class*="st-key-lin_"] {{ border-bottom:1px solid {COR['lineSoft']}; padding:10px 16px; border-radius:0; }}
  [class*="st-key-lin_"]:hover {{ background:{COR['creamSoft']}; }}
  [class*="st-key-lin_"] [data-testid="stMarkdownContainer"] {{ font-size:14px; color:{COR['text']}; }}
  .mf-rodape-tabela {{ display:flex; justify-content:space-between; gap:12px; flex-wrap:wrap; font-size:12px;
      color:{COR['text2']}; padding:12px 16px 0 16px; }}
  .mf-rodape-tabela span {{ display:inline-flex; gap:6px; align-items:center; }}
  .mf-aviso {{ background:{COR['creamSoft']}; border:1px solid {COR['line']}; border-radius:16px; padding:16px 20px;
      display:flex; gap:14px; align-items:flex-start; }}
  .mf-aviso b {{ display:block; font-size:14px; font-weight:600; color:{COR['text']}; }}
  .mf-aviso span {{ font-size:13px; color:{COR['text2']}; }}
  [class*="st-key-tx_"] button {{ border:none; background:transparent; padding:0; min-height:28px; gap:6px; }}
  [class*="st-key-tx_"] button p {{ color:{COR['deep']}; font-weight:600; font-size:13px; }}
  [class*="st-key-tx_"] button::after {{ content:""; width:14px; height:14px; background-color:{COR['deep']};
      -webkit-mask:{icone_url('arrow-right', '#000')} no-repeat center/contain;
      mask:{icone_url('arrow-right', '#000')} no-repeat center/contain; }}
  [class*="st-key-tx_"] button:hover p {{ text-decoration:underline; }}
  .mf-icbox {{ width:44px; height:44px; border-radius:12px; background:{COR['cream']}; display:inline-flex;
      align-items:center; justify-content:center; color:{COR['deep']}; flex:none; }}
  .mf-chips {{ display:flex; gap:8px; flex-wrap:wrap; margin:10px 0 6px 0; }}
  .mf-chip {{ display:inline-flex; gap:8px; align-items:center; background:{COR['creamSoft']}; border-radius:10px;
      padding:4px 10px 4px 4px; font-size:14px; font-weight:600; color:{COR['text']}; }}
  [class*="st-key-at_"] [data-testid="stPageLink"] a {{ position:relative; display:flex; align-items:flex-start;
      min-height:80px; padding:18px 44px 18px 78px; border:1px solid {COR['line']}; border-radius:16px;
      background:#FFFFFF {icone_url('chevron-right', COR['text2'])} no-repeat right 18px center / 16px; width:100%;
      box-sizing:border-box; }}
  [class*="st-key-at_"] [data-testid="stPageLink"] a:hover {{ border-color:{COR['gold']}; background-color:{COR['creamSoft']}; }}
  [class*="st-key-at_"] [data-testid="stPageLink"] a span, [class*="st-key-at_"] [data-testid="stPageLink"] a p {{
      font-size:14px; font-weight:600; color:{COR['text']}; }}
  [class*="st-key-at_"] [data-testid="stPageLink"] a::before {{ content:""; position:absolute; left:18px; top:18px;
      width:44px; height:44px; border-radius:12px; background-color:{COR['cream']}; background-repeat:no-repeat;
      background-position:center; background-size:22px; }}
  [class*="st-key-at_"] [data-testid="stPageLink"] a::after {{ position:absolute; left:78px; top:42px; right:44px;
      font-size:12px; color:{COR['text2']}; }}
  .mf-hero {{ display:flex; gap:20px; align-items:center; }}
  .mf-hero .mf-avatar {{ width:64px; height:64px; font-size:18px; }}
  .mf-hero h1 {{ font-size:22px; line-height:30px; font-weight:700; color:{COR['text']}; margin:0; padding:0;
               display:flex; gap:12px; align-items:center; flex-wrap:wrap; }}
  .mf-hero .meta {{ display:flex; gap:18px; flex-wrap:wrap; margin-top:6px; font-size:13px; color:{COR['text2']}; }}
  .mf-hero .meta span {{ display:inline-flex; gap:6px; align-items:center; }}
  .mf-linha {{ display:flex; justify-content:space-between; gap:16px; align-items:flex-start; padding:12px 0;
              border-bottom:1px solid {COR['lineSoft']}; }}
  .mf-linha:last-child {{ border-bottom:none; }}
  .mf-linha b {{ font-size:14px; font-weight:600; color:{COR['text']}; }}
  .mf-linha small {{ display:block; font-size:12px; color:{COR['text2']}; margin-top:2px; }}
  /* Tabelas de leitura (ui.grade) */
  .mf-grade-caixa {{ overflow-x:auto; border:1px solid {COR['line']}; border-radius:14px; background:#FFFFFF; }}
  .mf-grade-caixa:focus-visible {{ outline:3px solid {COR['gold']}; outline-offset:2px; }}
  .mf-grade {{ width:100%; border-collapse:separate; border-spacing:0; font-size:14px; color:{COR['text']};
      font-variant-numeric:tabular-nums; margin:0 !important; border:none !important; }}
  .mf-grade th, .mf-grade td {{ border-top:none !important; border-left:none !important; border-right:none !important; }}
  .mf-grade caption {{ position:absolute; width:1px; height:1px; overflow:hidden; clip:rect(0 0 0 0); }}
  .mf-grade th {{ background:{COR['creamSoft']}; color:{COR['text2']}; font-size:12px; font-weight:600;
      text-transform:uppercase; letter-spacing:.04em; padding:12px 16px; border-bottom:1px solid {COR['line']};
      white-space:nowrap; text-align:left; }}
  .mf-grade td {{ padding:14px 16px; border-bottom:1px solid {COR['lineSoft']}; vertical-align:middle; }}
  .mf-grade tbody tr:last-child td {{ border-bottom:none; }}
  .mf-grade tbody tr:hover td {{ background:#FFFCF4; }}
  .mf-grade td:first-child {{ font-weight:600; }}
  .mf-grade td b {{ display:block; font-weight:600; }}
  .mf-grade td small {{ display:block; font-size:12px; color:{COR['text2']}; font-weight:400; margin-top:2px; }}
  .mf-grade .al-c {{ text-align:center; }} .mf-grade .al-d {{ text-align:right; }}
  .mf-grade .mf-selo, .mf-grade [class*="mf-pil"] {{ white-space:nowrap; }}
  .mf-vazio {{ color:{COR['text3']}; }}
  .mf-nota {{ display:inline-block; min-width:40px; padding:3px 8px; border-radius:8px; font-weight:600;
      text-align:center; background:{COR['creamSoft']}; }}
  .mf-num {{ color:{COR['text2']}; font-weight:500; }}
  .mf-nota.mudou {{ background:{COR['goldSoft']}; color:{COR['deep']}; }}
  .mf-nota.baixa {{ background:{COR['errBg']}; color:{COR['errFg']}; }}
  .mf-freq {{ display:inline-flex; align-items:center; gap:10px; }}
  .mf-freq .trilho {{ display:inline-block; width:72px; height:6px; border-radius:999px; background:{COR['lineSoft']};
      overflow:hidden; }}
  .mf-freq .trilho span {{ display:block; height:100%; border-radius:999px; }}
  .mf-freq .num {{ min-width:40px; text-align:right; font-weight:600; }}
  .mf-freq.baixa .num {{ color:{COR['errFg']}; }}
  .mf-grade-leg {{ display:flex; gap:8px; align-items:flex-start; font-size:12.5px; color:{COR['text2']};
      margin:12px 2px 0 2px; }}
  .mf-grade-leg .mf-ic {{ margin-top:2px; }}
  .mf-resumo {{ display:grid; grid-template-columns:repeat(auto-fit, minmax(150px, 1fr)); gap:12px; margin:0 0 16px 0; }}
  .mf-resumo > div {{ border-radius:12px; padding:14px 16px; display:flex; flex-direction:column; gap:2px; }}
  .mf-resumo .v {{ font-size:24px; font-weight:700; line-height:30px; }}
  .mf-resumo .r {{ font-size:12.5px; color:{COR['text2']}; }}
  /* Fatores (o que influencia) em cartoes */
  .mf-fatores {{ display:grid; grid-template-columns:repeat(auto-fill, minmax(280px, 1fr)); gap:12px; }}
  .mf-fator {{ display:flex; gap:12px; background:#FFFFFF; border:1px solid {COR['line']};
      border-left:4px solid {COR['mustard']}; border-radius:12px; padding:14px 16px; }}
  .mf-fator .ico {{ width:34px; height:34px; border-radius:10px; background:{COR['goldSoft']}; color:{COR['deep']};
      display:flex; align-items:center; justify-content:center; flex:none; }}
  .mf-fator b {{ display:block; font-size:14.5px; font-weight:600; color:{COR['text']}; }}
  .mf-fator p {{ margin:4px 0 0 0; font-size:13px; line-height:1.5; color:{COR['text2']}; }}
  .mf-fator .pts {{ margin-top:8px; display:flex; flex-wrap:wrap; align-items:center; gap:8px 10px; font-size:12.5px;
      font-weight:600; color:{COR['text']}; }}
  .mf-fator .pts > span {{ white-space:nowrap; }}
  .mf-fator > div {{ min-width:0; flex:1; }}
  .mf-nota-metodo {{ display:flex; gap:10px; background:{COR['infoBg']}; color:{COR['infoFg']}; border-radius:12px;
      padding:12px 14px; font-size:12.5px; line-height:1.55; margin:0 0 14px 0; }}
  .mf-tempo {{ position:relative; padding:0 0 18px 26px; }}
  .mf-tempo::before {{ content:""; position:absolute; left:5px; top:6px; bottom:-6px; width:2px; background:{COR['lineSoft']}; }}
  .mf-tempo:last-child::before {{ display:none; }}
  .mf-tempo::after {{ content:""; position:absolute; left:0; top:4px; width:8px; height:8px; border-radius:999px;
                     border:2px solid {COR['gold']}; background:#FFFFFF; }}
  .mf-tempo.atual::after {{ background:{COR['gold']}; }}
  .mf-tempo b {{ font-size:14px; font-weight:600; color:{COR['text']}; }}
  .mf-tempo small {{ display:block; font-size:12px; color:{COR['text2']}; }}
  .mf-tempo p {{ font-size:13px; color:{COR['text']}; margin:4px 0 0 0; }}
  .mf-escala {{ position:relative; height:14px; border-radius:4px; overflow:hidden; display:flex; }}
  .mf-escala-mk {{ position:relative; height:0; }}
  .mf-escala-mk i {{ position:absolute; top:-18px; width:3px; height:22px; background:{COR['text']}; border-radius:2px;
                    box-shadow:0 0 0 2px #FFFFFF; }}
  .mf-escala-num {{ display:flex; justify-content:space-between; font-size:12px; color:{COR['text2']}; margin-top:8px; }}
  .mf-score {{ font-size:56px; line-height:60px; font-weight:700; color:{COR['text']}; }}
  .mf-score small {{ font-size:16px; color:{COR['text2']}; font-weight:500; }}
  .mf-barra {{ height:8px; border-radius:999px; background:{COR['lineSoft']}; overflow:hidden; }}
  .mf-barra i {{ display:block; height:100%; border-radius:999px; }}
  .mf-avatar {{ width:36px; height:36px; border-radius:999px; background:{COR['goldSoft']}; color:{COR['deep']};
               display:inline-flex; align-items:center; justify-content:center; font-size:12px; font-weight:700; flex:none; }}
""")


def selo(nivel: str | None) -> str:
    fundo, texto, _, nome = SELO.get(nivel or "PENDENTE", SELO["PENDENTE"])
    return (f'<span class="mf-selo" style="background:{fundo};color:{texto}" aria-label="Nível {nome}">'
            f'{icone(ICONE_NIVEL.get(nivel or "PENDENTE", "info"), 14)}{nome}</span>')


def mostrar_selo(nivel):
    st.markdown(selo(nivel), unsafe_allow_html=True)


def card(rotulo: str, valor, legenda: str = "", icone_nome: str | None = None):
    valor_txt = "suprimido" if valor is None else valor
    ic = icone(icone_nome, 18, COR["deep"]) if icone_nome else ""
    estilo = ' style="font-size:20px;line-height:28px"' if len(str(valor_txt)) > 12 else ""  # texto longo
    st.markdown(f'<div class="mf-card"><div class="topo"><span class="rot">{html.escape(rotulo)}</span>{ic}</div>'
                f'<div class="val"{estilo}>'
                f'{html.escape(str(valor_txt))}</div>'
                f'<div class="leg">{html.escape(legenda)}</div></div>', unsafe_allow_html=True)


def cabecalho(titulo: str, subtitulo: str = "", sobretitulo: str = ""):
    """Cabecalho de pagina do Figma: sobretitulo dourado, titulo (h1 28/36) e subtitulo."""
    st.markdown('<div class="mf-cab">' + (f'<div class="mf-sobre">{html.escape(sobretitulo)}</div>' if sobretitulo else "")
                + f'<h1 class="mf-titulo">{html.escape(titulo)}</h1>'
                + (f'<div class="mf-sub">{html.escape(subtitulo)}</div>' if subtitulo else "") + "</div>",
                unsafe_allow_html=True)


def titulo_painel(titulo: str, subtitulo: str = ""):
    st.markdown(f'<div class="mf-h3">{html.escape(titulo)}</div>'
                + (f'<div class="mf-h3sub">{html.escape(subtitulo)}</div>' if subtitulo else '<div style="height:10px"></div>'),
                unsafe_allow_html=True)


@contextlib.contextmanager
def painel(chave: str):
    """Bloco branco com borda creme e raio 16 (Figma: cartoes de secao)."""
    with st.container(key="pn_" + chave):
        yield


def banner(titulo: str, texto: str, icone_nome: str = "zap"):
    st.markdown(f'<div class="mf-banner">{icone(icone_nome, 20, COR["deep"])}<div><b>{html.escape(titulo)}</b>'
                f'<span>{html.escape(texto)}</span></div></div>', unsafe_allow_html=True)


def iniciais(nome: str | None) -> str:
    partes = [p for p in (nome or "?").replace(".", " ").split() if p[:1].isalpha()]
    return ((partes[0][0] + (partes[-1][0] if len(partes) > 1 else "")) if partes else "?").upper()


def restrito(texto="Informação restrita a outro perfil, conforme a matriz de acesso e a LGPD."):
    st.markdown(f'<div class="mf-restrito">{icone("lock", 16)}<span>{html.escape(texto)}</span></div>',
                unsafe_allow_html=True)


def decisao_humana():
    st.markdown(f'<div class="mf-decisao"><b>{icone("shield-check", 15, COR["deep"])}Decisão humana</b>'
                f'<span style="color:{COR["text2"]}">{AVISO_DECISAO}</span></div>', unsafe_allow_html=True)


def rodape(extra: str = ""):
    st.markdown(f'<div class="mf-rodape">{html.escape(AVISO_PESOS)} {html.escape(extra)}<br>'
                'Uso restrito à equipe autorizada. Dados pessoais tratados conforme a LGPD.</div>',
                unsafe_allow_html=True)


# ---------- Tabelas de dados (somente leitura) ----------
# Celulas ja em HTML seguro: todo texto vindo da API passa por html.escape.

def txt(valor, vazio: str = "—") -> str:
    if valor is None or valor == "":
        return f'<span class="mf-vazio">{vazio}</span>'
    return html.escape(str(valor))


def cel_dupla(principal, detalhe=None) -> str:
    """Texto principal em destaque e uma linha menor embaixo."""
    return f'<b>{txt(principal)}</b>' + (f'<small>{txt(detalhe)}</small>' if detalhe not in (None, "") else "")


def cel_nota(valor, minimo: float | None = 6.0, casas: int = 1) -> str:
    """Nota no formato brasileiro (7,8); abaixo do minimo fica em destaque."""
    if valor is None:
        return '<span class="mf-vazio">—</span>'
    if minimo is None:
        return f'<span class="mf-num">{numero_br(valor, casas)}</span>'
    abaixo = float(valor) < minimo
    return f'<span class="mf-nota{" baixa" if abaixo else ""}">{numero_br(valor, casas)}</span>'


def cel_freq(valor, minimo: float | None = 75.0) -> str:
    """Frequencia com barra curta; abaixo do minimo em destaque."""
    if valor is None:
        return '<span class="mf-vazio">sem dado</span>'
    v = max(0.0, min(100.0, float(valor)))
    abaixo = minimo is not None and v < minimo
    cor = COR["errFg"] if abaixo else COR["okFg"]
    return (f'<span class="mf-freq{" baixa" if abaixo else ""}"><span class="trilho"><span style="width:{v:.0f}%;'
            f'background:{cor}"></span></span><span class="num">{numero_br(v, 0)}%</span></span>')


SITUACAO_ESTILO = {"aprovad": ("okBg", "okFg", "check"), "reprovad": ("errBg", "errFg", "x"),
                   "cursando": ("infoBg", "infoFg", "clock"), "trancad": ("infoBg", "infoFg", "minus")}


def cel_situacao(texto) -> str:
    """Situacao da disciplina ou do pedido em selo com icone e texto."""
    if not texto:
        return '<span class="mf-vazio">—</span>'
    rotulo = str(texto).replace("_", " ").lower()
    rotulo = rotulo[:1].upper() + rotulo[1:]
    chave = next((k for k in SITUACAO_ESTILO if k in rotulo.lower()), None)
    fundo, cor, ic = SITUACAO_ESTILO.get(chave, ("creamSoft", "text2", None))
    return pilula(rotulo, COR[fundo], COR[cor], ic)


def cel_alertas(itens: list[str], ok: str = "Em dia") -> str:
    """Pontos de atencao em etiquetas; sem nenhum, um selo verde."""
    if not itens:
        return pilula(ok, COR["okBg"], COR["okFg"], "check")
    return " ".join(pilula(i, COR["errBg"], COR["errFg"], "triangle-alert") for i in itens)


def grade(colunas: list, linhas: list[list[str]], legenda: str = "", rotulo: str = "Tabela"):
    """
    Tabela de leitura no padrao visual do MUFASA (substitui st.dataframe nas telas).
    colunas: nomes, ou (nome, alinhamento) com alinhamento "e", "c" ou "d".
    linhas: celulas ja em HTML seguro (use txt/cel_* acima).
    """
    cols = [(c, "e") if isinstance(c, str) else c for c in colunas]
    cab = "".join(f'<th scope="col" class="al-{a}">{html.escape(n)}</th>' for n, a in cols)
    corpo = "".join("<tr>" + "".join(f'<td class="al-{cols[i][1]}">{cel}</td>' for i, cel in enumerate(l)) + "</tr>"
                    for l in linhas)
    st.markdown(f'<div class="mf-grade-caixa" role="region" aria-label="{html.escape(rotulo)}" tabindex="0">'
                f'<table class="mf-grade"><caption>{html.escape(rotulo)}</caption><thead><tr>{cab}</tr></thead>'
                f'<tbody>{corpo}</tbody></table></div>'
                + (f'<p class="mf-grade-leg">{icone("info", 13)}<span>{html.escape(legenda)}</span></p>' if legenda else ""),
                unsafe_allow_html=True)


def grade_simples(linhas: list[dict], rotulo: str, legenda: str = "", direita: tuple = (), destaque: dict | None = None):
    """Tabela a partir de dicionarios (chave = coluna). destaque: coluna -> funcao(valor) que devolve HTML."""
    if not linhas:
        return
    colunas = list(linhas[0])
    destaque = destaque or {}
    grade([(c, "d" if c in direita else "e") for c in colunas],
          [[destaque[c](l.get(c)) if c in destaque else txt(l.get(c)) for c in colunas] for l in linhas],
          legenda, rotulo)


def resumo(itens: list[tuple]):
    """Faixa de numeros-chave acima de uma tabela: (rotulo, valor, tom) com tom ok, alerta ou neutro."""
    tons = {"ok": (COR["okBg"], COR["okFg"]), "alerta": (COR["errBg"], COR["errFg"]),
            "neutro": (COR["creamSoft"], COR["text"])}
    st.markdown('<div class="mf-resumo">' + "".join(
        f'<div style="background:{tons[t][0]}"><span class="v" style="color:{tons[t][1]}">{html.escape(str(v))}</span>'
        f'<span class="r">{html.escape(r)}</span></div>' for r, v, t in itens) + "</div>", unsafe_allow_html=True)


ICONE_FATOR = {"notas": "book-open", "frequencia": "calendar-check", "reprovacao": "circle-x",
               "engajamento_ava": "monitor", "financeiro": "wallet", "trabalho": "clock", "dependentes": "users",
               "deslocamento": "map-pin", "moradia": "house", "saude_mental": "heart-pulse",
               "saude_fisica": "heart-pulse", "encaminhado": "lock"}


def cartoes_fatores(fatores: list[dict], direita=None):
    """Fatores do risco em cartoes com icone. direita(f) devolve HTML extra (pontos, faixa)."""
    st.markdown('<div class="mf-fatores">' + "".join(
        f'<div class="mf-fator"><span class="ico">{icone(ICONE_FATOR.get(f.get("fator"), "info"), 18)}</span>'
        f'<div><b>{html.escape((f.get("nome") or "").capitalize())}</b>'
        f'<p>{html.escape(f.get("explicacao") or "")}</p>'
        + (f'<div class="pts">{direita(f)}</div>' if direita and direita(f) else "") + "</div></div>"
        for f in fatores) + "</div>", unsafe_allow_html=True)


def nota_metodologica(texto: str):
    st.markdown(f'<div class="mf-nota-metodo">{icone("info", 16)}<span>{html.escape(texto)}</span></div>',
                unsafe_allow_html=True)


def numero_br(valor, casas=1) -> str:
    if valor is None:
        return "sem dado"
    texto = f"{float(valor):,.{casas}f}"
    return texto.replace(",", "X").replace(".", ",").replace("X", ".")


def data_br(texto) -> str:
    if not texto:
        return "—"
    try:
        return datetime.fromisoformat(str(texto)).astimezone().strftime("%d/%m/%Y %H:%M")
    except ValueError:
        return str(texto)


def _slug(texto: str) -> str:
    texto = unicodedata.normalize("NFKD", texto).encode("ascii", "ignore").decode().lower()
    return re.sub(r"[^a-z0-9]+", "_", texto).strip("_")


@contextlib.contextmanager
def secao(titulo: str | None = None, subtitulo: str = "", chave: str | None = None):
    """Isola uma parte da tela: erro aqui nao derruba o restante (Plano T27).

    Com titulo, a secao vira um painel do Figma (bloco branco, titulo h3 e subtitulo).
    """
    caixa = st.container(key="pn_s_" + (chave or _slug(titulo))) if titulo else st.container()
    with caixa:
        if titulo:
            titulo_painel(titulo, subtitulo)
        try:
            yield
        except ServicoIndisponivel as e:
            st.warning(e.mensagem)
        except ErroAPI as e:
            if e.status == 403 and e.pendencia:
                st.session_state["pendencia"] = e.pendencia
                st.rerun()
            if e.status in (403, 404, 409, 422):
                st.info(e.mensagem)
            else:
                st.error(e.mensagem + (f" Código para o suporte: {e.requisicao}." if e.requisicao else ""))
        except Exception:  # noqa: BLE001 - qualquer falha de exibicao fica contida na secao
            codigo = "P-" + uuid.uuid4().hex[:8]
            log.exception("falha ao montar a secao %r (codigo %s)", titulo or "-", codigo)
            st.error("Não foi possível mostrar esta parte agora. O restante da tela continua funcionando. "
                     f"Código para o suporte: {codigo}.")


def _seguro_planilha(valor):
    """Impede injecao de formula ao abrir o CSV no Excel/LibreOffice (OWASP CSV injection)."""
    if isinstance(valor, str) and valor[:1] in ("=", "+", "-", "@", "\t", "\r"):
        return "'" + valor
    return valor


def csv_exportacao(linhas: list[dict], colunas: list[str], titulo: str, perfil: str) -> bytes:
    saida = io.StringIO()
    escritor = csv.writer(saida, delimiter=";")
    escritor.writerow([_seguro_planilha(c) for c in colunas])
    for l in linhas:
        escritor.writerow([_seguro_planilha(l.get(c)) for c in colunas])
    escritor.writerow([])
    escritor.writerow([f"# {titulo} · gerado em {datetime.now():%d/%m/%Y %H:%M} · perfil {perfil}"])
    escritor.writerow([f"# {AVISO_PESOS}"])
    escritor.writerow(["# CONFIDENCIAL: uso restrito à equipe autorizada (LGPD). Não compartilhe fora da instituição."])
    return ("﻿" + saida.getvalue()).encode("utf-8")


def _icone_botao(chave_container: str, icone_nome: str):
    css(f".st-key-{chave_container} button::before {{ content:''; -webkit-mask-image:{icone_url(icone_nome, '#000')};"
        f" mask-image:{icone_url(icone_nome, '#000')}; }}")


def botao_exportar(linhas, colunas, titulo, nome_arquivo):
    chave = "lk_exp_" + _slug(nome_arquivo)
    _icone_botao(chave, "download")
    with st.container(key=chave):
        _botao_download(linhas, colunas, titulo, nome_arquivo)


def _botao_download(linhas, colunas, titulo, nome_arquivo):
    st.download_button("Exportar CSV", csv_exportacao(linhas, colunas, titulo, st.session_state.get("perfil", "")),
                       file_name=nome_arquivo, mime="text/csv", help="O arquivo leva o rodapé de versão e "
                       "confidencialidade (RF21, RN23).")


def ir(url_path: str, **estado):
    """Vai para outra tela do perfil levando o contexto (ex.: matricula da ficha)."""
    st.session_state.update(estado)
    pagina = st.session_state.get("_paginas", {}).get(url_path)
    if pagina is not None:
        st.switch_page(pagina)


def link(rotulo: str, url_path: str, chave: str, icone_nome: str | None = None, **estado):
    """Atalho para outra tela; com icone_nome, o icone do Figma vai antes do texto."""
    if icone_nome:
        _icone_botao("lk_" + chave, icone_nome)
    with st.container(key="lk_" + chave):
        if st.button(rotulo, key=chave):
            ir(url_path, **estado)


def voltar(rotulo: str, chave: str) -> bool:
    """Botao de texto com seta para a esquerda (Figma: voltar)."""
    with st.container(key="vt_" + chave):
        return st.button(rotulo, key=chave)


def pilula(texto: str, fundo: str | None = None, cor: str | None = None, icone_nome: str | None = None,
           contorno: bool = False) -> str:
    """Pilula de estado do Figma (prazo, situacao, categoria do fator)."""
    ic = icone(icone_nome, 12) if icone_nome else ""
    if contorno:
        return f'<span class="mf-pilula contorno">{html.escape(texto)}</span>'
    return (f'<span class="mf-pilula" style="background:{fundo or COR["goldSoft"]};color:{cor or COR["text"]}">'
            f'{ic}{html.escape(texto)}</span>')


def barra(valor, maximo=100, cor: str | None = None, largura: str = "100%") -> str:
    pct = 0 if valor is None or not maximo else max(0, min(100, float(valor) / maximo * 100))
    return (f'<div class="mf-barra" style="width:{largura}"><i style="width:{pct:.0f}%;'
            f'background:{cor or COR["mustard"]}"></i></div>')


def pessoa(nome: str, detalhe: str = "", tamanho: int = 32) -> str:
    """Celula de tabela do Figma: iniciais, nome e uma linha de detalhe."""
    return (f'<div class="mf-lista-l" style="min-height:0">{avatar(nome, tamanho)}<div><b>{html.escape(nome)}</b>'
            f'<small>{html.escape(detalhe)}</small></div></div>')


def tabela(chave: str, cabecalho: list[str], pesos: list[float], linhas: list[tuple], rotulo_acao: str | None = None,
           primario: bool = False, rodape: str = ""):
    """Tabela do Figma (cabecalho creme, linhas com divisoria e botao de acao por linha).

    linhas: (identificador, [html de cada coluna]). Devolve o identificador da linha cujo botao foi clicado.
    """
    clicado = None
    pesos_todos = pesos + ([0.9] if rotulo_acao else [])
    with st.container(key="pn_tb_" + chave):
        grade = " ".join(f"{p}fr" for p in pesos_todos)
        st.markdown(f'<div class="mf-cab-tabela" style="grid-template-columns:{grade}">'
                    + "".join(f"<span>{html.escape(c)}</span>" for c in cabecalho + ([""] if rotulo_acao else []))
                    + "</div>", unsafe_allow_html=True)
        for ident, celulas in linhas:
            with st.container(key=f"lin_{chave}_{_slug(str(ident))}"):
                cols = st.columns(pesos_todos, vertical_alignment="center")
                for col, conteudo in zip(cols, celulas):
                    col.markdown(conteudo, unsafe_allow_html=True)
                if rotulo_acao and cols[-1].button(rotulo_acao, key=f"bt_{chave}_{_slug(str(ident))}",
                                                   type="primary" if primario else "secondary"):
                    clicado = ident
        if rodape:
            st.markdown(f'<div class="mf-rodape-tabela">{rodape}</div>', unsafe_allow_html=True)
    return clicado


def heroi(nome: str, selo_html: str, meta: list[tuple[str, str]], proporcao=(3, 1)):
    """Cabecalho de pessoa do Figma (ficha e alerta): avatar, nome, selo e metadados.

    Devolve a coluna da direita, para os botoes de acao.
    """
    with st.container(key="heroi"):
        esq, dir_ = st.columns(proporcao, vertical_alignment="center")
        esq.markdown(f'<div class="mf-hero">{avatar(nome, 64)}<div><h1>{html.escape(nome)} {selo_html}</h1>'
                     '<div class="meta">' + "".join(f"<span>{icone(i, 14)}{html.escape(t)}</span>" for i, t in meta)
                     + '</div></div></div>', unsafe_allow_html=True)
    return dir_


def aviso(titulo: str, texto: str, icone_nome: str = "info"):
    """Faixa informativa do Figma (fundo creme claro, icone, titulo e texto)."""
    st.markdown(f'<div class="mf-aviso">{icone(icone_nome, 20, COR["deep"])}<div><b>{html.escape(titulo)}</b>'
                f'<span>{html.escape(texto)}</span></div></div>', unsafe_allow_html=True)


def atalho(chave: str, url_path: str, titulo: str, texto: str, icone_nome: str):
    """Cartao de atalho do Figma (icone em caixa creme, titulo, descricao e seta)."""
    pagina = st.session_state.get("_paginas", {}).get(url_path)
    if pagina is None:
        return
    texto_css = texto.replace("\\", "").replace("'", "’")
    css(f".st-key-at_{chave} [data-testid='stPageLink'] a::before {{ background-image:{icone_url(icone_nome, COR['deep'])}; }}"
        f".st-key-at_{chave} [data-testid='stPageLink'] a::after {{ content:'{texto_css}'; }}")
    with st.container(key="at_" + chave):
        st.page_link(pagina, label=titulo)


def texto_link(rotulo: str, chave: str) -> bool:
    """Link de texto com seta (Figma: "Ver alunos ->")."""
    with st.container(key="tx_" + chave):
        return st.button(rotulo, key=chave)


def selo_decisao() -> str:
    return pilula("Recomendação do sistema — decisão humana", COR["text"], "#FFFFFF", "shield-check")


def avatar(nome: str | None, tamanho: int = 36) -> str:
    return (f'<span class="mf-avatar" style="width:{tamanho}px;height:{tamanho}px">'
            f'{html.escape(iniciais(nome))}</span>')
