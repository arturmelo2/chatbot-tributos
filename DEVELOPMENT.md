# Desenvolvimento

Este documento descreve o fluxo de desenvolvimento local, comandos úteis, padrão de estilo e testes para este projeto.

## Requisitos

- Windows 10/11 (ou Linux/macOS)
- Docker Desktop (para executar a stack; opcional em dev puro, porém recomendado)
- Python 3.11 (para rodar linters/testes localmente)

## Setup rápido (dev local)

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements-dev.txt
```

Rodar lint + testes:

```powershell
./scripts/test.ps1            # ruff + black --check + pytest
./scripts/test.ps1 -LintOnly  # somente lint
```

## Executar com Docker (recomendado)

A stack completa é orquestrada via Docker Compose.

```powershell
# subir containers
./scripts/up.ps1

# rebuild (se alterar dependências / Dockerfile)
./scripts/rebuild.ps1
./scripts/rebuild.ps1 -NoCache

# logs
./scripts/logs-api.ps1

# carregar/conferir base de conhecimento
./scripts/load-knowledge.ps1
./scripts/load-knowledge.ps1 -Clear
```

Observações:
- Os serviços usam `restart: unless-stopped` e healthchecks.
- As credenciais e parâmetros ficam em `.env` e no `compose.yml` (env_file + overrides).
- Volumes persistentes: `chroma_data/`, `exports/`, `logs/`, e dados do WAHA/n8n.

## Variáveis importantes

Arquivo `.env` (ver também `.env.example`):

- LLM_PROVIDER / LLM_MODEL (padrão Groq: `llama-3.3-70b-versatile`)
- GROQ_API_KEY / OPENAI_API_KEY / XAI_API_KEY
- EMBEDDING_MODEL (padrão `sentence-transformers/all-MiniLM-L6-v2`)
- CHROMA_DIR (padrão `/app/chroma_data` no container)
- WAHA_API_URL / WAHA_API_KEY / WAHA_TIMEOUT
- PORT / ENVIRONMENT / DEBUG / LOG_LEVEL

## Estilo e qualidade

- Formatação: Black
- Lint: Ruff (E, F, I, B, UP, N, SIM) — configurado em `pyproject.toml`
- Tipagem: Mypy (ignora imports de libs externas por padrão)

Executar manualmente:

```powershell
ruff check .
black --check .
mypy
pytest -q
```

## Estrutura e módulos

- `services/config.py`: Configurações centralizadas via decouple/env
- `services/logging_setup.py`: Setup de logging unificado
- `services/waha.py`: Cliente WAHA com timeouts e headers
- `bot/ai_bot.py`: RAG + LLM (Groq/OpenAI/xAI) + roteamento de links opcional
- `rag/`: carga e recuperação da base de conhecimento
- `scripts/`: automação para Docker e dev no Windows

## Commits e PRs

- Use commits semânticos: `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`, etc.
- Inclua testes quando viável (ao menos smoke tests)
- Atualize documentação (README/DEVELOPMENT.md) quando necessário

## Versionamento

- A versão do serviço fica em `services/version.py`.
- Atualize quando houver mudanças compatíveis (semver sugerido).

## Dicas no Windows

- Se quiser manter os containers sempre rodando no boot, use:

```powershell
./scripts/install-auto-start.ps1 -DelaySeconds 60
# para remover
./scripts/uninstall-auto-start.ps1
```

- Preferimos `docker compose`, mas os scripts têm fallback para `docker-compose`.
