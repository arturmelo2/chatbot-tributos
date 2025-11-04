# Post a WAHA-like message event to the n8n WAHA Trigger (Docker-only)
param(
  [string]$From = "554899999999@c.us",
  [string]$Body = "Teste via script",
  [string]$WebhookId = "8c0ac011-c46c-4c2c-bab1-ac5e0c3a365b"
)

$payload = @{ event = 'message'; payload = @{ from = $From; body = $Body } } | ConvertTo-Json -Depth 5
$uri = "http://localhost:5679/webhook/$WebhookId/waha"

Write-Host "POST $uri" -ForegroundColor Cyan
Write-Host $payload

try {
  $resp = Invoke-RestMethod -Uri $uri -Method POST -ContentType 'application/json' -Body $payload -TimeoutSec 10
  Write-Host "OK" -ForegroundColor Green
  $resp | ConvertTo-Json -Depth 5
} catch {
  Write-Host "Request failed: $($_.Exception.Message)" -ForegroundColor Red
  if ($_.Exception.Response) {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $body = $reader.ReadToEnd()
    Write-Host $body
  }
  exit 1
}
