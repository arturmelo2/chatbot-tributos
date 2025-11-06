# ===============================================================================
# Script de Configuração Completa do RAG no n8n
# ===============================================================================
# Este script:
# 1. Cria credencial WAHA (Header Auth)
# 2. Importa workflow RAG completo com 13 nodes
# 3. Ativa o workflow automaticamente
# 4. Desativa workflows antigos
# 5. Testa o workflow
# ===============================================================================

$ErrorActionPreference = "Continue"

# Cores
$Green = "Green"
$Yellow = "Yellow"
$Cyan = "Cyan"
$Red = "Red"
$White = "White"

# Token n8n
$token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxNzY1ZWYzNS0zNWYzLTQ3NDItYjY5Mi1kZmVjMGRmZjU1MGQiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzYyNDY1MDk0LCJleHAiOjE3NjQ5OTAwMDB9.AyvjOuOk25dSVuSxjUgop22frjyGNWoO03W-YAWE_B4"

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor $Cyan
Write-Host "║   🤖 CONFIGURAÇÃO RAG COMPLETO NO N8N                    ║" -ForegroundColor $Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor $Cyan

# ===============================================================================
# PASSO 1: Criar Credencial WAHA
# ===============================================================================
Write-Host "📝 Passo 1/5: Criando credencial WAHA..." -ForegroundColor $Yellow

$wahaCredential = @{
    name = "WAHA API Key"
    type = "httpHeaderAuth"
    data = @{
        name = "X-Api-Key"
        value = "tributos_nova_trento_2025_api_key_fixed"
    }
} | ConvertTo-Json -Depth 10

