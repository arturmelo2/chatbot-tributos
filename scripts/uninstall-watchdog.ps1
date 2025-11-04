[CmdletBinding(SupportsShouldProcess=$true)]
param(
  [string]$TaskName = 'TributosChatbot-Watchdog'
)

function Assert-Admin {
  $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
  if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error 'Este script precisa ser executado como Administrador.'
    exit 1
  }
}

Assert-Admin

$existing = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if (-not $existing) {
  Write-Host "Tarefa '$TaskName' não encontrada. Nada a remover." -ForegroundColor Yellow
  exit 0
}

Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
Write-Host "✅ Watchdog removido: '$TaskName'" -ForegroundColor Green
