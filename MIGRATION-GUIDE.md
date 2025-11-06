# Migration Guide - Chatbot de Tributos

Guia completo para migração entre diferentes stacks e tecnologias.

## Índice

- [WAHA → WhatsApp Cloud API](#waha--whatsapp-cloud-api)
- [n8n → Camunda](#n8n--camunda)
- [n8n → Temporal](#n8n--temporal)
- [ChromaDB → Qdrant](#chromadb--qdrant)
- [Stack Completo → Minimal Stack](#stack-completo--minimal-stack)

---

## WAHA → WhatsApp Cloud API

### Motivação
- ✅ API oficial da Meta
- ✅ Mais estável (sem quebras do WhatsApp Web)
- ✅ Sem necessidade de QR code
- ✅ Webhooks mais confiáveis
- ❌ Custo por conversa (~$0.005-0.05)

### Pré-requisitos
1. Conta Meta Business Manager
2. App criado no Facebook Developers
3. Phone Number ID configurado
4. Webhook verificado

### Passos

#### 1. Criar App no Meta Business
```bash
# Acesse: https://business.facebook.com
# Crie um app tipo "Business"
# Adicione produto: WhatsApp
# Configure número de telefone
# Obtenha: Phone Number ID, Access Token
```

#### 2. Atualizar Código

**Criar `services/whatsapp_cloud.py`:**
```python
"""WhatsApp Cloud API client."""
import requests
from services.config import get_settings

class WhatsAppCloud:
    def __init__(self):
        settings = get_settings()
        self.phone_id = settings.WA_PHONE_NUMBER_ID
        self.token = settings.WA_ACCESS_TOKEN
        self.api_url = f"https://graph.facebook.com/v21.0/{self.phone_id}"
    
    def send_message(self, to: str, message: str) -> None:
        url = f"{self.api_url}/messages"
        payload = {
            "messaging_product": "whatsapp",
            "to": to,
            "type": "text",
            "text": {"body": message}
        }
        headers = {"Authorization": f"Bearer {self.token}"}
        resp = requests.post(url, json=payload, headers=headers)
        resp.raise_for_status()
```

**Atualizar `app.py`:**
```python
from services.whatsapp_cloud import WhatsAppCloud

@app.route("/webhook", methods=["GET", "POST"])
def webhook():
    # GET: Verification
    if request.method == "GET":
        mode = request.args.get("hub.mode")
        token = request.args.get("hub.verify_token")
        challenge = request.args.get("hub.challenge")
        if mode == "subscribe" and token == VERIFY_TOKEN:
            return challenge, 200
        return "Forbidden", 403
    
    # POST: Messages
    data = request.json
    wa_client = WhatsAppCloud()
    
    for entry in data.get("entry", []):
        for change in entry.get("changes", []):
            value = change.get("value", {})
            for message in value.get("messages", []):
                from_number = message["from"]
                text = message.get("text", {}).get("body", "")
                
                # Process with AI
                bot = AIBot()
                response = bot.invoke([], text)
                
                # Send response
                wa_client.send_message(from_number, response)
    
    return "OK", 200
```

#### 3. Atualizar `.env`
```env
# Remove WAHA vars
# WAHA_API_URL=...
# WAHA_API_KEY=...

# Add Cloud API vars
WA_PHONE_NUMBER_ID=123456789012345
WA_ACCESS_TOKEN=EAAxxxxxxxxxxxxx
WA_VERIFY_TOKEN=seu_token_personalizado
```

#### 4. Atualizar `compose.yml`
```yaml
services:
  # Remove entire 'waha:' service
  
  api:
    environment:
      - WA_PHONE_NUMBER_ID=${WA_PHONE_NUMBER_ID}
      - WA_ACCESS_TOKEN=${WA_ACCESS_TOKEN}
      - WA_VERIFY_TOKEN=${WA_VERIFY_TOKEN}
```

#### 5. Configurar Webhook na Meta
```bash
# Webhook URL: https://seu-dominio.com/webhook
# Verify Token: mesmo do .env (WA_VERIFY_TOKEN)
# Subscribe to: messages
```

#### 6. Testar
```powershell
# Enviar mensagem de teste
curl -X POST "http://localhost:5000/webhook" `
  -H "Content-Type: application/json" `
  -d '{
    "entry": [{
      "changes": [{
        "value": {
          "messages": [{
            "from": "5511999999999",
            "text": {"body": "Teste"}
          }]
        }
      }]
    }]
  }'
```

### Custos Estimados
- **Free tier**: 1000 conversas/mês
- **Após free tier**: $0.005-0.05 por conversa
- **Marketing messages**: $0.03-0.10 por mensagem

---

## ChromaDB → Qdrant

### Motivação
- ✅ Performance 10x melhor
- ✅ Escalável (clustering)
- ✅ Dashboard web integrado
- ✅ API REST completa

### Tempo Estimado
- 1-2 horas (migração de dados)
- Depende do tamanho da base

### Passos

#### 1. Iniciar Qdrant
```powershell
# Usando minimal stack
.\scripts\up-minimal.ps1

# Ou adicionar ao compose.yml atual
docker compose up -d qdrant
```

#### 2. Migrar Dados
```powershell
# Executar script de migração
python scripts/migrations/migrate_chroma_to_qdrant.py

# Ou com parâmetros personalizados
python scripts/migrations/migrate_chroma_to_qdrant.py `
  --chroma-dir ./chroma_data `
  --qdrant-url http://localhost:6333 `
  --collection tributos_docs
```

#### 3. Atualizar `bot/ai_bot.py`
```python
# Trocar imports
from langchain_qdrant import QdrantVectorStore
from qdrant_client import QdrantClient

# Atualizar __build_retriever()
def __build_retriever(self):
    settings = get_settings()
    embedding_model = settings.EMBEDDING_MODEL
    embedding = HuggingFaceEmbeddings(model_name=embedding_model)
    
    client = QdrantClient(url=settings.QDRANT_URL)
    vector_store = QdrantVectorStore(
        client=client,
        collection_name="tributos_docs",
        embedding=embedding
    )
    
    return vector_store.as_retriever(
        search_type="mmr",
        search_kwargs={"k": 30, "lambda_mult": 0.5}
    )
```

#### 4. Atualizar `.env`
```env
VECTOR_DB=qdrant
QDRANT_URL=http://qdrant:6333
```

#### 5. Reiniciar API
```powershell
docker compose restart api
```

#### 6. Verificar
```powershell
# Test Qdrant dashboard
Start-Process http://localhost:6333/dashboard

# Test retrieval
curl http://localhost:5000/health
```

### Rollback (se necessário)
```powershell
# Voltar para ChromaDB
# 1. Reverter mudanças em bot/ai_bot.py
# 2. Atualizar .env: VECTOR_DB=chroma
# 3. Reiniciar: docker compose restart api
```

---

## Stack Completo → Minimal Stack

### Motivação
- ✅ Menos containers (4 vs 3)
- ✅ Mais simples de manter
- ✅ WhatsApp Cloud API oficial
- ✅ PostgreSQL para histórico
- ✅ Redis para rate limiting
- ❌ Perde editor visual (n8n)
- ❌ Custo por conversa

### Pré-requisitos
- WhatsApp Cloud API configurado
- `.env.minimal.example` → `.env`

### Passos

#### 1. Parar Stack Atual
```powershell
docker compose down
```

#### 2. Backup de Dados
```powershell
# Backup ChromaDB (se quiser migrar para Qdrant)
Copy-Item -Recurse chroma_data chroma_data.backup

# Backup n8n workflows
Copy-Item -Recurse n8n n8n.backup
```

#### 3. Configurar `.env`
```powershell
# Copiar template
Copy-Item .env.minimal.example .env

# Editar .env com suas credenciais
notepad .env
```

#### 4. Iniciar Minimal Stack
```powershell
.\scripts\up-minimal.ps1 -Build
```

#### 5. Migrar Dados para Qdrant (opcional)
```powershell
python scripts/migrations/migrate_chroma_to_qdrant.py `
  --chroma-dir ./chroma_data.backup `
  --qdrant-url http://localhost:6333
```

#### 6. Configurar Webhook
```bash
# Meta Developers Console
# Webhook URL: https://seu-dominio.com/webhook
# Verify Token: valor do .env (WA_VERIFY_TOKEN)
# Subscribe: messages
```

#### 7. Testar
```powershell
# Health check
curl http://localhost:5000/health

# Test webhook
.\scripts\test-minimal-webhook.ps1
```

### Estrutura Final
```
Minimal Stack:
├── API (Flask) - Port 5000
├── Qdrant - Port 6333
├── PostgreSQL - Port 5432
└── Redis - Port 6379

Volumes:
├── qdrant_data/
├── postgres_data/
└── redis_data/
```

---

## Troubleshooting

### Erro: "Collection already exists" (Qdrant)
```powershell
# Deletar collection existente
python -c "from qdrant_client import QdrantClient; QdrantClient('http://localhost:6333').delete_collection('tributos_docs')"

# Re-executar migração
python scripts/migrations/migrate_chroma_to_qdrant.py
```

### Erro: "Database connection failed" (PostgreSQL)
```powershell
# Verificar se PostgreSQL está rodando
docker compose -f compose.minimal.yml ps postgres

# Ver logs
docker compose -f compose.minimal.yml logs postgres

# Recriar volume
docker compose -f compose.minimal.yml down -v
docker compose -f compose.minimal.yml up -d postgres
```

### Erro: "WhatsApp webhook verification failed"
```bash
# Verificar se API está acessível publicamente
curl https://seu-dominio.com/webhook

# Testar verificação local
curl "http://localhost:5000/webhook?hub.mode=subscribe&hub.verify_token=seu_token&hub.challenge=test123"
# Deve retornar: test123
```

### Performance lenta (Qdrant)
```python
# Ajustar parâmetros de busca em bot/ai_bot.py
search_kwargs={"k": 10, "lambda_mult": 0.7}  # Menos documentos, mais relevância
```

---

## Rollback Geral

### Voltar para Stack Original
```powershell
# 1. Parar minimal stack
docker compose -f compose.minimal.yml down

# 2. Restaurar dados (se fez backup)
Remove-Item -Recurse chroma_data
Copy-Item -Recurse chroma_data.backup chroma_data

# 3. Iniciar stack original
.\scripts\up-n8n.ps1
```

---

## Suporte

- **Issues**: https://github.com/arturmelo2/chatbot-tributos/issues
- **Docs**: `/docs` folder
- **Email**: ti@novatrento.sc.gov.br

---

**Última atualização**: Novembro 2025  
**Versão**: 1.0.0
