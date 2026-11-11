"""
Testes do painel (Streamlit) sem navegador, com o AppTest do proprio Streamlit.

Conferem que cada pagina carrega sem excecao e que o painel nao derruba a
tela quando a API esta fora do ar (isolamento de falhas). Os fluxos com
dados sao cobertos por teste_fluxos.py, direto na API que o painel usa.

    pytest testes/teste_painel.py -v
"""

import os
import sys
from pathlib import Path

import pytest

PAINEL = Path(__file__).resolve().parents[1] / "painel"
sys.path.insert(0, str(PAINEL))

AppTest = pytest.importorskip("streamlit.testing.v1").AppTest


@pytest.fixture
def app_sem_api(monkeypatch):
    # Porta onde nada escuta: simula a API fora do ar.
    monkeypatch.setenv("MUFASA_API_URL", "http://127.0.0.1:9")
    monkeypatch.chdir(PAINEL)
    return AppTest.from_file(str(PAINEL / "app.py"), default_timeout=30)


def test_login_mostra_seletor_de_perfil(app_sem_api):
    at = app_sem_api.run()
    assert not at.exception
    rotulos = [s.label for s in at.selectbox]
    assert "Perfil de acesso" in rotulos
    opcoes = at.selectbox[0].options
    assert len(opcoes) == 8


def test_login_com_api_fora_do_ar_mostra_aviso_sem_quebrar(app_sem_api):
    at = app_sem_api.run()
    at.text_input[0].input("coordenacao.demo")
    at.text_input[1].input("qualquer-senha")
    at.button[0].click().run()
    assert not at.exception
    textos = " ".join(e.value for e in at.error)
    assert "Não foi possível" in textos


def test_csv_exportado_tem_rodape_e_neutraliza_formula():
    import ui
    dados = ui.csv_exportacao([{"a": "+cmd", "b": "-1"}], ["a", "b"], "Teste", "DIRECAO").decode("utf-8-sig")
    assert "'+cmd" in dados


def test_resposta_do_chat_vira_html_seguro_e_organizado():
    from paginas.comum import formatar_resposta
    saida = formatar_resposta("Oi <script>x</script>\n\n• Cálculo I: nota final 7\n  VA1 7 · VA2 0\n\n"
                              "O nível de risco indica que o padrão de teste.")
    assert "<script>" not in saida and "&lt;script&gt;" in saida
    assert "<ul><li><b>Cálculo I</b>: nota final 7<small>VA1 7 · VA2 0</small></li></ul>" in saida
    assert 'class="mf-msg-nota"' in saida


def test_botao_de_acessibilidade_so_carrega_vlibras_depois_de_confirmar():
    import re
    import ui

    js = (PAINEL / "acessibilidade.js").read_text(encoding="utf-8")
    # VLibras desligado por padrao e baixado so dentro de carregarVLibras()
    assert re.search(r"libras:\s*false", js)
    corpo = js.split("function carregarVLibras()", 1)[1].split("function desligarVLibras()", 1)[0]
    assert "VLIBRAS + \"/vlibras-plugin.js\"" in corpo
    assert js.count("vlibras-plugin.js") == 1
    assert js.count("carregarVLibras();") == 1 and "if (pref.libras) carregarVLibras();" in js
    # o "Ativar" so aparece no aviso, e e ele que liga a preferencia
    assert 'acao === "libras-sim") { aviso.hidden = true; pref.libras = true; }' in js
    # o codigo vai para a pagina sem fechar a tag <script> antes da hora
    carregador = ui._carregador_acessibilidade()
    assert carregador.count("</") == 1 and carregador.endswith("</script>")


def test_tabela_de_dados_escapa_texto_e_destaca_abaixo_do_minimo():
    import ui

    assert "<script>" not in ui.txt("<script>x</script>")
    assert 'class="mf-nota baixa"' in ui.cel_nota(5.9, 6.0) and "5,9" in ui.cel_nota(5.9, 6.0)
    assert 'class="mf-nota"' in ui.cel_nota(7.0, 6.0)
    assert "baixa" in ui.cel_freq(60, 75) and "60%" in ui.cel_freq(60, 75)
    assert "Reprovado" in ui.cel_situacao("REPROVADO_NOTA") or "Reprovado nota" in ui.cel_situacao("REPROVADO_NOTA")
    assert "Em dia" in ui.cel_alertas([])


def test_configurar_copia_so_chaves_groq_para_o_env(tmp_path):
    sys.path.insert(0, str(PAINEL.parent))
    from scripts.configurar import aplicar_chaves, ler_chaves

    (tmp_path / "groq.env").write_text("﻿# chave\r\nGROQ_API_KEY=abc\r\nDATABASE_URL=invasao\r\n", encoding="utf-8")
    env = tmp_path / ".env"
    env.write_text("DATABASE_URL=certo\nGROQ_API_KEY=\n", encoding="utf-8")
    assert aplicar_chaves(env, ler_chaves(tmp_path / "groq.env")) == ["GROQ_API_KEY"]
    assert env.read_text(encoding="utf-8") == "DATABASE_URL=certo\nGROQ_API_KEY=abc\n"
    assert aplicar_chaves(env, ler_chaves(tmp_path / "groq.env")) == []
