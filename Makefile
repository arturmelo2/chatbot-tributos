# =============================================================================
# Makefile - Chatbot de Tributos Nova Trento/SC
# =============================================================================

.PHONY: help up down restart logs logs-api logs-n8n logs-waha health rebuild clean backup restore \
        test lint format install

help: ## Mostra esta mensagem de ajuda
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
	@echo "  make test        - Run tests with coverage"
	@echo "  make lint        - Run linting checks"
	@echo "  make format      - Format code with Black"
	@echo "  make install     - Install dependencies"

# -----------------------------------------------------------------------------
# Docker Operations
# -----------------------------------------------------------------------------
up: ## Start all services
	docker compose up -d

down: ## Stop all services
	docker compose down

restart: ## Restart all services
	docker compose restart

logs: ## Follow all logs
	docker compose logs -f

logs-api: ## Follow API logs
	docker compose logs -f api

logs-n8n: ## Follow n8n logs
	docker compose logs -f n8n

logs-waha: ## Follow WAHA logs
	docker compose logs -f waha

rebuild: ## Rebuild and restart API
	docker compose build --no-cache api
	docker compose up -d api

clean: ## Stop and remove all containers
	docker compose down -v

# -----------------------------------------------------------------------------
# Health & Status
# -----------------------------------------------------------------------------
health: ## Check all services health
	@echo "🔍 Checking services health..."
	@docker compose ps
	@echo ""
	@echo "API Health:"
	@curl -s http://localhost:5000/health | python -m json.tool || echo "❌ API not responding"
	@echo ""
	@echo "n8n Health:"
	@curl -s http://localhost:5678/healthz || echo "❌ n8n not responding"

status: ## Show containers status
	docker compose ps

# -----------------------------------------------------------------------------
# Data Management
# -----------------------------------------------------------------------------
backup: ## Backup all persistent data
	@mkdir -p backups
	tar -czf backups/chatbot-backup-$$(date +%Y%m%d-%H%M%S).tar.gz chroma_data/ waha_data/ n8n_data/
	@echo "✅ Backup created in backups/"

restore: ## Restore from backup
	@echo "Available backups:"
	@ls -lh backups/*.tar.gz 2>/dev/null || echo "No backups found"

load-knowledge: ## Load knowledge base into ChromaDB
	docker compose exec api python rag/load_knowledge.py

# -----------------------------------------------------------------------------
# Development
# -----------------------------------------------------------------------------
install: ## Install Python dependencies
	pip install --upgrade pip
	pip install -r requirements.txt
	pip install -r requirements-dev.txt

test: ## Run tests with coverage
	pytest --cov=. --cov-report=html --cov-report=term-missing

lint: ## Run linting checks
	ruff check .
	mypy .

format: ## Format code with Black
	black .

format-check: ## Check code formatting
	black --check .

check: lint format-check test ## Run all checks (CI)

# -----------------------------------------------------------------------------
# Cleanup
# -----------------------------------------------------------------------------
clean-cache: ## Remove Python cache files
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true
	rm -rf htmlcov/ .coverage 2>/dev/null || true

.DEFAULT_GOAL := help

# -----------------------------------------------------------------------------
# Instalação e Setup
# -----------------------------------------------------------------------------
install: ## Instala dependências do projeto
	@echo "$(GREEN)Instalando dependências...$(NC)"
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt
	$(PIP) install -r requirements-dev.txt

install-prod: ## Instala apenas dependências de produção
	@echo "$(GREEN)Instalando dependências de produção...$(NC)"
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt

install-hooks: ## Instala pre-commit hooks
	@echo "$(GREEN)Instalando pre-commit hooks...$(NC)"
	pre-commit install

setup: install install-hooks ## Setup completo (install + hooks)
	@echo "$(GREEN)Setup concluído!$(NC)"

# -----------------------------------------------------------------------------
# Ambiente
# -----------------------------------------------------------------------------
env: ## Cria arquivo .env a partir do .env.example
	@if [ ! -f .env ]; then \
		echo "$(YELLOW)Criando .env...$(NC)"; \
		cp .env.example .env; \
		echo "$(GREEN)Arquivo .env criado! Configure suas credenciais.$(NC)"; \
	else \
		echo "$(YELLOW).env já existe$(NC)"; \
	fi

# -----------------------------------------------------------------------------
# Qualidade de Código
# -----------------------------------------------------------------------------
lint: ## Executa linting (ruff + mypy)
	@echo "$(GREEN)Executando lint...$(NC)"
	ruff check .
	mypy .

lint-fix: ## Corrige problemas de lint automaticamente
	@echo "$(GREEN)Corrigindo problemas de lint...$(NC)"
	ruff check --fix .

format: ## Formata código com Black
	@echo "$(GREEN)Formatando código...$(NC)"
	black .

format-check: ## Verifica formatação sem modificar
	@echo "$(GREEN)Verificando formatação...$(NC)"
	black --check .

check: lint format-check ## Verifica lint e formatação (CI)
	@echo "$(GREEN)✓ Todas as verificações passaram!$(NC)"

# -----------------------------------------------------------------------------
# Testes
# -----------------------------------------------------------------------------
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
