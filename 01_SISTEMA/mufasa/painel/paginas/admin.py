"""Administracao tecnica (Figma Parte 6): servicos, cargas, contas, parametros e registros. Sem dado de aluno."""

import html

import streamlit as st

import cliente
import ui

NOME_SERVICO = {"api": "API de dados", "chat": "Assistente", "calculo": "Serviço de cálculo", "painel": "Painel"}
PERFIS = {"Aluno": "ALUNO", "Docente": "DOCENTE", "Coordenação": "COORDENACAO", "NAE": "NUCLEO_APOIO",
          "Setor financeiro": "FINANCEIRO", "Gestão": "DIRECAO", "Administração técnica": "ADMIN",
          "Encarregado de dados": "ENCARREGADO_DADOS"}


def hub():
    ui.cabecalho("Visão técnica", "Saúde dos serviços, fila de cálculo e atalhos da administração · sem dado de aluno",
                 "Administração técnica")

    @st.fragment(run_every="15s")
    def _servicos():
        with ui.secao("Serviços"):
            r = cliente.get("/api/v1/admin/servicos")
            cols = st.columns(max(len(r["servicos"]), 1) + 1)
            for col, s in zip(cols, r["servicos"]):
                with col:
                    ui.card(NOME_SERVICO.get(s["servico"], s["servico"]), "no ar" if s["no_ar"] else "sem sinal",
                            f"último sinal há {s['segundos_desde_sinal']} s",
                            "circle-check" if s["no_ar"] else "circle-x")
            with cols[-1]:
                ui.card("Fila de recálculo", r["alunos_na_fila_de_calculo"], "alunos aguardando", "hourglass")
            st.caption("Cada serviço roda em processo separado: se um cair, os outros continuam.")
    _servicos()

    with st.container(horizontal=True):
        ui.link("Cargas de dados", "cargas", "h_cargas", "database")
        ui.link("Usuários", "usuarios", "h_usu", "users")
        ui.link("Registros técnicos", "registros", "h_reg", "terminal")
    with ui.secao("Recalcular scores"):
        with st.form("recalculo"):
            curso = st.text_input("Curso (opcional, código)", max_chars=12).strip().upper() or None
            semestre = st.number_input("Semestre (0 = todos)", 0, 20, 0)
            if st.form_submit_button("Enfileirar recálculo"):
                r = cliente.post("/api/v1/calculos", {"curso": curso, "semestre": int(semestre) or None})
                st.success(f"{r['alunos_enfileirados']} aluno(s) enfileirados. O serviço de cálculo processa em seguida.")


def _relatorio(r: dict):
    rej = r.get("rejeicoes") or []
    st.markdown(f"Carga {r['id_carga']} {ui.pilula(r['situacao'].replace('_', ' ').capitalize(), contorno=True)} · "
                f"{r.get('linhas_total')} linhas, {r.get('linhas_validas')} válidas", unsafe_allow_html=True)
    if rej:
        st.error("Nenhuma linha foi aplicada. Corrija e envie de novo (RN08: sem carga parcial).")
        ui.grade_simples(rej, "Linhas rejeitadas")


