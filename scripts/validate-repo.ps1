# =============================================================================
# validate-repo.ps1 - Validação da Estrutura do Repositório
# =============================================================================
# Verifica se todos os arquivos essenciais estão presentes e configurados

Write-Host "🔍 Validando estrutura do repositório..." -ForegroundColor Cyan
Write-Host ""

$issues = @()
$warnings = @()
$success = @()

# -----------------------------------------------------------------------------
# Função auxiliar para verificar arquivo
# -----------------------------------------------------------------------------
function Test-FileExists {
    param($Path, $Name)
    if (Test-Path $Path) {
        $script:success += "✅ $Name"
        return $true
    } else {
        $script:issues += "❌ FALTANDO: $Name ($Path)"
        return $false
    }
}

function Test-FileNotEmpty {
    param($Path, $Name)
    if ((Test-Path $Path) -and ((Get-Content $Path -Raw).Length -gt 100)) {
        $script:success += "✅ $Name (com conteúdo)"
        return $true
    } else {
        $script:warnings += "⚠️  $Name está vazio ou muito pequeno"
        return $false
    }
}

# -----------------------------------------------------------------------------
# 1. Documentação
# -----------------------------------------------------------------------------
Write-Host "📚 Documentação:" -ForegroundColor Yellow

Test-FileExists "README.md" "README.md"
Test-FileExists "ARCHITECTURE.md" "ARCHITECTURE.md"
Test-FileExists "DEPLOYMENT.md" "DEPLOYMENT.md"
Test-FileExists "CONTRIBUTING.md" "CONTRIBUTING.md"
Test-FileExists "CHANGELOG.md" "CHANGELOG.md"
Test-FileExists "LICENSE" "LICENSE"
Test-FileExists "PROJECT_STRUCTURE.md" "PROJECT_STRUCTURE.md"

Write-Host ""

# -----------------------------------------------------------------------------
# 2. Configuração
# -----------------------------------------------------------------------------
Write-Host "⚙️  Configuração:" -ForegroundColor Yellow

Test-FileExists ".env.example" ".env.example"
Test-FileExists "pyproject.toml" "pyproject.toml"
Test-FileExists "setup.py" "setup.py"
Test-FileExists "MANIFEST.in" "MANIFEST.in"
Test-FileExists "requirements.txt" "requirements.txt"
Test-FileExists "requirements-dev.txt" "requirements-dev.txt"

# Verificar .env (deve existir mas não estar versionado)
if (Test-Path ".env") {
    $warnings += "⚠️  Arquivo .env existe (OK), mas certifique-se de que está no .gitignore"
} else {
    $warnings += "⚠️  Arquivo .env não existe. Copie de .env.example"
}

Write-Host ""

# -----------------------------------------------------------------------------
# 3. Docker
# -----------------------------------------------------------------------------
Write-Host "🐳 Docker:" -ForegroundColor Yellow

Test-FileExists "dockerfile" "dockerfile"
Test-FileExists ".dockerignore" ".dockerignore"
Test-FileExists "compose.yml" "compose.yml"
Test-FileExists "Makefile" "Makefile"

Write-Host ""

# -----------------------------------------------------------------------------
# 4. Qualidade de Código
# -----------------------------------------------------------------------------
Write-Host "🔍 Qualidade de Código:" -ForegroundColor Yellow

Test-FileExists ".gitignore" ".gitignore"
Test-FileExists ".pre-commit-config.yaml" ".pre-commit-config.yaml"
Test-FileExists ".github\workflows\ci.yml" "GitHub Actions CI/CD"

Write-Host ""

# -----------------------------------------------------------------------------
# 5. Código Fonte
# -----------------------------------------------------------------------------
Write-Host "🤖 Código Fonte:" -ForegroundColor Yellow

Test-FileExists "app.py" "app.py"
Test-FileExists "bot\ai_bot.py" "bot\ai_bot.py"
Test-FileExists "bot\link_router.py" "bot\link_router.py"
Test-FileExists "services\config.py" "services\config.py"
Test-FileExists "services\waha.py" "services\waha.py"
Test-FileExists "services\version.py" "services\version.py"
Test-FileExists "rag\load_knowledge.py" "rag\load_knowledge.py"

Write-Host ""

# -----------------------------------------------------------------------------
# 6. Testes
# -----------------------------------------------------------------------------
Write-Host "🧪 Testes:" -ForegroundColor Yellow

Test-FileExists "tests\test_ai_bot.py" "tests\test_ai_bot.py"
Test-FileExists "tests\test_health.py" "tests\test_health.py"
Test-FileExists "tests\test_waha.py" "tests\test_waha.py"

Write-Host ""

