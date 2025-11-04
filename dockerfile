# =============================================================================
# Dockerfile - Chatbot de Tributos Nova Trento/SC
# =============================================================================

FROM python:3.11-slim

# Variáveis de ambiente
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Diretório de trabalho
WORKDIR /app

# Instalar dependências do sistema mínimas (apenas para build de wheels)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       gcc \
       g++ \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements e instalar dependências Python
COPY requirements.txt .
RUN python -m pip install --upgrade pip && \
    pip install -r requirements.txt && \
    apt-get purge -y --auto-remove gcc g++ && \
    rm -rf /var/lib/apt/lists/*

# Copiar código da aplicação
COPY . .

# Criar diretório para dados do Chroma (será montado como volume)
RUN mkdir -p /app/chroma_data

# Expor porta da aplicação
EXPOSE 5000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:5000/health', timeout=5)" || exit 1

# Comando de inicialização
CMD ["python", "app.py"]
