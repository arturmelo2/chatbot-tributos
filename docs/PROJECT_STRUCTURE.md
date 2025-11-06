# 📁 Estrutura do Repositório - Chatbot de Tributos

## 🎯 Visão Geral

Repositório organizado para uso em **produção** e **escalável**, seguindo melhores práticas de desenvolvimento Python, DevOps e documentação.

```
whatsapp-ai-chatbot/
│
├── 📄 Documentação Principal
│   ├── README.md                          # Guia de início rápido
│   ├── ARCHITECTURE.md                    # Arquitetura técnica completa
│   ├── DEPLOYMENT.md                      # Guia de deployment
│   ├── CONTRIBUTING.md                    # Guia de contribuição
│   ├── CHANGELOG.md                       # Histórico de versões
│   └── LICENSE                            # Licença MIT
│
├── 🐳 Docker & Deploy
│   ├── dockerfile                         # Imagem Docker da API
│   ├── .dockerignore                      # Otimização de build
│   ├── compose.yml                        # Stack completa (WAHA+n8n+API)
│   └── Makefile                           # Comandos úteis (build, test, run)
│
├── ⚙️ Configuração
│   ├── .env.example                       # Template de variáveis (COPIAR PARA .env)
│   ├── pyproject.toml                     # Config Python (Black, Ruff, Mypy)
│   ├── setup.py                           # Instalação como pacote Python
│   ├── MANIFEST.in                        # Arquivos incluídos no pacote
│   ├── requirements.txt                   # Dependências de produção
│   └── requirements-dev.txt               # Dependências de desenvolvimento
│
├── 🔍 Qualidade de Código
│   ├── .gitignore                         # Arquivos ignorados pelo Git
│   ├── .pre-commit-config.yaml            # Hooks pre-commit (lint, format)
│   └── .github/
│       └── workflows/
│           └── ci.yml                     # GitHub Actions (lint, test, build)
│
├── 🤖 Código Fonte
│   ├── app.py                             # Aplicação Flask (API principal)
│   ├── bot/
│   │   ├── __init__.py
│   │   ├── ai_bot.py                      # RAG + LLM chatbot
│   │   └── link_router.py                 # Menus e roteamento
│   ├── services/
│   │   ├── __init__.py
│   │   ├── config.py                      # Configuração centralizada
│   │   ├── logging_setup.py               # Setup de logging
│   │   ├── structured_logging.py          # Logs em JSON
│   │   ├── version.py                     # Versionamento (__version__)
│   │   └── waha.py                        # Cliente WAHA API
│   └── rag/
│       ├── load_knowledge.py              # Carregamento de documentos
│       └── data/                          # Base de conhecimento
│           ├── README.md
│           ├── faqs/                      # FAQs em Markdown
│           ├── leis/                      # Legislação municipal
│           ├── manuais/                   # Manuais de procedimentos
│           └── procedimentos/             # Procedimentos internos
│
├── 🔄 Workflows n8n
│   └── n8n/
│       └── workflows/
│           ├── chatbot_completo_n8n.json            # Workflow básico
│           ├── chatbot_completo_orquestracao.json   # Workflow com orquestração
│           └── chatbot_orquestracao_plus_menu.json  # Workflow com engine de menu
│
├── 🧪 Testes
│   └── tests/
│       ├── test_ai_bot.py                 # Testes do bot
│       ├── test_health.py                 # Testes de health check
│       └── test_waha.py                   # Testes integração WAHA
│
├── 🛠️ Scripts de Automação
│   └── scripts/
│       ├── up.ps1                         # Iniciar todos os serviços
│       ├── up-n8n.ps1                     # Iniciar WAHA + n8n
│       ├── rebuild.ps1                    # Rebuild completo
│       ├── load-knowledge.ps1             # Carregar base de conhecimento
│       ├── start-waha-session.ps1         # Conectar WhatsApp
│       ├── waha-status.ps1                # Status do WAHA
│       ├── logs-api.ps1                   # Ver logs da API
│       ├── export-history.ps1             # Exportar conversas
│       ├── test.ps1                       # Executar testes
│       ├── install-auto-start.ps1         # Auto-start Windows
│       └── uninstall-auto-start.ps1       # Remover auto-start
│
├── 📚 Documentação Adicional
│   └── docs/
│       ├── CONFIGURAR_N8N.md              # Setup n8n
│       ├── CONFIGURAR_WEBHOOK.md          # Config webhooks
│       ├── CREDENCIAIS_WAHA.md            # Credenciais WAHA
│       ├── DEVELOPMENT.md                 # Guia de desenvolvimento
│       ├── DOCKER_DESKTOP.md              # Instalação Docker
│       ├── DOCS_TRIBUTOS.md               # Documentação tributos
│       ├── N8N_CHATBOT_COMPLETO.md        # Guia n8n completo
│       ├── N8N_WORKFLOW.md                # Detalhes workflows
│       ├── QUICK_START_DOCKER.md          # Início rápido
│       ├── STATUS.md                      # Status do projeto
│       └── TROUBLESHOOTING_PORTA_3000.md  # Solução de problemas
│
├── 💾 Dados (Não versionados - em .gitignore)
│   ├── chroma_data/                       # Base vetorial ChromaDB
│   ├── exports/                           # Exportações de histórico
│   ├── logs/                              # Logs da aplicação
│   ├── n8n_data/                          # Dados do n8n
│   └── waha_data/                         # Dados do WAHA
│
└── 📊 Reports (Gerados por testes)
    └── htmlcov/                           # Relatório de cobertura
```

