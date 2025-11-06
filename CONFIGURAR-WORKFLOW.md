# 🔧 Configuração Final do Workflow RAG

## ✅ Status: Workflow Importado - Faltam Credenciais

---

## 📋 CHECKLIST DE CONFIGURAÇÃO

### 1️⃣ **Groq API (LLM)**

**Nodes afetados**: `Groq Chat Model` + `Groq Summarizer`

#### Passos:
1. Clique no node **"Groq Chat Model"**
2. Em "Credential to connect with", clique em **"Create New Credential"**
3. Preencha:
   - **Name**: `Groq API`
   - **API Key**: Sua chave da Groq (ex: `gsk_...`)
4. Clique em **"Save"**
5. **Repita** para o node **"Groq Summarizer"** (use a mesma credential)

#### Onde pegar a API Key:
- Acesse: https://console.groq.com/keys
- Copie sua API key

---

### 2️⃣ **ChromaDB Vector Store**

**Node afetado**: `ChromaDB Vector Store`

#### Opção A: Usar API Existente (RECOMENDADO)

**PROBLEMA**: O node ChromaDB do n8n espera um servidor ChromaDB dedicado, mas estamos usando embeddings embutidos na API Python.

**SOLUÇÃO**: Substituir por HTTP Request para a API Python

#### Passos para corrigir:

1. **Delete o node** "ChromaDB Vector Store"
2. **Adicione** um node "HTTP Request"
3. Configure:
   ```
   Method: POST
   URL: http://api:5000/rag/search
   Body (JSON):
   {
     "query": "{{ $json.question }}",
     "k": 5
   }
   ```
4. **Conecte**:
   - De: `Vector Store Tool`
   - Para: Novo `HTTP Request`

#### Opção B: Usar ChromaDB Standalone (Mais Complexo)

Se quiser usar o node nativo do n8n:

1. Configure ChromaDB standalone:
```yaml
# Adicionar ao compose.yml
chromadb:
  image: chromadb/chroma:latest
  ports:
    - "8000:8000"
  volumes:
    - ./chroma_data:/chroma/chroma
```

2. No node "ChromaDB Vector Store":
   - Host: `http://chromadb:8000`
   - Collection: `tributos_docs`

---

### 3️⃣ **HuggingFace Embeddings**

**Node afetado**: `HuggingFace Embeddings`

#### Se usar API Python (Opção A acima):
- **NÃO PRECISA** configurar este node
- Pode até **deletá-lo** (API Python já faz embeddings)

#### Se usar ChromaDB standalone (Opção B):
1. Clique no node
2. Configure:
   - **Model**: `sentence-transformers/all-MiniLM-L6-v2`
   - **API Key**: Deixe em branco (usará modelo local)

---

### 4️⃣ **WAHA Authentication (3 nodes HTTP)**

**Nodes afetados**:
- `Enviar WhatsApp`
- `Iniciar Digitando`
- `Parar Digitando`

#### Passos (fazer para os 3 nodes):

1. Clique no node
2. Em **"Authentication"**, selecione: `Generic Credential Type`
3. Escolha: `Header Auth`
4. Clique em **"Create New Credential"**
5. Preencha:
   ```
   Name: WAHA API Key
   Header Name: X-Api-Key
   Header Value: tributos_nova_trento_2025_api_key_fixed
   ```
6. Salve
7. **Repita** para os outros 2 nodes (use a mesma credential)

---

## 🚀 VERSÃO SIMPLIFICADA (SEM RAG NO N8N)

Se as configurações acima estiverem muito complexas, use esta versão que delega tudo para a API Python:

### Workflow Minimalista:

```
Webhook → Filtro → HTTP Request (API Python) → Done
```

#### JSON para importar:

```json
{
  "name": "Chatbot Simples - API Python",
  "nodes": [
    {
      "parameters": {
        "httpMethod": "POST",
        "path": "94a8adfc-1dba-41e7-be61-4c13b51fa08e"
      },
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
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
              "value2": "false"
            }
          ]
        }
      },
      "name": "IF",
      "type": "n8n-nodes-base.if",
      "position": [460, 300]
    },
    {
      "parameters": {
        "method": "POST",
        "url": "http://api:5000/chatbot/webhook/",
        "sendBody": true,
        "bodyParameters": {
          "parameters": [
            {
              "name": "=",
              "value": "={{ JSON.stringify($json) }}"
            }
          ]
        }
      },
      "name": "Call API",
      "type": "n8n-nodes-base.httpRequest",
      "position": [680, 300]
    }
  ],
  "connections": {
    "Webhook": {
      "main": [[{"node": "IF", "type": "main", "index": 0}]]
    },
    "IF": {
      "main": [[{"node": "Call API", "type": "main", "index": 0}]]
    }
  }
}
```

---

## ✅ TESTAR

Após configurar:

1. **Ative o workflow** (toggle verde)
2. **Teste via webhook**:
```powershell
$test = '{"event":"message","payload":{"from":"5547999999999@c.us","body":"Como pagar IPTU?","fromMe":false}}'
curl -X POST "http://localhost:5679/webhook/94a8adfc-1dba-41e7-be61-4c13b51fa08e" -H "Content-Type: application/json" -d $test
```

3. **Veja execução**: http://localhost:5679 → Executions

---

## 🎯 RECOMENDAÇÃO

**Use a versão SIMPLIFICADA** e deixe a API Python fazer todo o trabalho RAG. 

Assim você tem:
✅ Workflow n8n limpo e fácil de entender  
✅ API Python já testada e funcionando  
✅ Base de conhecimento já carregada  
✅ Menos pontos de falha  

**Quer que eu crie o workflow simplificado para você?**
