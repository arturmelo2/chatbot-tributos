<#
.SYNOPSIS
    Script de início rápido - Deploy em um comando

.DESCRIPTION
    Executa verificação, deploy completo e mostra próximos passos

.EXAMPLE
    .\QUICK-START.ps1
#>

$ErrorActionPreference = "Stop"

Clear-Host

Write-Host @"
╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║                   🚀 CHATBOT DE TRIBUTOS - QUICK START                    ║
║                   Prefeitura Municipal de Nova Trento/SC                  ║
║                                                                            ║
║                   Deploy Automatizado em 5 Minutos                        ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

Write-Host "`n"

# Verificar se está na pasta correta
if (-not (Test-Path "compose.yml")) {
    Write-Host "❌ Erro: Execute este script na pasta raiz do projeto!" -ForegroundColor Red
    Write-Host "   Pasta esperada: whatsapp-ai-chatbot\" -ForegroundColor Yellow
    exit 1
}

# Perguntar se quer continuar
Write-Host "Este script vai:" -ForegroundColor Yellow
Write-Host "  1. Verificar pré-requisitos" -ForegroundColor White
Write-Host "  2. Iniciar todos os containers" -ForegroundColor White
Write-Host "  3. Carregar base de conhecimento (66 documentos)" -ForegroundColor White
Write-Host "  4. Mostrar próximos passos`n" -ForegroundColor White

$response = Read-Host "Continuar? (S/N)"
if ($response -notmatch '^[Ss]') {
    Write-Host "`n❌ Cancelado pelo usuário." -ForegroundColor Yellow
    exit 0
}

Write-Host "`n"

# Executar deploy completo
& ".\scripts\deploy-completo.ps1"

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ Erro durante o deploy. Verifique as mensagens acima." -ForegroundColor Red
    exit 1
}

# Aguardar input do usuário
Write-Host "`n"
Write-Host "Pressione qualquer tecla para abrir os serviços no navegador..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Abrir serviços no navegador
Write-Host "`n🌐 Abrindo serviços no navegador..." -ForegroundColor Yellow

Start-Sleep -Seconds 1

try {
    Start-Process "http://localhost:5000/health"
    Start-Sleep -Seconds 1
    Start-Process "http://localhost:3000"
    Start-Sleep -Seconds 1
    Start-Process "http://localhost:5679"
} catch {
    Write-Host "⚠️  Não foi possível abrir navegador. Acesse manualmente:" -ForegroundColor Yellow
    Write-Host "   - API:  http://localhost:5000" -ForegroundColor White
    Write-Host "   - WAHA: http://localhost:3000" -ForegroundColor White
    Write-Host "   - n8n:  http://localhost:5679" -ForegroundColor White
}

Write-Host "`n"
Write-Host @"
╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║                         ✅ DEPLOY CONCLUÍDO!                              ║
║                                                                            ║
║  Próximos passos:                                                          ║
║                                                                            ║
║  1️⃣  n8n (http://localhost:5679)                                          ║
║     - Workflow "WAHA → API" já ativo                                      ║
║     - Edite apenas se precisar customizar                                 ║
║                                                                            ║
║  2️⃣  WAHA (http://localhost:3000)                                         ║
║     - Login: admin / Tributos@NovaTrento2025                              ║
║     - Conectar WhatsApp (QR Code)                                         ║
║                                                                            ║
║  3️⃣  Testar                                                                ║
║     - Enviar mensagem de teste                                            ║
║                                                                            ║
║  📚 Documentação: START-HERE.md ou PRODUCTION-README.md                   ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Green

Write-Host "`n"
