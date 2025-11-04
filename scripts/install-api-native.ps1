<#
Instala a API nativa como Tarefa Agendada do Windows (modo serviço).
 - Aciona no logon do usuário
 - Executa em background com privilégios elevados
#>
[CmdletBinding()]
param(
  [string]$TaskName = "TributosAPI-Native",
  [int]$Port = 5000
)

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $scriptDir
$runScript = Join-Path $scriptDir "run-api-native.ps1"

if (-not (Test-Path $runScript)) {
  throw "Script não encontrado: $runScript. Execute setup-api-native.ps1 primeiro."
}

# Comando para executar a API
$psExe = (Get-Command powershell.exe).Source
$arg = "-NoProfile -ExecutionPolicy Bypass -File `"$runScript`" -Port $Port"

# Ação e gatilhos
$action   = New-ScheduledTaskAction -Execute $psExe -Argument $arg -WorkingDirectory $root
$trigger1 = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest

# Registrar e iniciar
Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger1 -Principal $principal -Force | Out-Null
Start-ScheduledTask -TaskName $TaskName

Write-Host "[install] Tarefa '$TaskName' instalada e iniciada."
Write-Host "[install] A API subirá automaticamente a cada logon do usuário $($env:USERNAME)."
