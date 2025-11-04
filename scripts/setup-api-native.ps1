<#
.SYNOPSIS
  Prepara ambiente nativo (Windows) para rodar a API sem Docker: venv + deps.
.DESCRIPTION
  - Cria .venv
  - Gera requirements-native.txt filtrando pacotes non-Windows (nvidia-*, triton, uvloop, httptools)
  - Instala dependências + waitress (servidor WSGI para Windows)

.EXAMPLE
  ./scripts/setup-api-native.ps1

.NOTES
  Requer Python 3.11+ no PATH ("py -3.11" ou "python").
#>
[CmdletBinding()]
param(
  [switch]$Force
)

$ErrorActionPreference = 'Stop'

# Raiz do projeto
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $scriptDir
Set-Location $root

Write-Host "[setup] Projeto: $root"

# Detectar Python
$pythonCmd = $null
try {
  $null = & py -3.11 --version 2>$null
  if ($LASTEXITCODE -eq 0) { $pythonCmd = 'py -3.11' }
} catch {}
if (-not $pythonCmd) {
  try {
    $null = & python --version 2>$null
    if ($LASTEXITCODE -eq 0) { $pythonCmd = 'python' }
  } catch {}
}
if (-not $pythonCmd) {
  throw "Python 3.11+ não encontrado no PATH. Instale Python e tente novamente."
}

# Criar venv
$venvPath = Join-Path $root ".venv"
if (Test-Path $venvPath -and $Force) {
  Write-Host "[setup] Removendo venv existente..."
  Remove-Item -Recurse -Force $venvPath
}
if (-not (Test-Path $venvPath)) {
  Write-Host "[setup] Criando venv em $venvPath"
  & $pythonCmd -m venv $venvPath
}
$pythonExe = Join-Path $venvPath "Scripts\python.exe"
$pipExe = Join-Path $venvPath "Scripts\pip.exe"

# Gerar requirements-native.txt
$reqSrc = Join-Path $root "requirements.txt"
$reqNative = Join-Path $root "requirements-native.txt"
if (-not (Test-Path $reqSrc)) {
  throw "Arquivo requirements.txt não encontrado em $root"
}

Write-Host "[setup] Gerando requirements-native.txt (excluindo nvidia-*, triton, uvloop, httptools)"
(Get-Content $reqSrc) |
  Where-Object { $_ -notmatch '^(?i)(nvidia-|triton==|uvloop==|httptools==)' } |
  Set-Content $reqNative

# Instalar dependências
Write-Host "[setup] Atualizando pip"
& $pythonExe -m pip install --upgrade pip

Write-Host "[setup] Instalando dependências nativas (isto pode demorar)"
& $pipExe install -r $reqNative

Write-Host "[setup] Instalando waitress (WSGI para Windows)"
& $pipExe install waitress

Write-Host "[setup] Concluído. Para rodar a API: scripts/run-api-native.ps1"
