param(
  [Parameter(Mandatory=$true)][string]$Domain
)

Write-Host "Health check em https://$Domain ..." -ForegroundColor Cyan

function Test-Endpoint($url) {
  try {
    $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    return @{ ok = $true; status = $resp.StatusCode; body = $resp.Content }
  } catch {
    return @{ ok = $false; error = $_.Exception.Message }
  }
}

$api = Test-Endpoint "https://$Domain/api/health"
if ($api.ok) { Write-Host "API OK ($($api.status))" -ForegroundColor Green } else { Write-Host "API FAIL: $($api.error)" -ForegroundColor Red }

$waha = Test-Endpoint "https://$Domain/waha"
if ($waha.ok) { Write-Host "WAHA OK ($($waha.status))" -ForegroundColor Green } else { Write-Host "WAHA FAIL: $($waha.error)" -ForegroundColor Yellow }

$n8n = Test-Endpoint "https://$Domain/n8n"
if ($n8n.ok) { Write-Host "n8n OK ($($n8n.status))" -ForegroundColor Green } else { Write-Host "n8n FAIL: $($n8n.error)" -ForegroundColor Yellow }

if (-not $api.ok) { exit 1 } else { exit 0 }
