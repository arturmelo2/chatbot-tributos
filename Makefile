# =============================================================================
# Makefile - Chatbot de Tributos Nova Trento/SC
# =============================================================================
# Comandos úteis para desenvolvimento e operação
#
# Uso: make <target>
# Lista de targets: make help
# =============================================================================

.PHONY: help install test lint format clean docker-build docker-up docker-down logs

# Variáveis
PYTHON := python
PIP := pip
DOCKER_COMPOSE := docker-compose
PROJECT_NAME := tributos_chatbot

# Cores para output
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

# -----------------------------------------------------------------------------
# Help
# -----------------------------------------------------------------------------
help: ## Mostra esta mensagem de ajuda
	@echo "$(GREEN)Chatbot de Tributos - Nova Trento/SC$(NC)"
	@echo ""
	@echo "$(YELLOW)Targets disponíveis:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""

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