def cargas():
    ui.cabecalho("Cargas de dados", "CSV separado por ponto e vírgula ou vírgula, em UTF-8, até 20 MB. A carga só é "
                 "aplicada se todas as linhas forem válidas e depois da sua confirmação.", "Administração técnica")
    with ui.secao("Enviar arquivo"):
        with st.form("carga", clear_on_submit=True):
            tipo = st.radio("Tipo", ["NOTAS", "INDICADORES"], horizontal=True,
                            captions=["id_aluno;id_turma;va1;va2;va3;nota_final;frequencia_pct;situacao",
                                      "id_aluno;periodo_letivo;faltas_total;atividades_pendentes;"
                                      "disciplinas_reprovadas_historico;media_semestre_anterior"])
            arquivo = st.file_uploader("Arquivo CSV", type=["csv"])
            if st.form_submit_button("Validar", type="primary") and arquivo is not None:
                r = cliente.post("/api/v1/importacoes", data={"tipo": tipo},
                                 files={"arquivo": (arquivo.name, arquivo.getvalue(), "text/csv")})
                st.session_state["carga_aberta"] = r["id_carga"]
    with ui.secao("Histórico de cargas"):
        lista = cliente.get("/api/v1/importacoes")
        if not lista:
            st.caption("Nenhuma carga enviada.")
        pesos = [0.6, 1, 2.4, 1.2, 1.4, 1, 1]
        if lista:
            st.markdown('<div class="mf-cab-tabela" style="grid-template-columns:' + " ".join(f"{p}fr" for p in pesos)
                        + '"><span>Nº</span><span>Tipo</span><span>Arquivo</span><span>Linhas</span><span>Situação</span>'
                        '<span></span><span></span></div>', unsafe_allow_html=True)
        for c in lista:
            with st.container(key=f"lin_cargas_{c['id_carga']}"):
                col = st.columns(pesos, vertical_alignment="center")
                col[0].markdown(f"#{c['id_carga']}")
                col[1].markdown(c["tipo"].capitalize())
                col[2].markdown(f'<div class="mf-est"><b>{html.escape(c["nome_arquivo"])}</b><small>'
                                f'{ui.data_br(c["enviado_em"])} · {html.escape(c.get("enviado_por") or "—")}</small></div>',
                                unsafe_allow_html=True)
                col[3].markdown(f"{c['linhas_validas']}/{c['linhas_total']} válidas")
                col[4].markdown(ui.pilula(c["situacao"].replace("_", " ").capitalize(), contorno=True), unsafe_allow_html=True)
                if col[5].button("Detalhes", key=f"cd{c['id_carga']}"):
                    st.session_state["carga_aberta"] = c["id_carga"]
                if c["situacao"] == "VALIDADA" and col[6].button("Confirmar", key=f"cc{c['id_carga']}", type="primary"):
                    r = cliente.post(f"/api/v1/importacoes/{c['id_carga']}/confirmacao")
                    st.success(r["observacao"])
                    st.rerun()
    if aberta := st.session_state.get("carga_aberta"):
        with ui.secao(f"Relatório da carga {aberta}"):
            r = cliente.get(f"/api/v1/importacoes/{aberta}")
            _relatorio(r)
            st.caption(f"SHA-256: {r.get('hash_sha256')}" + (f" · resultado: {r['resultado']}" if r.get("resultado") else ""))
            if r["situacao"] == "VALIDADA" and st.button("Cancelar esta carga"):
                cliente.post(f"/api/v1/importacoes/{aberta}/cancelamento")
                st.rerun()


