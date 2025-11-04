# Rebuild images and restart containers (Docker-only)
param([switch]$NoCache)

Write-Host "Rebuilding containers..." -ForegroundColor Cyan
$env:COMPOSE_HTTP_TIMEOUT = 240
. "$PSScriptRoot/_compose.ps1"
$compose = Get-ComposeCmd

if ($NoCache) {
  & $compose build --no-cache
} else {
  & $compose build
}
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $compose down
& $compose up -d
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Rebuild complete." -ForegroundColor Green
