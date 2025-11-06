# 🚀 Guia de Deploy Rápido - Produção

> **Sistema pronto para uso!** Todas as credenciais já estão configuradas.

## ⚡ Deploy em 5 Minutos

### Pré-requisitos
- ✅ Docker Desktop instalado e rodando
- ✅ PowerShell
- ✅ Porta 3000, 5000 e 5679 disponíveis

### Passo 1️⃣ - Iniciar o Sistema

```powershell
# Navegar até a pasta do projeto
cd c:\Users\artur\code\chatbot-tributos\whatsapp-ai-chatbot

# Iniciar todos os serviços
docker-compose up -d
```

**Aguarde ~2 minutos** para todos os containers iniciarem.

### Passo 2️⃣ - Verificar Status

```powershell
# Verificar containers
docker-compose ps

# Verificar health da API
curl http://localhost:5000/health
```

**Esperado:**
```json
{
  "status": "healthy",
  "service": "Chatbot de Tributos Nova Trento/SC",
  "environment": "production",
  "llm_provider": "xai"
}
```

### Passo 3️⃣ - Carregar Base de Conhecimento

```powershell
# Carregar documentos no ChromaDB
docker-compose exec api python rag/load_knowledge.py
```

**Esperado:** `✅ 66 documentos processados e indexados`

### Passo 4️⃣ - Configurar n8n

1. **Acessar n8n:**
   ```
   http://localhost:5679
   ```

2. **Primeira vez:**
   - Criar conta de usuário
   - Email: admin@novatrento.sc.gov.br
   - Senha: (sua escolha - ANOTE!)

3. **Instalar community node:**
   - Settings → Community Nodes
   - Instalar: `n8n-nodes-waha`

4. **Importar workflow:**
   - Import → Selecionar arquivo:
     ```
     n8n/workflows/chatbot_completo_orquestracao.json
     ```

5. **Configurar credencial WAHA:**
   - Credentials → Add Credential → Header Auth
   - Nome: `WAHA API`
   - Name: `X-Api-Key`
   - Value: `tributos_nova_trento_2025_api_key_fixed`
   - Salvar

6. **Ativar workflow:**
   - Abrir workflow importado
   - Clicar em "Active" (toggle no canto superior direito)
   - ✅ Workflow deve ficar verde

### Passo 5️⃣ - Conectar WhatsApp

```powershell
# Iniciar sessão WAHA
.\scripts\start-waha-session.ps1
```

**OU manualmente:**

1. Acessar: http://localhost:3000
2. **Credenciais:**
   - Usuário: `admin`
   - Senha: `Tributos@NovaTrento2025`
3. Criar sessão → Escanear QR Code com WhatsApp
4. ✅ Aguardar "Connected"

### Passo 6️⃣ - Testar

Envie uma mensagem de qualquer WhatsApp para o número conectado:

```
Olá, quanto é o IPTU?
```

**Resposta esperada:** Bot deve responder com informações sobre IPTU da base de conhecimento.

---

## 🔧 Comandos Úteis

### Ver Logs
```powershell
# Logs da API
docker-compose logs -f api

# Logs do WAHA
docker-compose logs -f waha

# Logs do n8n
docker-compose logs -f n8n
```

### Reiniciar Serviços
```powershell
# Reiniciar tudo
docker-compose restart

# Reiniciar apenas a API
docker-compose restart api
```

### Parar Sistema
```powershell
# Parar (mantém dados)
docker-compose stop

# Parar e remover containers (mantém volumes)
docker-compose down

# CUIDADO: Remove TUDO incluindo volumes
docker-compose down -v
```

### Recarregar Base de Conhecimento
```powershell
# Limpar e recarregar
docker-compose exec api python rag/load_knowledge.py --clear
```

---

## 📊 Monitoramento

### Health Checks
```powershell
# API
curl http://localhost:5000/health

# WAHA Sessions
curl -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed" http://localhost:3000/api/sessions

# n8n
curl http://localhost:5679/healthz
```

### Status do WAHA
```powershell
.\scripts\waha-status.ps1
```

### Exportar Histórico de Conversas
```powershell
.\scripts\export-history.ps1
```

---

## 🔐 Credenciais Configuradas

### LLM Provider
- **Provider:** xAI (Grok)
- **Modelo:** grok-4-fast-reasoning
- **API Key:** ✅ Configurada no .env

### WAHA
- **Dashboard:** http://localhost:3000
- **Usuário:** admin
- **Senha:** Tributos@NovaTrento2025
- **API Key:** tributos_nova_trento_2025_api_key_fixed

### n8n
- **URL:** http://localhost:5679
- **Usuário:** (criar no primeiro acesso)

---

## 🚨 Troubleshooting

### Porta 3000 não acessível
```powershell
# Verificar se porta está em uso
netstat -ano | findstr :3000

# Se estiver em uso, matar processo ou usar porta alternativa
```

### Container não inicia
```powershell
# Ver logs detalhados
docker-compose logs [nome-container]

# Rebuild completo
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Base de conhecimento vazia
```powershell
# Recarregar
docker-compose exec api python rag/load_knowledge.py --clear
```

### n8n workflow não recebe mensagens
1. Verificar se workflow está ativo (toggle verde)
2. Verificar webhook URL no WAHA:
   ```
   http://n8n:5678/webhook/94a8adfc-1dba-41e7-be61-4c13b51fa08e
   ```
3. Verificar credencial WAHA no n8n
4. Ver logs: `docker-compose logs -f n8n`

---

## 📱 Produção

### Backup
```powershell
# Backup dos volumes
docker run --rm -v whatsapp-ai-chatbot_chroma_data:/data -v ${PWD}/backup:/backup alpine tar czf /backup/chroma_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').tar.gz -C /data .
```

### Auto-start no Windows
```powershell
# Instalar auto-start (Task Scheduler)
.\scripts\install-auto-start.ps1 -DelaySeconds 60
```

### Atualizar Sistema
```powershell
# Pull atualizações
git pull

# Rebuild e restart
docker-compose down
docker-compose build
docker-compose up -d

# Recarregar conhecimento (se necessário)
docker-compose exec api python rag/load_knowledge.py
```

---

## ✅ Checklist de Deploy

- [ ] Docker Desktop rodando
- [ ] Containers iniciados (`docker-compose up -d`)
- [ ] API healthy (`curl http://localhost:5000/health`)
- [ ] Base de conhecimento carregada (66 docs)
- [ ] n8n configurado e workflow ativo
- [ ] WAHA conectado ao WhatsApp
- [ ] Teste de mensagem realizado
- [ ] Logs sem erros críticos
- [ ] Backup configurado (opcional)
- [ ] Auto-start configurado (opcional)

---

## 📞 Suporte

- **Documentação:** README.md, ARCHITECTURE.md
- **Issues:** https://github.com/arturmelo2/chatbot-tributos/issues
- **Email:** ti@novatrento.sc.gov.br

---

**Sistema pronto para atender os cidadãos de Nova Trento! 🎉**
