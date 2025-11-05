param(
  [string]$WahaUrl = "http://localhost:3000",
  [string]$ApiKey = "tributos_nova_trento_2025_api_key_fixed",
  [string]$NewWebhookUrl = "http://n8n:5678/webhook/94a8adfc-1dba-41e7-be61-4c13b51fa08e"
)

$headers = @{ 
  'X-Api-Key' = $ApiKey
  'Content-Type' = 'application/json'
}

Write-Host "Step 1: Stopping session..." -ForegroundColor Cyan
try {
  Invoke-RestMethod -Uri "$WahaUrl/api/sessions/default/stop" -Headers $headers -Method POST -TimeoutSec 10 | Out-Null
  Write-Host "Session stopped." -ForegroundColor Green
} catch {
  Write-Host "Warning: Could not stop session (may already be stopped)" -ForegroundColor Yellow
}

Start-Sleep -Seconds 3

Write-Host "`nStep 2: Starting session with new webhook: $NewWebhookUrl" -ForegroundColor Cyan
$startPayload = @{
  config = @{}
  webhooks = @(
    @{
      url = $NewWebhookUrl
      events = @("message", "session.status")
    }
  )
} | ConvertTo-Json -Depth 5

Write-Host $startPayload

try {
  $resp = Invoke-RestMethod -Uri "$WahaUrl/api/sessions/default/start" -Headers $headers -Method POST -Body $startPayload -TimeoutSec 15
  Write-Host "`nSession started successfully!" -ForegroundColor Green
  $resp | ConvertTo-Json -Depth 3
  Write-Host "`nWait ~10 seconds for QR scan, then check status with waha-status.ps1" -ForegroundColor Yellow
} catch {
  Write-Host "`nFailed to start session: $($_.Exception.Message)" -ForegroundColor Red
  if ($_.Exception.Response) {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $body = $reader.ReadToEnd()
    Write-Host $body
  }
  exit 1
}
