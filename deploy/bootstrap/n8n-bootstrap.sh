#!/bin/sh
set -euo pipefail

DATA_DIR="${N8N_USER_FOLDER:-/home/node/.n8n}"
MARKER_NAME="${N8N_BOOTSTRAP_MARKER:-.bootstrap_done}"
MARKER_PATH="${DATA_DIR}/${MARKER_NAME}"
WORKFLOW_PATH="${N8N_BOOTSTRAP_WORKFLOW:-/bootstrap/workflows/waha_to_api_8c0ac011.json}"
COMMUNITY_NODE="${N8N_BOOTSTRAP_COMMUNITY_NODE:-n8n-nodes-waha}"

if [ -f "$MARKER_PATH" ]; then
  echo "✅ n8n já foi inicializado anteriormente. Pulando bootstrap."
  exit 0
fi

if [ ! -f "$WORKFLOW_PATH" ]; then
  echo "❌ Arquivo de workflow padrão não encontrado: $WORKFLOW_PATH" >&2
  exit 1
fi

mkdir -p "$DATA_DIR"

# Garantir permissões de escrita para o usuário padrão (node)
if command -v chown >/dev/null 2>&1; then
  chown -R node:node "$DATA_DIR" || true
fi

printf '\n🚀 Importando workflow padrão (%s) para o n8n...\n' "$WORKFLOW_PATH"

if [ ! -d "$DATA_DIR/node_modules/$COMMUNITY_NODE" ]; then
  printf '📦 Instalando community node %s...\n' "$COMMUNITY_NODE"
  su node -c "cd '$DATA_DIR' && npm install $COMMUNITY_NODE@latest"
fi

su node -c "n8n import:workflow --input='$WORKFLOW_PATH' --activate --overwrite"

touch "$MARKER_PATH"
if command -v chown >/dev/null 2>&1; then
  chown node:node "$MARKER_PATH" || true
fi

echo "✨ Bootstrap do n8n concluído com sucesso."
