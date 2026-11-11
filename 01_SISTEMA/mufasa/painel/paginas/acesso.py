"""Login com seletor de perfil e primeiro acesso (termo LGPD e troca de senha) - Figma Parte 1."""

import html
from pathlib import Path

import streamlit as st

import cliente
import ui

PERFIS = [("ALUNO", "Aluno"), ("DOCENTE", "Docente"), ("COORDENACAO", "Coordenação"),
          ("NUCLEO_APOIO", "NAE — Núcleo de apoio"), ("FINANCEIRO", "Setor financeiro"), ("DIRECAO", "Gestão"),
          ("ADMIN", "Administração técnica"), ("ENCARREGADO_DADOS", "Encarregado de dados")]
DOCS = Path(__file__).resolve().parents[2] / "docs"
VERSAO_TERMO = "1.0"


def _ler_documento(nome: str) -> str:
    try:
        return (DOCS / nome).read_text(encoding="utf-8")
    except OSError:
        return "Documento indisponível nesta instalação. Peça o texto ao encarregado de dados."


def _css_login():
    c = ui.COR
    ui.css(f"""
  /* Duas colunas do Figma (39% creme | 61% branco) em qualquer largura de tela */
  .block-container {{ max-width:none !important; padding:0 !important; }}
  [data-testid="stHorizontalBlock"]:has(.st-key-login_marca) {{ gap:0; min-height:100vh; align-items:stretch; }}
  [data-testid="stColumn"]:has(> div > .st-key-login_marca),
  [data-testid="stColumn"]:has(.st-key-login_marca) {{ background:{c['cream']}; }}
  .st-key-login_marca {{ min-height:100vh; padding:56px clamp(32px, 4vw, 72px) 48px clamp(32px, 4vw, 72px);
      display:flex; flex-direction:column; box-sizing:border-box; }}
  .st-key-login_form {{ min-height:100vh; justify-content:center; box-sizing:border-box; width:100%; max-width:456px;
      margin:0 auto; padding:48px 24px; }}
  .mf-lg-marca {{ display:flex; gap:14px; align-items:flex-start; }}
  .mf-lg-marca img {{ width:52px; height:52px; border-radius:10px; }}
  .mf-lg-marca b {{ font-size:14px; color:{c['text']}; display:block; }}
  .mf-lg-marca b {{ line-height:20px; }}
  .mf-lg-marca span {{ font-size:13px; color:{c['text2']}; line-height:18px; display:block; max-width:340px; margin-top:2px; }}
  .st-key-login_marca > [data-testid="stElementContainer"]:has(.mf-lg-chamada),
  .st-key-login_marca > [data-testid="stElementContainer"]:has(.mf-lg-selos) {{ margin-top:auto; }}
  .mf-lg-chamada {{ padding-top:48px; }}
  .mf-lg-chamada h1 {{ font-size:34px; line-height:42px; font-weight:700; color:{c['text']}; margin:0 0 14px 0;
                      padding:0; max-width:400px; }}
  .mf-lg-chamada p {{ font-size:15px; line-height:24px; color:{c['text2']}; max-width:420px; margin:0; }}
  .mf-lg-selos {{ padding-top:48px; }}
  .mf-lg-selos div {{ display:flex; gap:10px; align-items:center; font-size:13px; color:{c['text2']}; margin-top:10px; }}
  .mf-lg-titulo {{ font-size:28px; line-height:36px; font-weight:700; color:{c['text']}; margin:0 0 6px 0; }}
  .mf-lg-sub {{ font-size:14px; line-height:21px; color:{c['text2']}; margin:0 0 8px 0; }}
  .st-key-login_form [data-testid="stForm"] {{ border:none; padding:0; }}
  .st-key-login_form label p {{ font-size:13px !important; font-weight:600; color:{c['text']}; letter-spacing:0; }}
  .st-key-login_form [data-baseweb="input"] {{ min-height:44px; }}
  .st-key-login_form input {{ height:42px; }}
  /* icone fica na moldura do campo, para o preenchimento automatico do navegador nao escondê-lo */
  .st-key-campo_login [data-baseweb="input"] {{ background:#FFFFFF {ui.icone_url('user', c['text2'])} no-repeat 14px center / 16px
      !important; padding-left:30px; }}
  .st-key-campo_senha [data-baseweb="input"] {{ background:#FFFFFF {ui.icone_url('lock', c['text2'])} no-repeat 14px center / 16px
      !important; padding-left:30px; }}
  .st-key-login_form input:-webkit-autofill, .st-key-login_form input:-webkit-autofill:focus {{
      -webkit-box-shadow:0 0 0 1000px #FFFFFF inset; -webkit-text-fill-color:{c['text']}; }}
  .st-key-login_form [data-testid="stFormSubmitButton"] button {{ height:46px; font-size:15px; margin-top:6px; }}
  .mf-lg-ajuda {{ font-size:12px; color:{c['text2']}; margin:4px 0 0 0; line-height:18px; }}
""")


