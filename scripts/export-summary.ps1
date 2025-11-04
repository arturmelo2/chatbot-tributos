param([int]$Count = 5)

$files = Get-ChildItem -Path ./exports -File | Sort-Object LastWriteTime -Descending | Select-Object -First $Count
if (-not $files) {
  Write-Host "Nenhum arquivo em ./exports" -ForegroundColor Yellow
  exit 0
}

$result = @()
foreach ($f in $files) {
  try {
    $lines = (Get-Content -Path $f.FullName | Measure-Object -Line).Lines
  } catch {
    $lines = 0
  }
  $result += [PSCustomObject]@{
    Nome = $f.Name
    TamanhoBytes = $f.Length
    Linhas = $lines
    ModificadoEm = $f.LastWriteTime
  }
}

$result | Format-Table -AutoSize
