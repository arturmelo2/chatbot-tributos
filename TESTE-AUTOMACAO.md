# 🚀 Guia de Teste Rápido - Automação n8n

## ✅ Checklist de Teste Completo

### Pré-requisitos
- [ ] Docker Desktop rodando
- [ ] Arquivo `.env` existe e tem `N8N_USER` e `N8N_PASSWORD`
- [ ] WhatsApp instalado no celular (para escanear QR code)

---

## 🧪 Teste 1: Primeira Execução (Zero-Touch)

### Comando
```powershell
./scripts/up-n8n.ps1
```

### O que deve acontecer (em ordem):

1. **Verificação Docker** ✅
   ```
   🐳 Verificando Docker...
      ✅ Docker OK
   ```

2. **Verificação .env** ✅
   ```
   (Se .env não existir, cria automaticamente)
   ```

3. **Subida dos containers** ✅
   ```
   📦 Iniciando containers (WAHA + n8n + API Python)...
   [+] Running 3/3
    ✔ Container tributos_waha    Started
    ✔ Container tributos_n8n     Started  
    ✔ Container tributos_api     Started
   ```

4. **Aguardando inicialização** ⏳
   ```
   ⏳ Aguardando containers iniciarem...
      • WAHA...
      • n8n...
      • API...
   (20 segundos)
   ```

5. **Status dos containers** 📊
   ```
   📊 Status dos containers:
   NAME              STATUS        PORTS
   tributos_waha     Up 20 sec     0.0.0.0:3000->3000/tcp
   tributos_n8n      Up 20 sec     0.0.0.0:5679->5678/tcp
   tributos_api      Up 20 sec     0.0.0.0:5000->5000/tcp
   ```

6. **Verificação WAHA - PRIMEIRA VEZ** 📱
   ```
   📱 Verificando sessão WhatsApp...
      ⚠️  Sessão não está ativa (status: STOPPED)
      🔄 Iniciando sessão WhatsApp...
      
      📲 AÇÃO NECESSÁRIA: Escaneie o QR Code!
      🌐 Abrindo navegador em: http://localhost:3000
      
      ⏳ Aguarde escanear o código QR no WhatsApp...
      (Abra WhatsApp > Dispositivos Conectados > Conectar Dispositivo)
   ```
   
   **AÇÃO MANUAL**: Escaneie o QR code que abriu no navegador
   
   ```
      ✅ QR Code escaneado! WhatsApp conectado com sucesso!
   ```

7. **Mensagem de sucesso** 🎉
   ```
   ================================================================================
   ✅ CHATBOT INICIADO COM SUCESSO!
   ================================================================================
   ```

8. **URLs de acesso** 🌐
   ```
   🌐 URLs de Acesso:
      • WAHA Dashboard: http://localhost:3000
        └─ Usuário: admin
        └─ Senha: Tributos@NovaTrento2025
      
      • n8n Workflows: http://localhost:5679
        └─ Usuário: admin (auto-configurado)
        └─ Senha: Tributos@NovaTrento2025
        └─ Workflow importado e ativado automaticamente!
      
      • API Python: http://localhost:5000
        └─ Health: http://localhost:5000/health
   ```

---

## 🧪 Teste 2: Verificar n8n Auto-Configurado

### 1. Acessar n8n
- Abra: http://localhost:5679
- Login: `admin` / `Tributos@NovaTrento2025`
- **Não deve pedir "Create Owner"** ✅

### 2. Verificar Workflow Importado
- [ ] Workflow "Chatbot Completo n8n" aparece na lista
- [ ] Toggle verde (ATIVO) ✅
- [ ] Webhook configurado: `/webhook/94a8adfc-1dba-41e7-be61-4c13b51fa08e`

### 3. Verificar Community Node
- Settings → Community Nodes
- [ ] `n8n-nodes-waha` instalado ✅

### 4. Verificar Credencial WAHA
- Credentials → "WAHA API Key"
- [ ] Tipo: Header Auth
- [ ] Header Name: `X-Api-Key`
- [ ] Value: `tributos_nova_trento_2025_api_key_fixed` ✅

---

## 🧪 Teste 3: Carregar Conhecimento

```powershell
./scripts/load-knowledge.ps1
```

### O que deve acontecer:
```
📚 Carregando base de conhecimento no ChromaDB...
✅ Carregados: 65 documentos, 461 chunks
```

---

## 🧪 Teste 4: Testar Chatbot End-to-End

### 1. Enviar Mensagem pelo WhatsApp
- Envie qualquer mensagem para o número conectado
- Exemplo: "Como pagar IPTU?"

### 2. Verificar Logs (em outro terminal)
```powershell
# Logs n8n (deve mostrar webhook recebido)
docker logs -f tributos_n8n

# Logs API (deve mostrar processamento RAG)
docker logs -f tributos_api

# Logs WAHA (deve mostrar mensagem enviada)
docker logs -f tributos_waha
```

