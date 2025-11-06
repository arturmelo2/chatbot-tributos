#!/usr/bin/env pwsh
# =============================================================================
# Assistente Interativo de Implantação em Produção
# =============================================================================
# Este script guia você passo-a-passo na implantação do chatbot em produção
# =============================================================================

param(
    [string]$ServerIP,
    [string]$ServerUser = "root",
    [switch]$LocalDeploy
)

$ErrorActionPreference = "Stop"

# Cores
function Write-Success { Write-Host "✅ $args" -ForegroundColor Green }
function Write-Error { Write-Host "❌ $args" -ForegroundColor Red }
function Write-Info { Write-Host "ℹ️  $args" -ForegroundColor Cyan }
function Write-Warning { Write-Host "⚠️  $args" -ForegroundColor Yellow }
function Write-Step { Write-Host "➡️  $args" -ForegroundColor Magenta }

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  $Text" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host ""
}

function Confirm-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "⏸️  $Message" -ForegroundColor Yellow
    Write-Host "   Pressione ENTER para continuar ou CTRL+C para cancelar..." -ForegroundColor Gray
    Read-Host
}

Write-Header "🚀 ASSISTENTE DE IMPLANTAÇÃO - CHATBOT v1.1.0"

# =============================================================================
# MODO DE IMPLANTAÇÃO
# =============================================================================

if ($LocalDeploy) {
    Write-Info "Modo: Deploy local (para testes)"
    $deployPath = $PWD.Path
} else {
    Write-Info "Modo: Deploy remoto em servidor"
    
    if (-not $ServerIP) {
        Write-Host ""
        Write-Host "Digite o IP ou domínio do servidor:" -ForegroundColor Cyan
        $ServerIP = Read-Host
    }
    
    Write-Success "Servidor alvo: $ServerUser@$ServerIP"
    $deployPath = "/opt/chatbot"
}

# =============================================================================
# CHECKLIST PRÉ-REQUISITOS
# =============================================================================

Write-Header "📋 CHECKLIST DE PRÉ-REQUISITOS"

$prerequisites = @(
    @{
        Name = "Servidor Linux Ubuntu 22.04+"
        Check = { $true } # Manual check
        Required = $true
    },
    @{
        Name = "Docker e Docker Compose v2 instalados"
        Check = { $true } # Will check on server
        Required = $true
    },
    @{
        Name = "Domínio configurado (ex: chatbot.exemplo.com)"
        Check = { $true }
        Required = $true
    },
    @{
        Name = "Cloudflare API Token obtido"
        Check = { $true }
        Required = $true
    },
    @{
        Name = "LLM API Key (Groq/OpenAI/xAI)"
        Check = { $true }
        Required = $true
    },
    @{
        Name = "Portas 80 e 443 abertas no firewall"
        Check = { $true }
        Required = $true
    }
)

foreach ($prereq in $prerequisites) {
    Write-Host "  [ ] $($prereq.Name)" -ForegroundColor White
}

Write-Host ""
Write-Host "Você tem TODOS os pré-requisitos acima? (S/n): " -NoNewline -ForegroundColor Cyan
$response = Read-Host
if ($response -and $response -notmatch '^[Ss]') {
    Write-Error "Complete os pré-requisitos primeiro. Ver: DEPLOY-PRODUCTION.md"
    exit 1
}

Write-Success "Pré-requisitos confirmados!"

# =============================================================================
# INFORMAÇÕES NECESSÁRIAS
# =============================================================================

Write-Header "🔐 COLETA DE INFORMAÇÕES"

$config = @{}

# Domínio
Write-Host "Digite seu domínio (ex: chatbot.exemplo.com.br):" -ForegroundColor Cyan
$config.DOMAIN = Read-Host
Write-Success "Domínio: $($config.DOMAIN)"

# Cloudflare
Write-Host ""
Write-Host "Digite seu email do Cloudflare:" -ForegroundColor Cyan
$config.CF_API_EMAIL = Read-Host
Write-Success "Email: $($config.CF_API_EMAIL)"

Write-Host ""
Write-Host "Digite seu Cloudflare API Token:" -ForegroundColor Cyan
$config.CF_DNS_API_TOKEN = Read-Host -AsSecureString
$config.CF_DNS_API_TOKEN_PLAIN = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($config.CF_DNS_API_TOKEN)
)
Write-Success "Token configurado (oculto)"

