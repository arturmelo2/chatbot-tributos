#!/usr/bin/env pwsh
# Validation script - Check repository structure after refactoring

Write-Host "🔍 Validating Repository Structure..." -ForegroundColor Cyan

$errors = @()
$warnings = @()
$success = @()

# Check essential directories
$requiredDirs = @(
    'bot',
    'services', 
    'rag',
    'tests',
    'scripts',
    'docs',
    'n8n/workflows',
    'reverse-proxy'
)

foreach ($dir in $requiredDirs) {
    if (Test-Path $dir) {
        $success += "✅ Directory exists: $dir"
    } else {
        $errors += "❌ Missing directory: $dir"
    }
}

# Check essential files in root
$requiredRootFiles = @(
    'README.md',
    'START-HERE.md',
    'ARCHITECTURE.md',
    'DEVELOPMENT.md',
    'CONTRIBUTING.md',
    'CHANGELOG.md',
    'LICENSE',
    'Makefile',
    'compose.yml',
    '.env.example',
    'pyproject.toml'
)

foreach ($file in $requiredRootFiles) {
    if (Test-Path $file) {
        $success += "✅ Essential file exists: $file"
    } else {
        $errors += "❌ Missing essential file: $file"
    }
}

# Check refactoring artifacts
$refactorFiles = @(
    'REFACTORING.md',
    'REFACTORING-SUMMARY.md',
    'docs/INDEX.md',
    'reverse-proxy/traefik.yml',
    'reverse-proxy/acme.json',
    'scripts/wait-for.sh',
    'scripts/load-knowledge.sh'
)

foreach ($file in $refactorFiles) {
    if (Test-Path $file) {
        $success += "✅ Refactor artifact exists: $file"
    } else {
        $warnings += "⚠️  Missing refactor artifact: $file"
    }
}

# Check for unwanted duplicates
$unwantedFiles = @(
    '.env.minimal.example',
    '.env.production.example',
    'compose.minimal.yml',
    'compose.prod.caddy.yml',
    'QUICK-START.bat',
    'QUICK-START.ps1'
)

foreach ($file in $unwantedFiles) {
    if (Test-Path $file) {
        $errors += "❌ Duplicate file should be removed: $file"
    } else {
        $success += "✅ Duplicate removed: $file"
    }
}

# Check unwanted caches
$unwantedDirs = @(
    '.mypy_cache',
    '.pytest_cache',
    '.ruff_cache',
    '.venv-2'
)

foreach ($dir in $unwantedDirs) {
    if (Test-Path $dir) {
        $warnings += "⚠️  Cache directory exists (should be in .gitignore): $dir"
    } else {
        $success += "✅ Cache cleaned: $dir"
    }
}

# Display results
Write-Host "`n📊 Validation Results:" -ForegroundColor Yellow
Write-Host "=====================`n" -ForegroundColor Yellow

if ($success.Count -gt 0) {
    Write-Host "✅ SUCCESS ($($success.Count)):" -ForegroundColor Green
    $success | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    Write-Host ""
}

if ($warnings.Count -gt 0) {
    Write-Host "⚠️  WARNINGS ($($warnings.Count)):" -ForegroundColor Yellow
    $warnings | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
    Write-Host ""
}

if ($errors.Count -gt 0) {
    Write-Host "❌ ERRORS ($($errors.Count)):" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    Write-Host ""
    Write-Host "❌ Validation FAILED" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✅ Validation PASSED!" -ForegroundColor Green
    Write-Host "`nRepository structure is correct.`n" -ForegroundColor Cyan
    exit 0
}
