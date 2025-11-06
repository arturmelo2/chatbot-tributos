# Automação Completa do n8n - Documentação

## ✅ O que foi implementado (100% Zero-Touch)

### 1. **Consolidação dos Workflows**
- **Antes**: 8 arquivos JSON diferentes e confusos
- **Depois**: 1 único arquivo `n8n/workflows/chatbot_completo_n8n.json`
- **Estrutura do workflow**:
  ```
  Webhook Trigger (94a8adfc-1dba-41e7-be61-4c13b51fa08e)
    ↓
  Filtrar Grupos (@g.us)
    ↓
  Extrair Dados (chat_id, mensagem)
    ↓
  Iniciar Typing
    ↓
  Chamar API (http://api:5000/chatbot/webhook/)
    ↓
  Extrair Resposta
    ↓
  Enviar Mensagem (WAHA)
    ↓
  Parar Typing
    ↓
  Responder OK
  
  [Branch de Erro]
    ↓
  Parar Typing Erro → Enviar Mensagem Erro → Responder Erro
  ```

### 2. **Auto-configuração Completa do n8n**

#### `.env` configurado:
```env
# Basic Auth (auto-configuração, bypassa tela de setup)
N8N_USER=admin
N8N_PASSWORD=Tributos@NovaTrento2025
```

#### `compose.yml` configurado:
```yaml
n8n:
  environment:
    # 1. Bypass da tela de setup
    - N8N_BASIC_AUTH_ACTIVE=true
    - N8N_BASIC_AUTH_USER=${N8N_USER:-admin}
    - N8N_BASIC_AUTH_PASSWORD=${N8N_PASSWORD:-Tributos@NovaTrento2025}
    
    # 2. URL correta para webhooks
    - WEBHOOK_TUNNEL_URL=http://n8n:5678/
    
    # 3. Auto-instala community nodes
    - N8N_NODES_INCLUDE=n8n-nodes-waha
    
    # 4. Credenciais WAHA para bootstrap
    - WAHA_API_KEY=tributos_nova_trento_2025_api_key_fixed
    
  volumes:
    # Script de bootstrap
    - ./deploy/bootstrap/n8n-bootstrap.sh:/app/n8n-bootstrap.sh:ro
    
  entrypoint: ["/bin/sh", "/app/n8n-bootstrap.sh"]
```

### 3. **Script Bootstrap Simplificado**

O script `deploy/bootstrap/n8n-bootstrap.sh` agora faz:

```bash
1. ✅ Inicia n8n em background
2. ✅ Aguarda API ficar pronta (healthcheck)
3. ✅ Importa workflow: chatbot_completo_n8n.json
4. ✅ Cria credencial WAHA (Header Auth)
5. ✅ Ativa workflow automaticamente
6. ✅ Traz n8n para foreground (mantém container rodando)
```

### 4. **Script `up-n8n.ps1` Inteligente**

Agora faz verificação completa e automática:

```powershell
1. ✅ Verifica Docker
2. ✅ Verifica .env
3. ✅ Inicia containers (WAHA + n8n + API)
4. ✅ Aguarda 20s para containers ficarem prontos
5. ✅ Mostra status dos containers

# NOVA LÓGICA INTELIGENTE DE SESSÃO WAHA:
6. ✅ Verifica status da sessão via API
7. ✅ Se WORKING: Informa que já está conectado
8. ✅ Se STOPPED/FAILED/SCAN_QR_CODE:
   - Inicia sessão automaticamente
   - Abre navegador com QR code
   - Aguarda até 60s pelo escaneamento
   - Monitora status a cada 3s
9. ✅ Se conectou: Confirma sucesso
10. ✅ Se timeout: Orienta a conectar manualmente depois
```

## 🚀 Como usar (UM ÚNICO COMANDO!)

### Primeira execução completa:

```powershell
# 1. APENAS ESTE COMANDO! (faz tudo automaticamente)
./scripts/up-n8n.ps1

# O script vai:
# ✅ Iniciar 3 containers (WAHA, n8n, API)
# ✅ n8n se auto-configura (usuário admin criado)
# ✅ n8n instala n8n-nodes-waha automaticamente
# ✅ n8n importa workflow automaticamente
# ✅ n8n cria credencial WAHA automaticamente
# ✅ n8n ativa workflow automaticamente
# ✅ Verifica sessão WhatsApp
# ✅ Se primeira vez: abre QR code para escanear
# ✅ Se já conectado: informa que está pronto

# 2. Carregar base de conhecimento (apenas uma vez)
./scripts/load-knowledge.ps1

# 3. Pronto! Envie mensagem pelo WhatsApp para testar
```

### Execuções subsequentes:

```powershell
# Sempre o mesmo comando:
./scripts/up-n8n.ps1

# Desta vez:
# ✅ Tudo sobe instantaneamente
# ✅ Sessão WhatsApp já conectada (restaurada do volume)
# ✅ Workflow já está ativo
# ✅ ZERO configuração manual!
```

### O que acontece automaticamente:

#### 🐳 **Docker Compose (compose.yml)**
- ✅ WAHA inicia na porta 3000 com volume persistente
- ✅ n8n inicia na porta 5679 com entrypoint customizado
- ✅ API inicia na porta 5000 com ChromaDB

#### 🤖 **n8n Bootstrap (automático via deploy/bootstrap/n8n-bootstrap.sh)**
- ✅ Inicia n8n em background
- ✅ Aguarda healthcheck (até 60s)
- ✅ Importa `chatbot_completo_n8n.json`
- ✅ Cria credencial WAHA com Header Auth (X-Api-Key)
- ✅ Ativa workflow (ID=1 ou nome "Chatbot Completo n8n")
- ✅ Mantém n8n rodando em foreground
- ✅ **ZERO interação manual!**

