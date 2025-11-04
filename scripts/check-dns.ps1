param(
  [Parameter(Mandatory=$true)][string]$Domain,
  [string]$ExpectedIP
)

Write-Host "Resolvendo DNS para $Domain ..." -ForegroundColor Cyan
try {
  $records = Resolve-DnsName -Name $Domain -Type A -ErrorAction Stop | Select-Object -ExpandProperty IPAddress
} catch {
  Write-Host "Falha ao resolver A: $($_.Exception.Message)" -ForegroundColor Red
  $records = @()
}
try {
  $recordsAAAA = Resolve-DnsName -Name $Domain -Type AAAA -ErrorAction Stop | Select-Object -ExpandProperty IPAddress
} catch { $recordsAAAA = @() }

if ($records.Count -eq 0 -and $recordsAAAA.Count -eq 0) {
  Write-Host "Nenhum registro A/AAAA encontrado." -ForegroundColor Yellow
  exit 1
}

Write-Host "A:    $($records -join ', ')" -ForegroundColor Green
if ($recordsAAAA.Count -gt 0) { Write-Host "AAAA: $($recordsAAAA -join ', ')" -ForegroundColor Green }

if ($ExpectedIP) {
  if ($records -contains $ExpectedIP -or $recordsAAAA -contains $ExpectedIP) {
    Write-Host "OK: IP esperado presente ($ExpectedIP)." -ForegroundColor Green
    exit 0
  } else {
    Write-Host "ATENÇÃO: IP esperado ($ExpectedIP) não encontrado nos registros." -ForegroundColor Yellow
    exit 2
  }
}
exit 0
