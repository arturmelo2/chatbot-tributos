[CmdletBinding()]
param(
  [int]$Port = 5000
)

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$runScript = Join-Path $scriptDir "run-api-native.ps1"

if (-not (Test-Path $runScript)) { throw "run-api-native.ps1 não encontrado. Rode setup-api-native.ps1" }

Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$runScript`" -Port $Port" -WindowStyle Hidden
Write-Host "[start] API iniciada em background (porta $Port)."
