# 🚀 Comandos Úteis - Chatbot Tributos

## ✅ Sistema Implantado com Sucesso!

**Status:** 100% Operacional  
**Data:** 06/11/2025

---

## 📊 Status dos Serviços

```powershell
# Ver todos os containers
docker compose ps

# Status da sessão WhatsApp
curl -s "http://localhost:3000/api/sessions/default" -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed"

# Health check dos serviços
curl http://localhost:5000/health
curl http://localhost:5679/healthz
curl http://localhost:3000
```

---

## 🔍 Monitoramento em Tempo Real

```powershell
# Ver logs da API
docker compose logs -f api

# Ver logs do n8n
docker compose logs -f n8n

# Ver logs do WAHA
docker compose logs -f waha

# Ver logs de todos os serviços
docker compose logs -f
```

---

## 🎮 Controle dos Containers

```powershell
# Iniciar sistema
docker compose up -d

# Parar sistema
docker compose down

# Reiniciar todos os serviços
docker compose restart

# Reiniciar serviço específico
docker compose restart api
docker compose restart n8n
docker compose restart waha

# Rebuild da API (após mudanças no código)
docker compose build --no-cache api
docker compose up -d api
```

---

## 📚 Base de Conhecimento

```powershell
# Carregar/Recarregar base de conhecimento
docker compose exec api python rag/load_knowledge.py

# Limpar e recarregar do zero
docker compose exec api python rag/load_knowledge.py --clear

# Verificar tamanho da base
docker compose exec api ls -lh /app/chroma_data/
```

---

## 📱 WhatsApp (WAHA)

```powershell
# Ver sessões ativas
curl -s "http://localhost:3000/api/sessions" -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed"

# Status da sessão
curl -s "http://localhost:3000/api/sessions/default" -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed"

# Parar sessão
curl -X POST "http://localhost:3000/api/sessions/default/stop" -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed"

# Iniciar sessão
curl -X POST "http://localhost:3000/api/sessions/default/start" -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed"

# Ver QR Code (abrir no navegador)
Start-Process "http://localhost:3000/api/default/auth/qr?format=image"

# Enviar mensagem de teste
$body = '{"chatId":"5547999999999@c.us","text":"Teste","session":"default"}'
curl -X POST "http://localhost:3000/api/sendText" -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed" -H "Content-Type: application/json" -d $body
```

---

## 🔧 n8n

```powershell
# Listar workflows
docker compose exec n8n n8n list:workflow

# Abrir n8n no navegador
Start-Process "http://localhost:5679"

# Ver execuções via API (requer autenticação)
curl -u "admin:Tributos@NovaTrento2025" "http://localhost:5679/api/v1/executions"
```

---

## 🧪 Testes

```powershell
# Executar testes
docker compose exec api pytest

# Testes com cobertura
docker compose exec api pytest --cov=. --cov-report=html

# Linting
docker compose exec api ruff check .

# Formatação
docker compose exec api black --check .

# Type checking
docker compose exec api mypy .
```

---

## 💾 Backup e Restore

```powershell
# Criar backup
$data = Get-Date -Format "yyyyMMdd_HHmmss"
tar -czf "backup_$data.tar.gz" chroma_data/ data/ .env

# Restaurar backup
tar -xzf backup_YYYYMMDD_HHMMSS.tar.gz

# Backup apenas da base de conhecimento
tar -czf "chroma_backup_$data.tar.gz" chroma_data/
```

---

## 🌐 URLs de Acesso

| Serviço | URL | Credenciais |
|---------|-----|-------------|
| **API** | http://localhost:5000 | - |
| **n8n** | http://localhost:5679 | admin / Tributos@NovaTrento2025 |
| **WAHA** | http://localhost:3000 | admin / Tributos@NovaTrento2025 |
| **Health API** | http://localhost:5000/health | - |
| **Health n8n** | http://localhost:5679/healthz | - |

---

## 🐛 Troubleshooting

### API não responde

```powershell
# Verificar logs
docker compose logs api --tail 100

# Reiniciar
docker compose restart api

# Rebuild
docker compose build --no-cache api
docker compose up -d api
```

### WhatsApp desconectado

```powershell
# Verificar status
curl -s "http://localhost:3000/api/sessions/default" -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed"

# Reiniciar sessão
curl -X POST "http://localhost:3000/api/sessions/default/stop" -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed"
curl -X POST "http://localhost:3000/api/sessions/default/start" -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed"

# Ver QR Code
Start-Process "http://localhost:3000/api/default/auth/qr?format=image"
```

### n8n não executando workflow

```powershell
# Verificar se workflow está ativo
docker compose logs n8n --tail 50 | Select-String "workflow"

# Reiniciar n8n
docker compose restart n8n

# Acessar n8n e verificar:
# 1. Workflow está ativado (toggle verde)
# 2. Credenciais WAHA configuradas
# 3. Webhook URL correto
```

### Base de conhecimento vazia

```powershell
# Recarregar
docker compose exec api python rag/load_knowledge.py --clear

# Verificar documentos
docker compose exec api ls -lR /app/rag/data/

# Ver tamanho do ChromaDB
docker compose exec api du -sh /app/chroma_data/
```

---

## 📝 Variáveis de Ambiente Importantes

```env
# LLM
LLM_PROVIDER=groq
LLM_MODEL=llama-3.3-70b-versatile
GROQ_API_KEY=gsk_...

# WAHA
WAHA_API_KEY=tributos_nova_trento_2025_api_key_fixed

# n8n
N8N_USER=admin
N8N_PASSWORD=Tributos@NovaTrento2025
N8N_WEBHOOK_ID=94a8adfc-1dba-41e7-be61-4c13b51fa08e
```

---

## 🚀 Fluxo de Trabalho Diário

```powershell
# 1. Iniciar sistema
docker compose up -d

# 2. Verificar status
docker compose ps

# 3. Monitorar logs (em terminal separado)
docker compose logs -f api

# 4. Acessar n8n para monitorar execuções
Start-Process "http://localhost:5679"

# 5. Ao final do dia (opcional)
docker compose down
```

---

## 📊 Estatísticas da Base Atual

- **Documentos:** 65
- **Chunks vetorizados:** 461
- **Categorias:**
  - FAQs: 7 arquivos
  - Leis: 43 arquivos
  - Manuais: 6 arquivos
  - Procedimentos: 5 arquivos

---

## 🎯 Testes Recomendados

```powershell
# 1. Enviar mensagem de teste via WAHA
$body = '{"chatId":"5547999999999@c.us","text":"Como pagar IPTU?","session":"default"}'
curl -X POST "http://localhost:3000/api/sendText" -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed" -H "Content-Type: application/json" -d $body

# 2. Monitorar execução no n8n
Start-Process "http://localhost:5679"

# 3. Ver logs da API em tempo real
docker compose logs -f api
```

---

## 💡 Dicas

- **Sempre verifique os logs** quando algo não funcionar
- **n8n Executions** é a melhor ferramenta para debug
- **ChromaDB** persiste em `chroma_data/` - faça backup!
- **Sessão WhatsApp** persiste em `data/waha/` - faça backup!
- **Use `docker compose ps`** para verificar health dos containers

---

**Sistema implantado com sucesso em 06/11/2025** ✅