# -----------------------------------------------------------------------------
# 7. Scripts
# -----------------------------------------------------------------------------
Write-Host "🛠️  Scripts:" -ForegroundColor Yellow

$scripts = @(
    "scripts\up.ps1",
    "scripts\up-n8n.ps1",
    "scripts\load-knowledge.ps1",
    "scripts\test.ps1",
    "scripts\start-waha-session.ps1"
)

foreach ($script in $scripts) {
    Test-FileExists $script (Split-Path $script -Leaf)
}

Write-Host ""

# -----------------------------------------------------------------------------
# 8. Workflows n8n
# -----------------------------------------------------------------------------
Write-Host "🔄 Workflows n8n:" -ForegroundColor Yellow

Test-FileExists "n8n\workflows\chatbot_completo_orquestracao.json" "chatbot_completo_orquestracao.json"

Write-Host ""

# -----------------------------------------------------------------------------
# 9. Verificações Especiais
# -----------------------------------------------------------------------------
Write-Host "🔐 Verificações de Segurança:" -ForegroundColor Yellow

# Verificar se .env está no .gitignore
if (Get-Content .gitignore | Select-String -Pattern "^\.env$") {
    $success += "✅ .env está no .gitignore"
} else {
    $issues += "❌ CRÍTICO: .env NÃO está no .gitignore!"
}

# Verificar se chroma_data está no .gitignore
if (Get-Content .gitignore | Select-String -Pattern "chroma_data") {
    $success += "✅ chroma_data/ está no .gitignore"
} else {
    $issues += "❌ chroma_data/ não está no .gitignore"
}

# Verificar se logs está no .gitignore
if (Get-Content .gitignore | Select-String -Pattern "^logs/") {
    $success += "✅ logs/ está no .gitignore"
} else {
    $warnings += "⚠️  logs/ deveria estar no .gitignore"
}

Write-Host ""

# -----------------------------------------------------------------------------
# 10. Verificar Variáveis de Ambiente
# -----------------------------------------------------------------------------
Write-Host "🔑 Variáveis de Ambiente (.env.example):" -ForegroundColor Yellow

if (Test-Path ".env.example") {
    $envContent = Get-Content ".env.example" -Raw
    
    $requiredVars = @(
        "LLM_PROVIDER",
        "GROQ_API_KEY",
        "WAHA_API_URL",
        "WAHA_API_KEY",
        "PORT",
        "ENVIRONMENT"
    )
    
    foreach ($var in $requiredVars) {
        if ($envContent -match $var) {
            $success += "✅ $var definido em .env.example"
        } else {
            $issues += "❌ $var não encontrado em .env.example"
        }
    }
}

Write-Host ""

# -----------------------------------------------------------------------------
# Resumo Final
# -----------------------------------------------------------------------------
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "RESUMO DA VALIDAÇÃO" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host ""

if ($issues.Count -gt 0) {
    Write-Host "❌ PROBLEMAS CRÍTICOS ($($issues.Count)):" -ForegroundColor Red
    foreach ($issue in $issues) {
        Write-Host "   $issue" -ForegroundColor Red
    }
    Write-Host ""
}

if ($warnings.Count -gt 0) {
    Write-Host "⚠️  AVISOS ($($warnings.Count)):" -ForegroundColor Yellow
    foreach ($warning in $warnings) {
        Write-Host "   $warning" -ForegroundColor Yellow
    }
    Write-Host ""
}

Write-Host "✅ SUCESSOS ($($success.Count)):" -ForegroundColor Green
Write-Host "   Todos os itens essenciais estão presentes!" -ForegroundColor Green
Write-Host ""

# Estatísticas
$total = $issues.Count + $warnings.Count + $success.Count
$score = [math]::Round(($success.Count / $total) * 100, 1)

Write-Host "📊 PONTUAÇÃO: $score% ($($success.Count)/$total itens OK)" -ForegroundColor Cyan
Write-Host ""

if ($issues.Count -eq 0) {
    Write-Host "🎉 REPOSITÓRIO ESTÁ PRONTO PARA PRODUÇÃO!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Próximos passos:" -ForegroundColor Cyan
    Write-Host "1. Copie .env.example para .env e configure suas credenciais" -ForegroundColor White
    Write-Host "2. Execute: docker-compose up -d" -ForegroundColor White
    Write-Host "3. Carregue a base de conhecimento: .\scripts\load-knowledge.ps1" -ForegroundColor White
    Write-Host "4. Configure o n8n em http://localhost:5679" -ForegroundColor White
    Write-Host "5. Conecte o WhatsApp em http://localhost:3000" -ForegroundColor White
    exit 0
} else {
    Write-Host "⚠️  Corrija os problemas críticos antes do deploy!" -ForegroundColor Yellow
    exit 1
}
