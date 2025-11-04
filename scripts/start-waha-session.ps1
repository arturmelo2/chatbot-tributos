param(
  [string]$WahaUrl = "http://localhost:3000",
  [string]$ApiKey = "tributos_nova_trento_2025_api_key_fixed"
)

$headers = @{ 'X-Api-Key' = $ApiKey; 'Content-Type' = 'application/json' }

function Try-Start {
  param([string]$Url)
  try {
    Write-Host "POST $Url" -ForegroundColor Cyan
    $resp = Invoke-RestMethod -Uri $Url -Headers $headers -Method POST -TimeoutSec 15 -ErrorAction Stop
    $resp | ConvertTo-Json -Depth 5
    return $true
  } catch {
    Write-Host "Start endpoint failed: $($_.Exception.Message)" -ForegroundColor Yellow
    if ($_.Exception.Response) {
      $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
      $reader.BaseStream.Position = 0
      $reader.DiscardBufferedData()
      $body = $reader.ReadToEnd()
      Write-Host $body
    }
    return $false
  }
}

$ok = $false
$ok = $ok -or (Try-Start -Url "$WahaUrl/api/sessions/default/start")
if (-not $ok) { $ok = $ok -or (Try-Start -Url "$WahaUrl/api/sessions/start?session=default") }

Write-Host "Start requested. Now check status:" -ForegroundColor Green
& "$PSScriptRoot/waha-status.ps1" -WahaUrl $WahaUrl -ApiKey $ApiKey
