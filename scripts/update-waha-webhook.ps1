param(
  [string]$WahaUrl = "http://localhost:3000",
  [string]$ApiKey = "tributos_nova_trento_2025_api_key_fixed",
  [string]$WebhookUrl = "http://n8n:5678/webhook/8c0ac011-c46c-4c2c-bab1-ac5e0c3a365b/waha",
  [string[]]$Events = @("message", "session.status")
)

$headers = @{ 
  'X-Api-Key' = $ApiKey
  'Content-Type' = 'application/json'
}

$payload = @{
  webhooks = @(
    @{
      url = $WebhookUrl
      events = $Events
      hmac = $null
      retries = $null
      customHeaders = $null
    }
  )
} | ConvertTo-Json -Depth 5

Write-Host "Updating WAHA webhook to: $WebhookUrl" -ForegroundColor Cyan
Write-Host $payload

try {
  $resp = Invoke-RestMethod -Uri "$WahaUrl/api/sessions/default" -Headers $headers -Method PATCH -Body $payload -TimeoutSec 15
  Write-Host "Webhook updated successfully!" -ForegroundColor Green
  $resp | ConvertTo-Json -Depth 5
  Write-Host "`nSession will restart. Wait a few seconds and check status with waha-status.ps1" -ForegroundColor Yellow
} catch {
  Write-Host "Failed to update webhook: $($_.Exception.Message)" -ForegroundColor Red
  if ($_.Exception.Response) {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $body = $reader.ReadToEnd()
    Write-Host $body
  }
  exit 1
}
