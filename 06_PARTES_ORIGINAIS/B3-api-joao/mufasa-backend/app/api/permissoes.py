"""
Perfis e escopo de acesso (SRS Anexo E, RN07, RN17).

Duas perguntas, sempre no servidor e sempre nesta ordem:
1. O perfil pode usar este recurso?          -> auth.exigir_perfis
2. Este usuario pode ver ESTE aluno?          -> verificar_escopo_aluno

A segunda e a defesa contra BOLA/IDOR: trocar a matricula na URL nao
basta para ver outro aluno.
"""

from fastapi import Request
from sqlalchemy.engine import Connection

from app.api import auditoria
from app.api.auth import Usuario
from app.api.consultas import ALUNO_DAS_TURMAS_DO_DOCENTE, ALUNO_DO_CURSO, NIVEL_MAIS_RECENTE
from app.api.erros import MSG_ACESSO_NEGADO, erro_http

ALUNO = "ALUNO"
DOCENTE = "DOCENTE"
COORDENACAO = "COORDENACAO"
NUCLEO_APOIO = "NUCLEO_APOIO"
FINANCEIRO = "FINANCEIRO"
DIRECAO = "DIRECAO"
ADMIN = "ADMIN"
ENCARREGADO_DADOS = "ENCARREGADO_DADOS"

PERFIS = (ALUNO, DOCENTE, COORDENACAO, NUCLEO_APOIO, FINANCEIRO, DIRECAO, ADMIN, ENCARREGADO_DADOS)

# Perfis que leem dados individuais de aluno. DIRECAO, ADMIN e ENCARREGADO
# ficam fora por definicao do Anexo E.
LEITURA_INDIVIDUAL = (ALUNO, DOCENTE, COORDENACAO, NUCLEO_APOIO, FINANCEIRO)

NIVEIS_DE_ALERTA = ("Alto", "Crítico")

# Fatores do score por grau de restricao (RN07).
FATORES_SOCIOECONOMICOS = {"financeiro", "trabalho", "deslocamento", "moradia", "dependentes"}
FATORES_SAUDE = {"saude_mental", "saude_fisica"}
ROTULO_ENCAMINHADO = "fator encaminhado ao núcleo de apoio"


def _no_escopo(conexao: Connection, usuario: Usuario, id_aluno: str) -> bool:
    if usuario.perfil == ALUNO:
        return usuario.id_aluno is not None and usuario.id_aluno == id_aluno

    if usuario.perfil == DOCENTE:
        return usuario.id_professor is not None and conexao.execute(
            ALUNO_DAS_TURMAS_DO_DOCENTE, {"id_aluno": id_aluno, "id_professor": usuario.id_professor}
        ).first() is not None

    if usuario.perfil == COORDENACAO:
        return usuario.id_curso is not None and conexao.execute(
            ALUNO_DO_CURSO, {"id_aluno": id_aluno, "id_curso": usuario.id_curso}
        ).first() is not None

    if usuario.perfil in (NUCLEO_APOIO, FINANCEIRO):
        # Enquanto o modulo de alertas (Sprint 3) nao existe, "aluno com alerta"
        # e aproximado por: do mesmo curso e com ultima avaliacao Alto ou Critico.
        if usuario.id_curso is None:
            return False
        if conexao.execute(ALUNO_DO_CURSO, {"id_aluno": id_aluno, "id_curso": usuario.id_curso}).first() is None:
            return False
        nivel = conexao.execute(NIVEL_MAIS_RECENTE, {"id_aluno": id_aluno}).scalar()
        return nivel in NIVEIS_DE_ALERTA

    return False


def verificar_escopo_aluno(request: Request, conexao: Connection, usuario: Usuario,
                           id_aluno: str, operacao: str) -> None:
    """Barra e registra; a mensagem nao diz se o aluno existe."""
    if usuario.perfil not in LEITURA_INDIVIDUAL or not _no_escopo(conexao, usuario, id_aluno):
        auditoria.registrar(request, operacao, "NEGADO", usuario=usuario, id_aluno_alvo=id_aluno)
        raise erro_http(403, MSG_ACESSO_NEGADO)
    auditoria.registrar(request, operacao, "PERMITIDO", usuario=usuario, id_aluno_alvo=id_aluno)


def fator_visivel(perfil: str, fator: str) -> bool:
    """O perfil pode ver o NOME deste fator?"""
    if perfil in (ALUNO, NUCLEO_APOIO):
        return True
    if fator in FATORES_SAUDE:
        return False  # so o proprio aluno e o nucleo veem a natureza de dado de saude
    if perfil == DOCENTE and fator in FATORES_SOCIOECONOMICOS:
        return False
    return True


def valor_do_fator_visivel(perfil: str, fator: str) -> bool:
    """O perfil pode ver o VALOR numerico do risco deste fator?"""
    if perfil in (ALUNO, NUCLEO_APOIO):
        return True
    if perfil == COORDENACAO and fator in FATORES_SOCIOECONOMICOS:
        return False  # coordenacao ve faixa qualitativa, nao valor
    return fator_visivel(perfil, fator)


def faixa_qualitativa(risco: float) -> str:
    if risco <= 33:
        return "baixa"
    if risco <= 66:
        return "media"
    return "alta"
