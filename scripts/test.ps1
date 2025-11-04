param([switch]$LintOnly)

Write-Host "Running tests/lint..." -ForegroundColor Cyan

# Prefer venv if available
$python = "python"
if (Test-Path ".venv/Scripts/python.exe") { $python = ".venv/Scripts/python.exe" }

if (-not $LintOnly) {
  & $python -m pip install -r requirements-dev.txt | Out-Null
}

# Ruff
try { & ruff --version | Out-Null } catch { & $python -m pip install ruff | Out-Null }
& ruff check .

# Black (check only)
try { & black --version | Out-Null } catch { & $python -m pip install black | Out-Null }
& black --check .

if (-not $LintOnly) {
  # Pytest
  try { & pytest --version | Out-Null } catch { & $python -m pip install pytest | Out-Null }
  & pytest -q
}

Write-Host "Done." -ForegroundColor Green
