<#
.SYNOPSIS
  Remove a Tarefa Agendada que mantém o chatbot sempre rodando.

.DESCRIPTION
  Remove a tarefa "TributosChatbot-AutoStart" criada por install-auto-start.ps1.

.PARAMETER TaskName
  Nome da tarefa (padrão: TributosChatbot-AutoStart)
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param(
  [string]$TaskName = 'TributosChatbot-AutoStart'
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
  Write-Host "Tarefa '$TaskName' não encontrada. Nada a remover."
  exit 0
}

Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
Write-Host "✅ Tarefa '$TaskName' removida com sucesso."