def usuarios():
    ui.cabecalho("Usuários e perfis de acesso", "Contas, perfis e senhas provisórias · cada mudança fica na trilha "
                 "de auditoria", "Administração técnica")
    with ui.secao("Criar conta"):
        with st.form("novo", clear_on_submit=True):
            c1, c2, c3 = st.columns(3)
            nome = c1.text_input("Nome", max_chars=120)
            login = c2.text_input("Login", max_chars=64)
            perfil = c3.selectbox("Perfil", list(PERFIS))
            c4, c5, c6 = st.columns(3)
            id_curso = c4.text_input("Curso (coordenação/NAE)", max_chars=12).strip().upper() or None
            id_prof = c5.text_input("Código do professor (docente)", max_chars=40).strip() or None
            id_aluno = c6.text_input("Matrícula (aluno)", max_chars=7).strip().upper() or None
            if st.form_submit_button("Criar", type="primary"):
                try:
                    r = cliente.post("/api/v1/admin/usuarios", {"nome": nome, "login": login, "perfil": PERFIS[perfil],
                                                                "id_curso": id_curso, "id_professor": id_prof,
                                                                "id_aluno": id_aluno})
                    st.success(f"Conta {r['login']} criada. Senha provisória: `{r['senha_provisoria']}`. {r['aviso']}")
                except cliente.ErroAPI as e:
                    st.error(e.mensagem + (" " + "; ".join(c["mensagem"] for c in e.campos) if e.campos else ""))
    with ui.secao("Contas"):
        c1, c2, c3 = st.columns([1, 2, 1])
        filtro = c1.selectbox("Perfil", ["Todos"] + list(PERFIS))
        busca = c2.text_input("Buscar por login ou nome", max_chars=60)
        pagina = c3.number_input("Página", 1, 10_000, 1)
        r = cliente.get("/api/v1/admin/usuarios", perfil=PERFIS.get(filtro), busca=busca.strip() or None,
                        limite=50, pagina=int(pagina))
        st.caption(" · ".join(f"{x['perfil'].lower()}: {x['ativos']}/{x['total']} ativas, {x['primeiro_acesso']} sem "
                              "primeiro acesso" for x in r["resumo"]))
        pesos = [2.6, 1.4, 1.6, 1, 1, 1]
        st.markdown('<div class="mf-cab-tabela" style="grid-template-columns:' + " ".join(f"{p}fr" for p in pesos)
                    + '"><span>Conta</span><span>Perfil</span><span>Situação</span><span></span><span></span>'
                    '<span></span></div>', unsafe_allow_html=True)
        for u in r["itens"]:
            with st.container(key=f"lin_usu_{u['id_usuario']}"):
                col = st.columns(pesos, vertical_alignment="center")
                col[0].markdown(ui.pessoa(u.get("nome") or u["login"], u["login"] + (" · demonstração" if u.get("demonstracao")
                                                                                      else "")), unsafe_allow_html=True)
                col[1].markdown(ui.pilula(u["perfil"].replace("_", " ").capitalize()), unsafe_allow_html=True)
                col[2].markdown(f'<div class="mf-est">{ui.pilula("Ativa" if u["ativo"] else "Desativada", contorno=True)}'
                                f'{" " + ui.pilula("Bloqueada", ui.COR["errBg"], ui.COR["errFg"], "lock") if u["bloqueado"] else ""}'
                                f'<small>último acesso {ui.data_br(u.get("ultimo_login"))}</small></div>',
                                unsafe_allow_html=True)
                if col[3].button("Desativar" if u["ativo"] else "Ativar", key=f"at{u['id_usuario']}"):
                    cliente.patch(f"/api/v1/admin/usuarios/{u['id_usuario']}", {"ativo": not u["ativo"]})
                    st.rerun()
                if col[4].button("Nova senha", key=f"rs{u['id_usuario']}"):
                    s = cliente.patch(f"/api/v1/admin/usuarios/{u['id_usuario']}", {"redefinir_senha": True})
                    st.success(f"Senha provisória de {u['login']}: `{s['senha_provisoria']}` (mostrada só agora).")
                if u["bloqueado"] and col[5].button("Desbloquear", key=f"db{u['id_usuario']}"):
                    cliente.patch(f"/api/v1/admin/usuarios/{u['id_usuario']}", {"desbloquear": True})
                    st.rerun()


def tabela_parametros(dados: dict):
    def _valor(p):
        mudou = p["padrao_srs"] is not None and p["valor"] != p["padrao_srs"]
        unidade = f' <small>{ui.txt(p["unidade"])}</small>' if p.get("unidade") else ""
        return f'<span class="mf-nota{" mudou" if mudou else ""}">{ui.txt(format(p["valor"], "g"))}</span>{unidade}'

    ui.grade(["Parâmetro", ("Valor", "c"), ("Padrão do SRS", "c"), ("Faixa permitida", "c"), "Quem altera"],
             [[ui.cel_dupla(p["chave"], p["descricao"]), _valor(p),
               ui.txt(None if p["padrao_srs"] is None else f"{p['padrao_srs']:g}"),
               ui.txt(f"{p['minimo']:g} a {p['maximo']:g}"), ui.txt(p["quem_altera"])] for p in dados["parametros"]],
             "Valor em dourado: diferente do padrão do SRS.", "Parâmetros")
    with st.expander("Versões"):
        ui.grade(["Versão", "Criada em", "Autor", "Aprovador", "Justificativa"],
                 [[ui.txt(v["versao"]), ui.txt(ui.data_br(v["criada_em"])), ui.txt(v["autor"]),
                   ui.txt(v["aprovador"]), ui.txt(v["justificativa"])] for v in dados["versoes"]],
                 rotulo="Versões dos parâmetros")


