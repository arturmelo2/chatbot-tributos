# Script de Acesso Rápido aos Serviços de Observabilidade
# =========================================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  📊 STACK DE OBSERVABILIDADE" -ForegroundColor Cyan
Write-Host "  Chatbot de Tributos Nova Trento/SC" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Função para verificar se serviço está UP
function Test-Service {
    param($Url, $Name)
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
        Write-Host "  ✅ $Name" -ForegroundColor Green -NoNewline
        Write-Host " → $Url" -ForegroundColor Gray
        return $true
    }
    catch {
        Write-Host "  ❌ $Name" -ForegroundColor Red -NoNewline
        Write-Host " → $Url (OFFLINE)" -ForegroundColor Gray
        return $false
    }
}

# Verificar status dos serviços
Write-Host "📡 Status dos Serviços:`n" -ForegroundColor Yellow

$apiUp = Test-Service "http://localhost:5000/health" "API Chatbot"
$prometheusUp = Test-Service "http://localhost:9090/-/healthy" "Prometheus"
$grafanaUp = Test-Service "http://localhost:3001/api/health" "Grafana"
$wahaUp = Test-Service "http://localhost:3000/health" "WAHA"
$n8nUp = Test-Service "http://localhost:5679/healthz" "N8N"

Write-Host "`n========================================`n" -ForegroundColor Cyan

# Menu de opções
Write-Host "🔗 Links de Acesso:`n" -ForegroundColor Yellow

Write-Host "1. " -ForegroundColor White -NoNewline
Write-Host "Grafana Dashboard" -ForegroundColor Cyan
Write-Host "   → http://localhost:3001/d/chatbot-tributos" -ForegroundColor Gray
Write-Host "   Usuário: admin | Senha: Tributos@2025`n" -ForegroundColor DarkGray

Write-Host "2. " -ForegroundColor White -NoNewline
Write-Host "Prometheus (Métricas)" -ForegroundColor Cyan
Write-Host "   → http://localhost:9090" -ForegroundColor Gray
Write-Host "   Targets: http://localhost:9090/targets`n" -ForegroundColor DarkGray

Write-Host "3. " -ForegroundColor White -NoNewline
Write-Host "API Metrics (Raw)" -ForegroundColor Cyan
Write-Host "   → http://localhost:5000/metrics`n" -ForegroundColor Gray

Write-Host "4. " -ForegroundColor White -NoNewline
Write-Host "API Health Check" -ForegroundColor Cyan
Write-Host "   → http://localhost:5000/health`n" -ForegroundColor Gray

Write-Host "5. " -ForegroundColor White -NoNewline
Write-Host "WAHA Dashboard" -ForegroundColor Cyan
Write-Host "   → http://localhost:3000/dashboard" -ForegroundColor Gray
Write-Host "   Usuário: admin | Senha: Tributos@NovaTrento2025`n" -ForegroundColor DarkGray

Write-Host "6. " -ForegroundColor White -NoNewline
Write-Host "N8N Workflows" -ForegroundColor Cyan
Write-Host "   → http://localhost:5679`n" -ForegroundColor Gray

Write-Host "========================================`n" -ForegroundColor Cyan

# Menu interativo
Write-Host "🎯 Ações Rápidas:`n" -ForegroundColor Yellow
Write-Host "[1] Abrir Grafana no navegador" -ForegroundColor White
Write-Host "[2] Abrir Prometheus no navegador" -ForegroundColor White
Write-Host "[3] Ver logs em tempo real" -ForegroundColor White
Write-Host "[4] Verificar targets do Prometheus" -ForegroundColor White
Write-Host "[5] Testar métricas da API" -ForegroundColor White
Write-Host "[6] Ver status dos containers" -ForegroundColor White
Write-Host "[0] Sair`n" -ForegroundColor White

$opcao = Read-Host "Escolha uma opção"

switch ($opcao) {
    "1" {
        Write-Host "`n🌐 Abrindo Grafana..." -ForegroundColor Green
        Start-Process "http://localhost:3001/d/chatbot-tributos"
    }
    "2" {
        Write-Host "`n🌐 Abrindo Prometheus..." -ForegroundColor Green
        Start-Process "http://localhost:9090"
    }
    "3" {
        Write-Host "`n📋 Logs em tempo real (Ctrl+C para sair):`n" -ForegroundColor Green
        docker compose logs -f
    }
    "4" {
        Write-Host "`n🎯 Targets do Prometheus:`n" -ForegroundColor Green
        curl -s http://localhost:9090/api/v1/targets | ConvertFrom-Json | Select-Object -ExpandProperty data | Select-Object -ExpandProperty activeTargets | ForEach-Object {
            Write-Host "Target: " -NoNewline -ForegroundColor Yellow
            Write-Host $_.labels.job -ForegroundColor Cyan
            Write-Host "  URL: $($_.scrapeUrl)" -ForegroundColor White
            Write-Host "  Estado: " -NoNewline
            if ($_.health -eq 'up') {
                Write-Host "$($_.health)" -ForegroundColor Green
            } else {
                Write-Host "$($_.health)" -ForegroundColor Red
            }
            Write-Host "  Última coleta: $($_.lastScrape)`n" -ForegroundColor Gray
        }
    }
    "5" {
        Write-Host "`n📊 Métricas da API:`n" -ForegroundColor Green
        $metrics = (curl -s http://localhost:5000/metrics) -split "`n"
        Write-Host "Total de linhas: $($metrics.Count)" -ForegroundColor Cyan
        Write-Host "`nPrimeiras 30 linhas:`n" -ForegroundColor Yellow
        $metrics | Select-Object -First 30
    }
    "6" {
        Write-Host "`n🐳 Status dos containers:`n" -ForegroundColor Green
        docker compose ps
    }
    "0" {
        Write-Host "`n👋 Até logo!`n" -ForegroundColor Cyan
    }
    default {
        Write-Host "`n❌ Opção inválida!`n" -ForegroundColor Red
    }
}
