# 🚀 Chatbot de Tributos - Guia de Produção

> **Sistema 100% pronto para uso** com todas as credenciais configuradas.

## ⚡ Início Rápido - 3 Comandos

```powershell
# 1. Deploy automático completo
.\scripts\deploy-completo.ps1

# 2. Configurar n8n (acessar http://localhost:5679 e seguir instruções)

# 3. Conectar WhatsApp
.\scripts\start-waha-session.ps1
```

**Pronto!** O sistema está operacional.

---

## 🔐 Credenciais Configuradas

### xAI Grok (LLM)
- ✅ **Provider:** xAI
- ✅ **Modelo:** grok-4-fast-reasoning
- ✅ **API Key:** Configurada

### Groq (LLM alternativo)
- ✅ **Provider:** Groq
- ✅ **API Key:** Configurada
- Para usar, altere `LLM_PROVIDER=groq` no `.env`

### WAHA Dashboard
- 🔗 **URL:** http://localhost:3000
- 👤 **Usuário:** `admin`
- 🔑 **Senha:** `Tributos@NovaTrento2025`
- 🔐 **API Key:** `tributos_nova_trento_2025_api_key_fixed`

### n8n
- 🔗 **URL:** http://localhost:5679
- ✅ **Acesso direto (login desativado por padrão)**
- 🔒 Para habilitar autenticação em produção, defina `N8N_USER_MANAGEMENT_DISABLED=false` e crie um usuário proprietário.

---

## 📋 Checklist de Deploy

```powershell
# Executar verificação pré-deploy
.\scripts\pre-deploy-check.ps1
```

- [ ] Docker Desktop instalado e rodando
- [ ] Arquivo `.env` configurado
- [ ] Portas 3000, 5000, 5679 disponíveis
- [ ] Base de conhecimento em `rag/data/` (66 documentos)
- [ ] Workflows n8n em `n8n/workflows/`

---

## 🎯 Arquitetura em Produção

```
Internet
    │
    ▼
WhatsApp (Usuários)
    │
    ▼
WAHA:3000 (WhatsApp HTTP API)
    │
    ▼
n8n:5679 (Orquestração + Regras de Negócio)
    │
    ▼
API:5000 (Python + RAG + LLM)
    │
    ├──▶ ChromaDB (Base Vetorial - 66 docs)
    └──▶ xAI Grok / Groq (LLM)
```

### Responsabilidades

| Componente | Função | Tecnologia |
|------------|--------|------------|
| **WAHA** | Interface WhatsApp | Node.js |
| **n8n** | Orquestração, filtros, logging | Node.js |
| **API** | RAG, LLM, Histórico | Python 3.11 |
| **ChromaDB** | Base vetorial | Embedded |

---

## 🔧 Operações Diárias

### Iniciar Sistema
```powershell
docker-compose up -d
```

### Parar Sistema
```powershell
docker-compose stop
```

### Reiniciar API (após alterações)
```powershell
docker-compose restart api
```

### Ver Logs em Tempo Real
```powershell
# API
docker-compose logs -f api

# WAHA
docker-compose logs -f waha

# n8n
docker-compose logs -f n8n

# Todos
docker-compose logs -f
```

### Status do Sistema
```powershell
# Containers
docker-compose ps

# Health da API
curl http://localhost:5000/health

# Status WAHA
.\scripts\waha-status.ps1
```

### Recarregar Base de Conhecimento
```powershell
# Após adicionar novos documentos em rag/data/
docker-compose exec api python rag/load_knowledge.py --clear
```

---

## 📚 Base de Conhecimento

### Estrutura Atual
```
rag/data/
├── faqs/          # Perguntas frequentes
├── leis/          # Legislação municipal
├── manuais/       # Guias e procedimentos
└── procedimentos/ # Processos internos
```

**Total:** 66 documentos indexados

### Adicionar Novos Documentos

1. Adicionar arquivos (`.md`, `.pdf`, `.txt`) em `rag/data/`
2. Recarregar base:
   ```powershell
   docker-compose exec api python rag/load_knowledge.py --clear
   ```
3. Verificar nos logs: `✅ X documentos processados`