#### 📱 **WAHA (verificação inteligente via up-n8n.ps1)**
- ✅ Lê `WAHA_API_KEY` do .env automaticamente
- ✅ Tenta conectar via API: `/api/sessions/default`
- ✅ **Se status = WORKING**: 
  - Informa "WhatsApp já conectado!"
  - Pula QR code
- ✅ **Se status = STOPPED/FAILED/SCAN_QR_CODE**:
  - Inicia sessão via `/api/sessions/start`
  - Abre navegador com http://localhost:3000
  - Monitora status a cada 3s por até 60s
  - Detecta quando QR code é escaneado
  - Confirma conexão bem-sucedida
- ✅ **Se timeout**: Orienta a conectar manualmente depois
- ✅ Sessão persiste no volume `waha_data` (próxima vez já vem conectado!)

## 🔐 Credenciais

### n8n
- **URL**: http://localhost:5679
- **Usuário**: `admin`
- **Senha**: `Tributos@NovaTrento2025`
- **Status**: Auto-configurado (não pede setup!)

### WAHA
- **URL**: http://localhost:3000
- **Usuário**: `admin`
- **Senha**: `Tributos@NovaTrento2025`

### API
- **URL**: http://localhost:5000
- **Health**: http://localhost:5000/health
- **Autenticação**: Nenhuma (uso interno)

## 📋 Checklist de Verificação

Após executar `./scripts/up-n8n.ps1`:

- [ ] 3 containers rodando (WAHA, n8n, API)
- [ ] n8n acessível em http://localhost:5679
- [ ] Login n8n funciona com `admin` / `Tributos@NovaTrento2025`
- [ ] Workflow "Chatbot Completo n8n" aparece na lista
- [ ] Workflow está ATIVADO (toggle verde)
- [ ] Community node "n8n-nodes-waha" instalado
- [ ] Credencial WAHA criada e configurada
- [ ] WAHA acessível em http://localhost:3000
- [ ] Sessão WhatsApp conectada (ou QR code exibido)

## 🐛 Troubleshooting

### n8n pede setup mesmo com N8N_BASIC_AUTH

**Problema**: Tela de "Create Owner" aparece

**Solução**: 
```powershell
# 1. Parar tudo
docker compose down -v

# 2. Verificar .env
cat .env | Select-String "N8N_USER"

# 3. Reiniciar
./scripts/up-n8n.ps1
```

### Workflow não aparece no n8n

**Problema**: Lista de workflows está vazia

**Solução**:
```powershell
# 1. Verificar logs do bootstrap
docker logs tributos_n8n | Select-String "workflow"

# 2. Importar manualmente
# - Acesse n8n UI
# - Settings → Import from file
# - Selecione: n8n/workflows/chatbot_completo_n8n.json
```

### Community node n8n-nodes-waha não instalado

**Problema**: Nodes WAHA não aparecem na paleta

**Solução**:
```powershell
# 1. Verificar logs
docker logs tributos_n8n | Select-String "n8n-nodes-waha"

# 2. Instalar manualmente
# - Acesse n8n UI
# - Settings → Community Nodes
# - Install: n8n-nodes-waha
```

### WAHA não inicia sessão automaticamente

**Problema**: Sessão sempre pede QR code

**Solução**:
```powershell
# 1. Verificar se volume persiste
docker volume ls | Select-String "waha"

# 2. Iniciar sessão manualmente
./scripts/start-waha-session.ps1

# 3. Após escanear QR, dados ficam em ./data/waha/
```

## 📁 Arquivos Importantes

| Arquivo | Propósito | Estado |
|---------|-----------|--------|
| `n8n/workflows/chatbot_completo_n8n.json` | Workflow consolidado | ✅ Criado |
| `deploy/bootstrap/n8n-bootstrap.sh` | Script de auto-configuração | ✅ Existente |
| `compose.yml` | Orquestração Docker | ✅ Atualizado |
| `.env` | Credenciais | ✅ Atualizado |
| `scripts/up-n8n.ps1` | Inicialização melhorada | ✅ Atualizado |

## 🎯 Próximos Passos

### Desenvolvimento Local
```powershell
# Após primeira configuração, sempre use:
./scripts/up-n8n.ps1

# Ver logs específicos:
docker logs -f tributos_n8n   # n8n
docker logs -f tributos_waha  # WAHA
docker logs -f tributos_api   # API

# Recarregar conhecimento:
./scripts/load-knowledge.ps1
```

### Deploy Produção
```powershell
# 1. Atualizar .env com credenciais reais
nano .env

# 2. Deploy completo
./scripts/deploy-completo.ps1

# 3. Verificar health
./scripts/health-check.ps1
```

## ✨ Resumo das Melhorias

| Antes | Depois |
|-------|--------|
| 8 workflows confusos | 1 workflow consolidado |
| Setup manual do n8n | Auto-configuração com credenciais |
| Instalar node manualmente | Auto-instala n8n-nodes-waha |
| Importar workflow manualmente | Auto-importa e ativa |
| Sempre mostra QR code | Inteligente: só mostra se preciso |
| Instruções longas | "Execute up-n8n.ps1 e pronto!" |

---

**Criado em**: 2025-01-06  
**Versão**: 1.0.0  
**Autor**: Chatbot Tributos Team
