# 🚀 Guia: Criar Chatbot RAG no n8n

## 📋 **Passo a Passo Completo**

### **1. Acesse o n8n**
- URL: http://localhost:5679
- Login: `admin` / `Tributos@NovaTrento2025`

---

### **2. Criar Novo Workflow**
1. Clique em **"+ Add workflow"** (canto superior direito)
2. Nome: **"Chatbot RAG Tributos"**

---

### **3. Adicionar Nodes (arrastar da barra lateral)**

#### **Node 1: Webhook** (receber mensagens do WAHA)
- Type: `Webhook`
- HTTP Method: `POST`
- Path: `94a8adfc-1dba-41e7-be61-4c13b51fa08e`
- Respond: `Immediately`

#### **Node 2: IF** (filtrar mensagens)
- Conectar ao Webhook
- Conditions:
  - `{{ $json.payload.from }}` **does not contain** `@g.us`
  - `{{ $json.payload.fromMe }}` **equals** `false`

#### **Node 3: Code** (preparar dados)
- Conectar ao IF (ramo TRUE)
- Code:
```javascript
const chatId = $input.item.json.payload.from;
const messageText = $input.item.json.payload.body || '';

return {
  chatId: chatId,
  question: messageText,
  timestamp: Date.now()
};
```

#### **Node 4: HTTP Request** (iniciar typing)
- Conectar ao Code
- Method: `POST`
- URL: `http://waha:3000/api/default/typing`
- Authentication: Header Auth
  - Name: `X-Api-Key`
  - Value: `tributos_nova_trento_2025_api_key_fixed`
- Body JSON:
```json
{
  "chatId": "{{ $json.chatId }}",
  "isTyping": true
}
```

#### **Node 5: AI Agent** (RAG principal)
- Conectar ao Code
- Agent Type: `Tools Agent`
- System Message:
```
Você é um assistente especializado em tributos municipais de Nova Trento/SC. 
Use APENAS as informações da base de conhecimento para responder. 
Se não souber, diga que não tem informação suficiente. 
Seja claro, objetivo e cite a fonte.
```

#### **Node 6: Groq Chat Model** (LLM principal)
- Conectar ao AI Agent (entrada "Chat Model")
- Credentials: Sua conta Groq
- Model: `llama-3.3-70b-versatile`
- Temperature: `0.3`
- Max Tokens: `1000`

#### **Node 7: Window Buffer Memory** (memória de conversa)
- Conectar ao AI Agent (entrada "Memory")
- Context Window Length: `10`

#### **Node 8: Vector Store Tool** (ferramenta de busca)
- Conectar ao AI Agent (entrada "Tool")
- Name: `Base_Conhecimento_Tributos`
- Description:
```
Use esta ferramenta para buscar informações sobre tributos municipais, 
leis, procedimentos, FAQs e manuais de Nova Trento/SC.
```
- Top K: `5`

#### **Node 9: HTTP Request** (conexão ChromaDB)
- Conectar ao Vector Store Tool (entrada "Vector Store")
- Method: `POST`
- URL: `http://api:5000/rag/query`
- Body JSON:
```json
{
  "query": "{{ $json.question }}",
  "k": 5
}
```

#### **Node 10: Code** (formatar resposta)
- Conectar ao AI Agent (saída)
- Code:
```javascript
const response = $input.item.json.output;
const chatId = $input.item.json.chatId;

return {
  chatId: chatId,
  response: response
};
```

#### **Node 11: HTTP Request** (enviar WhatsApp)
- Conectar ao Code
- Method: `POST`
- URL: `http://waha:3000/api/sendText`
- Authentication: Header Auth
  - Name: `X-Api-Key`
  - Value: `tributos_nova_trento_2025_api_key_fixed`
- Body JSON:
```json
{
  "chatId": "{{ $json.chatId }}",
  "text": "{{ $json.response }}",
  "session": "default"
}
```

#### **Node 12: HTTP Request** (parar typing)
- Conectar ao Code
- Method: `POST`
- URL: `http://waha:3000/api/default/typing`
- Authentication: Header Auth
  - Name: `X-Api-Key`
  - Value: `tributos_nova_trento_2025_api_key_fixed`
- Body JSON:
```json
{
  "chatId": "{{ $json.chatId }}",
  "isTyping": false
}
```

---

### **4. Ativar Workflow**
1. Clique no toggle no canto superior direito
2. Deve ficar **VERDE** ("Active")

---

### **5. Configurar WAHA Webhook**
Execute no PowerShell:
```powershell
curl -X POST "http://localhost:3000/api/sessions/default/stop" -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed"

$body = '{"name":"default","config":{"webhooks":[{"url":"http://n8n:5678/webhook/94a8adfc-1dba-41e7-be61-4c13b51fa08e","events":["message"]}]}}'
curl -X POST "http://localhost:3000/api/sessions/start" -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed" -H "Content-Type: application/json" -d $body
```

---

### **6. Testar**
1. Envie mensagem pelo WhatsApp: **"Como pagar IPTU?"**
2. Veja execução em: http://localhost:5679 → Executions
3. Deve aparecer resposta baseada na base de conhecimento

---

## 🆘 **Alternativa Mais Simples**

Se o workflow RAG completo estiver muito complexo, podemos usar uma abordagem mais direta:

### **Opção 1: Chamar API Python Diretamente**
O workflow já existente pode ser simplificado para apenas:
1. Webhook → Filtro → HTTP Request para API Python → Enviar WhatsApp

Quer que eu mostre essa versão simplificada?

---

## 📊 **Verificar Se Está Funcionando**

```powershell
# Ver execuções
$token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxNzY1ZWYzNS0zNWYzLTQ3NDItYjY5Mi1kZmVjMGRmZjU1MGQiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzYyNDY1MDk0LCJleHAiOjE3NjQ5OTAwMDB9.AyvjOuOk25dSVuSxjUgop22frjyGNWoO03W-YAWE_B4"
curl -s "http://localhost:5679/api/v1/executions?limit=5" -H "X-N8N-API-KEY: $token" | ConvertFrom-Json | Select-Object -ExpandProperty data | Format-Table

# Ver logs da API
docker compose logs -f api

# Testar webhook manualmente
$testPayload = '{"event":"message","payload":{"from":"5547999999999@c.us","body":"Como pagar IPTU?","fromMe":false}}'
curl -X POST "http://localhost:5679/webhook/94a8adfc-1dba-41e7-be61-4c13b51fa08e" -H "Content-Type: application/json" -d $testPayload
```

---

## ❓ **Qual Caminho Seguir?**

**Opção A**: Criar workflow RAG completo no n8n (mais complexo, mas mais controle visual)  
**Opção B**: Workflow simples que chama a API Python existente (mais rápido, usa o que já está funcionando)

**Recomendação**: Opção B - já temos a API Python com RAG funcionando perfeitamente!

Quer que eu crie a **Opção B simplificada**?
