from fastapi import FastAPI
from app.api import chatbot
from app.banco import models
from app.banco.database import Base, engine

# Cria as tabelas no SQLite caso ainda não existam
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="MUFASA",
    description=(
        "Monitoramento Universitario de Frequencia, Atividades, Saude e"
        " Aprendizagem"
    ),
    version="0.1.0",
)

# Registar o router do chatbot
app.include_router(chatbot.router)


@app.get("/")
def pagina_inicial():
  return {"mensagem": "API MUFASA ativa. Acesse /docs para testar o chatbot."}


@app.get("/saude")
def verificar_saude():
  return {"status": "no ar", "sistema": "MUFASA"}