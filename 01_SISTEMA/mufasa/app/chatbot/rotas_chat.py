"""
Endpoints do chatbot (SRS Anexo D: /api/v1/chat/consultas).

O chatbot e uma parte da API, nao um servico ao lado do banco (RN06):
passa pelo mesmo login JWT, pelos mesmos perfis e pela mesma checagem de
escopo do B3. Sequencia de cada mensagem:

1. token -> usuario e perfil lidos do banco (app/api/auth.py)
2. limite de 20 mensagens por minuto (Anexo D.1)
3. classificacao em intencao fechada (intencoes.py)
4. consulta pre-aprovada com o escopo do usuario (servico.py)
5. redacao humanizada sem dado pessoal na IA (redacao.py)
6. historico e auditoria (conversa.py, app/api/auditoria.py)
"""

from fastapi import APIRouter, Depends, Request
from sqlalchemy.engine import Connection

from app.api import auditoria
from app.api.auth import Usuario, obter_usuario_liberado
from app.api.banco import obter_conexao
from app.api.erros import erro_http
from app.api.permissoes import ALUNO, NUCLEO_APOIO
from app.api.seguranca import limitador
from app.chatbot import conversa
from app.chatbot import consultas_chat as sql
from app.chatbot import intencoes as it
from app.chatbot.banco_chat import obter_conexao_chat
from app.chatbot.config_chat import obter_configuracao_chat
from app.chatbot.esquemas_chat import (Abertura, MensagemHistorico, PedidoChat, RespostaChat,
                                       limite_historico)
from app.chatbot.redacao import classificar_com_ia, redigir
from app.chatbot.servico import OPCOES_ALUNO, OPCOES_EQUIPE, OPCOES_NAE, executar, texto_abertura
from app.chatbot.texto import limpar_entrada, redigir_dados_pessoais

router_chat = APIRouter(prefix="/api/v1/chat", tags=["chatbot"])


def _limitar(request: Request, usuario: Usuario) -> None:
    cfg = obter_configuracao_chat()
    permitido, espera = limitador.permitir(f"chat:{usuario.id_usuario}", cfg.chat_limite_minuto)
    if not permitido:
        auditoria.registrar(request, "CHAT_LIMITE_EXCEDIDO", "NEGADO", usuario=usuario)
        raise erro_http(429, "Você enviou muitas mensagens seguidas. Aguarde um minuto e tente de novo.",
                        {"Retry-After": str(espera)})


@router_chat.get("/abertura", response_model=Abertura)
def abertura(usuario: Usuario = Depends(obter_usuario_liberado)):
    """Mensagem de abertura com a disponibilidade correta (RF13): chat 24 h, pessoas no horário."""
    cfg = obter_configuracao_chat()
    return Abertura(mensagem=texto_abertura(usuario.perfil), disponibilidade="Chat disponível 24 horas.",
                    atendimento_humano=f"Atendimento com a equipe {cfg.chat_janela_atendimento}.",
                    opcoes=OPCOES_ALUNO if usuario.perfil == ALUNO else
                    OPCOES_NAE if usuario.perfil == NUCLEO_APOIO else OPCOES_EQUIPE)


@router_chat.post("/consultas", response_model=RespostaChat)
def consultar(pedido: PedidoChat, request: Request,
              usuario: Usuario = Depends(obter_usuario_liberado),
              conexao_api: Connection = Depends(obter_conexao),
              conexao_chat: Connection = Depends(obter_conexao_chat)):
    _limitar(request, usuario)

    texto = limpar_entrada(pedido.texto)
    if not texto:
        raise erro_http(422, "Escreva uma pergunta.")

    classificacao = it.classificar(texto, usuario.perfil, usuario.id_aluno)
    intencao = classificacao.intencao
    # Tentativas de burla e outras recusas nao entram no contexto da IA.
    anteriores = [a for a in conversa.ultimas(conexao_chat, usuario.id_usuario) if a["intencao"] not in it.RECUSAS]
    # Retomada: "e em Calculo II?" logo depois de "minhas notas" continua no mesmo assunto.
    intencao = it.retomar_assunto(intencao, texto, [a["intencao"] for a in anteriores])
    cfg = obter_configuracao_chat()
    if intencao == it.NAO_ENTENDI and cfg.ia_habilitada and cfg.chat_ia_classificar:
        intencao = classificar_com_ia(texto, usuario.perfil)

    resultado = executar(intencao, classificacao.matriculas, texto, usuario, request, conexao_api, conexao_chat)
    historico = [a["pergunta_redigida"] for a in reversed(anteriores)]
    resposta, por_ia = redigir(resultado, usuario.perfil, texto, historico)

    id_conversa, aviso = conversa.obter_ou_abrir(conexao_chat, usuario.id_usuario)
    conversa.registrar(conexao_chat, id_conversa=id_conversa, id_usuario=usuario.id_usuario,
                       pergunta_redigida=redigir_dados_pessoais(texto), intencao=resultado.intencao,
                       consulta=resultado.consulta, registros=resultado.registros, resposta=resposta,
                       redigida_por_ia=por_ia, tentativa_burla=resultado.tentativa_burla)
    conexao_chat.commit()

    if resultado.tentativa_burla:
        auditoria.registrar(request, "CHAT_TENTATIVA_BURLA", "NEGADO", usuario=usuario)
    elif resultado.intencao != it.ALUNO_ESPECIFICO:  # esse ja foi registrado na checagem de escopo
        auditoria.registrar(request, "CHAT_" + resultado.intencao[:35],
                            "NEGADO" if resultado.recusa else "PERMITIDO", usuario=usuario,
                            id_aluno_alvo=usuario.id_aluno if usuario.perfil == ALUNO else resultado.id_aluno_alvo)

    return RespostaChat(
        conversa=id_conversa, intencao=resultado.intencao, resposta=resposta, dados=resultado.dados,
        filtros_aplicados=resultado.filtros, registros_considerados=resultado.registros,
        referencia=resultado.referencia, atalho_painel=resultado.atalho, opcoes=resultado.opcoes,
        aviso=aviso, redigida_por_ia=por_ia, recusa=resultado.recusa,
    )


@router_chat.get("/historico", response_model=list[MensagemHistorico])
def historico(request: Request, limite: int = Depends(limite_historico),
              usuario: Usuario = Depends(obter_usuario_liberado),
              conexao_chat: Connection = Depends(obter_conexao_chat)):
    """Historico do PROPRIO usuario, inclusive de conversas encerradas (RN13)."""
    linhas = conexao_chat.execute(sql.HISTORICO_DO_USUARIO,
                                  {"id_usuario": usuario.id_usuario, "limite": limite}).mappings().all()
    auditoria.registrar(request, "CHAT_LER_HISTORICO", "PERMITIDO", usuario=usuario)
    return [MensagemHistorico(conversa=l["id_conversa"], momento=l["momento"], pergunta=l["pergunta_redigida"],
                              intencao=l["intencao"], resposta=l["resposta"]) for l in linhas]


@router_chat.post("/encerrar", status_code=204)
def encerrar(request: Request, usuario: Usuario = Depends(obter_usuario_liberado),
             conexao_chat: Connection = Depends(obter_conexao_chat)):
    if conversa.encerrar(conexao_chat, usuario.id_usuario):
        conexao_chat.commit()
    auditoria.registrar(request, "CHAT_ENCERRAR", "PERMITIDO", usuario=usuario)
