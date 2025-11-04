# Export WAHA conversations for the last N months to JSONL (Docker-only)
param(
  [int]$Months = 6,
  [int]$ChatsLimit = 1000,
  [int]$MsgsLimit = 5000,
  [switch]$IncludeGroups
)

$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$out = "/app/exports/waha_history_${ts}.jsonl"

$cmd = @('python','tools/export_waha_history.py',"--months",$Months,"--out",$out,"--chats-limit",$ChatsLimit,"--msgs-limit",$MsgsLimit)
if ($IncludeGroups) { $cmd += '--include-groups' }

Write-Host "Exporting history..." -ForegroundColor Cyan
Write-Host ($cmd -join ' ')

. "$PSScriptRoot/_compose.ps1"
$compose = Get-ComposeCmd
& $compose exec api @cmd
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Export done. File (inside container): $out" -ForegroundColor Green
Write-Host "On host, check ./exports/ for the file." -ForegroundColor Green
