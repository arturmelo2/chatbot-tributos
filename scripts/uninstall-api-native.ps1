[CmdletBinding()]
param(
  [string]$TaskName = "TributosAPI-Native"
)

$ErrorActionPreference = 'Stop'

if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
  try {
    Stop-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue | Out-Null
  } catch {}
  Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
  Write-Host "[uninstall] Tarefa '$TaskName' removida."
} else {
  Write-Host "[uninstall] Tarefa '$TaskName' não encontrada."
}
