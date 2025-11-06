#!/usr/bin/env pwsh
# =============================================================================
# Auto Deploy - Implantação Automática Zero-Touch
# =============================================================================
# Configure as variáveis abaixo e execute: .\scripts\auto-deploy.ps1
# =============================================================================

param(
    [string]$Mode = "local" # local | remote
)

# =============================================================================
# CONFIGURAÇÃO - PREENCHA AQUI
# =============================================================================

$CONFIG = @{
    # Servidor (apenas para mode=remote)
    SERVER_IP = "SEU_IP_AQUI"  # ex: 192.168.1.100 ou chatbot.exemplo.com
    SERVER_USER = "root"
    
    # Domínio
    DOMAIN = "chatbot.exemplo.com.br"
    
    # Cloudflare
    CF_API_EMAIL = "seu-email@exemplo.com"
    CF_DNS_API_TOKEN = "seu-cloudflare-token-aqui"
    
    # n8n
    N8N_OWNER_EMAIL = "admin@chatbot.local"
    N8N_OWNER_PASSWORD = "SenhaForte123!"
    
    # LLM (groq|openai|xai)
    LLM_PROVIDER = "groq"
    GROQ_API_KEY = "gsk_seu_groq_key_aqui"
    # OPENAI_API_KEY = "sk_seu_openai_key_aqui"
    # XAI_API_KEY = "xai-seu_xai_key_aqui"
}

# =============================================================================
# NÃO EDITE ABAIXO DESTA LINHA
# =============================================================================

$ErrorActionPreference = "Stop"

function Write-Log { param([string]$Msg, [string]$Color = "White") Write-Host "$(Get-Date -Format 'HH:mm:ss') | $Msg" -ForegroundColor $Color }
function Write-Success { Write-Log "✅ $args" "Green" }
function Write-Error { Write-Log "❌ $args" "Red" }
function Write-Info { Write-Log "ℹ️  $args" "Cyan" }

Write-Host ""
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  🚀 AUTO DEPLOY - MODO: $($Mode.ToUpper())" -ForegroundColor Yellow
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""

# Validar configuração
if ($CONFIG.DOMAIN -eq "chatbot.exemplo.com.br") {
    Write-Error "Configure o DOMAIN no script antes de executar!"
    exit 1
}

# Gerar chaves
$CONFIG.N8N_ENCRYPTION_KEY = -join ((1..32) | ForEach-Object { '{0:x2}' -f (Get-Random -Maximum 256) })
$CONFIG.N8N_WEBHOOK_ID = [guid]::NewGuid().ToString()

# Modelo LLM
$LLM_MODELS = @{
    groq = "llama-3.3-70b-versatile"
    openai = "gpt-4.1"
    xai = "grok-4-fast-reasoning"
}
$CONFIG.LLM_MODEL = $LLM_MODELS[$CONFIG.LLM_PROVIDER]

# Criar .env
Write-Info "Gerando arquivo .env..."
$envContent = @"
DOMAIN=$($CONFIG.DOMAIN)
CF_API_EMAIL=$($CONFIG.CF_API_EMAIL)
CF_DNS_API_TOKEN=$($CONFIG.CF_DNS_API_TOKEN)

N8N_WEBHOOK_ID=$($CONFIG.N8N_WEBHOOK_ID)
N8N_ENCRYPTION_KEY=$($CONFIG.N8N_ENCRYPTION_KEY)
N8N_PROTOCOL=https
N8N_OWNER_EMAIL=$($CONFIG.N8N_OWNER_EMAIL)
N8N_OWNER_PASSWORD=$($CONFIG.N8N_OWNER_PASSWORD)
N8N_OWNER_FIRST_NAME=Admin
N8N_OWNER_LAST_NAME=Chatbot
N8N_COMMUNITY_PACKAGES=n8n-nodes-waha

WAHA_API_KEY=tributos_nova_trento_2025_api_key_fixed
WAHA_DASHBOARD_USERNAME=admin
WAHA_DASHBOARD_PASSWORD=Tributos@NovaTrento2025

LLM_PROVIDER=$($CONFIG.LLM_PROVIDER)
LLM_MODEL=$($CONFIG.LLM_MODEL)
GROQ_API_KEY=$($CONFIG.GROQ_API_KEY)
OPENAI_API_KEY=$($CONFIG.OPENAI_API_KEY)
XAI_API_KEY=$($CONFIG.XAI_API_KEY)

EMBEDDING_MODEL=sentence-transformers/all-MiniLM-L6-v2
AUTO_LOAD_KNOWLEDGE=true
LOG_LEVEL=INFO
"@