# n8n
Write-Host ""
Write-Host "Digite o email para admin do n8n:" -ForegroundColor Cyan
$config.N8N_OWNER_EMAIL = Read-Host
Write-Success "Email n8n: $($config.N8N_OWNER_EMAIL)"

Write-Host ""
Write-Host "Digite a senha para admin do n8n (mínimo 8 caracteres):" -ForegroundColor Cyan
$config.N8N_OWNER_PASSWORD = Read-Host -AsSecureString
$config.N8N_OWNER_PASSWORD_PLAIN = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($config.N8N_OWNER_PASSWORD)
)
Write-Success "Senha n8n configurada (oculta)"

# LLM Provider
Write-Host ""
Write-Host "Escolha o provedor de LLM:" -ForegroundColor Cyan
Write-Host "  1. Groq (gratuito, rápido) [RECOMENDADO]" -ForegroundColor White
Write-Host "  2. OpenAI (pago, alta qualidade)" -ForegroundColor White
Write-Host "  3. xAI (pago, reasoning)" -ForegroundColor White
Write-Host "Digite 1, 2 ou 3: " -NoNewline -ForegroundColor Cyan
$llmChoice = Read-Host

switch ($llmChoice) {
    "1" {
        $config.LLM_PROVIDER = "groq"
        $config.LLM_MODEL = "llama-3.3-70b-versatile"
        Write-Host ""
        Write-Host "Digite sua Groq API Key:" -ForegroundColor Cyan
        $config.GROQ_API_KEY = Read-Host -AsSecureString
        $config.GROQ_API_KEY_PLAIN = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($config.GROQ_API_KEY)
        )
        Write-Success "Groq configurado"
    }
    "2" {
        $config.LLM_PROVIDER = "openai"
        $config.LLM_MODEL = "gpt-4.1"
        Write-Host ""
        Write-Host "Digite sua OpenAI API Key:" -ForegroundColor Cyan
        $config.OPENAI_API_KEY = Read-Host -AsSecureString
        $config.OPENAI_API_KEY_PLAIN = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($config.OPENAI_API_KEY)
        )
        Write-Success "OpenAI configurado"
    }
    "3" {
        $config.LLM_PROVIDER = "xai"
        $config.LLM_MODEL = "grok-4-fast-reasoning"
        Write-Host ""
        Write-Host "Digite sua xAI API Key:" -ForegroundColor Cyan
        $config.XAI_API_KEY = Read-Host -AsSecureString
        $config.XAI_API_KEY_PLAIN = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($config.XAI_API_KEY)
        )
        Write-Success "xAI configurado"
    }
    default {
        Write-Error "Opção inválida. Abortando."
        exit 1
    }
}

# Gerar chaves
Write-Host ""
Write-Info "Gerando chaves de segurança..."
$config.N8N_ENCRYPTION_KEY = -join ((1..32) | ForEach-Object { '{0:x2}' -f (Get-Random -Maximum 256) })
$config.N8N_WEBHOOK_ID = [guid]::NewGuid().ToString()
Write-Success "Chaves geradas"

# =============================================================================
# RESUMO DA CONFIGURAÇÃO
# =============================================================================

Write-Header "📝 RESUMO DA CONFIGURAÇÃO"

Write-Host "  Domínio:           $($config.DOMAIN)" -ForegroundColor White
Write-Host "  Email Cloudflare:  $($config.CF_API_EMAIL)" -ForegroundColor White
Write-Host "  Email n8n:         $($config.N8N_OWNER_EMAIL)" -ForegroundColor White
Write-Host "  LLM Provider:      $($config.LLM_PROVIDER)" -ForegroundColor White
Write-Host "  LLM Model:         $($config.LLM_MODEL)" -ForegroundColor White
Write-Host ""
Write-Host "URLs que serão configuradas:" -ForegroundColor Yellow
Write-Host "  • https://waha.$($config.DOMAIN)" -ForegroundColor Cyan
Write-Host "  • https://n8n.$($config.DOMAIN)" -ForegroundColor Cyan
Write-Host "  • https://api.$($config.DOMAIN)" -ForegroundColor Cyan
Write-Host ""

Confirm-Step "Configuração correta?"

# =============================================================================
# CRIAR ARQUIVO .env
# =============================================================================

Write-Header "📄 CRIANDO ARQUIVO .env"

$envContent = @"
# =============================================================================
# Chatbot de Tributos - Production Environment
# Gerado automaticamente em $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
# =============================================================================

