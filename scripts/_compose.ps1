# Shared helpers for Docker Compose usage across scripts

function Get-ComposeCmd {
  if (Get-Command docker -ErrorAction SilentlyContinue) {
    try {
      & docker compose version 1>$null 2>$null
      if ($LASTEXITCODE -eq 0) {
        return { param([Parameter(ValueFromRemainingArguments=$true)][string[]]$rest) & docker compose @rest }
      }
    } catch {}
  }
  if (Get-Command docker-compose -ErrorAction SilentlyContinue) {
    return { param([Parameter(ValueFromRemainingArguments=$true)][string[]]$rest) & docker-compose @rest }
  }
  throw 'Nem "docker compose" nem "docker-compose" encontrados no PATH.'
}
