# 🚀 Workflow Simplificado - Chatbot Tributos (Chamando API Python)

## ✅ **Esta é a versão RECOMENDADA!**

Usa a API Python que já está funcionando com RAG + ChromaDB + Groq.

---

## 📋 **Instruções para Importar no n8n**

### **1. Acesse http://localhost:5679**
- Login: `admin` / `Tributos@NovaTrento2025`

### **2. Clique em "..." → "Import from file"**

### **3. Cole este JSON abaixo:**

```json
{
  "name": "Chatbot Tributos - Simples (API Python)",
  "nodes": [
    {
      "parameters": {
        "httpMethod": "POST",
        "path": "94a8adfc-1dba-41e7-be61-4c13b51fa08e",
        "options": {}
      },
      "id": "webhook",
      "name": "Webhook WAHA",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 2,
      "position": [240, 300],
      "webhookId": "94a8adfc-1dba-41e7-be61-4c13b51fa08e"
    },
    {
      "parameters": {
        "conditions": {
          "string": [
            {
              "value1": "={{ $json.payload.from }}",
              "operation": "notContains",
              "value2": "@g.us"
            },
            {
              "value1": "={{ $json.payload.fromMe }}",
              "operation": "equal",
              "value2": "false"
            },
            {
              "value1": "={{ $json.payload.body }}",
              "operation": "isNotEmpty"
            }
          ]
        }
      },
      "id": "filter",
      "name": "Filtrar Mensagens",
      "type": "n8n-nodes-base.if",
      "typeVersion": 2,
      "position": [460, 300]
    },
    {
      "parameters": {
        "method": "POST",
        "url": "http://api:5000/chatbot/webhook/",
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            {
              "name": "Content-Type",
              "value": "application/json"
            }
          ]
        },
        "sendBody": true,
        "bodyParameters": {
          "parameters": []
        },
        "options": {
          "response": {
            "response": {
              "fullResponse": false,
              "responseFormat": "json"
            }
          }
        }
      },
      "id": "call-api",
      "name": "Chamar API Python",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [680, 300]
    },
    {
      "parameters": {
        "content": "## Webhook → Filtro → API Python\nWorkflow simples que delega todo processamento RAG para a API Python existente",
        "height": 80,
        "width": 520
      },
      "id": "note",
      "name": "Sticky Note",
      "type": "n8n-nodes-base.stickyNote",
      "typeVersion": 1,
      "position": [180, 180]
    }
  ],
  "connections": {
    "Webhook WAHA": {
      "main": [
        [
          {
            "node": "Filtrar Mensagens",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Filtrar Mensagens": {
      "main": [
        [
          {
            "node": "Chamar API Python",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  },
  "pinData": {},
  "settings": {
    "executionOrder": "v1"
  },
  "staticData": null,
  "tags": [],
  "triggerCount": 1
}
```

### **4. Salvar e Ativar**
- Clique em "Save"
- Ative o toggle (verde)

---

## 🔧 **Configurar WAHA**

Execute no PowerShell:

```powershell
# Parar sessão atual
curl -X POST "http://localhost:3000/api/sessions/default/stop" -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed"

# Iniciar com webhook correto
$body = '{"name":"default","config":{"webhooks":[{"url":"http://n8n:5678/webhook/94a8adfc-1dba-41e7-be61-4c13b51fa08e","events":["message"]}]}}'
curl -X POST "http://localhost:3000/api/sessions/start" -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed" -H "Content-Type: application/json" -d $body
```

---

## ✅ **Testar**

```powershell
# 1. Teste via webhook
$testPayload = '{"event":"message","payload":{"from":"5547999999999@c.us","body":"Como pagar IPTU?","fromMe":false}}'
curl -X POST "http://localhost:5679/webhook/94a8adfc-1dba-41e7-be61-4c13b51fa08e" -H "Content-Type: application/json" -d $testPayload

# 2. Ver execuções
Start-Process "http://localhost:5679"

# 3. Ver logs da API
docker compose logs -f api
```

---

## 🎯 **Vantagens desta Abordagem**

✅ **Simples**: Apenas 3 nodes no n8n  
✅ **Rápido**: Usa código Python existente  
✅ **Mantido**: API Python já tem RAG + ChromaDB + Groq funcionando  
✅ **Testado**: Base de conhecimento já carregada (65 docs, 461 chunks)  
✅ **Escalável**: Fácil adicionar mais lógica na API Python  

---

## 📊 **Fluxo de Dados**

```
WhatsApp → WAHA → n8n Webhook → Filtro → API Python (RAG) → n8n → WAHA → WhatsApp
```

**Processamento RAG acontece na API Python:**
1. Recebe mensagem
2. Busca no ChromaDB (similaridade semântica)
3. Monta contexto com documentos relevantes
4. Envia para Groq LLM
5. Retorna resposta
6. WAHA envia para WhatsApp

---

## 🆘 **Troubleshooting**

### Webhook não dispara
```powershell
# Verificar sessão WAHA
curl -s "http://localhost:3000/api/sessions/default" -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed"

# Deve mostrar webhook_url: http://n8n:5678/webhook/...
```

### API não responde
```powershell
# Testar diretamente
curl -X POST http://localhost:5000/chatbot/webhook/ -H "Content-Type: application/json" -d '{"event":"message","payload":{"from":"test@c.us","body":"teste","fromMe":false}}'
```

### Ver execuções n8n
```powershell
$token = "sua_api_key"
curl -s "http://localhost:5679/api/v1/executions?limit=10" -H "X-N8N-API-KEY: $token" | ConvertFrom-Json | Select-Object -ExpandProperty data | Format-Table
```

---

**Pronto! Workflow simples e funcional!** 🚀
