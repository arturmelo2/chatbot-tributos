# Chatbot de Tributos - Nova Trento/SC

[![CI](https://github.com/arturmelo2/whatsapp-ai-chatbot/actions/workflows/ci.yml/badge.svg)](https://github.com/arturmelo2/whatsapp-ai-chatbot/actions/workflows/ci.yml)

Sistema de chatbot inteligente para atendimento automatizado sobre tributos municipais via WhatsApp.

**Arquitetura:** WhatsApp → WAHA → n8n (orquestração) → API Python (RAG+LLM) → n8n → WAHA

---

## 🎯 **SISTEMA 100% AUTOMATIZADO!**

> ✅ **Automação Zero-Touch: UM único comando faz tudo**  
> ✅ **Base de conhecimento com 65 documentos (461 chunks)**  
> ✅ **n8n auto-configura: workflow + credenciais + community node**  
> ✅ **WAHA verifica e conecta sessão automaticamente**

### ⚡ Deploy em 1 COMANDO (Zero-Touch)

```bash
# PRIMEIRO USO: Escaneia QR code uma vez
make up

# Carregar conhecimento (apenas uma vez)
make load-knowledge

# Ver todos os comandos disponíveis
make help

# PRÓXIMOS USOS: ZERO configuração, tudo automático!
make up
```

**📘 Guia completo de automação:** [**AUTOMACAO-N8N.md**](AUTOMACAO-N8N.md)  
**🧪 Checklist de testes:** [**TESTE-AUTOMACAO.md**](TESTE-AUTOMACAO.md)  
**� Migração PowerShell → Makefile:** [**MIGRACAO-MAKEFILE.md**](MIGRACAO-MAKEFILE.md)

---

## 🚀 O que acontece automaticamente

### 1️⃣ **Docker Compose**
- ✅ WAHA inicia na porta 3000
- ✅ n8n inicia na porta 5679 com bootstrap script
- ✅ API inicia na porta 5000

### 2️⃣ **n8n Bootstrap** (automático via script)
- ✅ Cria usuário `admin` / `Tributos@NovaTrento2025`
- ✅ Instala community node `n8n-nodes-waha`
- ✅ Importa workflow `chatbot_completo_n8n.json`
- ✅ Cria credencial WAHA (Header Auth)
- ✅ Ativa workflow

### 3️⃣ **WAHA** (verificação inteligente)
- ✅ Verifica sessão via API
- ✅ Se já conectado: informa "pronto"
- ✅ Se primeira vez: abre QR code automaticamente
- ✅ Aguarda escaneamento (60s timeout)
- ✅ Confirma conexão
- ✅ Próximas vezes: restaura sessão automaticamente

---

## 🔐 Credenciais (auto-configuradas)

| Serviço | URL | Usuário | Senha |
|---------|-----|---------|-------|
| **n8n** | http://localhost:5679 | `admin` | `Tributos@NovaTrento2025` |
| **WAHA** | http://localhost:3000 | `admin` | `Tributos@NovaTrento2025` |
| **API** | http://localhost:5000 | - | - |

---

## 🚀 Início Rápido (Detalhado)

```bash
# 1. Configurar LLM API Key (editar .env)
# Abrir .env e adicionar:
# GROQ_API_KEY=gsk_seu_token_aqui

# 2. APENAS ESTE COMANDO! (faz tudo)
make up
# → Sobe containers
# → Auto-configura n8n
# → Verifica WAHA
# → Abre QR code se necessário

# 3. Carregar conhecimento (apenas uma vez)
make load-knowledge

# 4. Ver comandos disponíveis
make help

# 5. Testar
# Envie mensagem pelo WhatsApp
```

## �️ Comandos Principais

```bash
make up              # Inicia todos os containers
make down            # Para todos os containers
make logs-api        # Logs da API
make logs-n8n        # Logs do n8n
make logs-waha       # Logs do WAHA
make status          # Status dos containers
make health          # Verifica health dos serviços
make load-knowledge  # Carrega base de conhecimento
make test            # Executa testes
make lint            # Verifica qualidade do código
make help            # Mostra todos os comandos
```

**💡 Dica:** Execute `make` ou `make help` para ver a lista completa de comandos disponíveis.

## �📋 Requisitos

- **Docker Desktop** (com Docker Compose v2)
- **Make** (vem com Git Bash no Windows, ou instale via Chocolatey/WSL)
- Chaves de API:
  - Groq ou OpenAI (para LLM)
  - WAHA (fixada no projeto)

## 🎯 Arquitetura

```
┌─────────────┐     ┌──────┐     ┌─────────────┐     ┌──────────────┐
│  WhatsApp   │────▶│ WAHA │────▶│     n8n     │────▶│  API Python  │
│             │◀────│      │◀────│ (orquestra) │◀────│  (RAG+LLM)   │
└─────────────┘     └──────┘     └─────────────┘     └──────────────┘
```

**Responsabilidades:**
- **WAHA**: Conexão WhatsApp, enviar/receber mensagens
- **n8n**: Orquestração visual, filtros, typing, erro handling, logging
- **API Python**: RAG (LangChain + ChromaDB), LLM (Groq/OpenAI), Histórico

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


## 📖 Guias e Documentação

### 🚀 Produção (COMECE AQUI!)
- [**START-HERE.md**](START-HERE.md) — 🎯 **Deploy em 5 minutos**
- [**PRODUCTION-README.md**](PRODUCTION-README.md) — Guia completo de produção
- [**DEPLOY.md**](DEPLOY.md) — Deploy detalhado passo a passo
- [**QUICK-START.ps1**](QUICK-START.ps1) — Script de deploy automático

### 📚 Documentação Técnica
- [ARCHITECTURE.md](ARCHITECTURE.md) — Arquitetura do sistema
- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) — Estrutura do repositório
- [CHANGELOG.md](CHANGELOG.md) — Histórico de versões
- [STATUS.md](STATUS.md) — Status do projeto

### 🛠️ Desenvolvimento
- [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) — Guia completo de desenvolvimento
- [docs/DOCKER_DESKTOP.md](docs/DOCKER_DESKTOP.md) — Instalação do Docker
- [docs/CONFIGURAR_N8N.md](docs/CONFIGURAR_N8N.md) — Integração n8n
- [docs/TROUBLESHOOTING_PORTA_3000.md](docs/TROUBLESHOOTING_PORTA_3000.md) — Resolver conflitos de porta
- [docs/QUICK_START_DOCKER.md](docs/QUICK_START_DOCKER.md) — Guia rápido Docker
- [docs/DOCS_TRIBUTOS.md](docs/DOCS_TRIBUTOS.md) — Documentação técnica
- [docs/CREDENCIAIS_WAHA.md](docs/CREDENCIAIS_WAHA.md) — Credenciais WAHA
- [docs/N8N_CHATBOT_COMPLETO.md](docs/N8N_CHATBOT_COMPLETO.md) — Guia n8n completo
- [docs/N8N_WORKFLOW.md](docs/N8N_WORKFLOW.md) — Workflow n8n

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
