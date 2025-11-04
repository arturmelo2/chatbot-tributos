param(
  [Parameter(Mandatory=$true)][string]$Plaintext
)

Write-Host "Generating Caddy bcrypt hash..." -ForegroundColor Cyan
docker run --rm caddy:2-alpine caddy hash-password --plaintext "$Plaintext"

Write-Host "Use the output as *_PASSWORD_HASH in .env (e.g., N8N_PASSWORD_HASH)." -ForegroundColor Green
