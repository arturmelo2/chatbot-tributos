# 🔔 Configurar Webhook do WAHA (via n8n)

> Importante: não usar mais “webhook normal” apontando direto para a API. O padrão agora é WAHA → n8n (WAHA Trigger) → API.

---

## 📝 Passos para Configurar (Via Dashboard do WAHA)

### 1️⃣ Acessar Configuração da Sessão
1. Abrir: http://localhost:3000
2. Login: `admin` / `Tributos@NovaTrento2025`
3. Localizar sessão: **default** (5548920049848@c.us)
4. Click no nome da sessão para abrir configurações

### 2️⃣ Seção "🔄 Webhooks"
Alterar os seguintes campos:

**URL (n8n WAHA Trigger):**
```
http://n8n:5678/webhook/8c0ac011-c46c-4c2c-bab1-ac5e0c3a365b/waha
```

**Eventos:**
- ✅ Marcar apenas: `message`

**Tentativas repetidas:**
- **Tentativas:** `15`
- **Atraso, em segundos:** `2`

### 3️⃣ Salvar
1. Click no botão **"Salvar"** ou **"Save"**
2. Confirmar reinício da sessão (se perguntado)
3. Aguardar sessão voltar ao estado **TRABALHANDO**

---

## ✅ Verificar se Funcionou

### Teste 1: Enviar Mensagem pelo WhatsApp
1. Enviar mensagem para: **+55 48 9200-4984**
2. Texto: `Olá, preciso de informações sobre IPTU`
3. Bot deve responder em segundos

### Teste 2: Ver Logs
```powershell
# Acompanhar logs em tempo real
docker-compose logs -f api

# Você verá:
# 📨 Nova mensagem de 5548xxxxxxxxx@c.us: Olá...
# ✅ Resposta enviada para 5548xxxxxxxxx@c.us
```

---

## 🔧 Alternativa: Via API (Avançado)

Se preferir configurar via API em vez do dashboard, use o endpoint de sessões do WAHA apontando para o WAHA Trigger do n8n:

```powershell
# Parar sessão
curl -X POST `
  -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed" `
  http://localhost:3000/api/sessions/default/stop

# Aguardar 5 segundos
Start-Sleep -Seconds 5

# Iniciar com nova configuração (n8n WAHA Trigger)
$config = @{
  name = "default"
  config = @{
    webhooks = @(
      @{
        url = "http://n8n:5678/webhook/8c0ac011-c46c-4c2c-bab1-ac5e0c3a365b/waha"
        events = @("message", "session.status")
        retries = @{
          delaySeconds = 2
          attempts = 15
        }
      }
    )
  }
} | ConvertTo-Json -Depth 10

curl -X POST `
  -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed" `
  -H "Content-Type: application/json" `
  -d $config `
  http://localhost:3000/api/sessions/

# Aguardar sessão conectar novamente (escanear QR se necessário)
```

---

## 📊 Configuração Correta (Resumo)

| Campo | Valor Correto |
|-------|---------------|
| **URL** | `http://n8n:5678/webhook/8c0ac011-c46c-4c2c-bab1-ac5e0c3a365b/waha` |
| **Eventos** | `message` |
| **Tentativas** | `15` |
| **Atraso** | `2` segundos |

---

## ❓ Troubleshooting

### Webhook não recebe mensagens?
```powershell
# 1. Ver se webhook está configurado
curl -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed" \
     http://localhost:3000/api/sessions/default

# 2. Ver logs do WAHA
docker-compose logs --tail=50 waha | Select-String "webhook"

# 3. Testar endpoint do n8n diretamente (porta externa 5679)
$body = @{
  event = 'message'
  payload = @{
    from = '5511999999999@c.us'
    body = 'teste'
  }
} | ConvertTo-Json -Depth 3

Invoke-RestMethod -Uri "http://localhost:5679/webhook/8c0ac011-c46c-4c2c-bab1-ac5e0c3a365b/waha" `
  -Method POST `
  -ContentType "application/json" `
  -Body $body
```

### Erro 500 no webhook?
- Ver logs: `docker-compose logs --tail=100 api`
- Verificar se base de conhecimento está carregada
- Reiniciar API: `docker-compose restart api`

---

## 🎯 Depois de Configurar

Quando o webhook estiver correto (WAHA → n8n → API), **qualquer mensagem enviada para o WhatsApp conectado** será:

1. ✅ Recebida pelo WAHA
2. ✅ Enviada para o n8n (WAHA Trigger) e, de lá, para a API
3. ✅ Processada pelo bot (RAG + LLM)
4. ✅ Resposta enviada de volta pelo WhatsApp

---

**Status Atual:** ✅ Padrão: WAHA → n8n (WAHA Trigger) → API
**Ação Necessária:** Ativar o workflow no n8n e garantir que o `WHATSAPP_HOOK_URL` use o webhookId correto.
**Tempo Estimado:** ⏱️ 2 minutos

**Após configurar, o bot estará 100% funcional!** 🚀
