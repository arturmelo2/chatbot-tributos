# Post a WAHA-like message event to the n8n WAHA Trigger (Docker-only)
param(
  [string]$From = "554899999999@c.us",
  [string]$Body = "Teste via script",
  [string]$WebhookId = "8c0ac011-c46c-4c2c-bab1-ac5e0c3a365b",
  [switch]$NoSuffix
)

$payload = @{ event = 'message'; payload = @{ from = $From; body = $Body } } | ConvertTo-Json -Depth 5
$uri1 = "http://localhost:5679/webhook/$WebhookId/waha"
$uri2 = "http://localhost:5679/webhook/$WebhookId"

function Try-Post($url, $json) {
  Write-Host "POST $url" -ForegroundColor Cyan
  Write-Host $json
  try {
    $resp = Invoke-RestMethod -Uri $url -Method POST -ContentType 'application/json' -Body $json -TimeoutSec 15
    Write-Host "OK" -ForegroundColor Green
    $resp | ConvertTo-Json -Depth 5
    return $true
  } catch {
    Write-Host "Request failed: $($_.Exception.Message)" -ForegroundColor Yellow
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

if ($NoSuffix) {
  if (-not (Try-Post -url $uri2 -json $payload)) { exit 1 }
  exit 0
} else {
  if (Try-Post -url $uri1 -json $payload) { exit 0 }
  Write-Host "Trying without suffix..." -ForegroundColor DarkCyan
  if (Try-Post -url $uri2 -json $payload) { exit 0 }
  exit 1
}
