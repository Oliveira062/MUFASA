@echo off
chcp 65001 >nul
setlocal
title MUFASA - iniciar
REM Liga o MUFASA (banco, API, chat, calculo e painel) e abre o painel no navegador.
REM Uso: duplo clique neste arquivo. Pode rodar quantas vezes quiser.
cd /d "%~dp0"

echo.
echo === MUFASA: ligando o sistema ===
echo.

where docker >nul 2>&1
if errorlevel 1 (
  echo [ERRO] O Docker nao foi encontrado. Instale o Docker Desktop: veja docs\06_USO_LOCAL_DOCKER.md
  goto :fim_erro
)

REM 1. Docker Desktop precisa estar aberto.
docker info >nul 2>&1
if not errorlevel 1 goto :docker_ok
echo Abrindo o Docker Desktop...
if exist "%ProgramFiles%\Docker\Docker\Docker Desktop.exe" start "" "%ProgramFiles%\Docker\Docker\Docker Desktop.exe"
set /a tentativas=0
:espera_docker
timeout /t 5 /nobreak >nul
docker info >nul 2>&1
if not errorlevel 1 goto :docker_ok
set /a tentativas+=1
if %tentativas% geq 36 (
  echo [ERRO] O Docker Desktop nao respondeu em 3 minutos. Abra o Docker Desktop, espere ficar verde e rode este arquivo de novo.
  goto :fim_erro
)
echo Esperando o Docker Desktop terminar de abrir...
goto :espera_docker
:docker_ok
echo [ok] Docker no ar.

REM 2. Atualiza a imagem com o codigo desta pasta (rapido quando nada mudou).
echo Preparando a versao desta pasta (na primeira vez leva alguns minutos)...
docker build -q -t mufasa:1.1.0 . >nul
if errorlevel 1 (
  docker build -t mufasa:1.1.0 .
  goto :fim_erro
)

REM 3. Primeira vez: cria o .env com senhas novas.
if exist ".env" goto :env_ok
echo Primeira vez neste computador: criando o arquivo .env...
docker run --rm -u root -v "%cd%:/app" mufasa:1.1.0 python -m scripts.configurar --docker
if errorlevel 1 goto :fim_erro
:env_ok
echo [ok] Configuracao (.env) encontrada.

REM 4. Chave da Groq: copia do groq.env para o .env, se o arquivo existir.
if exist "groq.env" docker run --rm -u root -v "%cd%:/app" mufasa:1.1.0 python -m scripts.configurar --chaves

REM 5. Sobe tudo. Na primeira vez o banco e montado (pode levar alguns minutos).
docker compose up -d
if errorlevel 1 (
  echo [ERRO] Nao foi possivel subir os servicos. Veja: docker compose ps -a  e  docker compose logs montar
  goto :fim_erro
)

REM 6. Espera o painel responder (ate 10 minutos na primeira vez).
echo Esperando o painel ficar pronto...
set /a tentativas=0
:espera_painel
curl -s -f -o nul http://127.0.0.1:8501/_stcore/health >nul 2>&1
if not errorlevel 1 goto :painel_ok
set /a tentativas+=1
if %tentativas% geq 120 (
  echo [ERRO] O painel nao respondeu. Veja: docker compose ps -a  e  docker compose logs painel
  goto :fim_erro
)
timeout /t 5 /nobreak >nul
goto :espera_painel
:painel_ok

echo.
echo [ok] MUFASA no ar:
echo      Painel  http://127.0.0.1:8501
echo      API     http://127.0.0.1:8000/docs
echo.
echo Para desligar, de duplo clique em PARAR_MUFASA.bat. Os dados ficam guardados.
start "" http://127.0.0.1:8501
timeout /t 10
exit /b 0

:fim_erro
echo.
pause
exit /b 1
