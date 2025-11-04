#!/usr/bin/env pwsh
<#
.SYNOPSIS
Remove volumes e arquivos do Prometheus e Grafana que não são mais utilizados.

.DESCRIPTION
Script para limpar volumes Docker e arquivos de configuração do Prometheus/Grafana
após a remoção desses serviços do projeto.

.EXAMPLE
./scripts/cleanup-observabilidade.ps1
#>

$ErrorActionPreference = "Stop"

Write-Host "🧹 Limpeza de Prometheus e Grafana" -ForegroundColor Cyan
Write-Host "=" * 80

# Parar containers se estiverem rodando
Write-Host "`n📦 Parando containers..." -ForegroundColor Yellow
docker stop tributos_prometheus tributos_grafana 2>$null
docker rm tributos_prometheus tributos_grafana 2>$null

# Remover volumes
Write-Host "`n🗑️  Removendo volumes Docker..." -ForegroundColor Yellow
docker volume rm whatsapp-ai-chatbot_prometheus_data 2>$null
docker volume rm whatsapp-ai-chatbot_grafana_data 2>$null

# Remover diretórios
Write-Host "`n📁 Removendo diretórios..." -ForegroundColor Yellow

$dirs = @(
    "grafana",
    "prometheus.yml"
)

foreach ($dir in $dirs) {
    $path = Join-Path $PSScriptRoot "..\$dir"
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force
        Write-Host "   ✅ Removido: $dir" -ForegroundColor Green
    } else {
        Write-Host "   ⏭️  Não encontrado: $dir" -ForegroundColor Gray
    }
}

Write-Host "`n✅ Limpeza concluída!" -ForegroundColor Green
Write-Host "`nPrometheus e Grafana foram removidos do projeto." -ForegroundColor Cyan
Write-Host "Os logs estruturados continuam disponíveis para monitoramento.`n" -ForegroundColor Cyan
