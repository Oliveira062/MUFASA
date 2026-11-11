# Uma imagem para todos os servicos Python do MUFASA (api, chat, calculo, painel);
# o docker-compose.yml escolhe o comando de cada um.
FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 PIP_NO_CACHE_DIR=1 \
    MUFASA_LOG_DIR=/app/logs

WORKDIR /app
COPY requirements.txt requirements.lock ./
RUN pip install -r requirements.lock

COPY . .
# Processo sem privilegio de root dentro do container
RUN useradd --create-home --uid 10001 mufasa && mkdir -p /app/logs && chown -R mufasa /app/logs
USER mufasa
