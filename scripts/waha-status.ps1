param(
  [string]$WahaUrl = "http://localhost:3000",
  [string]$ApiKey = "tributos_nova_trento_2025_api_key_fixed"
)

$headers = @{ 'X-Api-Key' = $ApiKey }

try {
  $session = Invoke-RestMethod -Uri "$WahaUrl/api/sessions/default" -Headers $headers -Method GET -TimeoutSec 10
  Write-Host "Session: $($session.session)" -ForegroundColor Cyan
  Write-Host "Status : $($session.status)" -ForegroundColor Cyan
  if ($session.webhooks) {
    Write-Host "Webhook: $($session.webhooks[0].url)" -ForegroundColor DarkGray
  }
} catch {
  Write-Host "Failed to query WAHA session: $($_.Exception.Message)" -ForegroundColor Red
  if ($_.Exception.Response) {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $body = $reader.ReadToEnd()
    Write-Host $body
  }
  exit 1
}