def parametros():
    ui.cabecalho("Parâmetros configuráveis", "Toda mudança gera uma versão nova; os scores antigos guardam a versão "
                 "que os gerou (RN22). Nota mínima e cortes de risco dependem de aprovação da coordenação.",
                 "Administração técnica")
    with ui.secao("Parâmetros vigentes"):
        dados = cliente.get("/api/v1/parametros")
        tabela_parametros(dados)
        editaveis = {p["chave"]: p for p in dados["parametros"] if p["quem_altera"].startswith("Administração")}
        with st.form("parametro"):
            chave = st.selectbox("Parâmetro", list(editaveis),
                                 format_func=lambda k: f"{k} · {editaveis[k]['descricao']}")
            valor = st.number_input("Novo valor", value=float(editaveis[chave]["valor"]) if chave else 0.0, step=0.1)
            just = st.text_input("Justificativa (mínimo 10 caracteres)", max_chars=500)
            if st.form_submit_button("Salvar", type="primary"):
                try:
                    r = cliente.put(f"/api/v1/parametros/{chave}", {"valor": valor, "justificativa": just})
                    st.success(("Proposta enviada à coordenação. " if r["situacao"] == "PENDENTE"
                                else f"Versão {r['versao']} criada. ") + r["observacao"])
                except cliente.ErroAPI as e:
                    st.error(e.mensagem + (" " + "; ".join(c["mensagem"] for c in e.campos) if e.campos else ""))
        ui.titulo_painel("Propostas")
        if not dados["propostas"]:
            st.caption("Nenhuma proposta.")
        else:
            ui.grade(["Parâmetro", ("De", "c"), ("Para", "c"), "Situação", "Proposta por", "Decidida por", "Em"],
                     [[ui.txt(p["chave"]), ui.txt(p["valor_anterior"]), ui.txt(p["valor_novo"]),
                       ui.cel_situacao(p["situacao"]), ui.txt(p["proposto_por"]), ui.txt(p.get("decidido_por")),
                       ui.txt(ui.data_br(p["proposto_em"]))] for p in dados["propostas"]], rotulo="Propostas")


def registros():
    ui.cabecalho("Registros técnicos", "Erros e eventos dos serviços · não contém dado de aluno",
                 "Administração técnica")
    c1, c2, c3 = st.columns(3)
    servico = c1.selectbox("Serviço", ["Todos"] + list(NOME_SERVICO), format_func=lambda s: NOME_SERVICO.get(s, s))
    nivel = c2.selectbox("Nível", ["Todos", "ERRO", "AVISO", "INFO"])
    pagina = c3.number_input("Página", 1, 10_000, 1)

    @st.fragment(run_every="30s")
    def _lista():
        with ui.secao():
            linhas = cliente.get("/api/v1/admin/registros", servico=servico, nivel=nivel, limite=100, pagina=int(pagina))
            if not linhas:
                st.caption("Nenhum registro neste recorte.")
                return
            tom = {"ERRO": ("errBg", "errFg", "circle-x"), "AVISO": ("goldSoft", "text", "triangle-alert"),
                   "INFO": ("infoBg", "infoFg", "info")}
            ui.grade(["Momento", "Serviço", "Nível", "Evento e mensagem", "Requisição"],
                     [[ui.txt(ui.data_br(l["momento"])), ui.txt(l["servico"]),
                       ui.pilula(l["nivel"] or "—", ui.COR[tom.get(l["nivel"], tom["INFO"])[0]],
                                 ui.COR[tom.get(l["nivel"], tom["INFO"])[1]], tom.get(l["nivel"], tom["INFO"])[2]),
                       ui.cel_dupla(l["evento"], l["mensagem"]), (f'<code>{ui.txt(l["id_requisicao"])}</code>' if l["id_requisicao"] else ui.txt(None))]
                      for l in linhas], rotulo="Registros técnicos")
    _lista()
