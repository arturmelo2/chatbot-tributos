param(
  [int]$WaitSeconds = 10,
  [switch]$AutoStart
)

Write-Host "Subindo stack (sem domínio)..." -ForegroundColor Cyan
$env:COMPOSE_HTTP_TIMEOUT = 240
. "$PSScriptRoot/_compose.ps1"
$compose = Get-ComposeCmd

# Sobe a stack de produção
& $compose -f (Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..')) 'compose.prod.yml') up -d
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Aguardando $WaitSeconds s para serviços inicializarem..." -ForegroundColor DarkGray
Start-Sleep -Seconds $WaitSeconds

# Health local
& "$PSScriptRoot/health-check-local.ps1"
$ok = $LASTEXITCODE -eq 0

# Dicas de próximos passos
Write-Host ""; Write-Host "Próximos passos:" -ForegroundColor Cyan
Write-Host "1) Conectar WAHA (uma vez) no servidor:" -ForegroundColor White
Write-Host "   - Abra no navegador do servidor: http://localhost:3000" -ForegroundColor Gray
Write-Host "   - Login: admin / Tributos@NovaTrento2025" -ForegroundColor Gray
Write-Host "   - Clique em 'Start Session' e escaneie o QR com o WhatsApp" -ForegroundColor Gray
Write-Host "2) Importar workflow no n8n: http://localhost:5679 (Workflows → Import from file)" -ForegroundColor White
Write-Host "3) Testar enviando mensagem para o número conectado." -ForegroundColor White

if ($AutoStart) {
  Write-Host "\nInstalando auto-start no boot (prod)..." -ForegroundColor Cyan
  pwsh -NoProfile -ExecutionPolicy Bypass -File "$PSScriptRoot/install-auto-start.ps1" -Mode prod -DelaySeconds 60
}

if ($ok) {
  Write-Host "\nTudo pronto! O chatbot está rodando localmente (sem domínio)." -ForegroundColor Green
  exit 0
} else {
  Write-Host "\nAlgum serviço não respondeu. Veja os logs:" -ForegroundColor Yellow
  Write-Host "   docker compose -f compose.prod.yml logs -f api|waha|n8n" -ForegroundColor DarkGray
  exit 1
}