---

## 🔄 Workflows n8n

### Workflow Recomendado (Produção)
📄 `n8n/workflows/chatbot_completo_orquestracao.json`

**Funcionalidades:**
- ✅ Filtro de mensagens de grupo
- ✅ Anti-spam (6 mensagens/minuto)
- ✅ Horário comercial (7h-13h, seg-sex)
- ✅ Comandos `/humano` e `/bot`
- ✅ Typing indicators
- ✅ Logging estruturado
- ✅ Handoff para atendente humano

### Importar no n8n

> ✅ **Automático**: o `docker compose up -d` executa o serviço `n8n-bootstrap`, que instala o community node `n8n-nodes-waha` e ativa o workflow padrão automaticamente.

Caso queira usar outro fluxo:

1. Acesse http://localhost:5679 (login desativado para agilizar).
2. Menu → Import from File.
3. Selecione o arquivo desejado (ex.: `n8n/workflows/chatbot_completo_orquestracao.json`).
4. Ajuste credenciais e salve com outro nome para não sobrescrever o fluxo padrão.

---

## 📊 Monitoramento

### Health Checks
```powershell
# API
Invoke-RestMethod http://localhost:5000/health

# WAHA Sessions
$headers = @{"X-Api-Key"="tributos_nova_trento_2025_api_key_fixed"}
Invoke-RestMethod -Uri http://localhost:3000/api/sessions -Headers $headers

# n8n
Invoke-RestMethod http://localhost:5679/healthz
```

### Logs Estruturados

A API gera logs em JSON para fácil análise:
```json
{
  "timestamp": "2025-11-06T10:30:00Z",
  "level": "INFO",
  "logger": "app",
  "message": "Nova mensagem processada",
  "chat_id": "5511999999999@c.us",
  "response_time": 1.234
}
```

Localização: `logs/app.log`

### Exportar Histórico de Conversas
```powershell
.\scripts\export-history.ps1
```

Gera arquivo em `exports/waha_history_YYYYMMDD_HHMMSS.jsonl`

---

## 💾 Backup

### Volumes Docker (Dados Críticos)
```
chroma_data   - Base vetorial (conhecimento)
waha_data     - Sessões WhatsApp
n8n_data      - Workflows n8n
```

### Script de Backup
```powershell
# Criar pasta backup
mkdir backup -Force

# Backup ChromaDB
docker run --rm -v whatsapp-ai-chatbot_chroma_data:/data -v ${PWD}/backup:/backup alpine tar czf /backup/chroma_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').tar.gz -C /data .

# Backup WAHA
docker run --rm -v whatsapp-ai-chatbot_waha_data:/data -v ${PWD}/backup:/backup alpine tar czf /backup/waha_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').tar.gz -C /data .

# Backup n8n
docker run --rm -v whatsapp-ai-chatbot_n8n_data:/data -v ${PWD}/backup:/backup alpine tar czf /backup/n8n_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').tar.gz -C /data .
```

### Restaurar Backup
```powershell
# Parar containers
docker-compose down

# Restaurar (exemplo: ChromaDB)
docker run --rm -v whatsapp-ai-chatbot_chroma_data:/data -v ${PWD}/backup:/backup alpine sh -c "cd /data && tar xzf /backup/chroma_backup_YYYYMMDD_HHMMSS.tar.gz"

# Reiniciar
docker-compose up -d
```

---

## 🔄 Atualização do Sistema

### Pull de Atualizações
```powershell
# Parar sistema
docker-compose down

# Atualizar código
git pull

# Rebuild e restart
docker-compose build
docker-compose up -d

# Recarregar conhecimento (se necessário)
docker-compose exec api python rag/load_knowledge.py
```

### Trocar Provedor LLM

**Exemplo: xAI → Groq**

1. Editar `.env`:
   ```properties
   LLM_PROVIDER=groq
   LLM_MODEL=llama-3.3-70b-versatile
   ```

2. Reiniciar API:
   ```powershell
   docker-compose restart api
   ```

3. Verificar health:
   ```powershell
   curl http://localhost:5000/health
   ```

---

