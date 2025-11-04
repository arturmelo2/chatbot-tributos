# Load knowledge base into Chroma (Docker-only)
param([switch]$Clear)

$cmd = "python rag/load_knowledge.py"
if ($Clear) { $cmd += " --clear" }

. "$PSScriptRoot/_compose.ps1"
Write-Host "Loading knowledge base... ($cmd)" -ForegroundColor Cyan
$compose = Get-ComposeCmd
& $compose exec api $cmd
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Knowledge load done." -ForegroundColor Green
