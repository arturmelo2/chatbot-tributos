param(
  [string]$From = "554899999999@c.us",
  [string]$Body = "Teste via API webhook",
  [string]$Url = "http://localhost:5000/chatbot/webhook/",
  [int]$TimeoutSec = 60
)

$payload = @{ event = 'message'; payload = @{ from = $From; body = $Body } } | ConvertTo-Json -Depth 5
Write-Host "POST $Url" -ForegroundColor Cyan
Write-Host $payload

try {
  $resp = Invoke-RestMethod -Uri $Url -Method POST -ContentType 'application/json' -Body $payload -TimeoutSec $TimeoutSec
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
