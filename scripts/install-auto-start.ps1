<#
.SYNOPSIS
  Instala uma Tarefa Agendada para manter o chatbot sempre rodando (Docker Compose).

.DESCRIPTION
  Cria a tarefa "TributosChatbot-AutoStart" que executa o script ./scripts/up.ps1
  a cada inicialização do Windows, com atraso para aguardar o Docker Desktop iniciar.
  A tarefa é executada com privilégios elevados sob a conta SYSTEM.

.NOTES
  - Requer PowerShell 7+ (pwsh)
  - Requer permissão de administrador para registrar a tarefa sob a conta SYSTEM
  - Os containers têm restart: unless-stopped, então irão reiniciar após o Docker subir

.PARAMETER DelaySeconds
  Atraso em segundos antes de executar (padrão: 60)

.PARAMETER TaskName
  Nome da tarefa (padrão: TributosChatbot-AutoStart)
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param(
  [int]$DelaySeconds = 60,
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

# Resolve caminhos
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot  = Resolve-Path (Join-Path $scriptDir '..')
$upScript  = Join-Path $repoRoot 'scripts' | Join-Path -ChildPath 'up.ps1'

if (-not (Test-Path $upScript)) {
  Write-Error "Não encontrei o script up.ps1 em: $upScript"
  exit 1
}

# Localiza pwsh.exe completo
$pwsh = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
if (-not $pwsh) {
  Write-Error 'pwsh.exe (PowerShell 7+) não encontrado no PATH.'
  exit 1
}

$sleepArg = if ($DelaySeconds -gt 0) { "Start-Sleep -Seconds $DelaySeconds; " } else { '' }
$escapedUp = $upScript.Replace('`', '``').Replace('"', '\"')
$command = "$sleepArg& `\"$escapedUp`\""

$action = New-ScheduledTaskAction \
  -Execute $pwsh \
  -Argument "-NoProfile -ExecutionPolicy Bypass -Command $command" \
  -WorkingDirectory $repoRoot

# Dispara ao iniciar o sistema, com atraso
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet \
  -StartWhenAvailable \
  -ExecutionTimeLimit (New-TimeSpan -Minutes 30) \
  -RestartCount 3 \
  -RestartInterval (New-TimeSpan -Minutes 2)

# Executa com privilégios elevados como SYSTEM
$principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest

# Se já existir, remover e recriar para garantir idempotência
$existing = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($existing) {
  Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

# Cria a tarefa
Register-ScheduledTask \
  -TaskName $TaskName \
  -Action $action \
  -Trigger $trigger \
  -Settings $settings \
  -Principal $principal \
  | Out-Null

# Definimos o atraso via Start-Sleep embutido no comando (-DelaySeconds)

Write-Host "✅ Tarefa '$TaskName' instalada com sucesso."
Write-Host "- Vai rodar no boot executando: $upScript"
Write-Host "- WorkingDir: $repoRoot"
Write-Host "Dica: Ajuste o delay usando o parâmetro -DelaySeconds (opcional); ou configure o Docker Desktop para iniciar com o Windows."
