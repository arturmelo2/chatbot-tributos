# Tail API logs (Docker-only)
param()

Write-Host "Tailing API logs... (Ctrl+C to stop)" -ForegroundColor Cyan
. "$PSScriptRoot/_compose.ps1"
$compose = Get-ComposeCmd
& $compose logs -f api