def tela_login():
    _css_login()
    esquerda, direita = st.columns([0.39, 0.61], gap=None, vertical_alignment="top")
    with esquerda:
        with st.container(key="login_marca"):
            st.markdown('<div class="mf-lg-marca"><img src="app/static/logo.png" alt="Logo do MUFASA"><div><b>MUFASA</b>'
                        '<span>Monitoramento Universitário de Frequência, Atividades, Saúde e Aprendizagem</span></div></div>',
                        unsafe_allow_html=True)
            st.markdown('<div class="mf-lg-chamada"><h1>Cada estudante visto a tempo.</h1><p>Sinais de risco de evasão '
                        'reunidos em um só lugar, com recomendações explicáveis e decisão sempre humana.</p></div>',
                        unsafe_allow_html=True)
            st.markdown(f'<div class="mf-lg-selos"><div>{ui.icone("shield-check", 16, ui.COR["deep"])}Dados tratados '
                        f'conforme a LGPD</div><div>{ui.icone("lock", 16, ui.COR["deep"])}Acesso por perfil, com trilha '
                        'de auditoria</div></div>', unsafe_allow_html=True)
    with direita:
        with st.container(key="login_form"):
            st.markdown('<div class="mf-lg-titulo">Entrar</div><div class="mf-lg-sub">Use seu login institucional para '
                        'acessar o MUFASA. Aluno entra com a matrícula.</div>', unsafe_allow_html=True)
            if aviso := st.session_state.pop("aviso_login", None):
                st.info(aviso)
            with st.form("login", clear_on_submit=False, border=False):
                perfil = st.selectbox("Perfil de acesso", PERFIS, format_func=lambda p: p[1],
                                      help="Escolha o perfil da sua conta. Perfil diferente do cadastrado não entra.")
                with st.container(key="campo_login"):
                    login = st.text_input("Login institucional (aluno: matrícula)", max_chars=64,
                                          autocomplete="username", placeholder="ex.: coordenacao.demo ou ALU0001")
                with st.container(key="campo_senha"):
                    senha = st.text_input("Senha", type="password", max_chars=72, autocomplete="current-password")
                enviar = st.form_submit_button("Entrar  →", type="primary", width="stretch")
            st.markdown('<div class="mf-lg-ajuda">Esqueceu a senha? Peça a redefinição à administração técnica pelo '
                        'canal institucional. Após 5 tentativas erradas, o acesso fica bloqueado por 15 minutos.</div>',
                        unsafe_allow_html=True)
            if enviar:
                if not login or not senha:
                    st.error("Preencha login e senha.")
                    return
                try:
                    cliente.entrar(login.strip(), senha, perfil[0])
                except cliente.ErroAPI as e:
                    st.error(f"Não foi possível entrar. {e.mensagem}")
                    return
                st.rerun()


def primeiro_acesso(conta: dict):
    _, meio, _ = st.columns([1, 2.2, 1])
    with meio:
        _primeiro_acesso(conta)


def _primeiro_acesso(conta: dict):
    st.markdown(f'<div class="mf-marca" style="display:flex;gap:12px;align-items:center;margin:24px 0 20px 0">'
                f'<img src="app/static/logo.png" alt="Logo do MUFASA" style="width:44px;height:44px;border-radius:10px">'
                f'<div><b style="display:block;font-size:15px">MUFASA</b><span style="font-size:13px;color:'
                f'{ui.COR["text2"]}">Primeiro acesso · {html.escape(conta.get("nome") or conta["login"])}</span></div></div>',
                unsafe_allow_html=True)
    if conta["termo_pendente"]:
        with ui.painel("termo"):
            ui.cabecalho("Aviso de privacidade e termo de uso", "Antes de usar o sistema, leia como seus dados e os dados "
                         "dos estudantes são tratados. O aceite fica registrado com data e versão.", "Passo 1 de 2")
            with st.expander("Termos de uso (versão 1.0)"):
                st.markdown(_ler_documento("TERMOS_DE_USO.md"))
            with st.expander("Política de privacidade"):
                st.markdown(_ler_documento("POLITICA_DE_PRIVACIDADE.md"))
            li = st.checkbox("Li e concordo com os termos de uso e a política de privacidade.")
            with st.container(horizontal=True):
                if st.button("Aceitar e continuar", type="primary", disabled=not li):
                    with ui.secao():
                        cliente.post("/api/v1/conta/termo", {"versao": VERSAO_TERMO, "aceito": True})
                        st.rerun()
                if st.button("Sair"):
                    cliente.sair()
                    st.rerun()
        return
    if conta["deve_trocar_senha"]:
        with st.form("senha"):
            ui.cabecalho("Troque a senha provisória", "A senha recebida é provisória. Crie uma senha sua: pelo menos "
                         "10 caracteres, com letras e números, sem o seu login.", "Passo 2 de 2")
            atual = st.text_input("Senha provisória", type="password", max_chars=72)
            nova = st.text_input("Nova senha", type="password", max_chars=72, autocomplete="new-password")
            repetir = st.text_input("Repita a nova senha", type="password", max_chars=72)
            ok = st.form_submit_button("Salvar nova senha", type="primary")
        if ok:
            if nova != repetir:
                st.error("As senhas novas não conferem.")
                return
            try:
                cliente.post("/api/v1/conta/senha", {"senha_atual": atual, "senha_nova": nova})
            except cliente.ErroAPI as e:
                detalhe = "; ".join(c["mensagem"] for c in e.campos) if e.campos else ""
                st.error(f"{e.mensagem} {detalhe}")
                return
            st.success("Senha alterada.")
            st.rerun()
