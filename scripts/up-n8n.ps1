#!/usr/bin/env pwsh
<#
.SYNOPSIS
Inicia o chatbot em modo n8n completo (sem API Python).

.DESCRIPTION
Inicia apenas os containers WAHA e n8n para operação completa do chatbot.
Todo o processamento (RAG, LLM, histórico) é feito no n8n.

.EXAMPLE
./scripts/up-n8n.ps1
#>

$ErrorActionPreference = "Stop"

Write-Host "🚀 Iniciando Chatbot de Tributos (Modo n8n Completo)" -ForegroundColor Cyan
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

# Iniciar apenas WAHA e n8n
Write-Host "`n📦 Iniciando containers (WAHA + n8n)..." -ForegroundColor Yellow
docker compose up -d waha n8n

# Aguardar containers ficarem saudáveis
Write-Host "`n⏳ Aguardando containers iniciarem..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Verificar status
Write-Host "`n📊 Status dos containers:" -ForegroundColor Cyan
docker compose ps waha n8n

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
Write-Host "     └─ Configure credenciais na primeira execução" -ForegroundColor Gray
Write-Host ""

Write-Host "📚 Próximos Passos:" -ForegroundColor Cyan
Write-Host "   1. Acesse n8n: http://localhost:5679" -ForegroundColor White
Write-Host "   2. Crie conta (primeiro acesso)" -ForegroundColor White
Write-Host "   3. Instale community nodes:" -ForegroundColor White
Write-Host "      • @n8n/n8n-nodes-langchain" -ForegroundColor Gray
Write-Host "      • n8n-nodes-waha" -ForegroundColor Gray
Write-Host "   4. Importe workflow: n8n/workflows/chatbot_completo_n8n.json" -ForegroundColor White
Write-Host "   5. Configure credenciais (Groq/OpenAI)" -ForegroundColor White
Write-Host "   6. Ative o workflow" -ForegroundColor White
Write-Host ""

Write-Host "📖 Documentação:" -ForegroundColor Cyan
Write-Host "   • N8N_CHATBOT_COMPLETO.md - Guia completo" -ForegroundColor White
Write-Host "   • CONFIGURAR_N8N.md - Setup básico" -ForegroundColor White
Write-Host ""

Write-Host "🛠️  Comandos úteis:" -ForegroundColor Cyan
Write-Host "   • Ver logs: docker compose logs -f n8n" -ForegroundColor White
Write-Host "   • Parar: docker compose down" -ForegroundColor White
Write-Host "   • Reiniciar: docker compose restart n8n" -ForegroundColor White
Write-Host ""
