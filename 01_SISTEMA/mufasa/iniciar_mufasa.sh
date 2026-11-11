#!/usr/bin/env bash
# Liga o MUFASA no macOS ou Linux e abre o painel no navegador.
# Uso: ./iniciar_mufasa.sh   (pode rodar quantas vezes quiser)
set -euo pipefail
cd "$(dirname "$0")"

echo "=== MUFASA: ligando o sistema ==="
command -v docker >/dev/null || { echo "[ERRO] Docker nao encontrado. Veja docs/06_USO_LOCAL_DOCKER.md"; exit 1; }

if ! docker info >/dev/null 2>&1; then
  echo "Abrindo o Docker..."
  if [ "$(uname)" = "Darwin" ]; then open -a Docker || true; fi
  for _ in $(seq 36); do
    docker info >/dev/null 2>&1 && break
    echo "Esperando o Docker terminar de abrir..."; sleep 5
  done
  docker info >/dev/null 2>&1 || { echo "[ERRO] O Docker nao respondeu. Abra o Docker e rode de novo."; exit 1; }
fi
echo "[ok] Docker no ar."

echo "Preparando a versao desta pasta..."
docker build -q -t mufasa:1.1.0 . >/dev/null
if [ ! -f .env ]; then
  echo "Primeira vez neste computador: criando o arquivo .env..."
  docker run --rm -u root -v "$PWD:/app" mufasa:1.1.0 python -m scripts.configurar --docker
fi
echo "[ok] Configuracao (.env) encontrada."
if [ -f groq.env ]; then
  docker run --rm -u root -v "$PWD:/app" mufasa:1.1.0 python -m scripts.configurar --chaves
fi

docker compose up -d

echo "Esperando o painel ficar pronto..."
for _ in $(seq 120); do
  if curl -sf -o /dev/null http://127.0.0.1:8501/_stcore/health; then
    echo "[ok] MUFASA no ar: painel http://127.0.0.1:8501 | API http://127.0.0.1:8000/docs"
    if command -v open >/dev/null; then open http://127.0.0.1:8501
    elif command -v xdg-open >/dev/null; then xdg-open http://127.0.0.1:8501 >/dev/null 2>&1 || true; fi
    echo "Para desligar: ./parar_mufasa.sh (os dados ficam guardados)."
    exit 0
  fi
  sleep 5
done
echo "[ERRO] O painel nao respondeu. Veja: docker compose ps -a  e  docker compose logs painel"
exit 1
