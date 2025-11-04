# 🎯 Guia Rápido: Validar Mensagem Real do WhatsApp

## ✅ O que já está funcionando

- WAHA Trigger está **capturando eventos** (você viu o `session.status: INICIANDO`)
- n8n está **recebendo** eventos do WAHA
- API está **respondendo 200 OK** aos POSTs do n8n

---

## 📋 Checklist Final (n8n)

### 1. Ativar o Workflow (Modo Produção)

**No n8n:**
- Clique no botão **"Ativo"** (toggle no canto superior direito)
- Quando ativo, o toggle fica **verde** ✅
- Isso habilita a URL de produção do webhook

**URL de Produção:**
```
http://n8n:5678/webhook/8c0ac011-c46c-4c2c-bab1-ac5e0c3a365b/waha
```

> ⚠️ **Importante:** O modo "teste" (`webhook-test`) só funciona quando você clica em "Ouvir Webhook". Para receber eventos automáticos do WAHA, o workflow deve estar **ATIVO** (modo produção).

---

## 📱 Testar com Mensagem Real

### Passo 1: Verificar WAHA
```powershell
& ./scripts/waha-status.ps1
```
**Esperado:** `Status: WORKING`

### Passo 2: Ativar Logs da API
```powershell
& ./scripts/logs-api.ps1
```
Deixe rodando em uma janela separada.

### Passo 3: Enviar Mensagem
**Do seu WhatsApp pessoal**, envie uma mensagem para o número conectado ao WAHA. Exemplo:
```
Olá, preciso de informações sobre IPTU
```

### Passo 4: Observar os Logs
Você deve ver na sequência:

1. **WAHA envia evento para n8n:**
   ```json
   {
     "event": "message",
     "payload": {
       "from": "5548xxxxxxxx@c.us",
       "body": "Olá, preciso de informações sobre IPTU",
       ...
     }
   }
   ```

2. **n8n encaminha para API** (nos logs):
   ```
   [INFO] __main__: ================================================================================
   [INFO] __main__: WEBHOOK PAYLOAD: {
     "event": "message",
     "payload": { ... }
   }
   [INFO] __main__: 📨 Nova mensagem de 5548xxxxxxxx@c.us: Olá, preciso...
   ```

3. **API processa e responde:**
   ```
   [INFO] __main__: ✅ Resposta enviada para 5548xxxxxxxx@c.us
   [INFO] werkzeug: 172.19.0.3 - - "POST /chatbot/webhook/ HTTP/1.1" 200 -
   ```

4. **WhatsApp recebe a resposta do bot**

---

## 🔍 Se Não Funcionar

### Verificar se workflow está ativo
No n8n, procure pelo ícone **verde "Ativo"** no topo.

### Verificar webhook no WAHA
```powershell
# Ver configuração atual
docker exec tributos_waha curl -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed" http://localhost:3000/api/sessions/default | ConvertFrom-Json | Select-Object -ExpandProperty webhooks
```
**Esperado:**
```json
{
  "url": "http://n8n:5678/webhook/8c0ac011-c46c-4c2c-bab1-ac5e0c3a365b/waha",
  "events": ["message", "session.status"]
}
```

### Reenviar configuração do webhook (se necessário)
Se o webhook estiver errado no WAHA:
```powershell
docker-compose down
docker-compose up -d
```

Isso reaplica as variáveis do `compose.yml`:
```yaml
WHATSAPP_HOOK_URL=http://n8n:5678/webhook/8c0ac011-c46c-4c2c-bab1-ac5e0c3a365b/waha
WHATSAPP_HOOK_EVENTS=message,session.status
```

---

## 📊 Teste Sintético (Opcional)

Se quiser simular um evento `message` sem enviar pelo WhatsApp:

```powershell
& ./scripts/test-n8n-webhook.ps1 -From '5548999999999@c.us' -Body 'Teste de mensagem sintética'
```

**Importante:** Esse teste envia para a URL do n8n, então:
- Se workflow estiver **ativo**, você verá logs na API
- Se estiver em modo **teste**, precisa clicar "Ouvir Webhook" antes

---

## ✅ Validação Completa

Quando tudo estiver OK, você verá:

1. ✅ Mensagem enviada do WhatsApp
2. ✅ WAHA captura e envia para n8n
3. ✅ n8n filtra (`event=message`) e POST na API
4. ✅ API processa com RAG + LLM
5. ✅ API envia resposta via WAHA
6. ✅ WhatsApp recebe a resposta do bot

---

## 🎓 Arquitetura (Fluxo Completo)

```
WhatsApp (seu celular)
    ↓ "Olá, IPTU?"
WAHA (container tributos_waha)
    ↓ webhook HTTP
n8n WAHA Trigger (8c0ac011...)
    ↓ IF event=message
n8n HTTP Request
    ↓ POST http://api:5000/chatbot/webhook/
API Flask (container tributos_api)
    ↓ RAG (Chroma) + LLM (xAI/Groq)
    ↓ waha.send_message()
WAHA
    ↓
WhatsApp (resposta do bot)
```

---

**Última atualização:** 03/Nov/2025 23:15 BRT
