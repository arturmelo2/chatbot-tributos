<#
Roda a API nativamente com waitress, usando o venv local (.venv).
#>
[CmdletBinding()]
param(
  [int]$Port
)

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $scriptDir
Set-Location $root

$pythonExe = Join-Path $root ".venv\Scripts\python.exe"
if (-not (Test-Path $pythonExe)) {
  throw ".venv não encontrado. Execute primeiro: scripts/setup-api-native.ps1"
}

# Variáveis de ambiente úteis (decouple lê .env automaticamente)
if (-not $env:PORT) { $env:PORT = if ($Port) { $Port } else { "5000" } }
if (-not $env:CHROMA_DIR) { $env:CHROMA_DIR = (Join-Path $root "chroma_data") }

# Garante diretório do Chroma
if (-not (Test-Path $env:CHROMA_DIR)) { New-Item -ItemType Directory -Force -Path $env:CHROMA_DIR | Out-Null }

Write-Host "[run] Iniciando waitress em 0.0.0.0:$($env:PORT)"
& $pythonExe -m waitress --host=0.0.0.0 --port $env:PORT app:app