$envContent | Out-File -FilePath ".env" -Encoding UTF8 -NoNewline
Write-Success ".env criado"

if ($Mode -eq "local") {
    # =========================================================================
    # DEPLOY LOCAL
    # =========================================================================
    
    Write-Info "Criando estrutura..."
    @("data/waha/session", "data/n8n", "data/chroma", "data/redis", "reverse-proxy", "logs", "exports", "backups") | ForEach-Object {
        New-Item -ItemType Directory -Force -Path $_ | Out-Null
    }
    "{}" | Out-File -FilePath "reverse-proxy/acme.json" -Encoding UTF8 -NoNewline
    Write-Success "Estrutura criada"
    
    Write-Info "Iniciando stack Docker..."
    docker compose -f compose.prod.yml up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Stack iniciado!"
        Write-Host ""
        Write-Host "URLs configuradas:" -ForegroundColor Yellow
        Write-Host "  • https://waha.$($CONFIG.DOMAIN)" -ForegroundColor Cyan
        Write-Host "  • https://n8n.$($CONFIG.DOMAIN)" -ForegroundColor Cyan
        Write-Host "  • https://api.$($CONFIG.DOMAIN)" -ForegroundColor Cyan
        Write-Host ""
        Write-Info "Aguarde ~3 minutos para inicialização completa"
        Write-Host ""
        Write-Host "Próximos passos:" -ForegroundColor Yellow
        Write-Host "  1. Acessar n8n e ativar workflow"
        Write-Host "  2. Acessar WAHA e escanear QR code"
        Write-Host "  3. Testar envio de mensagem"
        Write-Host ""
        Write-Host "Ver logs: docker compose -f compose.prod.yml logs -f" -ForegroundColor Cyan
    } else {
        Write-Error "Falha ao iniciar stack. Ver logs acima."
        exit 1
    }
    
} else {
    # =========================================================================
    # DEPLOY REMOTO
    # =========================================================================
    
    $SERVER = "$($CONFIG.SERVER_USER)@$($CONFIG.SERVER_IP)"
    $DEPLOY_PATH = "/opt/chatbot"
    
    Write-Info "Conectando a $SERVER..."
    
    # Criar diretório
    ssh $SERVER "mkdir -p $DEPLOY_PATH"
    Write-Success "Diretório criado no servidor"
    
    # Copiar arquivos
    Write-Info "Copiando arquivos..."
    $files = @("compose.prod.yml", "dockerfile", "requirements.txt", "requirements-dev.txt", "app.py", "Makefile", ".dockerignore", ".env")
    foreach ($f in $files) {
        if (Test-Path $f) { scp -q $f "${SERVER}:${DEPLOY_PATH}/" }
    }
    
    $dirs = @("bot", "services", "rag", "n8n", "deploy", "scripts", "reverse-proxy", "tests", "tools")
    foreach ($d in $dirs) {
        if (Test-Path $d) { scp -q -r $d "${SERVER}:${DEPLOY_PATH}/" }
    }
    Write-Success "Arquivos copiados"
    
    # Configurar servidor
    Write-Info "Configurando servidor..."
    ssh $SERVER @"
cd $DEPLOY_PATH
mkdir -p data/{waha/session,n8n,chroma,redis} logs exports backups
touch reverse-proxy/acme.json
chmod 600 reverse-proxy/acme.json .env
chmod +x scripts/*.sh deploy/bootstrap/*.sh
"@
    Write-Success "Servidor configurado"
    
    # Iniciar stack
    Write-Info "Iniciando stack no servidor..."
    ssh $SERVER "cd $DEPLOY_PATH && docker compose -f compose.prod.yml up -d"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Stack iniciado!"
        Write-Host ""
        Write-Host "URLs configuradas:" -ForegroundColor Yellow
        Write-Host "  • https://waha.$($CONFIG.DOMAIN)" -ForegroundColor Cyan
        Write-Host "  • https://n8n.$($CONFIG.DOMAIN)" -ForegroundColor Cyan
        Write-Host "  • https://api.$($CONFIG.DOMAIN)" -ForegroundColor Cyan
        Write-Host ""
        Write-Info "Aguarde ~3 minutos para inicialização"
        Write-Host ""
        Write-Host "Ver logs: ssh $SERVER 'cd $DEPLOY_PATH && docker compose -f compose.prod.yml logs -f'" -ForegroundColor Cyan
    } else {
        Write-Error "Falha ao iniciar stack"
        exit 1
    }
}

Write-Host ""
Write-Success "Deploy concluído! 🎉"
Write-Host ""
