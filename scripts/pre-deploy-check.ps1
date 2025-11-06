<#
.SYNOPSIS
    Verifica se o sistema está pronto para deploy em produção

.DESCRIPTION
    Script que valida todas as configurações necessárias antes do deployment

.EXAMPLE
    .\scripts\pre-deploy-check.ps1
#>

Write-Host "🔍 Verificação Pré-Deploy - Chatbot de Tributos" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Gray

$errors = @()
$warnings = @()
$checks = 0
$passed = 0

function Test-Check {
    param(
        [string]$Name,
        [scriptblock]$Test,
        [string]$ErrorMessage,
        [bool]$IsWarning = $false
    )
    
    $script:checks++
    Write-Host "`n[$script:checks] Verificando: $Name" -ForegroundColor Yellow
    
    try {
        $result = & $Test
        if ($result) {
            Write-Host "    ✅ OK" -ForegroundColor Green
            $script:passed++
            return $true
        } else {
            if ($IsWarning) {
                Write-Host "    ⚠️  AVISO: $ErrorMessage" -ForegroundColor Yellow
                $script:warnings += $ErrorMessage
            } else {
                Write-Host "    ❌ ERRO: $ErrorMessage" -ForegroundColor Red
                $script:errors += $ErrorMessage
            }
            return $false
        }
    } catch {
        if ($IsWarning) {
            Write-Host "    ⚠️  AVISO: $ErrorMessage - $_" -ForegroundColor Yellow
            $script:warnings += "$ErrorMessage - $_"
        } else {
            Write-Host "    ❌ ERRO: $ErrorMessage - $_" -ForegroundColor Red
            $script:errors += "$ErrorMessage - $_"
        }
        return $false
    }
}

# =============================================================================
# Verificações de Sistema
# =============================================================================

Test-Check -Name "Docker Desktop instalado" -Test {
    $null -ne (Get-Command docker -ErrorAction SilentlyContinue)
} -ErrorMessage "Docker não encontrado. Instale Docker Desktop."

Test-Check -Name "Docker está rodando" -Test {
    try {
        docker ps 2>&1 | Out-Null
        $LASTEXITCODE -eq 0
    } catch {
        $false
    }
} -ErrorMessage "Docker não está rodando. Inicie Docker Desktop."

Test-Check -Name "Docker Compose disponível" -Test {
    $null -ne (Get-Command docker-compose -ErrorAction SilentlyContinue)
} -ErrorMessage "Docker Compose não encontrado."

# =============================================================================
# Verificações de Arquivos
# =============================================================================

Test-Check -Name "Arquivo .env existe" -Test {
    Test-Path ".env"
} -ErrorMessage "Arquivo .env não encontrado. Copie de .env.example"

Test-Check -Name "Arquivo compose.yml existe" -Test {
    Test-Path "compose.yml"
} -ErrorMessage "compose.yml não encontrado."

Test-Check -Name "Dockerfile existe" -Test {
    Test-Path "dockerfile"
} -ErrorMessage "dockerfile não encontrado."

Test-Check -Name "Base de conhecimento existe" -Test {
    (Test-Path "rag/data") -and ((Get-ChildItem "rag/data" -Recurse -File).Count -gt 0)
} -ErrorMessage "Base de conhecimento vazia em rag/data/"

# =============================================================================
# Verificações de Configuração (.env)
# =============================================================================