### 3. Receber Resposta
- [ ] Mensagem de resposta chegou no WhatsApp ✅
- [ ] Conteúdo relevante baseado na base de conhecimento ✅

---

## 🧪 Teste 5: Segunda Execução (Sessão Persistida)

### Parar tudo
```powershell
docker compose down
```

### Iniciar novamente
```powershell
./scripts/up-n8n.ps1
```

### O que deve acontecer DIFERENTE:
```
📱 Verificando sessão WhatsApp...
   ✅ WhatsApp já está conectado e funcionando!
```

**NÃO deve pedir QR code novamente!** ✅

---

## ✅ Checklist Final de Validação

### Containers
- [ ] 3 containers rodando: `tributos_waha`, `tributos_n8n`, `tributos_api`
- [ ] Todos com status "Up"
- [ ] Healthchecks passando

### n8n
- [ ] Acesso sem tela de setup
- [ ] Login funciona com `admin` / `Tributos@NovaTrento2025`
- [ ] Workflow "Chatbot Completo n8n" ativo
- [ ] Community node `n8n-nodes-waha` instalado
- [ ] Credencial WAHA configurada

### WAHA
- [ ] Dashboard acessível: http://localhost:3000
- [ ] Sessão "default" com status WORKING
- [ ] Webhook configurado: `http://n8n:5678/webhook/94a8adfc-1dba-41e7-be61-4c13b51fa08e`

### API
- [ ] Health check: http://localhost:5000/health retorna `200 OK`
- [ ] ChromaDB com documentos carregados

### Fluxo Completo
- [ ] Mensagem enviada pelo WhatsApp
- [ ] n8n recebe webhook
- [ ] n8n chama API
- [ ] API processa com RAG+LLM
- [ ] n8n envia resposta via WAHA
- [ ] Resposta chega no WhatsApp

---

## 🐛 Problemas Comuns

### n8n pede "Create Owner"
**Causa**: `N8N_BASIC_AUTH_ACTIVE` não funcionou

**Solução**:
```powershell
# Verificar .env
cat .env | Select-String "N8N_USER"

# Se vazio, adicionar:
N8N_USER=admin
N8N_PASSWORD=Tributos@NovaTrento2025

# Recriar containers
docker compose down -v
./scripts/up-n8n.ps1
```

### Workflow não aparece
**Causa**: Bootstrap script não importou

**Solução**:
```powershell
# Ver logs do bootstrap
docker logs tributos_n8n | Select-String "bootstrap"

# Importar manualmente
# n8n UI > Settings > Import from file > n8n/workflows/chatbot_completo_n8n.json
```

### Community node não instalado
**Causa**: `N8N_NODES_INCLUDE` não funcionou

**Solução**:
```powershell
# Instalar manualmente
# n8n UI > Settings > Community Nodes > Install: n8n-nodes-waha
```

### WAHA sempre pede QR code
**Causa**: Volume `waha_data` não está persistindo

**Solução**:
```powershell
# Verificar volume existe
docker volume ls | Select-String "waha"

# Se não existe, criar
docker volume create whatsapp-ai-chatbot_waha_data

# Reiniciar
docker compose down
./scripts/up-n8n.ps1
```

### Resposta não chega no WhatsApp
**Causa**: Algum ponto do fluxo falhou

**Diagnóstico**:
```powershell
# 1. Verificar n8n recebeu webhook
docker logs tributos_n8n | Select-String "webhook"

# 2. Verificar API processou
docker logs tributos_api | Select-String "WEBHOOK PAYLOAD"

# 3. Verificar WAHA enviou
docker logs tributos_waha | Select-String "sendText"

# 4. Testar manualmente o webhook
./scripts/test-n8n-webhook.ps1
```

---

## 📊 Métricas de Sucesso

| Métrica | Target | Como Verificar |
|---------|--------|----------------|
| Tempo de inicialização | < 30s | Medir de `docker compose up` até mensagem de sucesso |
| QR code na primeira vez | Sim | Navegador deve abrir automaticamente |
| QR code na segunda vez | Não | Deve informar "já conectado" |
| Tempo de resposta | < 5s | Do envio da mensagem até resposta chegar |
| Taxa de erro | 0% | Não deve ter erros nos logs |

---

## 🎯 Resultado Esperado

**SUCESSO = UM ÚNICO COMANDO FAZ TUDO!**

```powershell
# Primeira vez
./scripts/up-n8n.ps1  # → Pede QR code uma vez
./scripts/load-knowledge.ps1
# Enviar mensagem → Receber resposta

# Segunda vez
./scripts/up-n8n.ps1  # → NÃO pede QR code
# Enviar mensagem → Receber resposta

# ZERO configuração manual em ambos os casos!
```

---

**Última atualização**: 2025-01-06  
**Versão**: 1.0.0
