# =============================================================================# =============================================================================

# Makefile - Chatbot de Tributos Nova Trento/SC# Makefile - Chatbot de Tributos Nova Trento/SC

# =============================================================================# =============================================================================

# Comandos principais para gerenciar o projeto de forma unificada

# =============================================================================.PHONY: help up down restart logs logs-api logs-n8n logs-waha health rebuild clean backup restore \

        test lint format install

# Variáveis

PYTHON := pythonhelp: ## Mostra esta mensagem de ajuda

PIP := pip	@echo "Available commands:"

DOCKER_COMPOSE := docker compose	@echo "  make up          - Start all services"

	@echo "  make down        - Stop all services"

# Cores para output	@echo "  make restart     - Restart all services"

GREEN := \033[0;32m	@echo "  make logs        - Follow all logs"

YELLOW := \033[1;33m	@echo "  make logs-api    - Follow API logs"

RED := \033[0;31m	@echo "  make logs-n8n    - Follow n8n logs"

NC := \033[0m # No Color	@echo "  make logs-waha   - Follow WAHA logs"

	@echo "  make health      - Check all services health"

.PHONY: help up down restart logs logs-api logs-n8n logs-waha health rebuild clean \	@echo "  make rebuild     - Rebuild and restart API"

        test lint format install status load-knowledge backup restore	@echo "  make clean       - Stop and remove all containers"

	@echo "  make backup      - Backup all persistent data"

# =============================================================================	@echo "  make restore     - Restore from backup"

# Help	@echo "  make test        - Run tests with coverage"

# =============================================================================	@echo "  make lint        - Run linting checks"

help: ## Mostra esta mensagem de ajuda	@echo "  make format      - Format code with Black"

	@echo "$(GREEN)Chatbot de Tributos - Comandos Disponíveis:$(NC)"	@echo "  make install     - Install dependencies"

	@echo ""

	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'# -----------------------------------------------------------------------------

	@echo ""# Docker Operations

# -----------------------------------------------------------------------------

# =============================================================================up: ## Start all services

# Docker Operations	docker compose up -d

# =============================================================================

up: ## Inicia todos os containers (WAHA + n8n + API)down: ## Stop all services

	@echo "$(GREEN)🚀 Iniciando stack completa...$(NC)"	docker compose down

	$(DOCKER_COMPOSE) up -d

	@echo "$(GREEN)✓ Containers iniciados!$(NC)"restart: ## Restart all services

	@echo "$(YELLOW)  • API:  http://localhost:5000$(NC)"	docker compose restart

	@echo "$(YELLOW)  • WAHA: http://localhost:3000$(NC)"

	@echo "$(YELLOW)  • n8n:  http://localhost:5679$(NC)"logs: ## Follow all logs

	docker compose logs -f

down: ## Para todos os containers

	@echo "$(YELLOW)⏸  Parando containers...$(NC)"logs-api: ## Follow API logs

	$(DOCKER_COMPOSE) down	docker compose logs -f api

	@echo "$(GREEN)✓ Containers parados!$(NC)"

logs-n8n: ## Follow n8n logs

restart: ## Reinicia todos os containers	docker compose logs -f n8n

	@echo "$(YELLOW)🔄 Reiniciando containers...$(NC)"

	$(DOCKER_COMPOSE) restartlogs-waha: ## Follow WAHA logs

	@echo "$(GREEN)✓ Containers reiniciados!$(NC)"	docker compose logs -f waha



rebuild: ## Reconstrói e reinicia API (após mudanças no código)rebuild: ## Rebuild and restart API

	@echo "$(GREEN)🔨 Reconstruindo API...$(NC)"	docker compose build --no-cache api

	$(DOCKER_COMPOSE) build --no-cache api	docker compose up -d api

	$(DOCKER_COMPOSE) up -d api

	@echo "$(GREEN)✓ API reconstruída e reiniciada!$(NC)"clean: ## Stop and remove all containers

	docker compose down -v

clean: ## Remove containers, volumes e networks

	@echo "$(RED)🗑️  Removendo containers e volumes...$(NC)"# -----------------------------------------------------------------------------

	$(DOCKER_COMPOSE) down -v# Health & Status

	@echo "$(GREEN)✓ Limpeza concluída!$(NC)"# -----------------------------------------------------------------------------

health: ## Check all services health

# =============================================================================	@echo "🔍 Checking services health..."

# Logs & Monitoring	@docker compose ps

# =============================================================================	@echo ""

logs: ## Mostra logs de todos os containers (tempo real)	@echo "API Health:"

	$(DOCKER_COMPOSE) logs -f	@curl -s http://localhost:5000/health | python -m json.tool || echo "❌ API not responding"

	@echo ""

logs-api: ## Mostra logs da API	@echo "n8n Health:"

	$(DOCKER_COMPOSE) logs -f api	@curl -s http://localhost:5678/healthz || echo "❌ n8n not responding"



logs-waha: ## Mostra logs do WAHAstatus: ## Show containers status

	$(DOCKER_COMPOSE) logs -f waha	docker compose ps



logs-n8n: ## Mostra logs do n8n# -----------------------------------------------------------------------------

	$(DOCKER_COMPOSE) logs -f n8n# Data Management

# -----------------------------------------------------------------------------

status: ## Mostra status dos containersbackup: ## Backup all persistent data

	@echo "$(GREEN)📊 Status dos containers:$(NC)"	@mkdir -p backups

	@$(DOCKER_COMPOSE) ps	tar -czf backups/chatbot-backup-$$(date +%Y%m%d-%H%M%S).tar.gz chroma_data/ waha_data/ n8n_data/

	@echo "✅ Backup created in backups/"

health: ## Verifica health de todos os serviços

	@echo "$(GREEN)🏥 Verificando health dos serviços...$(NC)"restore: ## Restore from backup

	@echo ""	@echo "Available backups:"

	@echo "$(YELLOW)API:$(NC)"	@ls -lh backups/*.tar.gz 2>/dev/null || echo "No backups found"

	@curl -s http://localhost:5000/health | $(PYTHON) -m json.tool || echo "$(RED)  ✗ API não está respondendo$(NC)"

	@echo ""load-knowledge: ## Load knowledge base into ChromaDB

	@echo "$(YELLOW)WAHA:$(NC)"	docker compose exec api python rag/load_knowledge.py

	@curl -s http://localhost:3000 > /dev/null && echo "$(GREEN)  ✓ WAHA OK$(NC)" || echo "$(RED)  ✗ WAHA offline$(NC)"

	@echo ""# -----------------------------------------------------------------------------

	@echo "$(YELLOW)n8n:$(NC)"# Development

	@curl -s http://localhost:5679/healthz > /dev/null && echo "$(GREEN)  ✓ n8n OK$(NC)" || echo "$(RED)  ✗ n8n offline$(NC)"# -----------------------------------------------------------------------------

install: ## Install Python dependencies

# =============================================================================	pip install --upgrade pip

# Knowledge Base & Data	pip install -r requirements.txt

# =============================================================================	pip install -r requirements-dev.txt

load-knowledge: ## Carrega documentos na base de conhecimento (ChromaDB)

	@echo "$(GREEN)📚 Carregando base de conhecimento...$(NC)"test: ## Run tests with coverage

	$(DOCKER_COMPOSE) exec api $(PYTHON) rag/load_knowledge.py	pytest --cov=. --cov-report=html --cov-report=term-missing

	@echo "$(GREEN)✓ Base de conhecimento carregada!$(NC)"

lint: ## Run linting checks

backup: ## Faz backup de todos os dados persistentes	ruff check .

	@echo "$(GREEN)💾 Criando backup...$(NC)"	mypy .

	@mkdir -p backups

	@tar -czf backups/chatbot-backup-$$(date +%Y%m%d-%H%M%S).tar.gz chroma_data/ data/ || trueformat: ## Format code with Black

	@echo "$(GREEN)✓ Backup criado em backups/$(NC)"	black .



restore: ## Lista backups disponíveis para restauraçãoformat-check: ## Check code formatting

	@echo "$(YELLOW)📦 Backups disponíveis:$(NC)"	black --check .

	@ls -lh backups/*.tar.gz 2>/dev/null || echo "$(RED)Nenhum backup encontrado$(NC)"

	@echo ""check: lint format-check test ## Run all checks (CI)

	@echo "$(YELLOW)Para restaurar, execute:$(NC)"

	@echo "  tar -xzf backups/chatbot-backup-YYYYMMDD-HHMMSS.tar.gz"# -----------------------------------------------------------------------------

# Cleanup

# =============================================================================# -----------------------------------------------------------------------------

# Development & Testingclean-cache: ## Remove Python cache files

# =============================================================================	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true

install: ## Instala dependências do projeto	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true

	@echo "$(GREEN)📦 Instalando dependências...$(NC)"	find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true

	$(PIP) install --upgrade pip	find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true

	$(PIP) install -r requirements.txt	rm -rf htmlcov/ .coverage 2>/dev/null || true

	$(PIP) install -r requirements-dev.txt

	@echo "$(GREEN)✓ Dependências instaladas!$(NC)".DEFAULT_GOAL := help



test: ## Executa testes com cobertura# -----------------------------------------------------------------------------

	@echo "$(GREEN)🧪 Executando testes...$(NC)"# Instalação e Setup

	pytest --cov=. --cov-report=html --cov-report=term-missing# -----------------------------------------------------------------------------

	@echo "$(YELLOW)📊 Relatório de cobertura: htmlcov/index.html$(NC)"install: ## Instala dependências do projeto

	@echo "$(GREEN)Instalando dependências...$(NC)"

lint: ## Verifica qualidade do código (ruff + mypy)	$(PIP) install --upgrade pip

	@echo "$(GREEN)🔍 Executando linting...$(NC)"	$(PIP) install -r requirements.txt

	ruff check .	$(PIP) install -r requirements-dev.txt

	mypy .

	@echo "$(GREEN)✓ Linting concluído!$(NC)"install-prod: ## Instala apenas dependências de produção

	@echo "$(GREEN)Instalando dependências de produção...$(NC)"

format: ## Formata código com Black	$(PIP) install --upgrade pip

	@echo "$(GREEN)✨ Formatando código...$(NC)"	$(PIP) install -r requirements.txt

	black .

	@echo "$(GREEN)✓ Código formatado!$(NC)"install-hooks: ## Instala pre-commit hooks

	@echo "$(GREEN)Instalando pre-commit hooks...$(NC)"

format-check: ## Verifica formatação sem modificar	pre-commit install

	@echo "$(GREEN)🔍 Verificando formatação...$(NC)"

	black --check .setup: install install-hooks ## Setup completo (install + hooks)

	@echo "$(GREEN)Setup concluído!$(NC)"

check: lint format-check test ## Executa todas as verificações (CI)

	@echo "$(GREEN)✅ Todas as verificações passaram!$(NC)"# -----------------------------------------------------------------------------

# Ambiente

# =============================================================================# -----------------------------------------------------------------------------

# Cleanupenv: ## Cria arquivo .env a partir do .env.example

# =============================================================================	@if [ ! -f .env ]; then \

clean-cache: ## Remove arquivos de cache Python		echo "$(YELLOW)Criando .env...$(NC)"; \

	@echo "$(YELLOW)🧹 Limpando cache...$(NC)"		cp .env.example .env; \

	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true		echo "$(GREEN)Arquivo .env criado! Configure suas credenciais.$(NC)"; \

	@find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true	else \

	@find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true		echo "$(YELLOW).env já existe$(NC)"; \

	@find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true	fi

	@find . -type f -name "*.pyc" -delete 2>/dev/null || true

	@rm -rf htmlcov/ .coverage 2>/dev/null || true# -----------------------------------------------------------------------------

	@echo "$(GREEN)✓ Cache limpo!$(NC)"# Qualidade de Código

# -----------------------------------------------------------------------------

# =============================================================================lint: ## Executa linting (ruff + mypy)

# Environment Setup	@echo "$(GREEN)Executando lint...$(NC)"

# =============================================================================	ruff check .

env: ## Cria arquivo .env a partir do .env.example	mypy .

	@if [ ! -f .env ]; then \

		echo "$(YELLOW)📝 Criando .env...$(NC)"; \lint-fix: ## Corrige problemas de lint automaticamente

		cp .env.example .env; \	@echo "$(GREEN)Corrigindo problemas de lint...$(NC)"

		echo "$(GREEN)✓ Arquivo .env criado! Configure suas credenciais.$(NC)"; \	ruff check --fix .

	else \

		echo "$(YELLOW)⚠️  .env já existe$(NC)"; \format: ## Formata código com Black

	fi	@echo "$(GREEN)Formatando código...$(NC)"

	black .

# =============================================================================

# Utilitiesformat-check: ## Verifica formatação sem modificar

# =============================================================================	@echo "$(GREEN)Verificando formatação...$(NC)"

shell: ## Abre shell Python no container da API	black --check .

	@echo "$(GREEN)🐚 Abrindo shell...$(NC)"

	$(DOCKER_COMPOSE) exec api $(PYTHON)check: lint format-check ## Verifica lint e formatação (CI)

	@echo "$(GREEN)✓ Todas as verificações passaram!$(NC)"

version: ## Mostra versão do projeto

	@$(PYTHON) -c "from services.version import __version__; print('v' + __version__)"# -----------------------------------------------------------------------------

# Testes

.DEFAULT_GOAL := help# -----------------------------------------------------------------------------

test: ## Executa todos os testes
	@echo "$(GREEN)Executando testes...$(NC)"
	pytest -v

test-cov: ## Executa testes com cobertura
	@echo "$(GREEN)Executando testes com cobertura...$(NC)"
	pytest --cov=. --cov-report=html --cov-report=term
	@echo "$(YELLOW)Relatório HTML: htmlcov/index.html$(NC)"

test-watch: ## Executa testes em modo watch
	@echo "$(GREEN)Executando testes em modo watch...$(NC)"
	pytest-watch

# -----------------------------------------------------------------------------
# Docker
# -----------------------------------------------------------------------------
docker-build: ## Build das imagens Docker
	@echo "$(GREEN)Building Docker images...$(NC)"
	$(DOCKER_COMPOSE) build

docker-up: ## Inicia todos os containers
	@echo "$(GREEN)Iniciando containers...$(NC)"
	$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)✓ Containers iniciados!$(NC)"
	@echo "$(YELLOW)API:    http://localhost:5000$(NC)"
	@echo "$(YELLOW)WAHA:   http://localhost:3000$(NC)"
	@echo "$(YELLOW)n8n:    http://localhost:5679$(NC)"

docker-up-n8n: ## Inicia apenas WAHA + n8n
	@echo "$(GREEN)Iniciando WAHA e n8n...$(NC)"
	$(DOCKER_COMPOSE) up -d waha n8n
	@echo "$(GREEN)✓ WAHA e n8n iniciados!$(NC)"

docker-down: ## Para todos os containers
	@echo "$(YELLOW)Parando containers...$(NC)"
	$(DOCKER_COMPOSE) down

docker-restart: docker-down docker-up ## Reinicia todos os containers

docker-clean: ## Remove containers, volumes e imagens
	@echo "$(RED)Removendo containers, volumes e imagens...$(NC)"
	$(DOCKER_COMPOSE) down -v --rmi all
	@echo "$(GREEN)✓ Limpeza concluída!$(NC)"

# -----------------------------------------------------------------------------
# Logs
# -----------------------------------------------------------------------------
logs: ## Mostra logs de todos os containers
	$(DOCKER_COMPOSE) logs -f

logs-api: ## Mostra logs da API
	$(DOCKER_COMPOSE) logs -f api

logs-waha: ## Mostra logs do WAHA
	$(DOCKER_COMPOSE) logs -f waha

logs-n8n: ## Mostra logs do n8n
	$(DOCKER_COMPOSE) logs -f n8n

# -----------------------------------------------------------------------------
# Desenvolvimento
# -----------------------------------------------------------------------------
run: ## Executa API localmente (sem Docker)
	@echo "$(GREEN)Iniciando API...$(NC)"
	$(PYTHON) app.py

dev: ## Modo desenvolvimento com reload automático
	@echo "$(GREEN)Iniciando em modo desenvolvimento...$(NC)"
	flask --app app.py --debug run --host=0.0.0.0 --port=5000

shell: ## Abre shell Python com contexto da aplicação
	@echo "$(GREEN)Abrindo shell...$(NC)"
	$(PYTHON) -i -c "from app import *; from bot.ai_bot import *"

# -----------------------------------------------------------------------------
# RAG / Knowledge Base
# -----------------------------------------------------------------------------
load-knowledge: ## Carrega documentos no ChromaDB
	@echo "$(GREEN)Carregando base de conhecimento...$(NC)"
	$(PYTHON) rag/load_knowledge.py

# -----------------------------------------------------------------------------
# Utilitários
# -----------------------------------------------------------------------------
clean: ## Remove arquivos temporários e cache
	@echo "$(YELLOW)Limpando arquivos temporários...$(NC)"
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	find . -type f -name "*.pyo" -delete 2>/dev/null || true
	find . -type f -name "*.log" -delete 2>/dev/null || true
	rm -rf htmlcov/ .coverage 2>/dev/null || true
	@echo "$(GREEN)✓ Limpeza concluída!$(NC)"

status: ## Mostra status dos containers
	@echo "$(GREEN)Status dos containers:$(NC)"
	$(DOCKER_COMPOSE) ps

health: ## Verifica health dos serviços
	@echo "$(GREEN)Verificando health...$(NC)"
	@curl -s http://localhost:5000/health | python -m json.tool || echo "$(RED)API não está respondendo$(NC)"
	@curl -s http://localhost:3000 > /dev/null && echo "$(GREEN)✓ WAHA OK$(NC)" || echo "$(RED)✗ WAHA offline$(NC)"
	@curl -s http://localhost:5679 > /dev/null && echo "$(GREEN)✓ n8n OK$(NC)" || echo "$(RED)✗ n8n offline$(NC)"

# -----------------------------------------------------------------------------
# Release
# -----------------------------------------------------------------------------
version: ## Mostra versão atual
	@$(PYTHON) -c "from services.version import __version__; print(__version__)"

# -----------------------------------------------------------------------------
# Default
# -----------------------------------------------------------------------------
.DEFAULT_GOAL := help
