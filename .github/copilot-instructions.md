# Copilot Instructions - Chatbot de Tributos

> **TL;DR for AI Agents**: This is a 3-service WhatsApp chatbot: `WAHA` (WhatsApp connector) → `n8n` (workflow orchestration) → `Python API` (RAG+LLM). Start services with `.\scripts\up-n8n.ps1`. The API is **NOT** the entry point. See [Quick Start for AI Agents](#quick-start-for-ai-agents) below.

## Table of Contents

- [Quick Start for AI Agents](#quick-start-for-ai-agents)
- [Project Overview](#project-overview)
- [Service Boundaries & Data Flow](#service-boundaries--data-flow)
- [Key Code Patterns](#key-code-patterns)
- [Development Workflows](#development-workflows)
- [Critical Conventions](#critical-conventions)
- [Common Tasks](#common-tasks)
- [Debugging Tips](#debugging-tips)
- [File Reference](#file-reference)
- [Anti-Patterns to Avoid](#anti-patterns-to-avoid)
- [Commit Conventions](#commit-conventions)
- [Performance Optimization](#performance-optimization)
- [Testing Strategy](#testing-strategy)
- [Monitoring & Observability](#monitoring--observability)
- [Data Management](#data-management)
- [Common Gotchas](#common-gotchas)
- [IDE Configuration](#ide-configuration)
- [Windows-Specific Notes](#windows-specific-notes)
- [CI/CD Pipeline](#cicd-pipeline-githubworkflowsciyml)
- [Advanced Features](#advanced-features)
- [PowerShell Scripts Deep Dive](#powershell-scripts-deep-dive)
- [Docker Architecture Details](#docker-architecture-details)
- [Troubleshooting Patterns](#troubleshooting-patterns)
- [Code Quality Tools Configuration](#code-quality-tools-configuration)
- [Security Considerations](#security-considerations)
- [Production Deployment](#production-deployment)
- [Extension Points](#extension-points)
- [Technology Alternatives & Migration](#technology-alternatives--migration)
- [Quick Reference](#quick-reference)
- [Glossary](#glossary)
- [Version History Reference](#version-history-reference)

## Quick Start for AI Agents

**Context**: You're working on a **3-service orchestrated WhatsApp chatbot** for Brazilian municipal tax inquiries. The architecture is: WhatsApp → WAHA → n8n → Python API (RAG+LLM).

### Critical First Steps

1. **Start services**: `.\scripts\up-n8n.ps1` (PowerShell on Windows)
2. **Check health**: `.\scripts\health-check.ps1`
3. **View logs**: `docker compose logs -f api`

### Most Common Tasks

```powershell
# Load knowledge base
.\scripts\load-knowledge.ps1

# Test webhook manually
.\scripts\test-n8n-webhook.ps1

# Rebuild after code changes
.\scripts\rebuild.ps1

# Run tests
.\scripts\test.ps1
```

### Architecture Mental Model

```
User WhatsApp → WAHA (port 3000) → n8n (port 5679) → API (port 5000) → LLM + RAG
                 ↓                   ↓                  ↓
               Session           Orchestration      ChromaDB
               Storage           Anti-spam          (vectorDB)
                                Bus Hours          
                                Typing            
```

### Key Files to Know

| File | Purpose | When to Edit |
|------|---------|--------------|
| `app.py` | Webhook handler with payload coercion | API endpoint changes, payload format issues |
| `bot/ai_bot.py` | RAG+LLM core, multi-provider support | Change retrieval params, add LLM provider, modify prompts |
| `services/config.py` | All settings (frozen dataclass) | Add new env vars, change defaults |
| `compose.yml` | 3-service definitions | Add services, change ports, update env vars |
| `rag/load_knowledge.py` | Knowledge base loader | Add doc types, change chunking strategy |
| `.env` | Credentials (NEVER commit) | Change API keys, configure LLM |

### Code Patterns You MUST Follow

1. **Payload Coercion** (`app.py` webhook):
   ```python
   # n8n sends 3 different formats - coerce all to standard
   if "event" not in data and "from" in data:
       data = {"event": "message", "payload": data}
   ```

2. **Typing Indicators** (always `try/finally`):
   ```python
   waha.start_typing(chat_id)
   try:
       response = ai_bot.invoke(history, question)
       waha.send_message(chat_id, response)
   finally:
       waha.stop_typing(chat_id)  # MUST run even on error
   ```

3. **Configuration** (singleton pattern):
   ```python
   from services.config import get_settings
   settings = get_settings()  # Cached, frozen dataclass
   ```

4. **Logging** (structured JSON):
   ```python
   from services.logging_setup import setup_logging
   logger = logging.getLogger(__name__)
   logger.info(f"Processing {chat_id}", extra={"chat_id": chat_id})
   ```

### Don't Break These Rules

❌ **DON'T** call WAHA directly from webhooks - n8n orchestrates  
❌ **DON'T** use `print()` - use `logger.info()`  
❌ **DON'T** hardcode credentials - use `.env` via `get_settings()`  
❌ **DON'T** modify `WAHA_API_KEY` - it's intentionally fixed  
❌ **DON'T** commit `.env` or `chroma_data/`  
❌ **DON'T** skip group message filtering (`@g.us` check)  

### Debugging Flow

```
1. Message not reaching API?
   → Check n8n logs: docker compose logs -f n8n
   → Check webhook URL in WAHA: .\scripts\waha-status.ps1
   → Verify n8n workflow is ACTIVATED (toggle in UI)

2. API errors?
   → Check API logs: .\scripts\logs-api.ps1
   → Verify ChromaDB loaded: ls chroma_data/ (should have .sqlite3)
   → Test health: curl http://localhost:5000/health

3. Empty responses?
   → Load knowledge: .\scripts\load-knowledge.ps1
   → Check retrieval params: bot/ai_bot.py → __build_retriever()
   → Verify LLM API key: echo $env:GROQ_API_KEY

4. WhatsApp disconnected?
   → Start session: .\scripts\start-waha-session.ps1
   → Scan QR code with WhatsApp mobile app
```

### RAG Tuning Quick Reference

**Location**: `bot/ai_bot.py` → `__build_retriever()`

**Current**: MMR search with `k=30, lambda_mult=0.5`

**Adjustments**:
- **Too broad answers**: Decrease `k` to 10-15
- **Missing info**: Increase `k` to 40-50  
- **Repetitive context**: Decrease `lambda_mult` to 0.3
- **Sparse context**: Increase `lambda_mult` to 0.7

### LLM Provider Switching

**Current**: Groq (fast, free tier)

**Switch to OpenAI**:
```env
# .env
LLM_PROVIDER=openai
LLM_MODEL=gpt-4.1
OPENAI_API_KEY=sk-...
```

**Switch to xAI (Grok)**:
```env
# .env
LLM_PROVIDER=xai
LLM_MODEL=grok-4-fast-reasoning
XAI_API_KEY=xai-...
```

Then: `docker compose restart api`

### Common Gotchas

1. **n8n community node missing**: Install `n8n-nodes-waha` via UI (Settings → Community Nodes)
2. **ChromaDB dimension mismatch**: Changed embedding model? Run `.\scripts\load-knowledge.ps1 -Clear`
3. **Port 3000 conflict**: Another process using it? See `docs/TROUBLESHOOTING_PORTA_3000.md`
4. **Webhook format errors**: Check `app.py` payload coercion - might need new case

### Testing Before Committing

```powershell
# Run full test suite
.\scripts\test.ps1

# Or individual steps
ruff check .                    # Linting
black --check .                 # Formatting
mypy .                          # Type checking
pytest --cov=. --cov-report=html  # Tests + coverage
```

### When You Need Deep Context

- **Full architecture**: See [Service Boundaries & Data Flow](#service-boundaries--data-flow)
- **All scripts explained**: See [PowerShell Scripts Deep Dive](#powershell-scripts-deep-dive)
- **Production deploy**: See [Production Deployment](#production-deployment) or [Zero-Touch Docker Deployment](#zero-touch-docker-deployment-100-automated)
- **Migration playbooks**: See [Technology Alternatives & Migration](#technology-alternatives--migration)

---

## Project Overview

**WhatsApp Municipal Tax Chatbot** (Nova Trento/SC) - RAG-powered AI assistant for tax inquiries via WhatsApp.

**Architecture**: WhatsApp → WAHA → n8n (orchestration) → Python API (RAG+LLM) → response flow back

**Critical**: This is a 3-service orchestrated system. The Python API is NOT the entry point - n8n receives webhooks from WAHA and calls the API.

## Service Boundaries & Data Flow

### 1. WAHA (WhatsApp HTTP API)
- **Port**: 3000
- **Role**: WhatsApp Web interface, sends webhooks to n8n
- **Fixed credentials**: `WAHA_API_KEY=tributos_nova_trento_2025_api_key_fixed`
- **Session management**: Use `scripts/start-waha-session.ps1` to connect WhatsApp

### 2. n8n (Workflow Orchestration)
- **Port**: 5679
- **Role**: Message filtering, anti-spam, business hours, handoff logic, typing indicators
- **Workflows**: In `n8n/workflows/*.json` - import via n8n UI
- **Key node**: Community node `n8n-nodes-waha` must be installed manually
- **Webhook format**: Receives `{event: "message", payload: {...}}` from WAHA

### 3. Python API (Flask)
- **Port**: 5000
- **Role**: RAG retrieval (ChromaDB), LLM inference (Groq/OpenAI/xAI), conversation history
- **Entry**: `/chatbot/webhook/` POST endpoint (called by n8n, NOT directly by WAHA)
- **Health**: `/health` GET endpoint

## Key Code Patterns

### Configuration (services/config.py)
- **All settings** via `get_settings()` singleton using `python-decouple`
- Never hardcode credentials - always use `.env`
- Settings are frozen dataclasses with defaults

### LLM Provider Selection (bot/ai_bot.py)
- **Multi-provider**: Groq (default), OpenAI, xAI/Grok via `LLM_PROVIDER` env var
- **Model normalization**: `_normalize_model()` maps legacy names (e.g., `gpt-4o` → `gpt-4.1`)
- **Default models**: 
  - Groq: `llama-3.3-70b-versatile`
  - OpenAI: `gpt-4.1`
  - xAI: `grok-4-fast-reasoning`

### RAG Architecture (bot/ai_bot.py)
- **Embeddings**: HuggingFace `sentence-transformers/all-MiniLM-L6-v2`
- **Vector DB**: ChromaDB (embedded, persisted to `chroma_data/`)
- **Retrieval**: MMR search with `k=30, lambda_mult=0.5` for diversity
- **Context formatting**: Sources annotated as `[Fonte: {filename}]` in prompt
- **System prompt**: `SPECIALIZED_SYSTEM_TEMPLATE` - instructs AI to ONLY use provided context, never hallucinate

### Message History Format
```python
[
  {"role": "user", "content": "..."},
  {"role": "assistant", "content": "..."}
]
```
Converted to LangChain messages via `_to_langchain_messages()` helper.

### WAHA Integration (services/waha.py)
- **Client class**: `Waha()` with timeout handling (default 10s)
- **Key methods**:
  - `send_message(chat_id, message)` - send text
  - `get_history_messages(chat_id, limit)` - fetch conversation (returns normalized format)
  - `start_typing(chat_id)` / `stop_typing(chat_id)` - typing indicators
- **Error handling**: Always wrap in try/finally to ensure typing stops

### Logging (services/logging_setup.py)
- **Structured JSON logs**: Use `JSONFormatter` for production
- **Fields**: timestamp, level, logger, message, module, function, line, chat_id (when available), response_time
- **Masking**: Never log sensitive data (CPF, phone numbers)

## Development Workflows

### Local Setup
```powershell
# PowerShell scripts are the primary dev interface
.\scripts\up-n8n.ps1          # Start WAHA + n8n only
.\scripts\up.ps1               # Start full stack (WAHA + n8n + API)
.\scripts\rebuild.ps1          # Rebuild API container (after dependency changes)
.\scripts\load-knowledge.ps1   # Load documents into ChromaDB
```

### Testing & Quality
```powershell
.\scripts\test.ps1             # Ruff + Black + Mypy + Pytest
make test                      # Alternative (requires make on Windows)
pytest --cov=. --cov-report=html  # Coverage report
```

### Code Style
- **Line length**: 100 chars (Black + Ruff)
- **Type hints**: Preferred but not strictly enforced (`mypy` with `disallow_untyped_defs=false`)
- **Imports**: Sorted by Ruff (isort rules in `pyproject.toml`)
- **Pre-commit hooks**: Configured but not required (`.pre-commit-config.yaml`)

### Docker Compose Commands
- **Preferred**: `docker compose` (v2 syntax)
- **Fallback**: Scripts handle `docker-compose` (v1) automatically
- **Volumes**: `chroma_data`, `waha_data`, `n8n_data` are persistent
- **Network**: `tributos_network` internal bridge

## Critical Conventions

### Environment Variables (.env)
```env
# LLM (required)
LLM_PROVIDER=groq              # groq|openai|xai
LLM_MODEL=llama-3.3-70b-versatile
GROQ_API_KEY=gsk_...

# WAHA (fixed for this project)
WAHA_API_URL=http://waha:3000
WAHA_API_KEY=tributos_nova_trento_2025_api_key_fixed

# Paths (container paths)
CHROMA_DIR=/app/chroma_data
KNOWLEDGE_PATH=/app/rag/data
```

### Webhook Payload Coercion (app.py)
- **Problem**: n8n may send malformed payloads (missing `event` or `payload` wrapper)
- **Solution**: `webhook()` function coerces 3 common formats:
  1. Raw message object → wrap in `{event: "message", payload: ...}`
  2. Only `payload` present → add `event: "message"`
  3. Correct format → pass through
- **Always log**: `logger.info(f"WEBHOOK PAYLOAD: {json.dumps(data, indent=2)}")` for debugging

### Group Message Filtering
- **Rule**: Ignore group chats (`@g.us` in chat_id)
- **Location**: Both in `app.py` webhook AND in n8n workflow (defense in depth)

### Knowledge Base (rag/data/)
```
rag/data/
├── faqs/          # Markdown FAQs
├── leis/          # Municipal laws (PDFs/text)
├── manuais/       # Procedural manuals
└── procedimentos/ # Internal procedures
```
- **Loading**: `python rag/load_knowledge.py` (walks all subdirs)
- **Format**: Supports `.txt`, `.md`, `.pdf` (via LangChain loaders)
- **Embedding**: Creates chunks with metadata (filename as source)

### n8n Workflow Configuration
1. Install community node: **n8n-nodes-waha** (Settings → Community Nodes)
2. Import workflow from `n8n/workflows/chatbot_completo_orquestracao.json`
3. Configure WAHA credential:
   - Type: Header Auth
   - Name: `X-Api-Key`
   - Value: `tributos_nova_trento_2025_api_key_fixed`
4. Activate workflow (toggle in UI)
5. Webhook URL: `http://n8n:5678/webhook/94a8adfc-1dba-41e7-be61-4c13b51fa08e`

## Common Tasks

### Add New LLM Provider
1. Update `bot/ai_bot.py` `__init__()` with new provider check
2. Add API key env var in `services/config.py` (e.g., `ANTHROPIC_API_KEY`)
3. Install LangChain integration: `pip install langchain-anthropic`
4. Add to `requirements.txt`
5. Update model normalization map if needed

### Modify RAG Behavior
- **Retrieval params**: `bot/ai_bot.py` → `__build_retriever()` → `search_kwargs`
- **System prompt**: `SPECIALIZED_SYSTEM_TEMPLATE` constant
- **Context formatting**: `_format_context()` method

### Add New Script
- **Location**: `scripts/` (PowerShell `.ps1` files)
- **Pattern**: Source `_compose.ps1` for Docker Compose detection
- **Example**:
```powershell
# Source helper
. "$PSScriptRoot\_compose.ps1"

# Get compose command (handles v1/v2)
$ComposeCmd = Get-DockerComposeCommand

# Run
& $ComposeCmd logs -f api
```

### Update Knowledge Base
1. Add files to `rag/data/` subdirectories
2. Run `.\scripts\load-knowledge.ps1` (rebuilds ChromaDB from scratch)
3. Or use `.\scripts\load-knowledge.ps1 -Clear` to force rebuild

## Debugging Tips

### API Not Responding
1. Check health: `curl http://localhost:5000/health`
2. View logs: `.\scripts\logs-api.ps1` or `docker compose logs -f api`
3. Verify ChromaDB loaded: Check `chroma_data/` exists and has SQLite DB

### n8n Workflow Not Triggering
1. Check n8n logs: `docker compose logs -f n8n`
2. Verify webhook URL in WAHA: `.\scripts\waha-status.ps1`
3. Test webhook manually: `.\scripts\test-n8n-webhook.ps1`
4. Ensure workflow is **activated** (toggle in n8n UI)

### WAHA Session Disconnected
1. Run `.\scripts\start-waha-session.ps1` (opens browser for QR code)
2. Check session status: `.\scripts\waha-status.ps1`
3. WAHA dashboard: http://localhost:3000 (admin/Tributos@NovaTrento2025)

### ChromaDB Empty
- Symptom: Responses say "não encontrei base suficiente"
- Fix: `.\scripts\load-knowledge.ps1` (loads all docs from `rag/data/`)
- Verify: `docker exec tributos_api python -c "from langchain_chroma import Chroma; print(Chroma(persist_directory='/app/chroma_data').get()['ids'][:5])"`

## File Reference

### Must-Read Files
- `app.py` - Flask webhook handler with payload coercion logic
- `bot/ai_bot.py` - RAG+LLM core with multi-provider support
- `services/config.py` - Centralized settings
- `compose.yml` - Service definitions and network

### Documentation Index
- `START-HERE.md` - Quick start guide
- `ARCHITECTURE.md` - System architecture
- `DEVELOPMENT.md` - Developer workflows
- `docs/N8N_CHATBOT_COMPLETO.md` - n8n setup guide
- `docs/TROUBLESHOOTING_PORTA_3000.md` - Port conflicts

### Config Files
- `pyproject.toml` - Black, Ruff, Mypy, Pytest config
- `.env.example` - Template for environment variables
- `requirements.txt` / `requirements-dev.txt` - Dependencies

## Anti-Patterns to Avoid

❌ **Don't** call WAHA directly from external webhooks - n8n must orchestrate  
❌ **Don't** modify `WAHA_API_KEY` - it's fixed for credential stability  
❌ **Don't** commit `.env` or `chroma_data/` - in `.gitignore`  
❌ **Don't** use `print()` - use `logger.info()` for structured logs  
❌ **Don't** hardcode prompts in multiple places - centralize in constants  
❌ **Don't** skip typing indicators - always `try/finally` pattern  

## Commit Conventions

Follow **Conventional Commits**:
- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation only
- `refactor:` - Code restructure without behavior change
- `chore:` - Maintenance (dependencies, config)
- `test:` - Test additions/fixes

Example: `feat(rag): add MMR search for better retrieval diversity`

## Performance Optimization

### RAG Tuning Parameters
**Location**: `bot/ai_bot.py` → `__build_retriever()`

**Current settings**:
- Search type: `mmr` (Maximal Marginal Relevance)
- `k=30`: Retrieve 30 documents (higher = more context, slower)
- `lambda_mult=0.5`: Balance relevance vs diversity (0=max diversity, 1=max relevance)

**Tuning guide**:
- **Too many irrelevant answers**: Decrease `k` to 10-15
- **Missing relevant info**: Increase `k` to 40-50
- **Repetitive context**: Decrease `lambda_mult` to 0.3
- **Sparse context**: Increase `lambda_mult` to 0.7

### Chunking Strategy
**Location**: `rag/load_knowledge.py` → `split_documents()`

**Current settings**:
- Chunk size: 1200 characters
- Overlap: 300 characters
- Separators: Legal-specific (`\nArt. `, `\n§ `, etc.)

**Impact**:
- **Larger chunks** (1500-2000): Better context preservation, slower retrieval
- **Smaller chunks** (800-1000): Faster retrieval, may miss context
- **Higher overlap** (400-500): Better continuity, more storage

### LLM Provider Performance
| Provider | Latency | Cost | Best For |
|----------|---------|------|----------|
| Groq | ~500ms | Free tier | Development, high volume |
| OpenAI | ~1-2s | $$ | Production, complex queries |
| xAI (Grok) | ~1-3s | $$$ | Advanced reasoning |

**Recommendation**: Use Groq for development, OpenAI for production

## Testing Strategy

### Unit Tests
**Location**: `tests/`

**Coverage areas**:
- `test_ai_bot.py`: RAG retrieval, LLM integration, message history
- `test_health.py`: Health check endpoint
- `test_waha.py`: WAHA client methods, endpoint fallback

### Integration Tests
**Marker**: `@pytest.mark.integration`

**Pattern**:
```python
@pytest.mark.integration
def test_full_chatbot_flow():
    # Requires Docker containers running
    waha = Waha()
    bot = AIBot()
    response = bot.invoke([], "Como pagar IPTU?")
    assert "IPTU" in response
```

**Run**: `pytest -m integration` (requires services running)

### Manual Testing
```powershell
# 1. Test n8n webhook
.\scripts\test-n8n-webhook.ps1

# 2. Test API directly
.\scripts\post-api-webhook.ps1

# 3. Test via WhatsApp
# Send message to connected number

# 4. Check logs
docker compose logs -f api | Select-String "WEBHOOK PAYLOAD"
```

## Monitoring & Observability

### Structured Logging Fields
**Format**: JSON (production), plain text (development)

**Standard fields**:
```json
{
  "timestamp": "2025-11-06T12:34:56.789Z",
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

**Sensitive data masking**: CPF, phone numbers automatically redacted

### Log Locations
- **API**: `logs/app.log` (mounted volume)
- **WAHA**: `docker compose logs waha`
- **n8n**: Web UI → Executions tab

### Health Check Endpoints
```bash
# API
curl http://localhost:5000/health
# Returns: {status, service, environment, llm_provider, version}

# WAHA
curl http://localhost:3000/api/sessions
# Returns: [{name, status, ...}]

# n8n
curl http://localhost:5679/healthz
# Returns: {status: "ok"}
```

### Metrics to Track
1. **Response time**: `response_time` field in logs
2. **Message volume**: Count log entries with `chat_id`
3. **Error rate**: Count `ERROR` level logs
4. **RAG retrieval quality**: Monitor "não encontrei base" responses
5. **LLM provider errors**: Count 429, 500, 503 from Groq/OpenAI

## Data Management

### Backup Strategy
**Critical data**:
1. `chroma_data/` - Vector database (large, ~100MB-1GB)
2. `waha_data/` - WhatsApp sessions (small, ~10MB)
3. `n8n_data/` - Workflows and credentials (small, ~5MB)

**Backup commands**:
```powershell
# Manual backup
docker compose stop
tar -czf backup-$(Get-Date -Format "yyyyMMdd").tar.gz chroma_data/ waha_data/ n8n_data/
docker compose start

# Automated (Windows Task Scheduler)
.\scripts\install-watchdog.ps1  # Includes backup task
```

### Export Conversation History
```powershell
.\scripts\export-history.ps1
# Outputs: exports/waha_history_YYYYMMDD_HHMMSS.jsonl
```

**Format**: JSONL (one JSON object per line)
```json
{"id": "...", "from": "5511999999999@c.us", "body": "...", "timestamp": 1699999999}
```

### ChromaDB Maintenance
```powershell
# Check database size
docker exec tributos_api du -sh /app/chroma_data

# Rebuild from scratch (if corrupted)
.\scripts\load-knowledge.ps1 -Clear

# Verify document count
docker exec tributos_api python -c "from langchain_chroma import Chroma; print(f'Total docs: {len(Chroma(persist_directory=\"/app/chroma_data\").get()[\"ids\"])}')"
```

## Common Gotchas

### 1. n8n Community Node Installation
**Problem**: `n8n-nodes-waha` node not found in workflow
**Solution**: 
1. Open n8n UI: http://localhost:5679
2. Settings → Community Nodes
3. Install: `n8n-nodes-waha`
4. Restart n8n: `docker compose restart n8n`

### 2. Webhook Payload Format Mismatch
**Problem**: API receives payload but rejects as invalid
**Symptom**: Log shows `Payload inválido - keys presentes: [...]`
**Solution**: Check `app.py` payload coercion logic - may need to add new format case

### 3. ChromaDB Embedding Dimension Mismatch
**Problem**: Error "dimension mismatch" when querying ChromaDB
**Cause**: Changed `EMBEDDING_MODEL` after loading documents
**Solution**: 
```powershell
.\scripts\load-knowledge.ps1 -Clear  # Rebuild with new embeddings
```

### 4. WAHA Session Expired
**Problem**: WhatsApp shows as disconnected in dashboard
**Solution**:
```powershell
.\scripts\start-waha-session.ps1
# Scan QR code with WhatsApp mobile app
```

### 5. Docker Compose v1 vs v2
**Problem**: Scripts fail with "unknown flag: --wait"
**Cause**: Using `docker-compose` (v1) instead of `docker compose` (v2)
**Solution**: Scripts auto-detect, but prefer Docker Desktop with Compose v2

### 6. Port 3000 Already in Use
**Problem**: WAHA fails to start (port conflict)
**Common culprits**: Node.js dev servers, other Docker containers
**Solution**: See `docs/TROUBLESHOOTING_PORTA_3000.md`
```powershell
# Find process using port
netstat -ano | findstr :3000
# Kill process
taskkill /PID <PID> /F
```

## IDE Configuration

### VS Code Recommended Extensions
```json
{
  "recommendations": [
    "ms-python.python",
    "ms-python.vscode-pylance",
    "charliermarsh.ruff",
    "ms-azuretools.vscode-docker",
    "redhat.vscode-yaml"
  ]
}
```

### Settings.json (Workspace)
```json
{
  "python.linting.enabled": true,
  "python.linting.ruffEnabled": true,
  "python.formatting.provider": "black",
  "editor.formatOnSave": true,
  "editor.rulers": [100],
  "[python]": {
    "editor.defaultFormatter": "ms-python.black-formatter"
  }
}
```

### Launch.json (Debugging)
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flask: API",
      "type": "python",
      "request": "launch",
      "module": "flask",
      "env": {
        "FLASK_APP": "app.py",
        "FLASK_ENV": "development"
      },
      "args": ["run", "--debug", "--host=0.0.0.0", "--port=5000"]
    }
  ]
}
```

## Glossary

**WAHA**: WhatsApp HTTP API - Node.js service that connects to WhatsApp Web
**n8n**: Workflow automation platform (like Zapier, self-hosted)
**RAG**: Retrieval-Augmented Generation - AI technique combining vector search + LLM
**ChromaDB**: Embedded vector database for semantic search
**MMR**: Maximal Marginal Relevance - balances relevance and diversity in search results
**Embedding**: Vector representation of text for semantic similarity
**LangChain**: Framework for building LLM applications
**Webhook**: HTTP callback for real-time event notifications
**Chat ID**: WhatsApp identifier format: `5511999999999@c.us` (individual) or `@g.us` (group)
**Session**: WAHA connection to WhatsApp Web (requires QR code pairing)
**Chunk**: Text segment for vector database (typically 500-2000 characters)

## Version History Reference

**Current version**: 1.0.0 (from `services/version.py`)

**Update version**:
```python
# services/version.py
__version__ = "1.1.0"  # Increment as needed
```

**Version is exposed**:
- Health endpoint: `GET /health` → `{version: "1.0.0"}`
- Logs: Startup message includes version
- Docker image tag: Use in `docker build -t chatbot:1.0.0`

## Windows-Specific Notes

- **PowerShell** is the primary shell (not bash)
- **Auto-start**: `.\scripts\install-auto-start.ps1` creates Windows Scheduled Task
- **Docker Desktop**: Required (WSL2 backend recommended)
- **Line endings**: Git auto-converts (`.gitattributes` configured)
- **Make**: Optional (PowerShell scripts are equivalent)

## CI/CD Pipeline (.github/workflows/ci.yml)

### Jobs
1. **lint**: Ruff → Black → Mypy (runs on push/PR to main/develop)
2. **test**: Pytest with coverage → uploads to Codecov
3. **docker**: Builds image with BuildKit cache (GitHub Actions cache)

### Local Testing
```powershell
.\scripts\test.ps1             # Full test suite (lint + tests)
.\scripts\test.ps1 -LintOnly   # Only linting (skip pytest)
```

### Pre-commit Integration
- Configured in `.pre-commit-config.yaml`
- Install: `pre-commit install`
- Run manually: `pre-commit run --all-files`

## Advanced Features

### Link Router (bot/link_router.py)
- **Two modes**:
  1. **Menu mode**: Stateful navigation with node tracking (e.g., user at "IPTU" menu chooses option "2")
  2. **Keyword mode**: Stateless intent matching (e.g., "iptu" → direct to IPTU links)
- **Business hours**: Checks if inside 07:00-13:00 Mon-Fri (America/Sao_Paulo)
- **Placeholder rendering**: `{{name}}`, `{{protocol}}` replacements via `render()` method
- **Flow JSON**: Expects n8n workflow JSON format with `nodeList`, `conditions`, `action=3` (closeTicket)

### RAG Knowledge Loading (rag/load_knowledge.py)
- **Supported formats**: PDF, TXT, Markdown (.md), HTML (laws)
- **HTML parsing**: BeautifulSoup extracts metadata tables from legal documents
  - Metadata: `law_type`, `number`, `year`, `date`, `subject`, `tags`, `status`, `url`
  - Categories: FAQ, Lei, Manual, Procedimento (auto-detected from folder structure)
- **Chunking**: RecursiveCharacterTextSplitter with legal-specific separators
  - Default: 1200 chars, 300 overlap
  - Separators: `\nArt. `, `\n§ `, `\nI - ` (Brazilian law formatting)
- **Metadata filtering**: `filter_complex_metadata()` removes lists/dicts incompatible with ChromaDB
- **Batch processing**: 100 chunks per batch for memory efficiency

### WAHA Client Multi-Endpoint Fallback (services/waha.py)
- **Problem**: WAHA API endpoints changed between versions
- **Solution**: Try multiple endpoint patterns until one succeeds
- **Example**: `get_messages()` tries:
  1. `/api/default/chats/{id}/messages`
  2. `/api/chats/{id}/messages?session=default`
  3. `/api/sessions/default/chats/{id}/messages`
- **401 handling**: Graceful degradation when `WAHA_API_KEY` missing (returns empty arrays)
- **Timeout**: Configurable via `WAHA_TIMEOUT` env var (default 10s)

### Message History Normalization
- **WAHA formats**: Handles both `{messages: [...]}` and direct array `[...]`
- **Role detection**: `fromMe: true` → `assistant`, else → `user`
- **Content extraction**: Tries `body`, then `text` field
- **Return format**: Always `[{"role": "user|assistant", "content": "..."}]`

## PowerShell Scripts Deep Dive

### Core Scripts
- **`_compose.ps1`**: Helper module - detects `docker compose` vs `docker-compose` (v2/v1)
  - Usage: `. "$PSScriptRoot\_compose.ps1"` → `Get-ComposeCmd`
  - Sets `COMPOSE_HTTP_TIMEOUT=240` for slow Docker operations

- **`up.ps1`** / **`up-n8n.ps1`**:
  - `up.ps1`: Starts all 3 services (WAHA + n8n + API)
  - `up-n8n.ps1`: Starts only WAHA + n8n (for n8n-only mode)
  - Both use `-d` (detached mode)

- **`rebuild.ps1`**:
  - `docker compose down` → `docker compose build --no-cache` → `docker compose up -d`
  - Use after changing `requirements.txt` or Dockerfile

- **`load-knowledge.ps1`**:
  - Executes `python rag/load_knowledge.py` inside API container
  - Accepts `-Clear` flag to wipe ChromaDB before loading
  - Useful after adding new documents to `rag/data/`

### Debugging Scripts
- **`logs-api.ps1`**: `docker compose logs -f api` (follows logs)
- **`waha-status.ps1`**: Checks WAHA session status, webhook config
- **`test-n8n-webhook.ps1`**: Sends test payload to n8n webhook endpoint
- **`post-api-webhook.ps1`**: Sends test payload directly to API (for debugging without n8n)

### Utility Scripts
- **`export-history.ps1`**: Exports WAHA conversation history to JSONL files
- **`export-summary.ps1`**: Generates conversation statistics/summary
- **`health-check.ps1`** / **`health-check-local.ps1`**: Curl all service health endpoints

## Docker Architecture Details

### Volumes
- **`chroma_data`**: ChromaDB SQLite DB + embeddings (persistent across restarts)
- **`waha_data`**: WhatsApp session data (QR code pairing, message cache)
- **`n8n_data`**: Workflow definitions, credentials, execution logs

### Network
- **`tributos_network`**: Bridge network (internal DNS)
- Services reference each other by name: `http://waha:3000`, `http://n8n:5678`, `http://api:5000`

### Health Checks
All 3 services have healthcheck configurations:
- **WAHA**: `wget http://localhost:3000` (30s interval, 40s start period)
- **n8n**: `wget http://localhost:5678/healthz` (30s interval, 40s start period)
- **API**: `python -c "import requests; requests.get('http://localhost:5000/health')"` (30s interval, 40s start period)

### Resource Limits (API)
```yaml
deploy:
  resources:
    limits:
      memory: 4G
    reservations:
      memory: 2G
```
Reason: HuggingFace embeddings + ChromaDB can consume significant RAM

## Troubleshooting Patterns

### "Base vetorial vazia" (Empty Vector DB)
**Symptoms**: AI responds "não encontrei base suficiente"
**Diagnosis**:
```powershell
docker exec tributos_api ls -lh /app/chroma_data/
# Should show chroma.sqlite3 (>10KB) and UUID directory
```
**Fix**:
```powershell
.\scripts\load-knowledge.ps1 -Clear
```

### "WAHA webhook não está sendo chamado"
**Symptoms**: Messages received on WhatsApp but API not triggered
**Diagnosis**:
```powershell
docker compose logs -f waha | Select-String "webhook"
# Should show HTTP POST to n8n webhook URL
```
**Fix**:
1. Check `WHATSAPP_HOOK_URL` in `compose.yml` matches n8n webhook
2. Verify WAHA session connected: `.\scripts\waha-status.ps1`
3. Restart WAHA: `docker compose restart waha`

### "n8n workflow não ativa"
**Symptoms**: Webhook receives calls but workflow doesn't execute
**Diagnosis**:
1. Open n8n UI: http://localhost:5679
2. Check workflow toggle (must be green/active)
3. Check execution logs (left sidebar)

**Fix**:
1. Re-import workflow from `n8n/workflows/chatbot_completo_orquestracao.json`
2. Install community node: Settings → Community Nodes → `n8n-nodes-waha`
3. Configure WAHA credential (Header Auth, `X-Api-Key`)

### "LLM API errors (429, 500)"
**Symptoms**: Groq/OpenAI/xAI errors in API logs
**Diagnosis**:
```powershell
docker compose logs -f api | Select-String "API|error"
```
**Fix**:
1. Check API key validity: `echo $env:GROQ_API_KEY` (or OPENAI_API_KEY)
2. Verify quota: Check provider dashboard
3. Switch provider: Change `LLM_PROVIDER` in `.env` (groq|openai|xai)
4. Restart API: `docker compose restart api`

## Code Quality Tools Configuration

### Ruff (pyproject.toml)
```toml
select = ["E", "W", "F", "I", "B", "C4", "UP", "N", "SIM"]
ignore = ["E501"]  # Line length handled by Black
```
**Key rules**:
- `I`: Import sorting (isort replacement)
- `B`: Bugbear (common bugs)
- `UP`: Modern Python syntax upgrades
- `SIM`: Simplify code suggestions

### Black
- Line length: 100 chars
- Target: Python 3.11
- No custom config needed (opinionated)

### Mypy
- `disallow_untyped_defs=false`: Type hints encouraged but not required
- `ignore_missing_imports=true`: Don't fail on untyped libraries
- `check_untyped_defs=true`: Check typed portions of untyped functions

### Pytest
- Markers: `@pytest.mark.integration`, `@pytest.mark.slow`
- Run fast tests only: `pytest -m "not slow and not integration"`
- Coverage target: No enforced minimum (informational only)

## Security Considerations

### Credentials Management
- **Never commit**: `.env` in `.gitignore`
- **Fixed API key pattern**: `WAHA_API_KEY` is intentionally static to avoid credential churn in n8n
- **Rotation**: Only rotate LLM API keys (Groq/OpenAI/xAI), not WAHA key

### Data Privacy
- **No PII in logs**: Structured logging masks CPF, phone numbers
- **Message history**: Stored in WAHA container (`waha_data` volume), not in API
- **ChromaDB**: Contains document chunks (public information), no user data

### Network Isolation
- **Internal network**: `tributos_network` is not exposed to host
- **Only exposed ports**: 3000 (WAHA), 5000 (API), 5679 (n8n)
- **Production**: Use reverse proxy (nginx/Caddy) with HTTPS

## Production Deployment

### Recommended Stack
```
Internet → Caddy (HTTPS) → Docker Network
                ↓
        WAHA + n8n + API
```

### Environment Differences
| Aspect | Development | Production |
|--------|-------------|------------|
| Debug | `DEBUG=true` | `DEBUG=false` |
| Log level | `INFO` | `WARNING` |
| Volumes | Local mounts | Named volumes |
| Restart | `no` | `unless-stopped` |
| HTTPS | HTTP only | Caddy with auto-TLS |

### Pre-deploy Checklist
```powershell
.\scripts\pre-deploy-check.ps1  # Validates config, checks DNS, tests endpoints
```

### Deployment Commands
```powershell
# Production with HTTPS (requires domain)
.\scripts\up-prod-https.ps1

# Production without domain (IP-based)
.\scripts\up-prod.ps1

# Full automated deploy
.\scripts\deploy-completo.ps1
```

## Zero-Touch Docker Deployment (100% Automated)

### Overview

This section documents a **fully automated Docker deployment** that requires minimal manual intervention after `docker compose up -d`. The only exception is WhatsApp QR code pairing on first run (or restore session backup to skip even that).

### Architecture Components

Complete stack with:
- **n8n**: Workflow orchestration
- **API**: FastAPI/Flask chatbot backend
- **WAHA**: WhatsApp HTTP API with auto-session restore
- **ChromaDB**: Vector database (persistent)
- **Redis**: Cache/queues (optional but recommended)
- **Traefik**: Reverse proxy with automatic HTTPS (optional)
- **Healthchecks**: All services monitored
- **Restart policies**: Auto-recovery on failures

### Directory Structure

```
chatbot/
├─ .env                    # Single source of truth for all configs
├─ docker-compose.yml      # Full stack definition
├─ Makefile                # Shortcut commands (optional but useful)
├─ reverse-proxy/          # Traefik config (optional)
│  ├─ traefik.yml
│  └─ acme.json            # Let's Encrypt certs (chmod 600)
├─ api/
│  ├─ Dockerfile
│  └─ app/
│     └─ main.py
├─ scripts/
│  ├─ wait-for.sh          # Wait for service dependencies
│  ├─ n8n-init.sh          # Auto-create n8n user on first boot
│  └─ load-knowledge.sh    # Auto-populate ChromaDB
└─ data/                   # Persistent volumes (gitignored)
   ├─ waha/
   │  └─ session/          # Place WhatsApp session backup here
   ├─ n8n/
   ├─ chroma/
   └─ redis/
```

### Complete docker-compose.yml (Zero-Touch)

```yaml
version: '3.8'

# =============================================================================
# Chatbot 100% Automated Stack
# =============================================================================
# All configs from .env | No manual setup after first boot
# WhatsApp session: place backup in ./data/waha/session/ before first start
# =============================================================================

services:
  # ---------------------------------------------------------------------------
  # Traefik - Reverse Proxy with Auto HTTPS (Optional)
  # ---------------------------------------------------------------------------
  traefik:
    image: traefik:v2.10
    container_name: traefik
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"  # Dashboard (secure in production!)
    environment:
      - CF_API_EMAIL=${CF_API_EMAIL:-}
      - CF_DNS_API_TOKEN=${CF_DNS_API_TOKEN:-}
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./reverse-proxy/traefik.yml:/etc/traefik/traefik.yml:ro
      - ./reverse-proxy/acme.json:/acme.json
      - traefik-logs:/var/log/traefik
    networks:
      - chatbot_network
    labels:
      - "traefik.enable=true"
      # Dashboard (remove in production or add auth)
      - "traefik.http.routers.traefik.rule=Host(`traefik.${DOMAIN}`)"
      - "traefik.http.routers.traefik.service=api@internal"
      - "traefik.http.routers.traefik.entrypoints=websecure"
      - "traefik.http.routers.traefik.tls.certresolver=letsencrypt"

  # ---------------------------------------------------------------------------
  # Redis - Cache & Message Queue
  # ---------------------------------------------------------------------------
  redis:
    image: redis:7-alpine
    container_name: chatbot_redis
    restart: unless-stopped
    command: >
      redis-server
      --appendonly yes
      --appendfsync everysec
      --maxmemory 512mb
      --maxmemory-policy allkeys-lru
    volumes:
      - ./data/redis:/data
    networks:
      - chatbot_network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5

  # ---------------------------------------------------------------------------
  # ChromaDB - Vector Database (Standalone)
  # ---------------------------------------------------------------------------
  chromadb:
    image: chromadb/chroma:latest
    container_name: chatbot_chromadb
    restart: unless-stopped
    environment:
      - IS_PERSISTENT=TRUE
      - ANONYMIZED_TELEMETRY=FALSE
    volumes:
      - ./data/chroma:/chroma/chroma
    networks:
      - chatbot_network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/api/v1/heartbeat"]
      interval: 30s
      timeout: 10s
      retries: 3

  # ---------------------------------------------------------------------------
  # WAHA - WhatsApp HTTP API (Auto-Restore Session)
  # ---------------------------------------------------------------------------
  waha:
    image: devlikeapro/waha:latest
    container_name: chatbot_waha
    restart: unless-stopped
    environment:
      - WHATSAPP_HOOK_URL=http://n8n:5678/webhook/${N8N_WEBHOOK_ID}
      - WHATSAPP_HOOK_EVENTS=message,session.status
      - WAHA_API_KEY=${WAHA_API_KEY}
      - WAHA_DASHBOARD_USERNAME=${WAHA_DASHBOARD_USERNAME:-admin}
      - WAHA_DASHBOARD_PASSWORD=${WAHA_DASHBOARD_PASSWORD}
      # Auto-start session on boot
      - WHATSAPP_START_SESSION=default
      - WHATSAPP_RESTART_ALL_SESSIONS=true
    volumes:
      - ./data/waha:/app/.waha
      # Pre-populated session backup goes in ./data/waha/session/
    networks:
      - chatbot_network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.waha.rule=Host(`waha.${DOMAIN}`)"
      - "traefik.http.routers.waha.entrypoints=websecure"
      - "traefik.http.routers.waha.tls.certresolver=letsencrypt"
      - "traefik.http.services.waha.loadbalancer.server.port=3000"
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

  # ---------------------------------------------------------------------------
  # n8n - Workflow Automation (Auto-Init User)
  # ---------------------------------------------------------------------------
  n8n:
    image: n8nio/n8n:latest
    container_name: chatbot_n8n
    restart: unless-stopped
    environment:
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}
      - WEBHOOK_URL=https://n8n.${DOMAIN}/
      - GENERIC_TIMEZONE=America/Sao_Paulo
      - N8N_METRICS=true
      # Auto-create owner user on first boot
      - N8N_OWNER_EMAIL=${N8N_OWNER_EMAIL:-admin@localhost}
      - N8N_OWNER_PASSWORD=${N8N_OWNER_PASSWORD}
      - N8N_OWNER_FIRST_NAME=${N8N_OWNER_FIRST_NAME:-Admin}
      - N8N_OWNER_LAST_NAME=${N8N_OWNER_LAST_NAME:-User}
      # Community nodes auto-install
      - N8N_COMMUNITY_PACKAGES_INSTALL=${N8N_COMMUNITY_PACKAGES:-n8n-nodes-waha}
      # LLM integrations
      - GROQ_API_KEY=${GROQ_API_KEY:-}
      - OPENAI_API_KEY=${OPENAI_API_KEY:-}
    volumes:
      - ./data/n8n:/home/node/.n8n
      - ./n8n/workflows:/home/node/.n8n/workflows:ro
    networks:
      - chatbot_network
    depends_on:
      redis:
        condition: service_healthy
      waha:
        condition: service_started
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.n8n.rule=Host(`n8n.${DOMAIN}`)"
      - "traefik.http.routers.n8n.entrypoints=websecure"
      - "traefik.http.routers.n8n.tls.certresolver=letsencrypt"
      - "traefik.http.services.n8n.loadbalancer.server.port=5678"
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:5678/healthz"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

  # ---------------------------------------------------------------------------
  # API - Chatbot Backend (FastAPI/Flask with Auto Knowledge Load)
  # ---------------------------------------------------------------------------
  api:
    build:
      context: ./api
      dockerfile: Dockerfile
    container_name: chatbot_api
    restart: unless-stopped
    environment:
      # LLM
      - LLM_PROVIDER=${LLM_PROVIDER:-groq}
      - LLM_MODEL=${LLM_MODEL:-llama-3.3-70b-versatile}
      - GROQ_API_KEY=${GROQ_API_KEY}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - XAI_API_KEY=${XAI_API_KEY}
      # Vector DB
      - CHROMA_HOST=chromadb
      - CHROMA_PORT=8000
      - EMBEDDING_MODEL=${EMBEDDING_MODEL:-sentence-transformers/all-MiniLM-L6-v2}
      # WAHA
      - WAHA_API_URL=http://waha:3000
      - WAHA_API_KEY=${WAHA_API_KEY}
      # Redis
      - REDIS_URL=redis://redis:6379
      # App
      - PORT=5000
      - ENVIRONMENT=production
      - DEBUG=false
      - LOG_LEVEL=${LOG_LEVEL:-INFO}
      # Auto-load knowledge on startup
      - AUTO_LOAD_KNOWLEDGE=${AUTO_LOAD_KNOWLEDGE:-true}
      - KNOWLEDGE_PATH=/app/knowledge
    volumes:
      - ./api/app:/app
      - ./rag/data:/app/knowledge:ro
      - ./logs:/app/logs
      - ./exports:/app/exports
    networks:
      - chatbot_network
    depends_on:
      chromadb:
        condition: service_healthy
      redis:
        condition: service_healthy
      n8n:
        condition: service_started
    # Wait for ChromaDB to be ready, then load knowledge
    entrypoint: ["/bin/sh", "-c"]
    command:
      - |
        /app/scripts/wait-for.sh chromadb:8000 -t 60 -- \
        if [ "$AUTO_LOAD_KNOWLEDGE" = "true" ]; then
          echo "🔄 Auto-loading knowledge base..."
          python -m app.load_knowledge
        fi
        exec uvicorn app.main:app --host 0.0.0.0 --port 5000
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.api.rule=Host(`api.${DOMAIN}`)"
      - "traefik.http.routers.api.entrypoints=websecure"
      - "traefik.http.routers.api.tls.certresolver=letsencrypt"
      - "traefik.http.services.api.loadbalancer.server.port=5000"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 90s
    deploy:
      resources:
        limits:
          memory: 4G
        reservations:
          memory: 2G

# -----------------------------------------------------------------------------
# Networks
# -----------------------------------------------------------------------------
networks:
  chatbot_network:
    driver: bridge

# -----------------------------------------------------------------------------
# Volumes (all in ./data/ for easy backup)
# -----------------------------------------------------------------------------
volumes:
  traefik-logs:
```

### Complete .env Template

```bash
# =============================================================================
# Chatbot 100% Automated - Environment Variables
# =============================================================================

# -----------------------------------------------------------------------------
# Domain & Networking (for Traefik HTTPS)
# -----------------------------------------------------------------------------
DOMAIN=chatbot.example.com
CF_API_EMAIL=your-email@example.com
CF_DNS_API_TOKEN=your-cloudflare-token

# -----------------------------------------------------------------------------
# n8n Configuration
# -----------------------------------------------------------------------------
# Webhook ID (generate with: uuidgen or online)
N8N_WEBHOOK_ID=94a8adfc-1dba-41e7-be61-4c13b51fa08e

# Encryption key (generate with: openssl rand -hex 32)
N8N_ENCRYPTION_KEY=your-32-byte-hex-key

# Owner credentials (auto-created on first boot)
N8N_OWNER_EMAIL=admin@chatbot.local
N8N_OWNER_PASSWORD=ChangeMe123!
N8N_OWNER_FIRST_NAME=Admin
N8N_OWNER_LAST_NAME=Chatbot

# Community packages (comma-separated)
N8N_COMMUNITY_PACKAGES=n8n-nodes-waha

# -----------------------------------------------------------------------------
# WAHA (WhatsApp HTTP API)
# -----------------------------------------------------------------------------
# Fixed API key (consistent across restarts)
WAHA_API_KEY=tributos_nova_trento_2025_api_key_fixed

# Dashboard credentials
WAHA_DASHBOARD_USERNAME=admin
WAHA_DASHBOARD_PASSWORD=Tributos@NovaTrento2025

# -----------------------------------------------------------------------------
# LLM Provider
# -----------------------------------------------------------------------------
LLM_PROVIDER=groq
LLM_MODEL=llama-3.3-70b-versatile

# API Keys (fill only the one you're using)
GROQ_API_KEY=gsk_your_key_here
OPENAI_API_KEY=sk-your_key_here
XAI_API_KEY=xai-your_key_here

# -----------------------------------------------------------------------------
# Embeddings & RAG
# -----------------------------------------------------------------------------
EMBEDDING_MODEL=sentence-transformers/all-MiniLM-L6-v2
AUTO_LOAD_KNOWLEDGE=true

# -----------------------------------------------------------------------------
# Logging & Monitoring
# -----------------------------------------------------------------------------
LOG_LEVEL=INFO
```

### Traefik Configuration (reverse-proxy/traefik.yml)

```yaml
# =============================================================================
# Traefik - Reverse Proxy with Auto HTTPS
# =============================================================================

api:
  dashboard: true
  insecure: false  # Set true only for local dev

entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
          permanent: true
  
  websecure:
    address: ":443"
    http:
      tls:
        certResolver: letsencrypt

certificatesResolvers:
  letsencrypt:
    acme:
      email: ${CF_API_EMAIL}
      storage: /acme.json
      dnsChallenge:
        provider: cloudflare
        resolvers:
          - "1.1.1.1:53"
          - "1.0.0.1:53"

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
    network: chatbot_network

log:
  level: INFO
  filePath: /var/log/traefik/traefik.log

accessLog:
  filePath: /var/log/traefik/access.log
```

### Helper Scripts

#### scripts/wait-for.sh

```bash
#!/bin/sh
# wait-for.sh - Wait for service to be available
# Usage: wait-for.sh host:port [-t timeout] [-- command args]

TIMEOUT=15
QUIET=0

while [ $# -gt 0 ]; do
  case "$1" in
    *:* )
    HOST=$(echo $1 | cut -d: -f1)
    PORT=$(echo $1 | cut -d: -f2)
    shift 1
    ;;
    -t)
    TIMEOUT="$2"
    shift 2
    ;;
    -q)
    QUIET=1
    shift 1
    ;;
    --)
    shift
    break
    ;;
    *)
    echo "Unknown argument: $1"
    exit 1
    ;;
  esac
done

start_ts=$(date +%s)
while :; do
  if nc -z "$HOST" "$PORT" > /dev/null 2>&1; then
    end_ts=$(date +%s)
    [ $QUIET -eq 0 ] && echo "$HOST:$PORT is available after $((end_ts - start_ts)) seconds"
    break
  fi
  
  elapsed=$(($(date +%s) - start_ts))
  if [ $elapsed -ge $TIMEOUT ]; then
    echo "Timeout waiting for $HOST:$PORT"
    exit 1
  fi
  
  sleep 1
done

exec "$@"
```

#### scripts/load-knowledge.sh

```bash
#!/bin/bash
# Auto-load knowledge base into ChromaDB on first boot

set -e

KNOWLEDGE_DIR="${KNOWLEDGE_PATH:-/app/knowledge}"
MARKER_FILE="/app/data/chroma/.knowledge_loaded"

if [ -f "$MARKER_FILE" ]; then
    echo "✅ Knowledge base already loaded (marker found)"
    exit 0
fi

echo "📚 Loading knowledge base from $KNOWLEDGE_DIR..."
python -m app.rag.load_knowledge --clear

# Create marker to prevent re-loading
touch "$MARKER_FILE"
echo "✅ Knowledge base loaded successfully"
```

### Makefile (Optional Convenience Commands)

```makefile
# =============================================================================
# Chatbot - Makefile
# =============================================================================

.PHONY: help up down restart logs logs-api logs-n8n logs-waha health rebuild clean backup restore

help:
	@echo "Available commands:"
	@echo "  make up          - Start all services"
	@echo "  make down        - Stop all services"
	@echo "  make restart     - Restart all services"
	@echo "  make logs        - Follow all logs"
	@echo "  make logs-api    - Follow API logs"
	@echo "  make logs-n8n    - Follow n8n logs"
	@echo "  make logs-waha   - Follow WAHA logs"
	@echo "  make health      - Check all services health"
	@echo "  make rebuild     - Rebuild and restart API"
	@echo "  make clean       - Stop and remove all containers"
	@echo "  make backup      - Backup all persistent data"
	@echo "  make restore     - Restore from backup"

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose restart

logs:
	docker compose logs -f

logs-api:
	docker compose logs -f api

logs-n8n:
	docker compose logs -f n8n

logs-waha:
	docker compose logs -f waha

health:
	@echo "🔍 Checking services health..."
	@docker compose ps
	@echo ""
	@echo "API Health:"
	@curl -s http://localhost:5000/health | jq . || echo "❌ API not responding"
	@echo ""
	@echo "n8n Health:"
	@curl -s http://localhost:5678/healthz || echo "❌ n8n not responding"

rebuild:
	docker compose build --no-cache api
	docker compose up -d api

clean:
	docker compose down -v
	@echo "⚠️  Warning: This will remove all volumes!"
	@read -p "Continue? [y/N] " -n 1 -r; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker compose down -v; \
	fi

backup:
	@mkdir -p backups
	tar -czf backups/chatbot-backup-$$(date +%Y%m%d-%H%M%S).tar.gz data/

restore:
	@echo "Available backups:"
	@ls -lh backups/*.tar.gz
	@read -p "Enter backup filename: " BACKUP; \
	tar -xzf backups/$$BACKUP

.DEFAULT_GOAL := help
```

### Zero-Touch Deployment Checklist

#### First-Time Setup

1. **Clone repository**
   ```bash
   git clone https://github.com/your-org/chatbot.git
   cd chatbot
   ```

2. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your credentials
   nano .env
   ```

3. **Prepare Traefik SSL** (if using HTTPS)
   ```bash
   touch reverse-proxy/acme.json
   chmod 600 reverse-proxy/acme.json
   ```

4. **Optional: Restore WhatsApp session** (skip QR code)
   ```bash
   # Place session backup in ./data/waha/session/
   cp -r /path/to/backup/session ./data/waha/
   ```

5. **Start stack**
   ```bash
   docker compose up -d
   # or
   make up
   ```

6. **Monitor startup**
   ```bash
   docker compose logs -f
   # Wait for all healthchecks to pass (~2-3 minutes)
   ```

7. **Verify services**
   ```bash
   make health
   ```

#### If WhatsApp Session NOT Pre-Loaded

1. Open WAHA dashboard: `https://waha.your-domain.com`
2. Login with credentials from `.env`
3. Click "Start Session" → scan QR code with WhatsApp mobile
4. Session automatically persists to `./data/waha/`

#### Import n8n Workflows (One-Time)

1. Open n8n: `https://n8n.your-domain.com`
2. Login with credentials from `.env` (auto-created on first boot)
3. Settings → Import from file
4. Select workflow from `./n8n/workflows/chatbot_completo_orquestracao.json`
5. Activate workflow

**Note**: Community node `n8n-nodes-waha` auto-installs via `N8N_COMMUNITY_PACKAGES` env var.

### Maintenance Operations

#### Update API Code

```bash
# Make changes to ./api/app/
# Rebuild and restart
make rebuild
```

#### Update Knowledge Base

```bash
# Add files to ./rag/data/
# Delete marker to trigger reload
rm data/chroma/.knowledge_loaded
docker compose restart api
```

#### Backup All Data

```bash
make backup
# Creates: backups/chatbot-backup-YYYYMMDD-HHMMSS.tar.gz
```

#### Restore from Backup

```bash
make restore
# Select backup file when prompted
```

#### View Logs

```bash
make logs           # All services
make logs-api       # API only
make logs-n8n       # n8n only
make logs-waha      # WAHA only
```

### Differences from Current Setup

| Aspect | Current Setup | Zero-Touch Setup |
|--------|---------------|------------------|
| **n8n user creation** | Manual via UI | Auto-created from env vars |
| **Community nodes** | Manual install | Auto-installed via env var |
| **Knowledge loading** | Manual script | Auto-loads on first boot |
| **Session restore** | Manual QR scan | Optional pre-loaded backup |
| **HTTPS** | Manual nginx/Caddy | Auto via Traefik + Let's Encrypt |
| **Service dependencies** | Hope for best | Healthchecks + wait-for.sh |
| **ChromaDB** | Embedded in API | Standalone service |
| **Redis** | Not present | Added for caching/queues |
| **Volumes** | Named volumes | ./data/ directory (easy backup) |

### Migration from Current Setup

To migrate your existing setup to zero-touch:

1. **Export current data**
   ```powershell
   # Backup ChromaDB
   docker cp tributos_api:/app/chroma_data ./migration/chroma_data
   
   # Backup WAHA session
   docker cp tributos_waha:/app/.waha ./migration/waha_data
   
   # Export n8n workflows
   # Via UI: Settings → Export all workflows
   ```

2. **Copy to new structure**
   ```bash
   mkdir -p data/chroma data/waha data/n8n
   cp -r migration/chroma_data/* data/chroma/
   cp -r migration/waha_data/* data/waha/
   ```

3. **Update .env** with current credentials

4. **Start new stack**
   ```bash
   docker compose up -d
   ```

### Troubleshooting Zero-Touch Setup

#### ChromaDB Not Loading Knowledge

```bash
# Check marker file
ls -la data/chroma/.knowledge_loaded

# Force reload
rm data/chroma/.knowledge_loaded
docker compose restart api
docker compose logs -f api | grep "knowledge"
```

#### n8n User Not Auto-Created

```bash
# Check env vars
docker compose exec n8n env | grep N8N_OWNER

# Manually create (fallback)
docker compose exec n8n n8n user:create \
  --email admin@localhost \
  --password ChangeMe123 \
  --firstName Admin \
  --lastName User
```

#### WAHA Session Not Restoring

```bash
# Check session files
ls -la data/waha/session/

# Verify permissions
chmod -R 755 data/waha/

# Check WAHA logs
docker compose logs -f waha | grep -i session
```

#### Traefik HTTPS Not Working

```bash
# Check acme.json permissions
ls -la reverse-proxy/acme.json  # Should be -rw------- (600)

# Check DNS challenge
docker compose logs -f traefik | grep -i acme

# Verify domain DNS
dig waha.your-domain.com
dig n8n.your-domain.com
dig api.your-domain.com
```

### Security Considerations (Zero-Touch)

1. **Traefik Dashboard**: Disable in production or add authentication
   ```yaml
   # In docker-compose.yml, comment out dashboard labels
   # labels:
   #   - "traefik.http.routers.traefik.rule=Host(`traefik.${DOMAIN}`)"
   ```

2. **n8n Webhook Security**: Use secret tokens
   ```env
   # In .env
   N8N_WEBHOOK_ID=$(uuidgen)  # Hard to guess
   ```

3. **WAHA API Key**: Rotate periodically
   ```bash
   # Generate new key
   NEW_KEY=$(openssl rand -hex 32)
   
   # Update .env and restart
   sed -i "s/WAHA_API_KEY=.*/WAHA_API_KEY=$NEW_KEY/" .env
   docker compose restart waha n8n api
   ```

4. **File Permissions**: Restrict sensitive files
   ```bash
   chmod 600 .env
   chmod 600 reverse-proxy/acme.json
   chmod 700 data/
   ```

5. **Network Isolation**: Use internal networks
   ```yaml
   # Services that don't need external access
   chromadb:
     networks:
       - internal_network
   
   networks:
     internal_network:
       internal: true
   ```

## Extension Points

### Adding Custom RAG Retrieval Strategies
**Location**: `bot/ai_bot.py` → `__build_retriever()`

**Example**: Add hybrid search (vector + keyword):
```python
# Change from MMR to similarity + score threshold
return vector_store.as_retriever(
    search_type="similarity_score_threshold",
    search_kwargs={"score_threshold": 0.7, "k": 10}
)
```

### Adding New Document Types
**Location**: `rag/load_knowledge.py` → `iter_docs()`

**Example**: Add DOCX support:
```python
from langchain_community.document_loaders import Docx2txtLoader

# In iter_docs():
elif fp.lower().endswith(".docx"):
    loader = Docx2txtLoader(fp)
    docs = loader.load()
    # ... metadata handling
```

### Custom System Prompts per Topic
**Location**: `bot/ai_bot.py` → `SPECIALIZED_SYSTEM_TEMPLATE`

**Pattern**: Create prompt variants and select based on document category:
```python
PROMPTS = {
    "IPTU": "You are an IPTU specialist...",
    "ISS": "You are an ISS specialist...",
    "default": SPECIALIZED_SYSTEM_TEMPLATE
}

# In invoke():
category = self._detect_category(question)
prompt_template = PROMPTS.get(category, PROMPTS["default"])
```

## Technology Alternatives & Migration

### Stack Alternatives Overview

This section documents alternative technologies for each component and migration strategies.

#### 1. WhatsApp Integration Alternatives

| Solution | Type | Pros | Cons | Best For |
|----------|------|------|------|----------|
| **WAHA** (current) | Self-hosted WhatsApp Web | Free, full control, no monthly fees | Requires QR pairing, can break with WA updates | Development, small scale |
| **WhatsApp Cloud API** | Official Meta API | Official support, stable, webhook-based | Costs per conversation, requires Meta Business | Production, high volume |
| **BSP (Twilio/Infobip)** | Business Solution Provider | Enterprise features, multi-channel | Expensive, vendor lock-in | Enterprise, omnichannel |
| **Baileys** | WhatsApp Web library | Free, programmable | Requires coding, maintenance | Custom integrations |
| **Evolution API** | Self-hosted WA API | Similar to WAHA, more features | Heavier, more complex | Advanced features needed |

**Recommendation**: 
- **Development**: WAHA (current)
- **Production (<10k msgs/month)**: WAHA or Evolution API
- **Production (>10k msgs/month)**: WhatsApp Cloud API
- **Enterprise**: BSP (Twilio/Infobip)

#### 2. Workflow Orchestration Alternatives

| Solution | Type | Pros | Cons | Best For |
|----------|------|------|------|----------|
| **n8n** (current) | Low-code automation | Visual flows, easy debugging, 400+ integrations | Limited complex logic, vendor-specific | Small/medium teams |
| **Camunda** | BPM/workflow engine | BPMN standard, robust, Java ecosystem | Steeper learning curve, heavier | Enterprise, compliance-heavy |
| **Temporal** | Durable execution | Code-first, versioning, great for long-running | Requires coding, infrastructure | Developers, complex workflows |
| **Prefect** | Data workflow | Python-native, great observability | Data-focused, less general-purpose | Data pipelines |
| **Airflow** | Task scheduler | Mature, Python, huge community | Overkill for simple workflows | Batch/scheduled tasks |
| **Custom Flask/FastAPI** | API-based | Full control, simple | Must implement everything | Simple linear flows |

**Recommendation**:
- **Current (n8n)**: Keep for visual workflows, non-technical users
- **Enterprise**: Camunda (if compliance/audit needs) or Temporal (if dev team)
- **Simplification**: Custom Flask endpoints (if workflow is just filtering → API call)

#### 3. Vector Database Alternatives

| Solution | Type | Pros | Cons | Best For |
|----------|------|------|------|----------|
| **ChromaDB** (current) | Embedded vector DB | Simple, embedded, no setup | Single-node, limited scale | Development, <1M docs |
| **Qdrant** | Vector search engine | Fast, scalable, good UX | Requires separate service | Production, >100k docs |
| **pgvector** | PostgreSQL extension | Use existing Postgres, transactions | Slower than specialized DBs | Existing Postgres stack |
| **Weaviate** | Vector DB | Hybrid search, multi-tenancy | More complex setup | Multi-tenant SaaS |
| **Pinecone** | Managed vector DB | Fully managed, no ops | Costs, vendor lock-in | No infra management |
| **Milvus** | Distributed vector DB | Highly scalable, open-source | Complex cluster setup | Large scale (>10M docs) |

**Recommendation**:
- **Development**: ChromaDB (current)
- **Production (<1M docs)**: Qdrant (Docker deployment)
- **Production (existing Postgres)**: pgvector
- **Serverless**: Pinecone

#### 4. LLM Provider Alternatives

| Provider | Models | Pros | Cons | Best For |
|----------|--------|------|------|----------|
| **Groq** (current default) | Llama 3.3 70B | Very fast (500ms), free tier | Limited free quota | Development, speed |
| **OpenAI** | GPT-4.1, o4-mini | Best quality, reliable | Costs, data privacy | Production, quality |
| **xAI (Grok)** | Grok-4 | Reasoning, up-to-date | Expensive, newer | Complex reasoning |
| **Anthropic Claude** | Claude 3.5 Sonnet | Long context (200k), safe | No free tier | Long documents |
| **Azure OpenAI** | GPT-4 (Azure) | Enterprise SLA, compliance | More expensive | Enterprise, compliance |
| **Local (Ollama)** | Llama, Mistral | Free, private, no API limits | Requires GPU, slower | Privacy, cost control |

**Current Implementation**: Code already supports Groq, OpenAI, xAI - see `bot/ai_bot.py`

### Migration Playbooks

#### Playbook 1: WAHA → WhatsApp Cloud API

**Why migrate**: Official API, better stability, no QR pairing, webhook reliability

**Steps**:

1. **Setup Meta Business Account**
```bash
# Create at: https://business.facebook.com
# Get: App ID, Phone Number ID, Access Token
```

2. **Update `services/waha.py` → `services/whatsapp_cloud.py`**
```python
"""WhatsApp Cloud API client."""
import requests
from services.config import get_settings

class WhatsAppCloud:
    def __init__(self):
        settings = get_settings()
        self.phone_id = settings.WA_PHONE_NUMBER_ID
        self.token = settings.WA_ACCESS_TOKEN
        self.api_url = f"https://graph.facebook.com/v21.0/{self.phone_id}"
    
    def send_message(self, to: str, message: str) -> None:
        """Send text message."""
        url = f"{self.api_url}/messages"
        payload = {
            "messaging_product": "whatsapp",
            "to": to,
            "type": "text",
            "text": {"body": message}
        }
        headers = {"Authorization": f"Bearer {self.token}"}
        resp = requests.post(url, json=payload, headers=headers)
        resp.raise_for_status()
    
    def get_history_messages(self, chat_id: str, limit: int) -> list:
        """Cloud API doesn't provide history - implement external storage."""
        # Store messages in Postgres/Redis when receiving webhooks
        # Return from your database
        return []
```

3. **Update webhook handler in `app.py`**
```python
# Cloud API webhook format is different
@app.route("/chatbot/webhook/", methods=["POST", "GET"])
def webhook():
    # GET for verification
    if request.method == "GET":
        mode = request.args.get("hub.mode")
        token = request.args.get("hub.verify_token")
        challenge = request.args.get("hub.challenge")
        if mode == "subscribe" and token == VERIFY_TOKEN:
            return challenge, 200
        return "Forbidden", 403
    
    # POST for messages
    data = request.json
    for entry in data.get("entry", []):
        for change in entry.get("changes", []):
            value = change.get("value", {})
            for message in value.get("messages", []):
                from_number = message["from"]
                text = message.get("text", {}).get("body", "")
                # Process message...
```

4. **Update `compose.yml`**
```yaml
# Remove WAHA service
services:
  # Remove entire waha: section
  
  api:
    environment:
      - WA_PHONE_NUMBER_ID=${WA_PHONE_NUMBER_ID}
      - WA_ACCESS_TOKEN=${WA_ACCESS_TOKEN}
      - WA_VERIFY_TOKEN=${WA_VERIFY_TOKEN}
```

5. **Migration checklist**
- [ ] Test with WhatsApp test number
- [ ] Migrate conversation history to database
- [ ] Update n8n webhook to point to new format
- [ ] Configure Cloud API webhook to point to your server
- [ ] Monitor costs (first 1000 conversations/month free)

**Effort**: Medium (2-3 days)  
**Cost**: $0.005-0.05 per conversation after free tier

---

#### Playbook 2: n8n → Camunda/Temporal

**Why migrate**: 
- **Camunda**: Enterprise compliance, BPMN standard, audit trails
- **Temporal**: Code-first, versioning, complex state machines

##### Option A: n8n → Camunda

**Architecture Change**:
```
Before: WAHA → n8n → API
After:  WAHA → API → Camunda workers → API
```

**Steps**:

1. **Add Camunda to `compose.yml`**
```yaml
services:
  camunda:
    image: camunda/camunda-bpm-platform:latest
    ports:
      - "8080:8080"
    environment:
      - DB_DRIVER=org.postgresql.Driver
      - DB_URL=jdbc:postgresql://postgres:5432/camunda
      - DB_USERNAME=camunda
      - DB_PASSWORD=camunda
    depends_on:
      - postgres
  
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: camunda
      POSTGRES_USER: camunda
      POSTGRES_PASSWORD: camunda
    volumes:
      - postgres_data:/var/lib/postgresql/data
```

2. **Model workflow in BPMN** (use Camunda Modeler)
```xml
<!-- chatbot_flow.bpmn -->
<bpmn:process id="chatbot_process">
  <bpmn:startEvent id="message_received"/>
  <bpmn:serviceTask id="check_spam" name="Anti-spam Check"/>
  <bpmn:serviceTask id="check_hours" name="Business Hours Check"/>
  <bpmn:serviceTask id="process_ai" name="AI Processing"/>
  <bpmn:endEvent id="message_sent"/>
</bpmn:process>
```

3. **Implement workers in Python**
```python
# workers/chatbot_worker.py
from camunda.client.external_task_client import ExternalTaskClient

client = ExternalTaskClient(worker_id="chatbot-worker", base_url="http://camunda:8080/engine-rest")

@client.subscribe("process_ai")
def process_ai_task(task):
    message = task.get_variable("message")
    chat_id = task.get_variable("chat_id")
    
    # Call AI
    bot = AIBot()
    response = bot.invoke([], message)
    
    # Complete task
    return {"response": response}

client.start()
```

**Effort**: High (1-2 weeks)  
**Best for**: Compliance-heavy, audit requirements, enterprise

##### Option B: n8n → Temporal

**Architecture Change**:
```
Before: WAHA → n8n → API
After:  WAHA → API → Temporal workflows → API
```

**Steps**:

1. **Add Temporal to `compose.yml`**
```yaml
services:
  temporal:
    image: temporalio/auto-setup:latest
    ports:
      - "7233:7233"
    environment:
      - DB=postgresql
      - DB_PORT=5432
      - POSTGRES_USER=temporal
      - POSTGRES_PWD=temporal
      - POSTGRES_SEEDS=postgres
    depends_on:
      - postgres
  
  temporal-ui:
    image: temporalio/ui:latest
    ports:
      - "8088:8080"
    environment:
      - TEMPORAL_ADDRESS=temporal:7233
```

2. **Define workflow in Python**
```python
# workflows/chatbot_workflow.py
from temporalio import workflow, activity
from datetime import timedelta

@workflow.defn
class ChatbotWorkflow:
    @workflow.run
    async def run(self, chat_id: str, message: str) -> str:
        # Anti-spam check
        is_spam = await workflow.execute_activity(
            check_spam,
            args=[chat_id, message],
            start_to_close_timeout=timedelta(seconds=10)
        )
        if is_spam:
            return "SPAM_DETECTED"
        
        # Business hours check
        in_hours = await workflow.execute_activity(
            check_business_hours,
            start_to_close_timeout=timedelta(seconds=5)
        )
        if not in_hours:
            return await workflow.execute_activity(
                send_out_of_hours_message,
                args=[chat_id]
            )
        
        # Process with AI
        response = await workflow.execute_activity(
            process_ai,
            args=[chat_id, message],
            start_to_close_timeout=timedelta(seconds=30)
        )
        
        # Send response
        await workflow.execute_activity(
            send_message,
            args=[chat_id, response]
        )
        
        return response

@activity.defn
async def process_ai(chat_id: str, message: str) -> str:
    bot = AIBot()
    return bot.invoke([], message)
```

3. **Start worker**
```python
# workers/start.py
from temporalio.client import Client
from temporalio.worker import Worker
from workflows.chatbot_workflow import ChatbotWorkflow, process_ai

async def main():
    client = await Client.connect("temporal:7233")
    worker = Worker(
        client,
        task_queue="chatbot-tasks",
        workflows=[ChatbotWorkflow],
        activities=[process_ai, check_spam, send_message]
    )
    await worker.run()
```

**Effort**: Medium-High (1 week)  
**Best for**: Developers, complex state, version control needs

---

#### Playbook 3: ChromaDB → Qdrant

**Why migrate**: Better performance, clustering, production-ready

**Steps**:

1. **Add Qdrant to `compose.yml`**
```yaml
services:
  qdrant:
    image: qdrant/qdrant:latest
    ports:
      - "6333:6333"
      - "6334:6334"
    volumes:
      - qdrant_data:/qdrant/storage

volumes:
  qdrant_data:
```

2. **Update `bot/ai_bot.py`**
```python
# Replace Chroma imports
from langchain_qdrant import QdrantVectorStore
from qdrant_client import QdrantClient

# In __build_retriever():
client = QdrantClient(url="http://qdrant:6333")
vector_store = QdrantVectorStore(
    client=client,
    collection_name="tributos_docs",
    embedding=embedding
)
```

3. **Migrate data**
```python
# scripts/migrate_chroma_to_qdrant.py
from langchain_chroma import Chroma
from langchain_qdrant import QdrantVectorStore
from qdrant_client import QdrantClient

# Load from Chroma
chroma = Chroma(persist_directory="/app/chroma_data", embedding_function=embedding)
docs = chroma.get()

# Save to Qdrant
client = QdrantClient(url="http://qdrant:6333")
qdrant = QdrantVectorStore.from_documents(
    documents=docs,
    embedding=embedding,
    url="http://qdrant:6333",
    collection_name="tributos_docs"
)
```

**Effort**: Low (1 day)  
**Benefit**: 10x faster search at scale, clustering support

### Minimal Self-Hosted Stack (No n8n, No WAHA)

**Use case**: Maximum simplicity, full control, no dependencies

**Architecture**:
```
WhatsApp Cloud API → Flask API (direct) → AI Bot → Response
```

**Docker Compose** (`compose.minimal.yml`):
```yaml
version: '3.8'

services:
  # API with everything built-in
  api:
    build: .
    ports:
      - "5000:5000"
    environment:
      # WhatsApp Cloud API
      - WA_PHONE_NUMBER_ID=${WA_PHONE_NUMBER_ID}
      - WA_ACCESS_TOKEN=${WA_ACCESS_TOKEN}
      - WA_VERIFY_TOKEN=${WA_VERIFY_TOKEN}
      
      # LLM
      - LLM_PROVIDER=groq
      - GROQ_API_KEY=${GROQ_API_KEY}
      
      # Vector DB
      - VECTOR_DB=qdrant
      - QDRANT_URL=http://qdrant:6333
      
      # App
      - PORT=5000
      - ENVIRONMENT=production
    volumes:
      - ./rag/data:/app/rag/data:ro
      - ./logs:/app/logs
    depends_on:
      - qdrant
      - postgres
    restart: unless-stopped

  # Vector database
  qdrant:
    image: qdrant/qdrant:latest
    ports:
      - "6333:6333"
    volumes:
      - qdrant_data:/qdrant/storage
    restart: unless-stopped

  # PostgreSQL for conversation history
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: chatbot
      POSTGRES_USER: chatbot
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  # Redis for rate limiting
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    restart: unless-stopped

volumes:
  qdrant_data:
  postgres_data:

networks:
  default:
    name: chatbot_network
```

**Simplified API** (`app.minimal.py`):
```python
"""Minimal self-contained chatbot API."""
import os
from flask import Flask, request, jsonify
from bot.ai_bot import AIBot
from services.whatsapp_cloud import WhatsAppCloud
from services.rate_limiter import RateLimiter
from services.history_store import HistoryStore

app = Flask(__name__)

# Services
wa_client = WhatsAppCloud()
ai_bot = AIBot()
rate_limiter = RateLimiter(redis_url="redis://redis:6379")
history_store = HistoryStore(db_url=os.getenv("DATABASE_URL"))

@app.route("/webhook", methods=["GET", "POST"])
def webhook():
    # GET: WhatsApp verification
    if request.method == "GET":
        mode = request.args.get("hub.mode")
        token = request.args.get("hub.verify_token")
        challenge = request.args.get("hub.challenge")
        if mode == "subscribe" and token == os.getenv("WA_VERIFY_TOKEN"):
            return challenge, 200
        return "Forbidden", 403
    
    # POST: Handle messages
    data = request.json
    for entry in data.get("entry", []):
        for change in entry.get("changes", []):
            value = change.get("value", {})
            for message in value.get("messages", []):
                from_number = message["from"]
                text = message.get("text", {}).get("body", "")
                
                # Rate limiting
                if not rate_limiter.allow(from_number, max_per_minute=6):
                    continue
                
                # Get history
                history = history_store.get_history(from_number, limit=10)
                
                # Generate response
                response = ai_bot.invoke(history, text)
                
                # Store message and response
                history_store.add_message(from_number, "user", text)
                history_store.add_message(from_number, "assistant", response)
                
                # Send response
                wa_client.send_message(from_number, response)
    
    return "OK", 200

@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "healthy"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

**Supporting services** (minimal implementations):

```python
# services/rate_limiter.py
import redis
from datetime import datetime

class RateLimiter:
    def __init__(self, redis_url: str):
        self.redis = redis.from_url(redis_url)
    
    def allow(self, user_id: str, max_per_minute: int = 6) -> bool:
        key = f"ratelimit:{user_id}:{datetime.now().strftime('%Y%m%d%H%M')}"
        count = self.redis.incr(key)
        if count == 1:
            self.redis.expire(key, 60)
        return count <= max_per_minute

# services/history_store.py
import psycopg2
from typing import List, Dict

class HistoryStore:
    def __init__(self, db_url: str):
        self.conn = psycopg2.connect(db_url)
        self._create_table()
    
    def _create_table(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                CREATE TABLE IF NOT EXISTS messages (
                    id SERIAL PRIMARY KEY,
                    chat_id VARCHAR(50),
                    role VARCHAR(20),
                    content TEXT,
                    timestamp TIMESTAMP DEFAULT NOW()
                )
            """)
            self.conn.commit()
    
    def add_message(self, chat_id: str, role: str, content: str):
        with self.conn.cursor() as cur:
            cur.execute(
                "INSERT INTO messages (chat_id, role, content) VALUES (%s, %s, %s)",
                (chat_id, role, content)
            )
            self.conn.commit()
    
    def get_history(self, chat_id: str, limit: int = 10) -> List[Dict[str, str]]:
        with self.conn.cursor() as cur:
            cur.execute(
                "SELECT role, content FROM messages WHERE chat_id = %s ORDER BY timestamp DESC LIMIT %s",
                (chat_id, limit)
            )
            return [{"role": row[0], "content": row[1]} for row in reversed(cur.fetchall())]
```

**Start the stack**:
```bash
docker compose -f compose.minimal.yml up -d
```

**Pros of minimal stack**:
- ✅ Only 4 containers (API, Qdrant, Postgres, Redis)
- ✅ No QR code pairing
- ✅ Official WhatsApp API
- ✅ Full control over logic
- ✅ Easier debugging

**Cons of minimal stack**:
- ❌ Costs per conversation
- ❌ More code to maintain
- ❌ No visual workflow editor
- ❌ Must implement all features in code

**When to use**: Production-ready, cost is acceptable, have dev team

### Decision Matrix

| Criteria | Keep Current Stack | Migrate to Cloud API + n8n | Minimal Self-Hosted | Enterprise (Camunda) |
|----------|-------------------|----------------------------|---------------------|---------------------|
| **Cost** | Free (except LLM) | $50-200/month | $50-200/month | $500+/month |
| **Complexity** | Medium | Medium | Low | High |
| **Reliability** | Medium (WAHA breaks) | High | High | Very High |
| **Scalability** | <1000 msgs/day | <50k msgs/day | <100k msgs/day | Unlimited |
| **Team Size** | 1-2 people | 1-3 people | 2-4 developers | 5+ team |
| **Compliance** | Low | Medium | Medium | High |
| **Time to Deploy** | Ready now | 3-5 days | 1-2 weeks | 2-4 weeks |

**Recommendation by use case**:
- **MVP/Testing**: Keep current (WAHA + n8n)
- **Small production (<5k msgs/month)**: Migrate to Cloud API + n8n
- **Medium production**: Minimal self-hosted stack
- **Enterprise/Government**: Camunda + Cloud API + Qdrant

## Quick Reference

### Essential Commands
```powershell
# Start everything
.\scripts\up-n8n.ps1

# View logs
docker compose logs -f api
docker compose logs -f waha
docker compose logs -f n8n

# Restart single service
docker compose restart api

# Load knowledge base
.\scripts\load-knowledge.ps1

# Run tests
.\scripts\test.ps1

# Health check all services
.\scripts\health-check.ps1
```

### Essential Files
| File | Purpose |
|------|---------|
| `app.py` | Flask webhook handler, payload coercion |
| `bot/ai_bot.py` | RAG+LLM core, multi-provider support |
| `services/config.py` | Centralized config (Settings dataclass) |
| `services/waha.py` | WAHA client with endpoint fallback |
| `rag/load_knowledge.py` | Knowledge base loader |
| `compose.yml` | Service definitions |
| `.env` | Credentials (NEVER commit) |
| `pyproject.toml` | Tool configs (Black, Ruff, Mypy, Pytest) |

### Port Reference
| Port | Service | URL |
|------|---------|-----|
| 3000 | WAHA | http://localhost:3000 |
| 5000 | API | http://localhost:5000 |
| 5679 | n8n | http://localhost:5679 |

### Default Credentials
| Service | Username | Password | Note |
|---------|----------|----------|------|
| WAHA | `admin` | `Tributos@NovaTrento2025` | Dashboard access |
| n8n | - | Set on first access | Web UI |
| API | - | - | No auth (internal) |
