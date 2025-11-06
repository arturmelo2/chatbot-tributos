@echo off
REM ============================================================================
REM QUICK START - Chatbot de Tributos
REM ============================================================================
REM 
REM Este script inicia o deploy automatizado do sistema
REM 
REM ============================================================================

echo.
echo ========================================================================
echo.
echo           CHATBOT DE TRIBUTOS - QUICK START
echo           Prefeitura Municipal de Nova Trento/SC
echo.
echo ========================================================================
echo.

REM Verificar se PowerShell está disponível
where pwsh >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Usando PowerShell Core...
    pwsh -ExecutionPolicy Bypass -File "QUICK-START.ps1"
) else (
    where powershell >nul 2>nul
    if %ERRORLEVEL% EQU 0 (
        echo Usando Windows PowerShell...
        powershell -ExecutionPolicy Bypass -File "QUICK-START.ps1"
    ) else (
        echo ERRO: PowerShell nao encontrado!
        echo Instale PowerShell ou execute manualmente: QUICK-START.ps1
        pause
        exit /b 1
    )
)

pause
