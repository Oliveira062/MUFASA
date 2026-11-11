"""
Painel do MUFASA (F1), em Streamlit.

    MUFASA_API_URL=http://127.0.0.1:8000 MUFASA_CHAT_URL=http://127.0.0.1:8001 \
        streamlit run painel/app.py

Fluxo: login com seletor de perfil -> primeiro acesso (termo e troca de
senha, exigidos pela API) -> hub do perfil, que leva as demais telas.
O painel nao tem acesso ao banco: cada numero vem da API, ja recortado
pelo perfil no servidor.
"""

import streamlit as st

import cliente
import casca
import ui
from paginas import acesso, admin, aluno, alertas, comum, coordenacao, docente, encarregado, financeiro, gestao, nae

st.set_page_config(page_title="MUFASA", page_icon="static/logo.png", layout="wide", initial_sidebar_state="expanded")
ui.aplicar_tema()
ui.acessibilidade()

def paginas_do_perfil(perfil: str):
    """Devolve (todas as paginas, itens do menu com o icone do Figma, pagina de notificacoes).

    O menu segue o shell do Figma de cada perfil; ficha, turma, notificacoes e conta
    continuam como paginas, abertas pelas listas, pelo sino e pelo nome na barra superior.
    """
    P = st.Page
    notificacoes = P(comum.notificacoes, title="Notificações", url_path="notificacoes")
    conta = P(comum.minha_conta, title="Minha conta", url_path="conta")
    assistente = P(comum.assistente, title="Assistente", url_path="assistente")
    ficha = P(comum.ficha, title="Ficha do aluno", url_path="ficha")
    menu, extras = [], [notificacoes, conta]
    if perfil == "COORDENACAO":
        menu = [(P(coordenacao.hub, title="Painel do curso", url_path="painel", default=True), "layout-dashboard"),
                (P(alertas.fila, title="Alertas", url_path="alertas"), "bell-ring"),
                (P(coordenacao.alunos, title="Alunos", url_path="alunos"), "users"),
                (assistente, "sparkles"),
                (P(coordenacao.parametros, title="Parâmetros", url_path="parametros"), "sliders-horizontal")]
        extras.append(ficha)
    elif perfil == "NUCLEO_APOIO":
        menu = [(P(nae.hub, title="Meus alertas", url_path="inicio", default=True), "bell-ring"),
                (P(nae.alunos, title="Alunos atribuídos", url_path="alunos"), "users"),
                (assistente, "sparkles"),
                (P(alertas.fila, title="Fila completa", url_path="alertas"), "list")]
        extras.append(ficha)
    elif perfil == "DOCENTE":
        menu = [(P(docente.hub, title="Minhas turmas", url_path="turmas", default=True), "book-open"),
                (P(alertas.fila, title="Alunos", url_path="alertas"), "users"),
                (assistente, "sparkles")]
        extras += [ficha, P(docente.turma, title="Turma", url_path="turma")]
    elif perfil == "FINANCEIRO":
        menu = [(P(financeiro.hub, title="Fator financeiro", url_path="inicio", default=True), "wallet"),
                (P(alertas.fila, title="Alertas", url_path="alertas"), "bell-ring")]
        extras.append(ficha)
    elif perfil == "DIRECAO":
        menu = [(P(gestao.hub, title="Painel institucional", url_path="painel", default=True), "landmark"),
                (P(gestao.relatorios, title="Relatórios", url_path="relatorios"), "file-chart-column")]
    elif perfil == "ADMIN":
        menu = [(P(admin.hub, title="Visão técnica", url_path="inicio", default=True), "monitor"),
                (P(admin.cargas, title="Cargas de dados", url_path="cargas"), "database"),
                (P(admin.usuarios, title="Usuários", url_path="usuarios"), "users"),
                (P(admin.parametros, title="Parâmetros", url_path="parametros"), "sliders-horizontal"),
                (P(admin.registros, title="Registros técnicos", url_path="registros"), "terminal")]
    elif perfil == "ENCARREGADO_DADOS":
        menu = [(P(encarregado.hub, title="Trilha de auditoria", url_path="auditoria", default=True), "shield-check"),
                (P(encarregado.solicitacoes, title="Pedidos dos titulares", url_path="pedidos"), "inbox")]
    elif perfil == "ALUNO":
        menu = [(P(aluno.hub, title="Início", url_path="inicio", default=True), "house"),
                (P(aluno.indicadores, title="Meus indicadores", url_path="indicadores"), "chart-line"),
                (P(aluno.apoio, title="Apoio", url_path="apoio"), "hand-heart"),
                (assistente, "sparkles"),
                (P(aluno.privacidade, title="Meu perfil e privacidade", url_path="privacidade"), "shield")]
    return [p for p, _ in menu] + extras, menu, notificacoes, conta


def principal():
    if "token" not in st.session_state:
        acesso.tela_login()
        return
    try:
        conta = cliente.get("/api/v1/conta/eu")
    except cliente.ErroAPI as e:
        if "token" not in st.session_state:  # sessao expirada: o cliente ja limpou
            st.rerun()
        st.error(e.mensagem)
        if st.button("Voltar ao login"):
            cliente.encerrar_sessao_local()
            st.rerun()
        return
    st.session_state["conta"] = conta
    if conta["termo_pendente"] or conta["deve_trocar_senha"]:
        acesso.primeiro_acesso(conta)
        return
    paginas, menu, notificacoes, pagina_conta = paginas_do_perfil(conta["perfil"])
    # Atalhos entre telas (ui.ir): cada pagina pelo endereco curto.
    st.session_state["_paginas"] = {p.url_path: p for p in paginas}
    navegacao = st.navigation(paginas, position="hidden")
    casca.menu_lateral(conta, menu, navegacao)
    casca.barra_superior(conta, navegacao.title, notificacoes, pagina_conta)
    navegacao.run()
    ui.rodape()


principal()
