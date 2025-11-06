# 🚀 Deploy de Produção - Guia Completo

Este guia documenta o processo de deploy **100% automatizado** do Chatbot de Tributos em ambiente de produção.

## 📋 Índice

1. [Pré-requisitos](#pré-requisitos)
2. [Preparação do Servidor](#preparação-do-servidor)
3. [Configuração DNS](#configuração-dns)
4. [Configuração de Variáveis de Ambiente](#configuração-de-variáveis-de-ambiente)
5. [Deploy Zero-Touch](#deploy-zero-touch)
6. [Validação Pós-Deploy](#validação-pós-deploy)
7. [Backup e Recuperação](#backup-e-recuperação)
8. [Troubleshooting](#troubleshooting)

---

## 🔧 Pré-requisitos

### Servidor

- **OS**: Ubuntu 22.04 LTS ou superior (recomendado)
- **RAM**: Mínimo 8GB, recomendado 16GB
- **Disco**: Mínimo 50GB SSD
- **Portas**: 80, 443 (HTTP/HTTPS)

### Software

- **Docker**: 24.0+ com Docker Compose v2
- **Git**: Para clonar repositório
- **Acesso root**: Para configurar firewall e portas

### Credenciais Necessárias

1. **Cloudflare** (para HTTPS automático):
   - Email da conta Cloudflare
   - API Token com permissões DNS:Edit

2. **LLM Provider** (escolha um):
   - Groq API Key (gratuito, recomendado para início)
   - OpenAI API Key
   - xAI API Key

3. **WhatsApp**:
   - Número de telefone com WhatsApp instalado
   - Acesso ao app para escanear QR code

---

## 🖥️ Preparação do Servidor

### 1. Instalar Docker

```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com | sh

# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

# Instalar Docker Compose v2 (se não veio com Docker)
sudo apt install docker-compose-plugin -y

# Verificar instalação
docker --version
docker compose version
```

### 2. Configurar Firewall

```bash
# Permitir HTTP e HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Habilitar firewall (se ainda não estiver)
sudo ufw enable

# Verificar status
sudo ufw status
```

### 3. Clonar Repositório

```bash
# Criar diretório para aplicação
mkdir -p /opt/chatbot
cd /opt/chatbot

# Clonar repositório
git clone https://github.com/arturmelo2/chatbot-tributos.git .

# Dar permissões corretas
chmod +x scripts/*.sh
chmod +x scripts/*.ps1
chmod +x deploy/bootstrap/*.sh
```

---

## 🌐 Configuração DNS

### Cloudflare (Recomendado)

1. Acesse [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Selecione seu domínio (ex: `exemplo.com.br`)
3. Vá em **DNS** → **Records**
4. Adicione os seguintes registros **tipo A**:

| Nome | Tipo | Conteúdo | Proxy |
|------|------|----------|-------|
| `waha` | A | `IP_DO_SERVIDOR` | ✅ Proxied |
| `n8n` | A | `IP_DO_SERVIDOR` | ✅ Proxied |
| `api` | A | `IP_DO_SERVIDOR` | ✅ Proxied |

**Nota**: Se quiser usar subdomínio, exemplo `chatbot.exemplo.com.br`:
- `waha.chatbot.exemplo.com.br`
- `n8n.chatbot.exemplo.com.br`
- `api.chatbot.exemplo.com.br`

### Obter API Token do Cloudflare

1. No Cloudflare Dashboard, clique no **ícone do perfil** → **My Profile**
2. Vá em **API Tokens** → **Create Token**
3. Use template **Edit zone DNS**
4. Configure:
   - **Permissions**: Zone → DNS → Edit
   - **Zone Resources**: Include → Specific zone → `seu-dominio.com.br`
5. **Create Token** → Copie o token (não será mostrado novamente!)

---

## 🔐 Configuração de Variáveis de Ambiente

### 1. Criar arquivo .env

```bash
cd /opt/chatbot
cp .env.production.example .env
nano .env
```

### 2. Preencher variáveis obrigatórias

```bash
# =============================================================================
# DOMAIN & NETWORKING
# =============================================================================
DOMAIN=exemplo.com.br                          # SEU DOMÍNIO
CF_API_EMAIL=seu-email@example.com             # EMAIL DO CLOUDFLARE
CF_DNS_API_TOKEN=seu-cloudflare-api-token      # TOKEN CRIADO ACIMA

# =============================================================================
# N8N
# =============================================================================
N8N_WEBHOOK_ID=94a8adfc-1dba-41e7-be61-4c13b51fa08e  # Pode manter ou gerar novo
N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)            # GERAR NOVO!

N8N_PROTOCOL=https
N8N_OWNER_EMAIL=admin@exemplo.com.br           # EMAIL DO ADMIN N8N
N8N_OWNER_PASSWORD=SenhaForte123!              # SENHA DO ADMIN N8N (mínimo 8 chars)
N8N_OWNER_FIRST_NAME=Admin
N8N_OWNER_LAST_NAME=Chatbot

# =============================================================================
# WAHA (WhatsApp)
# =============================================================================
WAHA_API_KEY=tributos_nova_trento_2025_api_key_fixed  # Pode manter
WAHA_DASHBOARD_USERNAME=admin
WAHA_DASHBOARD_PASSWORD=SenhaDashboardWAHA123!       # TROCAR POR SENHA FORTE

# =============================================================================
# LLM PROVIDER (escolha um)
# =============================================================================
LLM_PROVIDER=groq                              # Opções: groq, openai, xai
LLM_MODEL=llama-3.3-70b-versatile

# GROQ (gratuito, recomendado)
GROQ_API_KEY=gsk_SEU_GROQ_API_KEY_AQUI

# Ou OpenAI (se preferir)
# OPENAI_API_KEY=sk-SEU_OPENAI_API_KEY_AQUI

# Ou xAI (se preferir)
# XAI_API_KEY=xai-SEU_XAI_API_KEY_AQUI

# =============================================================================
# CONFIGURAÇÕES
# =============================================================================
EMBEDDING_MODEL=sentence-transformers/all-MiniLM-L6-v2
AUTO_LOAD_KNOWLEDGE=true
LOG_LEVEL=INFO
```

### 3. Gerar chaves seguras

```bash
# Gerar N8N_ENCRYPTION_KEY
openssl rand -hex 32

# Gerar N8N_WEBHOOK_ID (opcional)
uuidgen
```

### 4. Proteger arquivo .env

```bash
chmod 600 .env
```

---

## 🚀 Deploy Zero-Touch

### 1. Preparar estrutura de dados

```bash
# Criar diretórios para volumes persistentes
mkdir -p data/{waha/session,n8n,chroma,redis}
mkdir -p reverse-proxy
mkdir -p logs exports backups

# Criar arquivo acme.json para certificados SSL
touch reverse-proxy/acme.json
chmod 600 reverse-proxy/acme.json
```

### 2. (Opcional) Restaurar sessão WAHA existente

Se você já tem uma sessão WAHA configurada de outro ambiente:

```bash
# Copiar backup de sessão
cp -r /caminho/para/backup/session/* data/waha/session/

# Ajustar permissões
chmod -R 755 data/waha/
```

**Nota**: Se não tiver backup, você escaneará o QR code após o deploy.

### 3. Iniciar stack completo

```bash
# Subir todos os serviços
docker compose -f compose.prod.yml up -d

# Acompanhar logs
docker compose -f compose.prod.yml logs -f
```

### 4. Aguardar inicialização

O processo automático irá:
1. ✅ Traefik: Configurar HTTPS e obter certificados Let's Encrypt (~30s)
2. ✅ Redis: Iniciar cache (~5s)
3. ✅ ChromaDB: Iniciar banco vetorial (~10s)
4. ✅ WAHA: Iniciar WhatsApp API (~30s)
5. ✅ n8n: Auto-criar usuário, instalar packages, importar workflows (~60s)
6. ✅ API: Carregar knowledge base e iniciar (~90s)

**Tempo total estimado: 2-3 minutos**

---

## ✅ Validação Pós-Deploy

### 1. Verificar containers

```bash
docker compose -f compose.prod.yml ps
```

**Esperado**: Todos com status `healthy` ou `running`

### 2. Verificar logs

```bash
# API
docker compose -f compose.prod.yml logs api | tail -50

# n8n
docker compose -f compose.prod.yml logs n8n | tail -50

# WAHA
docker compose -f compose.prod.yml logs waha | tail -50
```

### 3. Testar endpoints HTTPS

```bash
# API health
curl https://api.seu-dominio.com.br/health

# n8n health
curl https://n8n.seu-dominio.com.br/healthz

# WAHA dashboard
curl https://waha.seu-dominio.com.br/
```

### 4. Acessar interfaces

| Serviço | URL | Credenciais |
|---------|-----|-------------|
| **n8n** | `https://n8n.seu-dominio.com.br` | Email e senha do `.env` (N8N_OWNER_*) |
| **WAHA** | `https://waha.seu-dominio.com.br` | Username: `admin`, Senha do `.env` (WAHA_DASHBOARD_PASSWORD) |
| **Traefik** | `https://traefik.seu-dominio.com.br:8080` | Sem autenticação (desabilite em produção!) |

### 5. Configurar WhatsApp (se não restaurou sessão)

1. Acesse `https://waha.seu-dominio.com.br`
2. Login com credenciais do WAHA
3. Clique em **Start Session**
4. Escaneie o QR code com WhatsApp no celular
5. Aguarde status mudar para **WORKING**

### 6. Ativar workflows no n8n

1. Acesse `https://n8n.seu-dominio.com.br`
2. Login com credenciais do n8n (do `.env`)
3. Vá em **Workflows**
4. Abra workflow `Chatbot Completo - Orquestração`
5. **IMPORTANTE**: Clique no toggle no canto superior direito para **Ativar** (deve ficar verde)

### 7. Testar chatbot

Envie mensagem no WhatsApp para o número conectado:

```
Olá! Qual o horário de atendimento?
```

Resposta esperada em ~2-5 segundos.

---

## 💾 Backup e Recuperação

### Backup Manual

```bash
# Parar serviços
docker compose -f compose.prod.yml down

# Criar backup
tar -czf backup-$(date +%Y%m%d-%H%M%S).tar.gz data/

# Reiniciar serviços
docker compose -f compose.prod.yml up -d
```

### Backup Automatizado (Cron)

```bash
# Editar crontab
crontab -e

# Adicionar linha (backup diário às 3h)
0 3 * * * cd /opt/chatbot && tar -czf backups/backup-$(date +\%Y\%m\%d).tar.gz data/ && find backups/ -name "backup-*.tar.gz" -mtime +7 -delete
```

### Restaurar Backup

```bash
# Parar serviços
docker compose -f compose.prod.yml down

# Extrair backup
tar -xzf backups/backup-YYYYMMDD-HHMMSS.tar.gz

# Reiniciar serviços
docker compose -f compose.prod.yml up -d
```

---

## 🔧 Troubleshooting

### Problema: Certificado SSL não gerado

**Sintoma**: Erro "SSL handshake failed" ao acessar URLs

**Diagnóstico**:
```bash
# Ver logs do Traefik
docker compose -f compose.prod.yml logs traefik | grep -i acme
```

**Soluções**:
1. Verificar DNS propagado: `dig waha.seu-dominio.com.br`
2. Verificar API Token Cloudflare no `.env`
3. Verificar `acme.json` tem permissão 600: `ls -la reverse-proxy/acme.json`
4. Forçar renovação:
   ```bash
   docker compose -f compose.prod.yml down
   rm reverse-proxy/acme.json
   touch reverse-proxy/acme.json
   chmod 600 reverse-proxy/acme.json
   docker compose -f compose.prod.yml up -d
   ```

### Problema: n8n não cria usuário automaticamente

**Sintoma**: Login n8n pede para criar conta, mas bootstrap deveria ter criado

**Diagnóstico**:
```bash
# Ver logs do bootstrap
docker compose -f compose.prod.yml logs n8n | grep -i bootstrap
```

**Soluções**:
1. Verificar variáveis N8N_OWNER_* no `.env`
2. Remover marker file e reiniciar:
   ```bash
   docker compose -f compose.prod.yml exec n8n rm -f /home/node/.n8n/.bootstrap_done
   docker compose -f compose.prod.yml restart n8n
   ```
3. Criar usuário manualmente:
   ```bash
   docker compose -f compose.prod.yml exec n8n n8n user:create \
     --email admin@exemplo.com.br \
     --password SenhaForte123 \
     --firstName Admin \
     --lastName Chatbot
   ```

### Problema: API não carrega knowledge base

**Sintoma**: Respostas "não encontrei informações suficientes"

**Diagnóstico**:
```bash
# Verificar se ChromaDB tem dados
docker compose -f compose.prod.yml exec api ls -lh /app/chroma_data/
```

**Soluções**:
1. Forçar reload:
   ```bash
   docker compose -f compose.prod.yml exec api python rag/load_knowledge.py
   ```
2. Verificar logs de carregamento:
   ```bash
   docker compose -f compose.prod.yml logs api | grep -i knowledge
   ```

### Problema: WAHA não conecta WhatsApp

**Sintoma**: QR code não aparece ou sessão fica em "FAILED"

**Diagnóstico**:
```bash
docker compose -f compose.prod.yml logs waha | tail -100
```

**Soluções**:
1. Limpar sessão e reiniciar:
   ```bash
   docker compose -f compose.prod.yml down
   rm -rf data/waha/*
   docker compose -f compose.prod.yml up -d waha
   ```
2. Verificar se WhatsApp Web está disponível no navegador
3. Tentar com outro número de telefone

### Problema: Mensagens não chegam no chatbot

**Sintoma**: Envio mensagem no WhatsApp mas nada acontece

**Diagnóstico**:
```bash
# Ver se webhook está configurado
docker compose -f compose.prod.yml logs waha | grep -i webhook

# Ver se n8n recebe webhook
docker compose -f compose.prod.yml logs n8n | grep -i webhook
```

**Soluções**:
1. Verificar workflow n8n está **ATIVO** (toggle verde)
2. Verificar webhook URL no WAHA:
   ```bash
   curl -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed" \
     https://waha.seu-dominio.com.br/api/default
   ```
3. Testar webhook manualmente:
   ```bash
   curl -X POST https://n8n.seu-dominio.com.br/webhook/94a8adfc-1dba-41e7-be61-4c13b51fa08e \
     -H "Content-Type: application/json" \
     -d '{"event":"message","payload":{"from":"5511999999999@c.us","body":"teste"}}'
   ```

### Obter Ajuda

1. **Documentação**: Veja `docs/` para guias específicos
2. **Logs completos**: `docker compose -f compose.prod.yml logs > debug.log`
3. **GitHub Issues**: https://github.com/arturmelo2/chatbot-tributos/issues

---

## 📚 Próximos Passos

Após deploy bem-sucedido:

1. ✅ **Monitoramento**: Configure alertas para containers down
2. ✅ **Backup**: Ative cron de backup automático
3. ✅ **Segurança**: Desabilite Traefik dashboard (comentar labels no compose.prod.yml)
4. ✅ **Customização**: Adicione documentos em `rag/data/` e recarregue knowledge base
5. ✅ **Escalabilidade**: Considere aumentar recursos se volume > 10k msgs/dia

---

**🎉 Parabéns! Seu chatbot está em produção com deploy 100% automatizado!**

Para dúvidas ou sugestões, abra uma issue no GitHub.
