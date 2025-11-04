param()

Write-Host "Health check local (sem domínio) ..." -ForegroundColor Cyan

function Test-Endpoint {
  param([string]$Url)
  try {
    $resp = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec 8 -UseBasicParsing
    if ($resp.StatusCode -ge 200 -and $resp.StatusCode -lt 400) { return $true }
    return $false
  } catch { return $false }
}

$api  = Test-Endpoint "http://localhost:5000/health"
$waha = Test-Endpoint "http://localhost:3000"
$n8n  = Test-Endpoint "http://localhost:5679"

if ($api)  { Write-Host "✓ API OK   → http://localhost:5000/health" -ForegroundColor Green } else { Write-Host "✗ API OFF  → http://localhost:5000/health" -ForegroundColor Red }
if ($waha) { Write-Host "✓ WAHA OK  → http://localhost:3000" -ForegroundColor Green } else { Write-Host "✗ WAHA OFF → http://localhost:3000" -ForegroundColor Red }
if ($n8n)  { Write-Host "✓ n8n OK   → http://localhost:5679" -ForegroundColor Green } else { Write-Host "✗ n8n OFF  → http://localhost:5679" -ForegroundColor Red }

if ($api) { exit 0 } else { exit 1 }
