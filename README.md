# Chatbot de Tributos - Nova Trento/SC

[![CI](https://github.com/arturmelo2/whatsapp-ai-chatbot/actions/workflows/ci.yml/badge.svg)](https://github.com/arturmelo2/whatsapp-ai-chatbot/actions/workflows/ci.yml)

Sistema de chatbot inteligente para atendimento automatizado sobre tributos municipais via WhatsApp, integrado com WAHA (WhatsApp HTTP API) e powered by RAG (Retrieval-Augmented Generation).

## 🚀 Início Rápido (Docker)

### Opção 1: Chatbot Completo em n8n (Recomendado)

```bash
# 1. Configurar variáveis de ambiente
cp .env.example .env
# Editar .env com suas credenciais (GROQ_API_KEY ou OPENAI_API_KEY)

# 2. Iniciar apenas WAHA e n8n
./scripts/up-n8n.ps1

# 3. Configurar n8n
# - Acesse http://localhost:5679
# - Crie conta
# - Instale community nodes: @n8n/n8n-nodes-langchain, n8n-nodes-waha
# - Importe workflow: n8n/workflows/chatbot_completo_n8n.json
# - Configure credenciais Groq/OpenAI
# - Ative o workflow

# 4. Testar
# Envie mensagem pelo WhatsApp conectado ao WAHA
```

### Opção 2: Com API Python (Avançado)

```bash
# 1. Configurar variáveis de ambiente
cp .env.example .env
# Editar .env com suas credenciais

# 2. Iniciar todos os serviços
./scripts/up.ps1

# 3. Carregar base de conhecimento
./scripts/load-knowledge.ps1

# 4. Testar
curl http://localhost:5000/health
```

## 📋 Requisitos

- **Docker Desktop** (com Docker Compose v2)
- **PowerShell** (scripts de automação)
- Chaves de API:
  - **Modo n8n**: Groq ou OpenAI (para LLM)
  - **Modo Python**: Groq/OpenAI/xAI (LLM provider)
  - WAHA API (WhatsApp) - fixada no projeto

## 🎯 Funcionalidades

- ✅ **RAG Inteligente**: Consulta base de documentos para respostas precisas
- ✅ **Multi-Provider LLM**: Groq (Llama 3.3), OpenAI (GPT-4o), xAI (Grok)
- ✅ **Histórico de Conversa**: Contexto mantido por usuário
- ✅ **Menu Interativo**: Rotas para links úteis (IPTU, Certidões, etc.)
- ✅ **Structured Logging**: Logs em JSON para análise
- ✅ **Auto-start Windows**: Inicialização automática via Scheduled Task

## 🛠️ Scripts PowerShell

### Modo n8n (Recomendado)

```bash
./scripts/up-n8n.ps1           # Iniciar WAHA + n8n
./scripts/waha-status.ps1       # Status do WAHA
```

### Modo Python (Avançado)

```bash
./scripts/up.ps1                # Iniciar todos os serviços
./scripts/rebuild.ps1           # Rebuild completo (limpa volumes)
./scripts/logs-api.ps1          # Ver logs da API
```

### Gerais

```bash
./scripts/load-knowledge.ps1    # Carregar documentos no ChromaDB
./scripts/export-history.ps1    # Exportar conversas do WAHA
### Gerais

```bash
./scripts/load-knowledge.ps1    # Carregar documentos no ChromaDB (modo Python)
./scripts/export-history.ps1    # Exportar conversas do WAHA
```

### Desenvolvimento (Modo Python)

```bash
./scripts/test.ps1              # Executar lint e testes
./scripts/install-auto-start.ps1 -DelaySeconds 60  # Auto-start no Windows
./scripts/uninstall-auto-start.ps1                 # Remover auto-start
```

## 📊 Logs Estruturados

Logs em formato JSON com campos:

```json
{
  "timestamp": "2025-11-04T12:34:56Z",
  "level": "INFO",
  "logger": "app",
  "message": "Nova mensagem processada",
  "module": "app",
  "function": "webhook",
  "line": 123,
  "chat_id": "5511999999999@c.us",
  "response_time": 1.234
}
```

## 🧪 Testes e Qualidade

### CI/CD (GitHub Actions)

Workflow automático executa em cada push:

- **Lint**: Ruff + Black + Mypy
- **Testes**: Pytest com cobertura
- **Build**: Docker image com cache

### Pre-commit Hooks

```bash
# Instalar hooks
pip install pre-commit
pre-commit install

# Executar manualmente
pre-commit run --all-files
```

Hooks configurados:
- `ruff` - Linter Python
- `ruff-format` - Auto-formatação
- `mypy` - Type checking
- `trailing-whitespace` - Remove espaços em branco
- `check-yaml` - Valida YAML
- `check-toml` - Valida TOML

### Executar Testes Localmente

```bash
# Lint e type-check
./scripts/test.ps1

# Testes com cobertura
pytest --cov=. --cov-report=html
# Abrir htmlcov/index.html para ver relatório
```

## 📁 Estrutura do Projeto

```
whatsapp-ai-chatbot/
├── n8n/
│   └── workflows/
│       └── chatbot_completo_n8n.json  # Workflow n8n completo
├── app.py                  # Aplicação Flask (opcional)
├── bot/
│   ├── ai_bot.py          # RAG + LLM chatbot (modo Python)
│   └── link_router.py     # Roteamento de menus
├── services/
│   ├── config.py          # Configuração centralizada
│   ├── logging_setup.py   # Setup de logging
│   ├── structured_logging.py  # Logging JSON
│   ├── waha.py            # Cliente WAHA API
│   └── version.py         # Versionamento
├── rag/
│   ├── load_knowledge.py  # Carregamento de documentos
│   └── data/              # Base de conhecimento
│       ├── faqs/
│       ├── leis/
│       ├── manuais/
│       └── procedimentos/
├── tests/                 # Testes (modo Python)
├── scripts/               # Automação PowerShell
├── .github/workflows/     # CI/CD GitHub Actions
├── compose.yml            # Docker Compose
├── dockerfile             # Container da API
└── pyproject.toml         # Config de dev tools
```

## 🔧 Configuração

### Variáveis de Ambiente (.env)

```env
# LLM Provider (groq, openai, xai)
LLM_PROVIDER=groq
LLM_MODEL=llama-3.3-70b-versatile
GROQ_API_KEY=gsk_...

# WAHA (WhatsApp)
WAHA_API_URL=http://waha:3000
WAHA_API_KEY=your-waha-key
WAHA_SESSION=default

# Aplicação
PORT=5000
ENVIRONMENT=production
DEBUG=false
LOG_LEVEL=INFO

# Caminhos
CHROMA_PATH=./chroma_data
KNOWLEDGE_PATH=./rag/data
```

## 📖 Guias Adicionais

- [DEVELOPMENT.md](DEVELOPMENT.md) - Guia completo de desenvolvimento
- [DOCKER_DESKTOP.md](DOCKER_DESKTOP.md) - Instalação do Docker
- [CONFIGURAR_N8N.md](CONFIGURAR_N8N.md) - Integração n8n
- [TROUBLESHOOTING_PORTA_3000.md](TROUBLESHOOTING_PORTA_3000.md) - Resolver conflitos de porta

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -m 'feat: adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

**Padrão de Commits**: Seguimos [Conventional Commits](https://www.conventionalcommits.org/)

## 📄 Licença

Este projeto é proprietário da Prefeitura Municipal de Nova Trento/SC.

## 🙏 Agradecimentos

- **WAHA** - WhatsApp HTTP API
- **LangChain** - Framework RAG
- **Groq** - LLM inference rápida
- **ChromaDB** - Vector database
