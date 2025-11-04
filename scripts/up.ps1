# Start all services in detached mode (Docker-only)
param()

Write-Host "Starting containers..." -ForegroundColor Cyan
$env:COMPOSE_HTTP_TIMEOUT = 240
. "$PSScriptRoot/_compose.ps1"
$compose = Get-ComposeCmd
& $compose up -d
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Containers started." -ForegroundColor Green