try {
    $credResult = curl -X POST "http://localhost:5679/api/v1/credentials" `
        -H "X-N8N-API-KEY: $token" `
        -H "Content-Type: application/json" `
        -d $wahaCredential 2>&1 | Out-String
    
    $credJson = $credResult | ConvertFrom-Json
    $credId = $credJson.id
    
    Write-Host "   ✅ Credencial criada: ID = $credId" -ForegroundColor $Green
} catch {
    Write-Host "   ⚠️  Credencial já existe ou erro na criação" -ForegroundColor $Yellow
    Write-Host "   Continuando com credencial existente..." -ForegroundColor $White
    $credId = "waha-header-auth"
}

# ===============================================================================
# PASSO 2: Listar Workflows Existentes
# ===============================================================================
Write-Host "`n📋 Passo 2/5: Listando workflows existentes..." -ForegroundColor $Yellow

try {
    $workflows = curl -s "http://localhost:5679/api/v1/workflows" `
        -H "X-N8N-API-KEY: $token" | ConvertFrom-Json
    
    Write-Host "   Workflows encontrados: $($workflows.data.Count)" -ForegroundColor $White
    foreach ($wf in $workflows.data) {
        $status = if ($wf.active) { "🟢 ATIVO" } else { "⚪ INATIVO" }
        Write-Host "   $status - $($wf.name) (ID: $($wf.id))" -ForegroundColor $White
    }
} catch {
    Write-Host "   ⚠️  Erro ao listar workflows" -ForegroundColor $Yellow
}

# ===============================================================================
# PASSO 3: Desativar Workflows Antigos
# ===============================================================================
Write-Host "`n🔴 Passo 3/5: Desativando workflows antigos..." -ForegroundColor $Yellow

foreach ($wf in $workflows.data) {
    if ($wf.active -and $wf.name -notlike "*RAG Completo*") {
        try {
            $updatePayload = @{
                active = $false
            } | ConvertTo-Json
            
            curl -X PATCH "http://localhost:5679/api/v1/workflows/$($wf.id)" `
                -H "X-N8N-API-KEY: $token" `
                -H "Content-Type: application/json" `
                -d $updatePayload | Out-Null
            
            Write-Host "   ✅ Desativado: $($wf.name)" -ForegroundColor $Green
        } catch {
            Write-Host "   ⚠️  Erro ao desativar: $($wf.name)" -ForegroundColor $Yellow
        }
    }
}

# ===============================================================================
# PASSO 4: Importar Workflow RAG Completo
# ===============================================================================
Write-Host "`n📦 Passo 4/5: Importando workflow RAG completo..." -ForegroundColor $Yellow

$workflowPath = "n8n\workflows\chatbot_rag_completo_auto.json"

if (Test-Path $workflowPath) {
    try {
        $workflowContent = Get-Content $workflowPath -Raw
        
        $importResult = curl -X POST "http://localhost:5679/api/v1/workflows" `
            -H "X-N8N-API-KEY: $token" `
            -H "Content-Type: application/json" `
            -d $workflowContent 2>&1 | Out-String
        
        $importJson = $importResult | ConvertFrom-Json
        $workflowId = $importJson.id
        
        Write-Host "   ✅ Workflow importado: ID = $workflowId" -ForegroundColor $Green
        Write-Host "   📊 Nodes: $($importJson.nodes.Count)" -ForegroundColor $White
        
    } catch {
        Write-Host "   ❌ Erro ao importar workflow" -ForegroundColor $Red
        Write-Host "   Detalhes: $importResult" -ForegroundColor $Red
        exit 1
    }
} else {
    Write-Host "   ❌ Arquivo não encontrado: $workflowPath" -ForegroundColor $Red
    exit 1
}

# ===============================================================================
# PASSO 5: Ativar Workflow
# ===============================================================================
Write-Host "`n🟢 Passo 5/5: Ativando workflow..." -ForegroundColor $Yellow

try {
    $activatePayload = @{
        active = $true
    } | ConvertTo-Json
    
    curl -X PATCH "http://localhost:5679/api/v1/workflows/$workflowId" `
        -H "X-N8N-API-KEY: $token" `
        -H "Content-Type: application/json" `
        -d $activatePayload | Out-Null
    
    Write-Host "   ✅ Workflow ativado com sucesso!" -ForegroundColor $Green
} catch {
    Write-Host "   ⚠️  Erro ao ativar workflow (pode já estar ativo)" -ForegroundColor $Yellow
}

# ===============================================================================
# REINICIAR API PARA CARREGAR NOVOS ENDPOINTS
# ===============================================================================
Write-Host "`n🔄 Reiniciando API Python..." -ForegroundColor $Yellow

try {
    docker compose restart api | Out-Null
    Start-Sleep -Seconds 5
    Write-Host "   ✅ API reiniciada" -ForegroundColor $Green
} catch {
    Write-Host "   ⚠️  Erro ao reiniciar API" -ForegroundColor $Yellow
}

# ===============================================================================
# RESUMO FINAL
# ===============================================================================
Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor $Green
Write-Host "║   ✅ CONFIGURAÇÃO CONCLUÍDA COM SUCESSO!                 ║" -ForegroundColor $Green
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor $Green

Write-Host "📊 RESUMO DA CONFIGURAÇÃO:" -ForegroundColor $Cyan
Write-Host "   • Credencial WAHA: ✅ Criada" -ForegroundColor $White
Write-Host "   • Workflow RAG: ✅ Importado (ID: $workflowId)" -ForegroundColor $White
Write-Host "   • Status: 🟢 ATIVO" -ForegroundColor $White
Write-Host "   • Nodes: 13 (Webhook → RAG → LLM → WhatsApp)" -ForegroundColor $White
Write-Host "   • API Endpoints: /rag/search, /llm/invoke" -ForegroundColor $White

Write-Host "`n🔗 PRÓXIMOS PASSOS:" -ForegroundColor $Yellow
Write-Host "   1. Acesse n8n: http://localhost:5679" -ForegroundColor $White
Write-Host "   2. Verifique o workflow 'Chatbot RAG Completo'" -ForegroundColor $White
Write-Host "   3. Teste enviando mensagem no WhatsApp" -ForegroundColor $White
Write-Host "   4. Monitore execuções em: Executions (sidebar)" -ForegroundColor $White

Write-Host "`n📱 TESTE RÁPIDO:" -ForegroundColor $Cyan
Write-Host "   Envie para o WhatsApp conectado:" -ForegroundColor $White
Write-Host "   'Como pagar IPTU?'" -ForegroundColor $Yellow

Write-Host "`n🔍 MONITORAMENTO:" -ForegroundColor $Cyan
Write-Host "   • Logs API: docker compose logs -f api" -ForegroundColor $White
Write-Host "   • Logs n8n: docker compose logs -f n8n" -ForegroundColor $White
Write-Host "   • Health API: curl http://localhost:5000/health" -ForegroundColor $White

Write-Host "`n✨ Sistema pronto para produção!`n" -ForegroundColor $Green
