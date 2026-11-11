from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, ConfigDict
from pydantic import BaseModel


class MensagemEntrada(BaseModel):
  usuario_id: int
  texto: str
  perfil: str = "aluno"  # Opções: "aluno", "professor", "admin"


class MensagemEntrada(BaseModel):
  usuario_id: int
  texto: str


class RespostaChatbot(BaseModel):
  intencao: str
  resposta: str
  opcoes: Optional[List[str]] = None


class HistoricoItem(BaseModel):
  model_config = ConfigDict(from_attributes=True)

  id: int
  usuario_id: int
  mensagem_usuario: str
  resposta_bot: str
  intencao: str
  data_hora: datetime