# Domain & Networking
DOMAIN=$($config.DOMAIN)
CF_API_EMAIL=$($config.CF_API_EMAIL)
CF_DNS_API_TOKEN=$($config.CF_DNS_API_TOKEN_PLAIN)

# n8n Configuration
N8N_WEBHOOK_ID=$($config.N8N_WEBHOOK_ID)
N8N_ENCRYPTION_KEY=$($config.N8N_ENCRYPTION_KEY)
N8N_PROTOCOL=https
N8N_OWNER_EMAIL=$($config.N8N_OWNER_EMAIL)
N8N_OWNER_PASSWORD=$($config.N8N_OWNER_PASSWORD_PLAIN)
N8N_OWNER_FIRST_NAME=Admin
N8N_OWNER_LAST_NAME=Chatbot
N8N_COMMUNITY_PACKAGES=n8n-nodes-waha

# WAHA
WAHA_API_KEY=tributos_nova_trento_2025_api_key_fixed
WAHA_DASHBOARD_USERNAME=admin
WAHA_DASHBOARD_PASSWORD=Tributos@NovaTrento2025

# LLM Provider
LLM_PROVIDER=$($config.LLM_PROVIDER)
LLM_MODEL=$($config.LLM_MODEL)
"@

# Adicionar API keys específicas
if ($config.GROQ_API_KEY_PLAIN) {
    $envContent += "`nGROQ_API_KEY=$($config.GROQ_API_KEY_PLAIN)"
}
if ($config.OPENAI_API_KEY_PLAIN) {
    $envContent += "`nOPENAI_API_KEY=$($config.OPENAI_API_KEY_PLAIN)"
}
if ($config.XAI_API_KEY_PLAIN) {
    $envContent += "`nXAI_API_KEY=$($config.XAI_API_KEY_PLAIN)"
}

$envContent += @"

# Embeddings & RAG
EMBEDDING_MODEL=sentence-transformers/all-MiniLM-L6-v2
AUTO_LOAD_KNOWLEDGE=true

# Logging & Monitoring
LOG_LEVEL=INFO
"@

# Salvar .env
$envPath = Join-Path $PWD.Path ".env"
$envContent | Out-File -FilePath $envPath -Encoding UTF8 -NoNewline
Write-Success "Arquivo .env criado: $envPath"
Write-Warning "IMPORTANTE: Não commite este arquivo! Ele contém credenciais."

# =============================================================================
# DEPLOY LOCAL OU REMOTO
# =============================================================================

