<#
.SYNOPSIS
    Deploy completo do Chatbot de Tributos

.DESCRIPTION
    Script que executa todos os passos necessários para colocar o sistema em produção

.EXAMPLE
    .\scripts\deploy-completo.ps1
#>

param(
    [switch]$SkipChecks,
    [switch]$Rebuild
)

$ErrorActionPreference = "Stop"

Write-Host @"
╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║           🚀 DEPLOY COMPLETO - CHATBOT DE TRIBUTOS                        ║
║           Prefeitura Municipal de Nova Trento/SC                          ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# =============================================================================
# Passo 1: Verificações Pré-Deploy
# =============================================================================
if (-not $SkipChecks) {
    Write-Host "`n[1/5] Executando verificações pré-deploy..." -ForegroundColor Yellow
    
    & "$PSScriptRoot\pre-deploy-check.ps1"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n❌ Verificações falharam. Deploy cancelado." -ForegroundColor Red
        exit 1
    }
    
    Write-Host "`n✅ Todas as verificações passaram!" -ForegroundColor Green
} else {
    Write-Host "`n[1/5] ⏭️  Verificações puladas (--SkipChecks)" -ForegroundColor Yellow
}

Start-Sleep -Seconds 2

# =============================================================================
# Passo 2: Parar containers existentes (se houver)
# =============================================================================
Write-Host "`n[2/5] Parando containers existentes..." -ForegroundColor Yellow

try {
    docker-compose down 2>&1 | Out-Null
    Write-Host "✅ Containers parados" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Nenhum container rodando" -ForegroundColor Yellow
}

Start-Sleep -Seconds 1

# =============================================================================
# Passo 3: Build/Rebuild das imagens
# =============================================================================
Write-Host "`n[3/5] Building imagens Docker..." -ForegroundColor Yellow

if ($Rebuild) {
    Write-Host "    Rebuild completo (--no-cache)..." -ForegroundColor Gray
    docker-compose build --no-cache
} else {
    Write-Host "    Build com cache..." -ForegroundColor Gray
    docker-compose build
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ Erro no build das imagens. Deploy cancelado." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Imagens buildadas com sucesso" -ForegroundColor Green
Start-Sleep -Seconds 1

# =============================================================================
# Passo 4: Iniciar containers
# =============================================================================
Write-Host "`n[4/5] Iniciando containers..." -ForegroundColor Yellow

docker-compose up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ Erro ao iniciar containers. Deploy cancelado." -ForegroundColor Red
    exit 1
}

Write-Host "`n✅ Containers iniciados!" -ForegroundColor Green
Write-Host "    Aguardando containers ficarem healthy..." -ForegroundColor Gray

# Aguardar containers iniciarem
Start-Sleep -Seconds 10

# =============================================================================
# Passo 5: Verificar Health
# =============================================================================
Write-Host "`n[5/5] Verificando health dos serviços..." -ForegroundColor Yellow

$maxRetries = 30
$retries = 0
$allHealthy = $false

while ($retries -lt $maxRetries -and -not $allHealthy) {
    $retries++
    
    try {
        # Verificar API
        $apiHealth = Invoke-RestMethod -Uri "http://localhost:5000/health" -TimeoutSec 2 -ErrorAction SilentlyContinue
        
        if ($apiHealth.status -eq "healthy") {
            $allHealthy = $true
        }
    } catch {
        Write-Host "    ⏳ Aguardando API ficar healthy... ($retries/$maxRetries)" -ForegroundColor Gray
        Start-Sleep -Seconds 2
    }
}

if (-not $allHealthy) {
    Write-Host "`n⚠️  API não respondeu a tempo. Verifique logs:" -ForegroundColor Yellow
    Write-Host "    docker-compose logs -f api" -ForegroundColor Gray
} else {
    Write-Host "`n✅ API está healthy!" -ForegroundColor Green
}

# =============================================================================
# Passo 6: Carregar Base de Conhecimento
# =============================================================================
Write-Host "`n[6/6] Carregando base de conhecimento..." -ForegroundColor Yellow

try {
    docker-compose exec -T api python rag/load_knowledge.py
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Base de conhecimento carregada!" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Erro ao carregar base de conhecimento. Tente manualmente:" -ForegroundColor Yellow
        Write-Host "    docker-compose exec api python rag/load_knowledge.py" -ForegroundColor Gray
    }
} catch {
    Write-Host "⚠️  Erro ao carregar base de conhecimento: $_" -ForegroundColor Yellow
}

# =============================================================================
# Resumo Final
# =============================================================================
Write-Host @"

╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║                    ✅ DEPLOY CONCLUÍDO COM SUCESSO!                       ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝

📊 STATUS DOS SERVIÇOS:

"@ -ForegroundColor Green

docker-compose ps

Write-Host @"

🔗 URLs de Acesso:

   📡 API:    http://localhost:5000
   💬 WAHA:   http://localhost:3000
   🔄 n8n:    http://localhost:5679

📋 PRÓXIMOS PASSOS:

   1️⃣  Configurar n8n:
      - Acessar: http://localhost:5679
      - Workflow "WAHA → API (mensagens)" já ativo
      - Edite apenas se quiser customizar o fluxo

   2️⃣  Conectar WhatsApp:
      - Acessar: http://localhost:3000
      - Login: admin / Tributos@NovaTrento2025
      - Criar sessão e escanear QR Code
      - OU executar: .\scripts\start-waha-session.ps1

   3️⃣  Testar:
      - Enviar mensagem de teste pelo WhatsApp
      - Verificar logs: docker-compose logs -f api

📚 Documentação:
   - Guia completo: DEPLOY.md
   - Arquitetura: ARCHITECTURE.md
   - README: README.md

🛠️  Comandos úteis:
   - Ver logs:       docker-compose logs -f [service]
   - Reiniciar:      docker-compose restart
   - Parar:          docker-compose stop
   - Status WAHA:    .\scripts\waha-status.ps1
   - Health check:   curl http://localhost:5000/health

"@ -ForegroundColor Cyan

Write-Host "Sistema pronto para atender os cidadãos! 🎉`n" -ForegroundColor Green
