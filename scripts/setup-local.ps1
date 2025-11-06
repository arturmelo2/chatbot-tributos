#!/usr/bin/env pwsh
# Deploy automático LOCAL - Execute e pronto!

Write-Host "🚀 Implantando localmente..." -ForegroundColor Green

# Criar estrutura
"data/waha/session","data/n8n","data/chroma","data/redis","logs","exports","backups" | ForEach-Object {
    New-Item -ItemType Directory -Force -Path $_ | Out-Null
}

# acme.json
if (-not (Test-Path "reverse-proxy/acme.json")) {
    "{}" | Out-File -FilePath "reverse-proxy/acme.json" -Encoding UTF8 -NoNewline
}

Write-Host "✅ Estrutura pronta" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Configure seu .env:" -ForegroundColor Yellow
Write-Host "   1. Copie: cp .env.production.example .env" -ForegroundColor Cyan
Write-Host "   2. Edite: code .env" -ForegroundColor Cyan
Write-Host "   3. Preencha: DOMAIN, CF_API_EMAIL, CF_DNS_API_TOKEN, GROQ_API_KEY" -ForegroundColor Cyan
Write-Host ""
Write-Host "🚀 Depois inicie:" -ForegroundColor Yellow
Write-Host "   docker compose -f compose.prod.yml up -d" -ForegroundColor Green
Write-Host ""
