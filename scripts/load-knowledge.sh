#!/bin/bash
# Auto-load knowledge base into ChromaDB on first boot

set -e

KNOWLEDGE_DIR="${KNOWLEDGE_PATH:-/app/rag/data}"
MARKER_FILE="/app/chroma_data/.knowledge_loaded"

if [ -f "$MARKER_FILE" ]; then
    echo "✅ Knowledge base already loaded (marker found)"
    exit 0
fi

echo "📚 Loading knowledge base from $KNOWLEDGE_DIR..."
python rag/load_knowledge.py

# Create marker to prevent re-loading
touch "$MARKER_FILE"
echo "✅ Knowledge base loaded successfully"
