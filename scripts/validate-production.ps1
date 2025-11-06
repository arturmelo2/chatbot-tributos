#!/usr/bin/env pwsh
# =============================================================================
# Validação Final do Deploy de Produção
# =============================================================================
# Este script valida que todos os componentes do deploy zero-touch estão
# funcionando corretamente antes do commit final.
# =============================================================================

param(
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

# Cores
function Write-Success { Write-Host "✅ $args" -ForegroundColor Green }
function Write-Error { Write-Host "❌ $args" -ForegroundColor Red }
function Write-Info { Write-Host "ℹ️  $args" -ForegroundColor Cyan }
function Write-Warning { Write-Host "⚠️  $args" -ForegroundColor Yellow }

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  🔍 VALIDAÇÃO FINAL - DEPLOY DE PRODUÇÃO v1.1.0" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""

$checks_passed = 0
$checks_failed = 0
$checks_total = 0

function Test-Check {
    param(
        [string]$Name,
        [scriptblock]$Test,
        [string]$SuccessMsg,
        [string]$FailMsg
    )
    
    $script:checks_total++
    Write-Host "[$script:checks_total] Testing: " -NoNewline
    Write-Host "$Name" -ForegroundColor White
    
    try {
        $result = & $Test
        if ($result) {
            Write-Success "  $SuccessMsg"
            $script:checks_passed++
            return $true
        } else {
            Write-Error "  $FailMsg"
            $script:checks_failed++
            return $false
        }
    } catch {
        Write-Error "  $FailMsg - Exception: $_"
        $script:checks_failed++
        return $false
    }
}

# =============================================================================
# CHECKS DE ESTRUTURA
# =============================================================================

Write-Host ""
Write-Host "📁 VALIDANDO ESTRUTURA DE ARQUIVOS..." -ForegroundColor Yellow
Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Gray

Test-Check -Name "compose.prod.yml existe" -Test {
    Test-Path "compose.prod.yml"
} -SuccessMsg "compose.prod.yml encontrado" -FailMsg "compose.prod.yml não encontrado"

Test-Check -Name ".env.production.example existe" -Test {
    Test-Path ".env.production.example"
} -SuccessMsg ".env.production.example encontrado" -FailMsg ".env.production.example não encontrado"

Test-Check -Name "DEPLOY-PRODUCTION.md existe" -Test {
    Test-Path "DEPLOY-PRODUCTION.md"
} -SuccessMsg "Guia de deploy criado" -FailMsg "Guia de deploy não encontrado"

Test-Check -Name "reverse-proxy/traefik.yml existe" -Test {
    Test-Path "reverse-proxy/traefik.yml"
} -SuccessMsg "Configuração Traefik encontrada" -FailMsg "Configuração Traefik não encontrada"

Test-Check -Name "deploy/bootstrap/n8n-bootstrap.sh existe" -Test {
    Test-Path "deploy/bootstrap/n8n-bootstrap.sh"
} -SuccessMsg "Script de bootstrap n8n encontrado" -FailMsg "Script de bootstrap n8n não encontrado"

Test-Check -Name "deploy/bootstrap/README.md existe" -Test {
    Test-Path "deploy/bootstrap/README.md"
} -SuccessMsg "Documentação de bootstrap encontrada" -FailMsg "Documentação de bootstrap não encontrada"

Test-Check -Name "scripts/wait-for.sh existe" -Test {
    Test-Path "scripts/wait-for.sh"
} -SuccessMsg "Helper wait-for.sh encontrado" -FailMsg "Helper wait-for.sh não encontrado"

Test-Check -Name "scripts/load-knowledge.sh existe" -Test {
    Test-Path "scripts/load-knowledge.sh"
} -SuccessMsg "Script de carregamento encontrado" -FailMsg "Script de carregamento não encontrado"

Test-Check -Name "docs/INDEX.md existe" -Test {
    Test-Path "docs/INDEX.md"
} -SuccessMsg "Índice de documentação encontrado" -FailMsg "Índice de documentação não encontrado"

Test-Check -Name "REFACTORING.md existe" -Test {
    Test-Path "REFACTORING.md"
} -SuccessMsg "Changelog de refatoração encontrado" -FailMsg "Changelog de refatoração não encontrado"

# =============================================================================
# CHECKS DE VERSÃO
# =============================================================================

Write-Host ""
Write-Host "🔢 VALIDANDO VERSÕES..." -ForegroundColor Yellow
Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Gray

Test-Check -Name "services/version.py está em 1.1.0" -Test {
    $content = Get-Content "services/version.py" -Raw
    $content -match '__version__\s*=\s*"1\.1\.0"'
} -SuccessMsg "Versão 1.1.0 confirmada em version.py" -FailMsg "Versão em version.py não está em 1.1.0"

Test-Check -Name "CHANGELOG.md contém v1.1.0" -Test {
    $content = Get-Content "CHANGELOG.md" -Raw
    $content -match '\[1\.1\.0\]'
} -SuccessMsg "v1.1.0 documentado no CHANGELOG" -FailMsg "v1.1.0 não encontrado no CHANGELOG"

# =============================================================================
# CHECKS DE CONFIGURAÇÃO
# =============================================================================

Write-Host ""
Write-Host "⚙️  VALIDANDO CONFIGURAÇÕES..." -ForegroundColor Yellow
Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Gray

Test-Check -Name "compose.prod.yml tem serviço traefik" -Test {
    $content = Get-Content "compose.prod.yml" -Raw
    $content -match 'traefik:'
} -SuccessMsg "Traefik configurado" -FailMsg "Traefik não encontrado"

Test-Check -Name "compose.prod.yml tem serviço redis" -Test {
    $content = Get-Content "compose.prod.yml" -Raw
    $content -match 'redis:'
} -SuccessMsg "Redis configurado" -FailMsg "Redis não encontrado"

Test-Check -Name "compose.prod.yml tem serviço chromadb" -Test {
    $content = Get-Content "compose.prod.yml" -Raw
    $content -match 'chromadb:'
} -SuccessMsg "ChromaDB standalone configurado" -FailMsg "ChromaDB não encontrado"

Test-Check -Name "compose.prod.yml usa bootstrap script" -Test {
    $content = Get-Content "compose.prod.yml" -Raw
    $content -match '/scripts/bootstrap\.sh'
} -SuccessMsg "Bootstrap script integrado ao n8n" -FailMsg "Bootstrap script não integrado"

Test-Check -Name "compose.prod.yml tem healthchecks" -Test {
    $content = Get-Content "compose.prod.yml" -Raw
    $matches = ($content | Select-String -Pattern "healthcheck:" -AllMatches).Matches
    $matches.Count -ge 6
} -SuccessMsg "Healthchecks configurados em todos os serviços (6 encontrados)" -FailMsg "Healthchecks insuficientes"

Test-Check -Name ".env.production.example tem todas as variáveis" -Test {
    $content = Get-Content ".env.production.example" -Raw
    ($content -match 'DOMAIN=') -and 
    ($content -match 'CF_API_EMAIL=') -and
    ($content -match 'N8N_ENCRYPTION_KEY=') -and
    ($content -match 'GROQ_API_KEY=')
} -SuccessMsg "Todas as variáveis essenciais presentes" -FailMsg "Variáveis de ambiente faltando"

# =============================================================================
# CHECKS DE PERMISSÕES
# =============================================================================

Write-Host ""
Write-Host "🔐 VALIDANDO PERMISSÕES..." -ForegroundColor Yellow
Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Gray

Test-Check -Name "Scripts bash são executáveis" -Test {
    # No Windows, verificamos apenas que os arquivos existem
    # Permissões Unix serão aplicadas no servidor Linux
    (Test-Path "scripts/wait-for.sh") -and
    (Test-Path "scripts/load-knowledge.sh") -and
    (Test-Path "deploy/bootstrap/n8n-bootstrap.sh")
} -SuccessMsg "Scripts bash encontrados (permissões serão aplicadas no deploy)" -FailMsg "Scripts bash não encontrados"

# =============================================================================
# CHECKS DE DOCUMENTAÇÃO
# =============================================================================

Write-Host ""
Write-Host "📚 VALIDANDO DOCUMENTAÇÃO..." -ForegroundColor Yellow
Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Gray

Test-Check -Name "DEPLOY-PRODUCTION.md tem seção de pré-requisitos" -Test {
    $content = Get-Content "DEPLOY-PRODUCTION.md" -Raw
    $content -match '## 🔧 Pré-requisitos'
} -SuccessMsg "Pré-requisitos documentados" -FailMsg "Pré-requisitos não documentados"

Test-Check -Name "DEPLOY-PRODUCTION.md tem seção de troubleshooting" -Test {
    $content = Get-Content "DEPLOY-PRODUCTION.md" -Raw
    $content -match '## 🔧 Troubleshooting'
} -SuccessMsg "Troubleshooting documentado" -FailMsg "Troubleshooting não documentado"

Test-Check -Name "deploy/bootstrap/README.md tem exemplos de integração" -Test {
    $content = Get-Content "deploy/bootstrap/README.md" -Raw
    $content -match 'docker-compose'
} -SuccessMsg "Exemplos de integração presentes" -FailMsg "Exemplos de integração faltando"

Test-Check -Name "docs/INDEX.md lista todos os documentos" -Test {
    $content = Get-Content "docs/INDEX.md" -Raw
    ($content -match 'N8N_CHATBOT_COMPLETO\.md') -and
    ($content -match 'TROUBLESHOOTING_PORTA_3000\.md')
} -SuccessMsg "Índice completo de documentação" -FailMsg "Índice de documentação incompleto"

# =============================================================================
# CHECKS DE .gitignore
# =============================================================================

Write-Host ""
Write-Host "🚫 VALIDANDO .gitignore..." -ForegroundColor Yellow
Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Gray

Test-Check -Name ".gitignore protege data/" -Test {
    $content = Get-Content ".gitignore" -Raw
    $content -match 'data/'
} -SuccessMsg "Diretório data/ protegido" -FailMsg "Diretório data/ não protegido"

Test-Check -Name ".gitignore protege acme.json" -Test {
    $content = Get-Content ".gitignore" -Raw
    $content -match 'acme\.json'
} -SuccessMsg "Certificados SSL protegidos" -FailMsg "Certificados SSL não protegidos"

Test-Check -Name ".gitignore protege backups/" -Test {
    $content = Get-Content ".gitignore" -Raw
    $content -match 'backups/'
} -SuccessMsg "Backups protegidos" -FailMsg "Backups não protegidos"

# =============================================================================
# CHECKS DE LIMPEZA
# =============================================================================

Write-Host ""
Write-Host "🧹 VALIDANDO LIMPEZA..." -ForegroundColor Yellow
Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Gray

Test-Check -Name "Caches removidos" -Test {
    !(Test-Path ".mypy_cache") -and 
    !(Test-Path ".pytest_cache") -and
    !(Test-Path ".ruff_cache")
} -SuccessMsg "Caches limpos" -FailMsg "Caches ainda presentes"

Test-Check -Name "Documentação consolidada em docs/" -Test {
    (Test-Path "docs/N8N_CHATBOT_COMPLETO.md") -and
    (Test-Path "docs/TROUBLESHOOTING_PORTA_3000.md") -and
    !(Test-Path "N8N_CHATBOT_COMPLETO.md")
} -SuccessMsg "Documentação consolidada" -FailMsg "Documentação ainda na raiz"

Test-Check -Name "Workflows em n8n/workflows/" -Test {
    (Test-Path "n8n/workflows") -and
    !(Test-Path "chatbot_orquestracao_plus_menu.json") -and
    !(Test-Path "n8n_workflow_waha_correto.json")
} -SuccessMsg "Workflows organizados" -FailMsg "Workflows ainda na raiz"

# =============================================================================
# CHECKS DE INTEGRIDADE
# =============================================================================

Write-Host ""
Write-Host "🔍 VALIDANDO INTEGRIDADE..." -ForegroundColor Yellow
Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Gray

Test-Check -Name "compose.prod.yml é válido YAML" -Test {
    try {
        $null = docker compose -f compose.prod.yml config 2>&1
        $LASTEXITCODE -eq 0
    } catch {
        $false
    }
} -SuccessMsg "compose.prod.yml é válido" -FailMsg "compose.prod.yml tem erros de sintaxe"

Test-Check -Name "Makefile tem comandos essenciais" -Test {
    $content = Get-Content "Makefile" -Raw
    ($content -match 'up:') -and
    ($content -match 'down:') -and
    ($content -match 'logs:') -and
    ($content -match 'backup:')
} -SuccessMsg "Makefile tem todos os comandos" -FailMsg "Makefile está incompleto"

# =============================================================================
# RELATÓRIO FINAL
# =============================================================================

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  📊 RELATÓRIO FINAL" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""

Write-Host "  Total de checks:   " -NoNewline
Write-Host "$checks_total" -ForegroundColor White

Write-Host "  ✅ Aprovados:      " -NoNewline
Write-Host "$checks_passed" -ForegroundColor Green

Write-Host "  ❌ Falhados:       " -NoNewline
if ($checks_failed -eq 0) {
    Write-Host "$checks_failed" -ForegroundColor Green
} else {
    Write-Host "$checks_failed" -ForegroundColor Red
}

$percentage = [math]::Round(($checks_passed / $checks_total) * 100, 1)
Write-Host "  📈 Taxa de sucesso: " -NoNewline
if ($percentage -eq 100) {
    Write-Host "$percentage%" -ForegroundColor Green
} elseif ($percentage -ge 90) {
    Write-Host "$percentage%" -ForegroundColor Yellow
} else {
    Write-Host "$percentage%" -ForegroundColor Red
}

Write-Host ""

if ($checks_failed -eq 0) {
    Write-Host "🎉 VALIDAÇÃO COMPLETA: $checks_passed/$checks_total CHECKS PASSED" -ForegroundColor Green -BackgroundColor Black
    Write-Host ""
    Write-Host "✅ Tudo pronto para commit!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Próximos passos:" -ForegroundColor Yellow
    Write-Host "  1. git add ." -ForegroundColor White
    Write-Host "  2. git commit -m 'refactor: complete repository refactoring with zero-touch deployment (v1.1.0)'" -ForegroundColor White
    Write-Host "  3. git push origin main" -ForegroundColor White
    Write-Host ""
    exit 0
} else {
    Write-Host "⚠️  VALIDAÇÃO INCOMPLETA: $checks_failed checks falharam" -ForegroundColor Yellow -BackgroundColor Black
    Write-Host ""
    Write-Host "Por favor, corrija os erros acima antes de fazer commit." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}