## 🚨 Troubleshooting

### Container não inicia
```powershell
# Ver logs detalhados
docker-compose logs [container-name]

# Rebuild sem cache
docker-compose build --no-cache [container-name]
docker-compose up -d
```

### Porta já em uso
```powershell
# Descobrir processo
netstat -ano | findstr :3000
netstat -ano | findstr :5000
netstat -ano | findstr :5679

# Matar processo (substitua PID)
taskkill /F /PID [PID]
```

### API retorna erro 503
```powershell
# Verificar se LLM está configurado
docker-compose exec api python -c "from services.config import get_settings; s=get_settings(); print(f'Provider: {s.LLM_PROVIDER}')"

# Verificar logs
docker-compose logs api | Select-String "ERROR"
```

### Base de conhecimento vazia
```powershell
# Recarregar com logs verbosos
docker-compose exec api python rag/load_knowledge.py --clear
```

### n8n workflow não dispara
1. Verificar se workflow está ATIVO (toggle verde)
2. Verificar webhook URL no WAHA:
   ```
   http://n8n:5678/webhook/8c0ac011-c46c-4c2c-bab1-ac5e0c3a365b/waha
   ```
3. Verificar credencial WAHA no n8n
4. Testar webhook manualmente:
   ```powershell
   .\scripts\test-n8n-webhook.ps1
   ```

---

## 🔐 Segurança em Produção

### ✅ Implementado
- [x] API Key fixa para WAHA
- [x] Variáveis sensíveis em `.env` (não versionado)
- [x] Network isolation (Docker)
- [x] Health checks
- [x] Logging sem dados pessoais

### 📋 Recomendado para Internet Pública
- [ ] Reverse proxy (nginx/Caddy) com HTTPS
- [ ] Firewall (permitir apenas portas necessárias)
- [ ] Rate limiting adicional
- [ ] Monitoramento de segurança (fail2ban)
- [ ] Backup automático diário
- [ ] Domínio próprio + SSL/TLS

### 🔒 Alterar Senhas Padrão
```powershell
# Editar .env
notepad .env

# Alterar:
# - WAHA_DASHBOARD_PASSWORD
# - WAHA_API_KEY (se desejar)

# Restart
docker-compose restart waha
```

---

## 🎯 Otimizações de Performance

### Limites de Recursos (já configurado)
```yaml
deploy:
  resources:
    limits:
      memory: 4G    # Máximo
    reservations:
      memory: 2G    # Mínimo garantido
```

### Cache de Embeddings
Base vetorial é persistente em volume Docker. Não precisa reprocessar documentos a cada restart.

### LLM Performance
- **xAI Grok:** ~2-3s por resposta
- **Groq:** ~0.5-1s por resposta (mais rápido)

Para respostas mais rápidas, considere trocar para Groq.

---

## 📞 Suporte

### Documentação
- 📘 [README.md](README.md) - Visão geral
- 🏗️ [ARCHITECTURE.md](ARCHITECTURE.md) - Arquitetura técnica
- 🚀 [DEPLOY.md](DEPLOY.md) - Guia de deploy detalhado
- 📚 [docs/](docs/) - Documentação adicional

### Scripts Úteis
```
scripts/
├── deploy-completo.ps1       # Deploy automático
├── pre-deploy-check.ps1      # Verificação pré-deploy
├── start-waha-session.ps1    # Conectar WhatsApp
├── waha-status.ps1           # Status do WAHA
├── export-history.ps1        # Exportar conversas
├── up-n8n.ps1               # Iniciar stack n8n
└── logs-api.ps1             # Ver logs da API
```

### Contato
- 📧 Email: ti@novatrento.sc.gov.br
- 🐛 Issues: https://github.com/arturmelo2/chatbot-tributos/issues

---

## ✅ Sistema Pronto!

O Chatbot de Tributos está **100% configurado e pronto para atender** os cidadãos de Nova Trento/SC.

**Desenvolvido com ❤️ para a Prefeitura Municipal de Nova Trento/SC**

---

**Versão:** 1.0.0  
**Data:** Novembro 2025  
**Status:** ✅ Produção
