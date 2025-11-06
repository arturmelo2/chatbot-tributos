#!/usr/bin/env pwsh
<#
.SYNOPSIS
Inicia o chatbot completo (WAHA + n8n + API Python).

.DESCRIPTION
Inicia todos os containers necessários:
- WAHA: WhatsApp HTTP API
- n8n: Orquestração de workflow
- API: Processamento RAG + LLM (Python)

Arquitetura: WhatsApp → WAHA → n8n → API Python → n8n → WAHA

.EXAMPLE
./scripts/up-n8n.ps1
#>

$ErrorActionPreference = "Stop"

Write-Host "🚀 Iniciando Chatbot de Tributos (Orquestração Completa n8n)" -ForegroundColor Cyan
Write-Host "=" * 80

# Verificar se Docker está rodando
Write-Host "`n🐳 Verificando Docker..." -ForegroundColor Yellow
try {
    docker info | Out-Null
} catch {
    Write-Host "❌ Docker não está rodando!" -ForegroundColor Red
    Write-Host "   Inicie o Docker Desktop e tente novamente." -ForegroundColor Yellow
    exit 1
}
Write-Host "   ✅ Docker OK" -ForegroundColor Green

# Verificar .env
if (-not (Test-Path ".env")) {
    Write-Host "`n⚠️  Arquivo .env não encontrado!" -ForegroundColor Yellow
    if (Test-Path ".env.example") {
        Write-Host "   Criando .env a partir de .env.example..." -ForegroundColor Cyan
        Copy-Item ".env.example" ".env"
        Write-Host "   ✅ Arquivo .env criado" -ForegroundColor Green
        Write-Host "   ⚠️  Configure suas chaves de API no .env antes de continuar!" -ForegroundColor Yellow
        exit 0
    } else {
        Write-Host "   ❌ .env.example não encontrado!" -ForegroundColor Red
        exit 1
    }
}

# Iniciar todos os containers
Write-Host "`n📦 Iniciando containers (WAHA + n8n + API Python)..." -ForegroundColor Yellow
docker compose up -d

# Aguardar containers ficarem saudáveis
Write-Host "`n⏳ Aguardando containers iniciarem..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Verificar status
Write-Host "`n📊 Status dos containers:" -ForegroundColor Cyan
docker compose ps

Write-Host "`n" -NoNewline
Write-Host "="*80 -ForegroundColor Green
Write-Host "✅ CHATBOT INICIADO COM SUCESSO!" -ForegroundColor Green
Write-Host "="*80 -ForegroundColor Green

Write-Host "`n🌐 URLs de Acesso:" -ForegroundColor Cyan
Write-Host "   • WAHA Dashboard: http://localhost:3000" -ForegroundColor White
Write-Host "     └─ Usuário: admin" -ForegroundColor Gray
Write-Host "     └─ Senha: Tributos@NovaTrento2025" -ForegroundColor Gray
Write-Host ""
Write-Host "   • n8n Workflows: http://localhost:5679" -ForegroundColor White
Write-Host "     └─ Workflow padrão já ativo (login desabilitado)" -ForegroundColor Gray
Write-Host ""
Write-Host "   • API Python: http://localhost:5000" -ForegroundColor White
Write-Host "     └─ Health: http://localhost:5000/health" -ForegroundColor Gray
Write-Host ""

Write-Host "📚 Próximos Passos:" -ForegroundColor Cyan
Write-Host "   1. Carregar base de conhecimento:" -ForegroundColor White
Write-Host "      ./scripts/load-knowledge.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "   2. Acesse n8n: http://localhost:5679" -ForegroundColor White
Write-Host "      • Confirme workflow \"WAHA → API (mensagens)\" ativo" -ForegroundColor Gray
Write-Host "      • Edite apenas se quiser customizar" -ForegroundColor Gray
Write-Host ""
Write-Host "   3. Conectar WhatsApp no WAHA:" -ForegroundColor White
Write-Host "      ./scripts/start-waha-session.ps1" -ForegroundColor Gray
Write-Host ""

Write-Host "🔄 Arquitetura do Fluxo:" -ForegroundColor Cyan
Write-Host "   WhatsApp → WAHA → n8n → API Python (RAG+LLM) → n8n → WAHA" -ForegroundColor White
Write-Host ""

Write-Host "📖 Documentação:" -ForegroundColor Cyan
Write-Host "   • N8N_CHATBOT_COMPLETO.md - Guia completo da orquestração" -ForegroundColor White
Write-Host "   • CONFIGURAR_N8N.md - Setup básico" -ForegroundColor White
Write-Host ""

Write-Host "🛠️  Comandos úteis:" -ForegroundColor Cyan
Write-Host "   • Ver logs n8n: docker compose logs -f n8n" -ForegroundColor White
Write-Host "   • Ver logs API: docker compose logs -f api" -ForegroundColor White
Write-Host "   • Parar tudo: docker compose down" -ForegroundColor White
Write-Host "   • Reiniciar: docker compose restart" -ForegroundColor White
Write-Host ""
