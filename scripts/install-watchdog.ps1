<#
.SYNOPSIS
  Instala tarefa agendada para executar o watchdog a cada N minutos.

.PARAMETER IntervalMinutes
  Intervalo em minutos entre execuções (padrão: 5)

.PARAMETER TaskName
  Nome da tarefa (padrão: TributosChatbot-Watchdog)
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param(
  [int]$IntervalMinutes = 5,
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

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot  = Resolve-Path (Join-Path $scriptDir '..')
$watchdog  = Join-Path $scriptDir 'watchdog.ps1'

if (-not (Test-Path $watchdog)) {
  Write-Error "watchdog.ps1 não encontrado em: $watchdog"
  exit 1
}

$pwsh = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
if (-not $pwsh) {
  Write-Error 'pwsh.exe (PowerShell 7+) não encontrado no PATH.'
  exit 1
}

# Ação: executar watchdog.ps1
$action = New-ScheduledTaskAction -Execute $pwsh -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$watchdog`"" -WorkingDirectory $repoRoot

# Gatilho: a cada N minutos, indefinidamente
$now = Get-Date
$trigger = New-ScheduledTaskTrigger -Once -At $now
$trigger.Repetition = New-ScheduledTaskRepetitionPattern -Interval (New-TimeSpan -Minutes $IntervalMinutes) -Duration (New-TimeSpan -Days 3650)

$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
$principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest

# Se existir, substituir
$existing = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($existing) { Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false }

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal | Out-Null

Write-Host "✅ Watchdog instalado: tarefa '$TaskName' a cada $IntervalMinutes min." -ForegroundColor Green
Write-Host "Logs em: $(Join-Path $repoRoot 'logs/watchdog.log')" -ForegroundColor DarkGray
