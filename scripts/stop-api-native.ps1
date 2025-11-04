[CmdletBinding()]
param(
  [string]$TaskName = "TributosAPI-Native"
)

$ErrorActionPreference = 'Stop'

if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
  Stop-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue | Out-Null
  Write-Host "[stop] Tarefa '$TaskName' parada."
} else {
  # Tentativa de matar waitress por porta 5000 (ou padrão)
  $conns = netstat -ano | Select-String ":5000" | ForEach-Object { ($_ -split "\s+")[-1] } | Sort-Object -Unique
  foreach ($procId in $conns) { try { Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue } catch {} }
  Write-Host "[stop] Nenhuma tarefa agendada encontrada; processos em :5000 interrompidos (se havia)."
}