if (Test-Path ".env") {
    $envContent = Get-Content ".env" -Raw
    
    Test-Check -Name "LLM_PROVIDER configurado" -Test {
        $envContent -match "LLM_PROVIDER\s*=\s*\w+"
    } -ErrorMessage "LLM_PROVIDER não configurado no .env"
    
    Test-Check -Name "API Key configurada" -Test {
        ($envContent -match "XAI_API_KEY\s*=\s*xai-\w+") -or 
        ($envContent -match "GROQ_API_KEY\s*=\s*gsk_\w+") -or 
        ($envContent -match "OPENAI_API_KEY\s*=\s*sk-\w+")
    } -ErrorMessage "Nenhuma API Key válida encontrada no .env"
    
    Test-Check -Name "WAHA_API_KEY configurado" -Test {
        $envContent -match "WAHA_API_KEY\s*=\s*.+"
    } -ErrorMessage "WAHA_API_KEY não configurado no .env" -IsWarning $true
    
    Test-Check -Name "ENVIRONMENT=production" -Test {
        $envContent -match "ENVIRONMENT\s*=\s*production"
    } -ErrorMessage "ENVIRONMENT não está configurado como 'production'" -IsWarning $true
    
    Test-Check -Name "DEBUG=false" -Test {
        $envContent -match "DEBUG\s*=\s*false"
    } -ErrorMessage "DEBUG deveria ser 'false' em produção" -IsWarning $true
}

# =============================================================================
# Verificações de Portas
# =============================================================================

Test-Check -Name "Porta 3000 disponível (WAHA)" -Test {
    $null -eq (Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue)
} -ErrorMessage "Porta 3000 já em uso" -IsWarning $true

Test-Check -Name "Porta 5000 disponível (API)" -Test {
    $null -eq (Get-NetTCPConnection -LocalPort 5000 -ErrorAction SilentlyContinue)
} -ErrorMessage "Porta 5000 já em uso" -IsWarning $true

Test-Check -Name "Porta 5679 disponível (n8n)" -Test {
    $null -eq (Get-NetTCPConnection -LocalPort 5679 -ErrorAction SilentlyContinue)
} -ErrorMessage "Porta 5679 já em uso" -IsWarning $true

# =============================================================================
# Verificações de Workflows n8n
# =============================================================================

Test-Check -Name "Workflows n8n existem" -Test {
    (Test-Path "n8n/workflows") -and ((Get-ChildItem "n8n/workflows" -Filter "*.json").Count -gt 0)
} -ErrorMessage "Nenhum workflow n8n encontrado" -IsWarning $true

# =============================================================================
# Verificações de Scripts
# =============================================================================

Test-Check -Name "Scripts PowerShell existem" -Test {
    (Test-Path "scripts") -and ((Get-ChildItem "scripts" -Filter "*.ps1").Count -gt 5)
} -ErrorMessage "Scripts PowerShell não encontrados"

# =============================================================================
# Resultados
# =============================================================================

Write-Host "`n" + ("=" * 80) -ForegroundColor Gray
Write-Host "`n📊 RESULTADO DA VERIFICAÇÃO" -ForegroundColor Cyan

Write-Host "`n✅ Verificações passadas: $passed / $checks" -ForegroundColor Green

if ($warnings.Count -gt 0) {
    Write-Host "`n⚠️  Avisos ($($warnings.Count)):" -ForegroundColor Yellow
    foreach ($warning in $warnings) {
        Write-Host "   - $warning" -ForegroundColor Yellow
    }
}

if ($errors.Count -gt 0) {
    Write-Host "`n❌ Erros ($($errors.Count)):" -ForegroundColor Red
    foreach ($error in $errors) {
        Write-Host "   - $error" -ForegroundColor Red
    }
    Write-Host "`n🚨 SISTEMA NÃO ESTÁ PRONTO PARA DEPLOY!" -ForegroundColor Red
    Write-Host "   Corrija os erros acima antes de prosseguir.`n" -ForegroundColor Red
    exit 1
} else {
    Write-Host "`n✅ SISTEMA PRONTO PARA DEPLOY!" -ForegroundColor Green
    
    if ($warnings.Count -gt 0) {
        Write-Host "`n   Os avisos acima são opcionais mas recomendados." -ForegroundColor Yellow
    }
    
    Write-Host "`n🚀 Próximos passos:" -ForegroundColor Cyan
    Write-Host "   1. docker-compose up -d" -ForegroundColor White
    Write-Host "   2. docker-compose exec api python rag/load_knowledge.py" -ForegroundColor White
    Write-Host "   3. Configurar n8n em http://localhost:5679" -ForegroundColor White
    Write-Host "   4. Conectar WhatsApp via http://localhost:3000" -ForegroundColor White
    Write-Host ""
    exit 0
}
