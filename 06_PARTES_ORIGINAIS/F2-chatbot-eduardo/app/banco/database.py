from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker

# Configuração de um banco de dados SQLite local em arquivo (.db)
SQLALCHEMY_DATABASE_URL = "sqlite:///./mufasa.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


def get_db():
  """Injeta a sessão do banco de dados na rota do FastAPI e fecha ao finalizar."""
  db = SessionLocal()
  try:
    yield db
  finally:
    db.close()