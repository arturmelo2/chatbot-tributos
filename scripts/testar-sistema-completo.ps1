# ===============================================================================
# Script de Teste Final - RAG Completo
# ===============================================================================
# Testa todos os componentes do sistema após configuração
# ===============================================================================

$ErrorActionPreference = "Continue"

# Cores
$Green = "Green"
$Yellow = "Yellow"
$Cyan = "Cyan"
$Red = "Red"
$White = "White"

Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor $Cyan
Write-Host "║   🧪 TESTE COMPLETO DO SISTEMA RAG                      ║" -ForegroundColor $Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝`n" -ForegroundColor $Cyan

# ===============================================================================
# TESTE 1: Health Check Básico
# ===============================================================================
Write-Host "1️⃣ Testando Health Check da API..." -ForegroundColor $Yellow

try {
    $health = curl -s "http://localhost:5000/health" | ConvertFrom-Json
    
    if ($health.status -eq "healthy") {
        Write-Host "   ✅ API saudável" -ForegroundColor $Green
        Write-Host "   📊 Provider: $($health.llm_provider)" -ForegroundColor $White
        Write-Host "   📦 Version: $($health.version)" -ForegroundColor $White
    } else {
        Write-Host "   ❌ API não saudável" -ForegroundColor $Red
        exit 1
    }
} catch {
    Write-Host "   ❌ Erro ao conectar na API" -ForegroundColor $Red
    Write-Host "   💡 Dica: Verifique se a API está rodando: docker compose ps" -ForegroundColor $Yellow
    exit 1
}

# ===============================================================================
# TESTE 2: Endpoint /rag/search
# ===============================================================================
Write-Host "`n2️⃣ Testando endpoint /rag/search..." -ForegroundColor $Yellow

try {
    $ragTest = '{"query":"Como pagar IPTU?","k":3,"search_type":"mmr","lambda_mult":0.5}'
    $ragResult = curl -s -X POST "http://localhost:5000/rag/search" `
        -H "Content-Type: application/json" `
        -d $ragTest | ConvertFrom-Json
    
    if ($ragResult.count -gt 0) {
        Write-Host "   ✅ RAG Search funcionando" -ForegroundColor $Green
        Write-Host "   📚 Documentos encontrados: $($ragResult.count)" -ForegroundColor $White
        Write-Host "   🔍 Query: $($ragResult.query)" -ForegroundColor $White
        
        # Mostrar primeira fonte
        $firstDoc = $ragResult.results[0]
        $source = $firstDoc.metadata.source
        Write-Host "   📄 Primeira fonte: $source" -ForegroundColor $White
    } else {
        Write-Host "   ⚠️  Nenhum documento encontrado" -ForegroundColor $Yellow
        Write-Host "   💡 Dica: Execute .\scripts\load-knowledge.ps1" -ForegroundColor $Yellow
    }
} catch {
    Write-Host "   ❌ Erro no endpoint /rag/search" -ForegroundColor $Red
    Write-Host "   💡 Detalhes: $_" -ForegroundColor $Yellow
    Write-Host "   💡 Certifique-se que o build da API está completo" -ForegroundColor $Yellow
}

# ===============================================================================
# TESTE 3: Endpoint /llm/invoke
# ===============================================================================
Write-Host "`n3️⃣ Testando endpoint /llm/invoke..." -ForegroundColor $Yellow

try {
    $llmTest = @{
        messages = @(
            @{
                role = "system"
                content = "Você é um assistente de tributos. Responda de forma objetiva."
            },
            @{
                role = "user"
                content = "Qual o prazo para pagamento do IPTU?"
            }
        )
        temperature = 0.3
        max_tokens = 150
    } | ConvertTo-Json -Depth 5
    
    $llmResult = curl -s -X POST "http://localhost:5000/llm/invoke" `
        -H "Content-Type: application/json" `
        -d $llmTest | ConvertFrom-Json
    
    if ($llmResult.response) {
        Write-Host "   ✅ LLM Invoke funcionando" -ForegroundColor $Green
        Write-Host "   🤖 Model: $($llmResult.model)" -ForegroundColor $White
        Write-Host "   💬 Resposta (primeiros 100 chars):" -ForegroundColor $White
        $preview = $llmResult.response.Substring(0, [Math]::Min(100, $llmResult.response.Length))
        Write-Host "      $preview..." -ForegroundColor $Cyan
    } else {
        Write-Host "   ⚠️  LLM não retornou resposta" -ForegroundColor $Yellow
    }
} catch {
    Write-Host "   ❌ Erro no endpoint /llm/invoke" -ForegroundColor $Red
    Write-Host "   💡 Detalhes: $_" -ForegroundColor $Yellow
    Write-Host "   💡 Verifique a variável GROQ_API_KEY no .env" -ForegroundColor $Yellow
}

# ===============================================================================
# TESTE 4: Workflow n8n
# ===============================================================================
Write-Host "`n4️⃣ Verificando workflow n8n..." -ForegroundColor $Yellow

$token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxNzY1ZWYzNS0zNWYzLTQ3NDItYjY5Mi1kZmVjMGRmZjU1MGQiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzYyNDY1MDk0LCJleHAiOjE3NjQ5OTAwMDB9.AyvjOuOk25dSVuSxjUgop22frjyGNWoO03W-YAWE_B4"

