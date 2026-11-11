"""
Servico de calculo do MUFASA: mantem score, alertas e paineis em tempo real.

    CALCULO_DATABASE_URL=postgresql+psycopg://mufasa_calculo:...@host/mufasa python -m app.servico_calculo

Processo separado da API: se ele parar, a API e o painel continuam no ar
mostrando o ultimo score calculado (Plano, T27: degradacao controlada), e o
painel avisa que o calculo esta parado pelo sinal de vida. Se a API parar,
o calculo continua.

Laco: espera NOTIFY 'mufasa_recalculo' (gatilhos de sql/painel.sql) por ate
5 segundos, processa a fila, aplica cargas confirmadas, confere prazos
vencidos e grava o sinal de vida. Banco fora do ar: tenta de novo com
espera crescente, sem derrubar o processo.
"""

import logging
import os
import signal
import sys
import time
from datetime import datetime, timezone

import psycopg
from sqlalchemy import create_engine
from sqlalchemy.engine import Engine, make_url

from app import __version__
from app.calculo.parametros import CATALOGO, Parametros, problemas_de_coerencia
from app.registro import configurar_registro
from app.servico_calculo import consultas_calculo as sql
from app.servico_calculo.cargas import aplicar_proxima_carga
from app.servico_calculo.recalculo import avisar_prazos_vencidos, processar_lote

log = logging.getLogger("mufasa.calculo")

ESPERA_NOTIFY_S = 5
INTERVALO_PRAZOS_S = 60
INTERVALO_SINAL_S = 15
ESPERA_MAXIMA_ERRO_S = 60

_parar = False


def _sinal_parar(*_):
    global _parar
    _parar = True


def carregar_parametros(engine: Engine) -> Parametros:
    """Versao vigente do banco. Valor incoerente nao entra: o calculo para e avisa (RN22)."""
    with engine.connect() as conexao:
        valores = {l["chave"]: float(l["valor"]) for l in conexao.execute(sql.PARAMETROS_VIGENTES).mappings()}
        versao = conexao.execute(sql.VERSAO_VIGENTE).scalar() or 0
    faltando = sorted(set(CATALOGO) - set(valores))
    if faltando:
        raise RuntimeError("parametros ausentes no banco: " + ", ".join(faltando))
    problemas = problemas_de_coerencia(valores)
    if problemas:
        raise RuntimeError("parametros incoerentes: " + " ".join(problemas))
    return Parametros(valores, versao=int(versao))


def _registrar(engine: Engine, nivel: str, evento: str, mensagem: str = "") -> None:
    try:
        with engine.begin() as conexao:
            conexao.execute(sql.REGISTRAR_LOG, {"agora": datetime.now(timezone.utc), "nivel": nivel,
                                                "evento": evento[:60], "mensagem": mensagem[:500]})
    except Exception:
        log.exception("nao foi possivel gravar o registro tecnico")


def _escutar(url_sqlalchemy: str):
    """Conexao psycopg crua so para LISTEN (o SQLAlchemy nao expoe notificacoes)."""
    url = make_url(url_sqlalchemy).set(drivername="postgresql")
    conexao = psycopg.connect(url.render_as_string(hide_password=False), autocommit=True)
    conexao.execute("LISTEN mufasa_recalculo")
    return conexao


def executar() -> int:
    configurar_registro("calculo")
    url = os.environ.get("CALCULO_DATABASE_URL")
    if not url:
        print("Defina CALCULO_DATABASE_URL (perfil mufasa_calculo).", file=sys.stderr)
        return 2
    signal.signal(signal.SIGTERM, _sinal_parar)
    signal.signal(signal.SIGINT, _sinal_parar)

    engine = create_engine(url, pool_pre_ping=True, pool_size=2, max_overflow=0, hide_parameters=True)
    escuta = None
    espera_erro = 1
    ultimo_prazo = ultimo_sinal = 0.0
    versao_em_uso = None
    _registrar(engine, "INFO", "servico_iniciado", f"versao {__version__}")

    while not _parar:
        try:
            p = carregar_parametros(engine)
            with engine.begin() as conexao:
                if versao_em_uso != p.versao:
                    conexao.execute(sql.ENFILEIRAR_SEM_SCORE)
                    conexao.execute(sql.ENFILEIRAR_VERSAO_ANTIGA, {"versao": p.versao})
                    versao_em_uso = p.versao
            processados = 1
            while processados and not _parar:
                with engine.begin() as conexao:
                    processados = processar_lote(conexao, p)
                if processados:
                    log.info("recalculados %s aluno(s)", processados)
            while aplicar_proxima_carga(engine) is not None:
                pass
            agora = time.monotonic()
            if agora - ultimo_prazo >= INTERVALO_PRAZOS_S:
                with engine.begin() as conexao:
                    avisar_prazos_vencidos(conexao)
                ultimo_prazo = agora
            if agora - ultimo_sinal >= INTERVALO_SINAL_S:
                with engine.begin() as conexao:
                    conexao.execute(sql.SINAL_DE_VIDA, {"agora": datetime.now(timezone.utc),
                                                        "detalhe": f"v{__version__}, parametros v{p.versao}"})
                ultimo_sinal = agora
            if escuta is None or escuta.closed:
                escuta = _escutar(url)
            for _ in escuta.notifies(timeout=ESPERA_NOTIFY_S, stop_after=1):
                pass
            espera_erro = 1
        except Exception as exc:
            log.exception("falha no laco de calculo; nova tentativa em %ss", espera_erro)
            _registrar(engine, "ERRO", "falha_no_laco", type(exc).__name__)
            if escuta is not None:
                try:
                    escuta.close()
                except Exception:
                    pass
                escuta = None
            time.sleep(espera_erro)
            espera_erro = min(ESPERA_MAXIMA_ERRO_S, espera_erro * 2)

    _registrar(engine, "INFO", "servico_encerrado")
    return 0


if __name__ == "__main__":
    raise SystemExit(executar())