if ($LocalDeploy) {
    Write-Header "🏠 DEPLOY LOCAL"
    
    Write-Info "Criando estrutura de diretórios..."
    New-Item -ItemType Directory -Force -Path "data/waha/session" | Out-Null
    New-Item -ItemType Directory -Force -Path "data/n8n" | Out-Null
    New-Item -ItemType Directory -Force -Path "data/chroma" | Out-Null
    New-Item -ItemType Directory -Force -Path "data/redis" | Out-Null
    New-Item -ItemType Directory -Force -Path "reverse-proxy" | Out-Null
    New-Item -ItemType Directory -Force -Path "logs" | Out-Null
    New-Item -ItemType Directory -Force -Path "exports" | Out-Null
    New-Item -ItemType Directory -Force -Path "backups" | Out-Null
    Write-Success "Diretórios criados"
    
    Write-Info "Criando acme.json para SSL..."
    $acmeFile = "reverse-proxy/acme.json"
    "{}" | Out-File -FilePath $acmeFile -Encoding UTF8 -NoNewline
    Write-Success "acme.json criado"
    
    Write-Host ""
    Write-Host "Para iniciar o stack, execute:" -ForegroundColor Yellow
    Write-Host "  docker compose -f compose.prod.yml up -d" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Para acompanhar logs:" -ForegroundColor Yellow
    Write-Host "  docker compose -f compose.prod.yml logs -f" -ForegroundColor Cyan
    Write-Host ""
    
} else {
    Write-Header "🌐 DEPLOY REMOTO"
    
    Write-Info "Conectando ao servidor $ServerIP..."
    
    # Testar conexão SSH
    Write-Step "Testando conexão SSH..."
    try {
        ssh -o ConnectTimeout=5 "$ServerUser@$ServerIP" "echo 'Conexão OK'"
        Write-Success "Conexão SSH estabelecida"
    } catch {
        Write-Error "Falha ao conectar via SSH. Verifique IP e credenciais."
        exit 1
    }
    
    # Criar diretório no servidor
    Write-Step "Criando diretório $deployPath no servidor..."
    ssh "$ServerUser@$ServerIP" "mkdir -p $deployPath"
    Write-Success "Diretório criado"
    
    # Copiar arquivos
    Write-Step "Copiando arquivos para o servidor..."
    $filesToCopy = @(
        "compose.prod.yml",
        "dockerfile",
        "requirements.txt",
        "requirements-dev.txt",
        "app.py",
        "Makefile",
        ".dockerignore"
    )
    
    foreach ($file in $filesToCopy) {
        if (Test-Path $file) {
            scp "$file" "$ServerUser@$ServerIP:$deployPath/"
            Write-Host "  ✓ $file" -ForegroundColor Green
        }
    }
    
    # Copiar diretórios
    Write-Step "Copiando diretórios..."
    $dirsToCohttp = @("bot", "services", "rag", "n8n", "deploy", "scripts", "reverse-proxy")
    
    foreach ($dir in $dirsToCohttp) {
        if (Test-Path $dir) {
            scp -r "$dir" "$ServerUser@$ServerIP:$deployPath/"
            Write-Host "  ✓ $dir/" -ForegroundColor Green
        }
    }
    
    # Copiar .env
    Write-Step "Copiando .env..."
    scp ".env" "$ServerUser@$ServerIP:$deployPath/"
    Write-Success ".env copiado"
    
    # Criar estrutura no servidor
    Write-Step "Criando estrutura de dados no servidor..."
    ssh "$ServerUser@$ServerIP" @"
cd $deployPath
mkdir -p data/{waha/session,n8n,chroma,redis}
mkdir -p logs exports backups
touch reverse-proxy/acme.json
chmod 600 reverse-proxy/acme.json
chmod 600 .env
chmod +x scripts/*.sh
chmod +x deploy/bootstrap/*.sh
"@
    Write-Success "Estrutura criada"
    
    # Iniciar stack
    Write-Host ""
    Write-Host "Deseja iniciar o stack agora? (S/n): " -NoNewline -ForegroundColor Cyan
    $response = Read-Host
    
    if ($response -notmatch '^[Nn]') {
        Write-Step "Iniciando Docker Compose..."
        ssh "$ServerUser@$ServerIP" "cd $deployPath && docker compose -f compose.prod.yml up -d"
        Write-Success "Stack iniciado!"
        
        Write-Host ""
        Write-Info "Aguarde ~3 minutos para inicialização completa..."
        Write-Host ""
        Write-Host "Acompanhe os logs com:" -ForegroundColor Yellow
        Write-Host "  ssh $ServerUser@$ServerIP 'cd $deployPath && docker compose -f compose.prod.yml logs -f'" -ForegroundColor Cyan
    }
}

# =============================================================================
# PRÓXIMOS PASSOS
# =============================================================================

Write-Header "🎯 PRÓXIMOS PASSOS"

Write-Host "1. Aguardar ~3 minutos para inicialização completa" -ForegroundColor White
Write-Host ""
Write-Host "2. Verificar status dos serviços:" -ForegroundColor White
if ($LocalDeploy) {
    Write-Host "   docker compose -f compose.prod.yml ps" -ForegroundColor Cyan
} else {
    Write-Host "   ssh $ServerUser@$ServerIP 'cd $deployPath && docker compose -f compose.prod.yml ps'" -ForegroundColor Cyan
}
Write-Host ""
Write-Host "3. Acessar n8n e ativar workflow:" -ForegroundColor White
Write-Host "   https://n8n.$($config.DOMAIN)" -ForegroundColor Cyan
Write-Host "   Login: $($config.N8N_OWNER_EMAIL)" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Acessar WAHA e escanear QR code:" -ForegroundColor White
Write-Host "   https://waha.$($config.DOMAIN)" -ForegroundColor Cyan
Write-Host "   Login: admin / Tributos@NovaTrento2025" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Testar API:" -ForegroundColor White
Write-Host "   curl https://api.$($config.DOMAIN)/health" -ForegroundColor Cyan
Write-Host ""
Write-Host "6. Enviar mensagem de teste no WhatsApp" -ForegroundColor White
Write-Host ""

Write-Success "Deploy concluído! 🎉"
Write-Host ""
Write-Info "Para mais detalhes, consulte: DEPLOY-PRODUCTION.md"
Write-Host ""
