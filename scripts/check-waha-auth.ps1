param(
  [string]$WahaUrl = "http://localhost:3000",
  [string]$ApiKey = "tributos_nova_trento_2025_api_key_fixed",
  [int]$Limit = 5
)

$headers = @{ 'X-Api-Key' = $ApiKey }

Write-Host "Checking WAHA (auth) at $WahaUrl ..." -ForegroundColor Cyan

function Try-Get {
  param([string]$Url)
  try {
    return Invoke-RestMethod -Uri $Url -Headers $headers -Method GET -TimeoutSec 10 -UseBasicParsing
  } catch {
    return $null
  }
}

# 1) Session status
$session = Try-Get "$WahaUrl/api/sessions/default"
if ($session) {
  Write-Host "Session: $($session.session)" -ForegroundColor Green
  Write-Host "Status : $($session.status)" -ForegroundColor Green
} else {
  Write-Host "Failed to get session status (auth)." -ForegroundColor Red
}

# 2) Chats (fallback across possible endpoints)
$chatCandidates = @(
  "$WahaUrl/api/default/chats?limit=$Limit",
  "$WahaUrl/api/chats?session=default&limit=$Limit",
  "$WahaUrl/api/sessions/default/chats?limit=$Limit"
)

$chats = $null
foreach ($u in $chatCandidates) {
  $r = Try-Get $u
  if ($r) { $chats = $r; break }
}

if ($chats) {
  if ($chats -is [System.Collections.IEnumerable]) {
    $count = @($chats).Count
    Write-Host "Chats: $count (showing up to $Limit)" -ForegroundColor Green
    $chats | Select-Object -First $Limit | ConvertTo-Json -Depth 3 | Write-Output
  } elseif ($chats.PSObject.Properties["result"]) {
    $arr = $chats.result
    $count = @($arr).Count
    Write-Host "Chats: $count (from result)" -ForegroundColor Green
    $arr | Select-Object -First $Limit | ConvertTo-Json -Depth 3 | Write-Output
  } else {
    Write-Host "Chats returned in unexpected format:" -ForegroundColor Yellow
    $chats | ConvertTo-Json -Depth 3 | Write-Output
  }
} else {
  Write-Host "Failed to fetch chats (auth)." -ForegroundColor Yellow
}
