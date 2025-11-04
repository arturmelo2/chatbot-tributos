# 🚀 Acesso Rápido - Chatbot de Tributos

## 📱 Conectar WhatsApp (Primeira Vez)

### 1️⃣ Acessar Dashboard WAHA
```
URL: http://localhost:3000
Username: admin
Password: Tributos@NovaTrento2025
```

### 2️⃣ Criar Sessão WhatsApp
No dashboard:
1. Click em **"Sessions"** ou **"Add Session"**
2. Nome: `default`
3. Click **"Start"**
4. Aparecerá um **QR Code**

### 3️⃣ Escanear QR Code
No WhatsApp do celular:
1. Abrir WhatsApp
2. Ir em **⋮ (menu)** → **Aparelhos conectados**
3. Click **"Conectar aparelho"**
4. Escanear o QR Code da tela
5. Aguardar confirmação ✅

### 4️⃣ Verificar Conexão
```powershell
# Ver se sessão está ativa
docker-compose logs waha | Select-String "Session.*ready"

# OU via API
curl -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed" http://localhost:3000/api/sessions
```

Resposta esperada:
```json
[{"name":"default","status":"WORKING"}]
```

---

## ✅ Testar o Bot

### Via WhatsApp Real
1. Enviar mensagem para o número conectado:
   ```
   Olá, preciso de informações sobre IPTU
   ```

2. O bot deve responder automaticamente com informações da base de conhecimento

### Via Simulação (Teste Local)
```powershell
$body = @{
    event = 'message'
    payload = @{
        from = '5511999999999@c.us'
        body = 'Olá, preciso de informações sobre IPTU'
    }
} | ConvertTo-Json -Depth 3

Invoke-RestMethod -Uri "http://localhost:5000/chatbot/webhook/" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body
```

Resposta esperada:
```json
{"status": "success"}
```

---

## 🔐 Credenciais Fixas (Não Mudam)

| Item | Valor |
|------|-------|
| **Dashboard URL** | http://localhost:3000 |
| **Username** | admin |
| **Password** | Tributos@NovaTrento2025 |
| **API Key** | tributos_nova_trento_2025_api_key_fixed |

> ⚠️ **IMPORTANTE:** Estas credenciais são fixas e persistem entre restarts.
> Guarde com segurança e não compartilhe publicamente!

---

## 🛠️ Comandos Úteis

### Iniciar Sistema
```powershell
docker-compose up -d
```

### Parar Sistema
```powershell
docker-compose down
```

### Ver Logs
```powershell
# API
docker-compose logs -f api

# WAHA
docker-compose logs -f waha

# Ambos
docker-compose logs -f
```

### Verificar Status
```powershell
# Containers
docker-compose ps

# Health da API
curl http://localhost:5000/health

# Sessões WAHA
curl -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed" \
     http://localhost:3000/api/sessions
```

### Reiniciar (Se necessário)
```powershell
docker-compose restart api
docker-compose restart waha
```

---

## 📊 Monitoramento

### Logs em Tempo Real
```powershell
# Ver mensagens chegando
docker-compose logs -f api | Select-String "📨"

# Ver respostas sendo enviadas
docker-compose logs -f api | Select-String "✅"

# Ver erros
docker-compose logs -f api | Select-String "ERROR|❌"
```

### Health Check
```powershell
# API
Invoke-RestMethod http://localhost:5000/health

# Resposta esperada:
# {
#   "status": "healthy",
#   "service": "Chatbot de Tributos Nova Trento/SC",
#   "llm_provider": "groq"
# }
```

---

## 🔄 Atualizar Base de Conhecimento

### Adicionar Documentos
1. Colocar PDFs/TXTs/Markdown em:
   ```
   rag/data/faqs/
   rag/data/leis/
   rag/data/manuais/
   ```

2. Recarregar base:
   ```powershell
   docker-compose exec api python rag/load_knowledge.py --clear
   ```

3. Aguardar indexação (veja logs)

---

## ❓ Troubleshooting Rápido

### Bot não responde?

1. **Verificar sessão WhatsApp conectada:**
   ```powershell
   curl -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed" \
        http://localhost:3000/api/sessions
   ```
   - Se retornar `[]` → Conectar WhatsApp no dashboard

2. **Verificar logs de erro:**
   ```powershell
   docker-compose logs --tail=50 api | Select-String "ERROR"
   ```

3. **Reiniciar containers:**
   ```powershell
   docker-compose restart
   ```

### Dashboard não abre?

- **Porta 3000 ocupada?** Use porta 3001 (veja `TROUBLESHOOTING_PORTA_3000.md`)
- **Container rodando?** `docker-compose ps`
- **Firewall bloqueando?** Desabilitar temporariamente

### Erro 401 ou 422?

- **401:** API key errada → Verificar `.env` e `compose.yml`
- **422:** Sessão não existe → Criar sessão no dashboard

---

## 📞 Suporte

- **Documentação Completa:** `README.md`
- **Troubleshooting Porta 3000:** `TROUBLESHOOTING_PORTA_3000.md`
- **Status do Sistema:** `STATUS.md`

---

**Última atualização:** Novembro 2025
**Versão:** 1.0.0 - Credenciais Fixas
**Projeto:** Prefeitura Municipal de Nova Trento/SC
