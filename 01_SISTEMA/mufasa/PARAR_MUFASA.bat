@echo off
chcp 65001 >nul
title MUFASA - parar
REM Desliga o MUFASA. Os dados do banco ficam guardados para a proxima vez.
cd /d "%~dp0"

echo.
echo === MUFASA: desligando o sistema ===
docker info >nul 2>&1
if errorlevel 1 (
  echo O Docker Desktop nao esta aberto, entao o MUFASA ja esta desligado.
  timeout /t 10
  exit /b 0
)
docker compose stop
echo.
echo [ok] MUFASA desligado. Para ligar de novo, de duplo clique em INICIAR_MUFASA.bat.
timeout /t 10
exit /b 0
