from datetime import datetime
from sqlalchemy import Column, DateTime, Float, Integer, String
from app.banco.database import Base


class Disciplina(Base):
  __tablename__ = "disciplinas"

  id = Column(Integer, primary_key=True, index=True)
  nome = Column(
      String, unique=True, index=True
  )  # Nome normalizado ex: "matematica"
  nome_exibicao = Column(String)  # Nome formatado ex: "Matemática"
  frequencia = Column(String)  # Ex: "88%"
  faltas = Column(Integer, default=0)
  nota = Column(Float, default=0.0)


class HistoricoMensagem(Base):
  __tablename__ = "historico_mensagens"

  id = Column(Integer, primary_key=True, index=True)
  usuario_id = Column(Integer, index=True)
  mensagem_usuario = Column(String, nullable=False)
  resposta_bot = Column(String, nullable=False)
  intencao = Column(String, nullable=False)
  data_hora = Column(DateTime, default=datetime.utcnow)