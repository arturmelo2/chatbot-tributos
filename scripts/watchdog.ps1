<#
.SYNOPSIS
  Watchdog de saúde: verifica API, WAHA e n8n em localhost e reinicia serviços se necessário.

.DESCRIPTION
  - Testa:
      API  → http://localhost:5000/health
      WAHA → http://localhost:3000/api/sessions
      n8n  → http://localhost:5679/
  - Em caso de falha e se -RestartOnFail, executa: docker compose -f compose.prod.yml restart <service>
  - Registra resultado em logs/watchdog.log

.PARAMETER ComposeFile
  Caminho do compose (padrão: compose.prod.yml no repo root)
.PARAMETER LogFile
  Caminho do arquivo de log (padrão: logs/watchdog.log)
.PARAMETER RestartOnFail
  Reinicia serviços automaticamente se falhar (padrão: habilitado)
.PARAMETER TimeoutSec
  Timeout por requisição HTTP (padrão: 8s)
#>
[CmdletBinding()]
param(
  [string]$ComposeFile,
  [string]$LogFile,
  [switch]$NoRestart,
  [int]$TimeoutSec = 8
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot  = Resolve-Path (Join-Path $scriptDir '..')
if (-not $ComposeFile) { $ComposeFile = Join-Path $repoRoot 'compose.prod.yml' }
if (-not $LogFile)     { $LogFile     = Join-Path $repoRoot 'logs/watchdog.log' }

# Garante pasta de logs
$logDir = Split-Path -Parent $LogFile
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }

function Log($msg) {
  $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
  $line = "[$ts] $msg"
  Add-Content -Path $LogFile -Value $line
}

function Test-Endpoint {
  param([string]$Url)
  try {
    $resp = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec $TimeoutSec -UseBasicParsing
    if ($resp.StatusCode -ge 200 -and $resp.StatusCode -lt 400) { return $true }
    return $false
  } catch { return $false }
}

# Verificações
$apiOk  = Test-Endpoint "http://localhost:5000/health"
$wahaOk = Test-Endpoint "http://localhost:3000/api/sessions"
$n8nOk  = Test-Endpoint "http://localhost:5679/"

$status = "API=" + ($apiOk ? 'OK' : 'OFF') + ", WAHA=" + ($wahaOk ? 'OK' : 'OFF') + ", n8n=" + ($n8nOk ? 'OK' : 'OFF')
Log "Status: $status"

$needRestart = @()
if (-not $apiOk)  { $needRestart += 'api' }
if (-not $wahaOk) { $needRestart += 'waha' }
if (-not $n8nOk)  { $needRestart += 'n8n' }

if ($needRestart.Count -gt 0 -and -not $NoRestart) {
  try {
    # Compose helper
    . (Join-Path $scriptDir '_compose.ps1')
    $compose = Get-ComposeCmd

    foreach ($svc in $needRestart) {
      Log "Reiniciando serviço: $svc"
      & $compose -f $ComposeFile restart $svc
      if ($LASTEXITCODE -ne 0) { Log "Falha ao reiniciar $svc (exit=$LASTEXITCODE)" }
      Start-Sleep -Seconds 2
    }
  } catch {
    Log "Erro no restart: $($_.Exception.Message)"
  }
}

# Saída de processo
if ($needRestart.Count -gt 0) { exit 2 } else { exit 0 }
