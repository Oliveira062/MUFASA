from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_menu_principal():
  """Testa se o envio de 'menu' devolve as opções principais."""
  response = client.post(
      "/chatbot/mensagens", json={"usuario_id": 1, "texto": "menu"}
  )
  assert response.status_code == 200
  dados = response.json()
  assert dados["intencao"] == "MENU_PRINCIPAL"
  assert "opcoes" in dados


def test_consulta_frequencia_com_acento():
  """Testa a consulta de frequência com acentuação e maiúsculas."""
  response = client.post(
      "/chatbot/mensagens",
      json={"usuario_id": 1, "texto": "Qual a minha frequência em Matemática?"},
  )
  assert response.status_code == 200
  dados = response.json()
  assert dados["intencao"] == "CONSULTA_FREQUENCIA_DISCIPLINA"
  assert "88%" in dados["resposta"]


def test_consulta_nota_calculo():
  """Testa a consulta de nota para Cálculo."""
  response = client.post(
      "/chatbot/mensagens", json={"usuario_id": 1, "texto": "nota calculo"}
  )
  assert response.status_code == 200
  dados = response.json()
  assert dados["intencao"] == "CONSULTA_NOTA_DISCIPLINA"
  assert "5.5" in dados["resposta"]


def test_mensagem_nao_reconhecida():
  """Testa o fallback para mensagens que o bot não ent ent entende."""
  response = client.post(
      "/chatbot/mensagens", json={"usuario_id": 1, "texto": "abracadabra 123"}
  )
  assert response.status_code == 200
  dados = response.json()
  assert dados["intencao"] == "NAO_RECONHECIDO"


def test_obter_historico_usuario():
  """Testa a recuperação do histórico de conversas salvas no banco."""
  client.post(
      "/chatbot/mensagens",
      json={"usuario_id": 99, "texto": "menu principal"},
  )

  response = client.get("/chatbot/historico/99")
  assert response.status_code == 200

  historico = response.json()
  assert len(historico) > 0
  assert historico[0]["usuario_id"] == 99
  assert historico[0]["mensagem_usuario"] == "menu principal"
  assert historico[0]["intencao"] == "MENU_PRINCIPAL"