try {
    $workflows = curl -s "http://localhost:5679/api/v1/workflows" `
        -H "X-N8N-API-KEY: $token" | ConvertFrom-Json
    
    $ragWorkflow = $workflows.data | Where-Object { $_.name -like "*RAG Completo*" }
    
    if ($ragWorkflow) {
        Write-Host "   ✅ Workflow RAG encontrado" -ForegroundColor $Green
        Write-Host "   📋 Nome: $($ragWorkflow.name)" -ForegroundColor $White
        Write-Host "   🆔 ID: $($ragWorkflow.id)" -ForegroundColor $White
        Write-Host "   📊 Nodes: $($ragWorkflow.nodes.Count)" -ForegroundColor $White
        
        if ($ragWorkflow.active) {
            Write-Host "   🟢 Status: ATIVO" -ForegroundColor $Green
        } else {
            Write-Host "   ⚪ Status: INATIVO" -ForegroundColor $Yellow
            Write-Host "   💡 Dica: Ative o workflow no n8n (http://localhost:5679)" -ForegroundColor $Yellow
        }
    } else {
        Write-Host "   ⚠️  Workflow RAG Completo não encontrado" -ForegroundColor $Yellow
        Write-Host "   💡 Dica: Execute .\scripts\configurar-rag-completo.ps1" -ForegroundColor $Yellow
    }
} catch {
    Write-Host "   ❌ Erro ao conectar no n8n" -ForegroundColor $Red
    Write-Host "   💡 Verifique se n8n está rodando: docker compose ps" -ForegroundColor $Yellow
}

# ===============================================================================
# TESTE 5: WAHA Session
# ===============================================================================
Write-Host "`n5️⃣ Verificando sessão WAHA..." -ForegroundColor $Yellow

try {
    $session = curl -s "http://localhost:3000/api/sessions/default" | ConvertFrom-Json
    
    if ($session.status -eq "WORKING") {
        Write-Host "   ✅ WAHA conectado" -ForegroundColor $Green
        Write-Host "   📱 Status: $($session.status)" -ForegroundColor $White
        Write-Host "   🔗 Webhook: $($session.config.webhooks[0].url)" -ForegroundColor $White
    } else {
        Write-Host "   ⚠️  WAHA não está conectado" -ForegroundColor $Yellow
        Write-Host "   📱 Status: $($session.status)" -ForegroundColor $Yellow
        Write-Host "   💡 Dica: Execute .\scripts\start-waha-session.ps1" -ForegroundColor $Yellow
    }
} catch {
    Write-Host "   ❌ Erro ao conectar no WAHA" -ForegroundColor $Red
    Write-Host "   💡 Verifique se WAHA está rodando: docker compose ps" -ForegroundColor $Yellow
}

# ===============================================================================
# TESTE 6: ChromaDB
# ===============================================================================
Write-Host "`n6️⃣ Verificando base de conhecimento..." -ForegroundColor $Yellow

try {
    $chromaCheck = docker exec tributos_api python -c "from langchain_chroma import Chroma; from services.config import get_settings; settings = get_settings(); chroma = Chroma(persist_directory=settings.CHROMA_DIR); print(f'Documentos: {len(chroma.get()[\"ids\"])}')" 2>&1
    
    if ($chromaCheck -match "Documentos: (\d+)") {
        $docCount = $Matches[1]
        
        if ([int]$docCount -gt 0) {
            Write-Host "   ✅ ChromaDB carregado" -ForegroundColor $Green
            Write-Host "   📚 Total de chunks: $docCount" -ForegroundColor $White
        } else {
            Write-Host "   ⚠️  ChromaDB vazio" -ForegroundColor $Yellow
            Write-Host "   💡 Dica: Execute .\scripts\load-knowledge.ps1" -ForegroundColor $Yellow
        }
    }
} catch {
    Write-Host "   ⚠️  Não foi possível verificar ChromaDB" -ForegroundColor $Yellow
}

# ===============================================================================
# RESUMO FINAL
# ===============================================================================
Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor $Cyan
Write-Host "║   📊 RESUMO DOS TESTES                                  ║" -ForegroundColor $Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝`n" -ForegroundColor $Cyan

Write-Host "🎯 PRÓXIMOS PASSOS:" -ForegroundColor $Yellow
Write-Host "   1. Se todos os testes passaram:" -ForegroundColor $White
Write-Host "      • Ative o workflow no n8n (http://localhost:5679)" -ForegroundColor $White
Write-Host "      • Teste enviando mensagem no WhatsApp" -ForegroundColor $White
Write-Host ""
Write-Host "   2. Se algum teste falhou:" -ForegroundColor $White
Write-Host "      • API não responde: docker compose restart api" -ForegroundColor $White
Write-Host "      • ChromaDB vazio: .\scripts\load-knowledge.ps1" -ForegroundColor $White
Write-Host "      • WAHA desconectado: .\scripts\start-waha-session.ps1" -ForegroundColor $White
Write-Host "      • Workflow faltando: .\scripts\configurar-rag-completo.ps1" -ForegroundColor $White

Write-Host "`n📱 TESTE MANUAL VIA WHATSAPP:" -ForegroundColor $Cyan
Write-Host "   Envie para o número conectado:" -ForegroundColor $White
Write-Host "   'Como pagar IPTU?'" -ForegroundColor $Yellow

Write-Host "`n🔍 MONITORAMENTO:" -ForegroundColor $Cyan
Write-Host "   • Logs API: docker compose logs -f api" -ForegroundColor $White
Write-Host "   • Executions n8n: http://localhost:5679 → Executions" -ForegroundColor $White
Write-Host "   • Health API: curl http://localhost:5000/health" -ForegroundColor $White

Write-Host "`n✨ Testes concluídos!`n" -ForegroundColor $Green
