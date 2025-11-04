param()

Write-Host "Starting production stack (compose.prod.yml)..." -ForegroundColor Cyan
$env:COMPOSE_HTTP_TIMEOUT = 240
. "$PSScriptRoot/_compose.ps1"
$compose = Get-ComposeCmd

# Resolve repo root and compose file path
$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$composeFile = Join-Path $root 'compose.prod.yml'

if (-not (Test-Path $composeFile)) {
  Write-Error "compose.prod.yml não encontrado em $composeFile"
  exit 1
}

& $compose -f $composeFile up -d
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Production stack started." -ForegroundColor Green
