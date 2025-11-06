# Test minimal stack webhook
param(
    [string]$Url = "http://localhost:5000/webhook",
    [string]$From = "5511999999999",
    [string]$Message = "Olá, teste do webhook!"
)

Write-Host "Testing minimal stack webhook..." -ForegroundColor Cyan
Write-Host "URL: $Url" -ForegroundColor Gray
Write-Host "From: $From" -ForegroundColor Gray
Write-Host "Message: $Message" -ForegroundColor Gray
Write-Host ""

# Test payload (WhatsApp Cloud API format)
$payload = @{
    entry = @(
        @{
            changes = @(
                @{
                    value = @{
                        messages = @(
                            @{
                                from = $From
                                text = @{
                                    body = $Message
                                }
                            }
                        )
                    }
                }
            )
        }
    )
} | ConvertTo-Json -Depth 10

Write-Host "Payload:" -ForegroundColor Yellow
Write-Host $payload -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri $Url -Method POST -Body $payload -ContentType "application/json"
    Write-Host "✅ Success!" -ForegroundColor Green
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor White
    Write-Host "Response: $($response.Content)" -ForegroundColor White
} catch {
    Write-Host "❌ Error!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Red
    }
}