## 🚀 Como Usar

### 1️⃣ Início Rápido (Docker)

```bash
# Clone
git clone https://github.com/arturmelo2/chatbot-tributos.git
cd chatbot-tributos/whatsapp-ai-chatbot

# Configurar
cp .env.example .env
# Editar .env com suas credenciais

# Iniciar
docker-compose up -d

# Carregar conhecimento
docker-compose exec api python rag/load_knowledge.py
```

### 2️⃣ Desenvolvimento Local

```bash
# Instalar
make setup  # ou pip install -r requirements-dev.txt

# Executar
make run    # ou python app.py

# Testes
make test   # ou pytest

# Lint
make check  # ou ruff + black + mypy
```

### 3️⃣ Contribuir

```bash
# Criar branch
git checkout -b feature/minha-feature

# Fazer mudanças
# Commits seguem Conventional Commits

# Testes passam?
make test

# Lint OK?
make check

# Pull Request
```

## 📦 Arquivos Essenciais

### ⚠️ NUNCA Versionar (já no .gitignore)
- `.env` - Credenciais sensíveis
- `chroma_data/` - Base vetorial
- `logs/` - Logs da aplicação
- `waha_data/` - Dados do WAHA
- `n8n_data/` - Dados do n8n
- `__pycache__/` - Cache Python
- `venv/`, `env/` - Ambientes virtuais

### ✅ SEMPRE Versionar
- Código fonte (`*.py`)
- Testes (`tests/*.py`)
- Documentação (`*.md`)
- Configuração (`pyproject.toml`, `compose.yml`)
- Workflows (`n8n/workflows/*.json`)
- Scripts (`scripts/*.ps1`)
- Templates (`.env.example`)

## 🔐 Segurança

### Antes de Commitar

```bash
# Pre-commit hooks executam automaticamente
# Mas você pode rodar manualmente:
pre-commit run --all-files

# Verificar se .env não está sendo commitado
git status
```

### Variáveis Sensíveis

Todas as credenciais vão em `.env` (nunca versionado):
- `GROQ_API_KEY` / `OPENAI_API_KEY`
- `WAHA_API_KEY`
- `WAHA_DASHBOARD_PASSWORD`

## 📈 Qualidade de Código

### Ferramentas Configuradas

- ✅ **Black**: Formatação automática (100 chars)
- ✅ **Ruff**: Linting rápido (pycodestyle, pyflakes, isort)
- ✅ **Mypy**: Type checking
- ✅ **Pytest**: Testes unitários e integração
- ✅ **Coverage**: Cobertura de código
- ✅ **Pre-commit**: Hooks automáticos

### CI/CD (GitHub Actions)

Executa em cada push:
1. Lint (Ruff + Black + Mypy)
2. Testes (Pytest)
3. Build Docker
4. Gera relatório de cobertura

## 📞 Suporte

- **Issues**: https://github.com/arturmelo2/chatbot-tributos/issues
- **Email**: ti@novatrento.sc.gov.br
- **Docs**: `/docs` folder

---

**Versão**: 1.0.0  
**Última atualização**: Novembro 2025  
**Licença**: MIT
