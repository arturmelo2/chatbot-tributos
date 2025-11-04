param()

Write-Host "Starting production stack with HTTPS (Caddy) ..." -ForegroundColor Cyan
$env:COMPOSE_HTTP_TIMEOUT = 240
. "$PSScriptRoot/_compose.ps1"
$compose = Get-ComposeCmd

$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$composeBase = Join-Path $root 'compose.prod.yml'
$composeProxy = Join-Path $root 'compose.prod.caddy.yml'

if (-not (Test-Path $composeBase)) {
  Write-Error "compose.prod.yml não encontrado em $composeBase"
  exit 1
}
if (-not (Test-Path $composeProxy)) {
  Write-Error "compose.prod.caddy.yml não encontrado em $composeProxy"
  exit 1
}

& $compose -f $composeBase -f $composeProxy up -d
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Production stack with HTTPS started." -ForegroundColor Green
