# Start minimal stack (no WAHA, no n8n)
param(
    [switch]$Build
)

Write-Host "Starting minimal stack..." -ForegroundColor Cyan

# Set timeout
$env:COMPOSE_HTTP_TIMEOUT = 240

# Source compose helper
. "$PSScriptRoot\_compose.ps1"
$compose = Get-ComposeCmd

# Build if requested
if ($Build) {
    Write-Host "Building containers..." -ForegroundColor Yellow
    & $compose -f compose.minimal.yml build
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

# Start containers
Write-Host "Starting containers..." -ForegroundColor Yellow
& $compose -f compose.minimal.yml up -d
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "=" * 70 -ForegroundColor Green
Write-Host "✅ Minimal stack started!" -ForegroundColor Green
Write-Host "=" * 70 -ForegroundColor Green
Write-Host ""
Write-Host "Services available:" -ForegroundColor Cyan
Write-Host "  API:        http://localhost:5000" -ForegroundColor White
Write-Host "  Qdrant:     http://localhost:6333" -ForegroundColor White
Write-Host "  PostgreSQL: localhost:5432 (user: chatbot)" -ForegroundColor White
Write-Host "  Redis:      localhost:6379" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Load knowledge base (if using Qdrant):" -ForegroundColor White
Write-Host "     docker exec chatbot_api_minimal python rag/load_knowledge.py" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Or migrate from ChromaDB:" -ForegroundColor White
Write-Host "     python scripts/migrations/migrate_chroma_to_qdrant.py" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Configure WhatsApp Cloud API webhook:" -ForegroundColor White
Write-Host "     Webhook URL: https://your-domain.com/webhook" -ForegroundColor Gray
Write-Host ""
Write-Host "  4. Test health:" -ForegroundColor White
Write-Host "     curl http://localhost:5000/health" -ForegroundColor Gray
Write-Host ""
