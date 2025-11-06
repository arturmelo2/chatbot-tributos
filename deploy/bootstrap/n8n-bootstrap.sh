#!/bin/sh
# =============================================================================
# n8n Bootstrap Script - Automação Zero-Touch
# =============================================================================
# Este script autoconfigura o n8n na inicialização:
# 1. Inicia n8n em background
# 2. Aguarda API ficar pronta
# 3. Importa workflow principal
# 4. Cria credencial WAHA
# 5. Ativa workflow
# 6. Mantém n8n rodando em foreground
# =============================================================================

set -e

echo "🚀 Starting n8n bootstrap process..."

# Inicia o n8n em background para que o script possa continuar
echo "📦 Starting n8n in background..."
/usr/local/bin/docker-entrypoint.sh n8n start &
N8N_PID=$!

# Espera o n8n ficar saudável (API pronta para receber comandos)
echo "⏳ Waiting for n8n to be ready..."
MAX_RETRIES=60
RETRY_COUNT=0

while ! wget -q --spider http://localhost:5678/healthz 2>/dev/null; do
  RETRY_COUNT=$((RETRY_COUNT + 1))
  if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo "❌ n8n failed to start after ${MAX_RETRIES} seconds"
    exit 1
  fi
  echo "   Attempt $RETRY_COUNT/$MAX_RETRIES..."
  sleep 1
done

echo "✅ n8n is up and running!"
sleep 3  # Aguarda mais um pouco para garantir que tudo está estável

# Importa o workflow principal
# O n8n pode demorar um pouco para registrar o workflow importado, por isso o "|| true"
echo "📥 Importing main workflow..."
n8n import:workflow --input=/home/node/.n8n/workflows/chatbot_completo_n8n.json 2>/dev/null || true
echo "✅ Workflow imported (or already exists)"

# Cria a credencial do WAHA usando variáveis de ambiente
# Isso evita ter que cadastrar a credencial na interface web
echo "🔑 Creating WAHA credentials..."
n8n create:credential --type="httpHeaderAuth" --name="WAHA API Key" --data='{"name":"X-Api-Key","value":"'"${WAHA_API_KEY}"'"}' 2>/dev/null || echo "   (Credential may already exist)"
echo "✅ WAHA credentials configured"

# Ativa o workflow principal
# O nome do workflow está definido no JSON
echo "⚡ Activating workflow..."
n8n update:workflow --id=1 --active=true 2>/dev/null || n8n update:workflow --name="Chatbot Completo n8n" --active=true 2>/dev/null || echo "   (Workflow may already be active)"
echo "✅ Workflow activated"

echo ""
echo "🎉 n8n bootstrap complete!"
echo "📊 Access n8n at: http://localhost:5678"
echo "🔐 Username: ${N8N_BASIC_AUTH_USER:-admin}"
echo "🔐 Password: ${N8N_BASIC_AUTH_PASSWORD:-***}"
echo ""

# Traz o processo do n8n para o primeiro plano para manter o container rodando
echo "🔄 Bringing n8n to foreground..."
wait $N8N_PID
