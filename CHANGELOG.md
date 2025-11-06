# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [1.1.0] - 2025-11-06

### 🔄 Refatoração Completa

#### Adicionado
- **Zero-Touch Deployment**: Nova estrutura para deploy 100% automatizado
  - `compose.prod.yml`: Stack completo de produção com Traefik, Redis, ChromaDB standalone, n8n bootstrap
  - `reverse-proxy/traefik.yml`: Proxy reverso com HTTPS automático via Let's Encrypt
  - `reverse-proxy/acme.json`: Armazenamento de certificados SSL
  - `scripts/wait-for.sh`: Helper para aguardar dependências de serviços
  - `scripts/load-knowledge.sh`: Auto-load da base de conhecimento no boot
- **n8n Bootstrap Automation**: Scripts para configuração zero-touch do n8n
  - `deploy/bootstrap/n8n-bootstrap.sh`: Auto-criação de usuário, instalação de packages, import de workflows (266 linhas)
  - `deploy/bootstrap/n8n-api-config.sh`: Configuração avançada via REST API (118 linhas)
  - `deploy/bootstrap/README.md`: Documentação completa dos scripts (283 linhas)
- **Documentação Consolidada**:
  - `docs/INDEX.md`: Índice navegável de toda documentação
  - `.github/copilot-instructions.md`: Expandido com Quick Start e Zero-Touch (+400 linhas, total 1900)
  - `REFACTORING.md`: Changelog detalhado da refatoração (387 linhas)
  - `REFACTORING-SUMMARY.md`: Resumo executivo das mudanças (212 linhas)
- **Makefile Simplificado**: Comandos concisos para desenvolvimento e operação (100 linhas vs 200)
- **.env.production.example**: Template de variáveis de ambiente para produção

#### Mudado
- **Estrutura de Documentação**: 18 arquivos `.md` movidos da raiz para `docs/`
  - Mantidos na raiz apenas: README, START-HERE, ARCHITECTURE, DEVELOPMENT, CONTRIBUTING, CHANGELOG, LICENSE
  - Toda documentação específica agora em `docs/` com índice navegável
- **Makefile**: Refatorado para ser mais conciso e focado
  - Comandos principais: `make up`, `make down`, `make logs`, `make health`, `make backup`, `make test`
  - Removida formatação desnecessária, mantido apenas funcionalidade essencial
- **.gitignore**: Atualizado para incluir novos diretórios
  - `data/` (volumes persistentes de produção)
  - `reverse-proxy/acme.json` (certificados SSL)
  - `backups/` (backups automáticos)
  - `compose.*.old.yml` (backups de configs antigas)
- **services/version.py**: Atualizado de 1.0.0 para 1.1.0

#### Removido
- **Arquivos Duplicados/Obsoletos**:
  - `.env.minimal.example` (funcionalidade integrada no .env.example)
  - `compose.minimal.yml` (funcionalidade integrada no compose.prod.yml)
  - `compose.prod.caddy.yml` (substituído por Traefik em compose.prod.yml)
  - `QUICK-START.bat`, `QUICK-START.ps1` (scripts PowerShell em `scripts/` são mais completos)
  - Caches desnecessários: `.mypy_cache/`, `.pytest_cache/`, `.ruff_cache/`, `.venv-2/`
- **18 arquivos de documentação** da raiz (movidos para `docs/`, não deletados)

#### Organizado
- **Workflows n8n**: JSONs movidos de raiz para `n8n/workflows/`
  - `chatbot_orquestracao_plus_menu.json`
  - `n8n_workflow_waha_correto.json`
- **Estrutura de diretórios** otimizada para produção:
  ```
  ├── deploy/
  │   └── bootstrap/         # Scripts de auto-configuração
  ├── docs/                  # Documentação consolidada
  ├── reverse-proxy/         # Configuração Traefik + SSL
  ├── scripts/               # Helpers de automação
  └── data/                  # Volumes persistentes (gitignored)
      ├── waha/
      ├── n8n/
      ├── chroma/
      └── redis/
  ```

### 📊 Estatísticas
- **Arquivos criados**: 10 novos (configs, docs, scripts)
- **Arquivos movidos**: 18 (raiz → docs/)
- **Arquivos removidos**: 10 duplicatas/obsoletos
- **Linhas no Makefile**: -50% (200 → 100)
- **Copilot Instructions**: +27% conteúdo útil (1500 → 1900 linhas)
- **Total de mudanças**: 38 arquivos afetados

### 🎯 Benefícios
- ✅ **Deploy 100% automatizado**: `docker compose -f compose.prod.yml up -d` e pronto
- ✅ **HTTPS automático**: Let's Encrypt configurado via Traefik
- ✅ **n8n auto-configurado**: Usuário, packages e workflows criados automaticamente
- ✅ **Documentação organizada**: Fácil navegação via docs/INDEX.md
- ✅ **Zero quebra de compatibilidade**: Todos os volumes e dados preservados
- ✅ **Manutenção simplificada**: 50% menos código no Makefile

### 🔗 Ver Detalhes
Para changelog completo da refatoração, veja: [REFACTORING.md](REFACTORING.md)

---

## [1.0.0] - 2025-11-04

### 🎉 Release Inicial

#### Adicionado
- Sistema completo de chatbot para atendimento sobre tributos municipais
- Integração WhatsApp via WAHA (WhatsApp HTTP API)
- Orquestração de workflows com n8n
- RAG (Retrieval-Augmented Generation) com LangChain + ChromaDB
- Suporte a múltiplos provedores LLM (Groq, OpenAI, xAI)
- Menu interativo de links e serviços
- Histórico de conversas por usuário
- Sistema de logging estruturado (JSON)
- Docker Compose para deployment completo
- Scripts PowerShell para automação
- Documentação completa (README, ARCHITECTURE, DEPLOYMENT, CONTRIBUTING)
- Testes automatizados (pytest)
- CI/CD com GitHub Actions
- Pre-commit hooks para qualidade de código
- Health checks e monitoramento

#### Componentes
- **WAHA**: WhatsApp interface (porta 3000)
- **n8n**: Workflow automation (porta 5679)
- **API Python**: RAG + LLM processing (porta 5000)
- **ChromaDB**: Vector database (embedded)

#### Features de Produção
- ✅ Anti-spam (throttling configurável)
- ✅ Filtro de mensagens de grupos
- ✅ Controle de horário comercial
- ✅ Comandos rápidos (`/humano`, `/bot`)
- ✅ Handoff para atendimento humano
- ✅ Typing indicators (simulação de digitação)
- ✅ Logs estruturados para análise
- ✅ Configuração via variáveis de ambiente
- ✅ Auto-start no Windows (Task Scheduler)

#### Documentação
- README.md com guia de início rápido
- ARCHITECTURE.md com visão técnica completa
- DEPLOYMENT.md com procedimentos de deploy
- CONTRIBUTING.md com guia de contribuição
- Documentação inline em todo o código
- Workflows n8n documentados
- Scripts PowerShell comentados

#### Testes
- Testes unitários da API
- Testes de integração com WAHA
- Health check tests
- Cobertura de código configurada
- CI/CD automatizado

#### Infraestrutura
- Docker multi-stage builds
- Docker Compose com healthchecks
- Volumes persistentes para dados
- Network isolation
- .env.example completo
- .gitignore robusto
- .dockerignore otimizado

---

## [Unreleased]

### Planejado
- [ ] Dashboard de métricas com Grafana
- [ ] Backup automático via cron
- [ ] Testes E2E automatizados
- [ ] Multi-tenancy (múltiplas prefeituras)
- [ ] Análise de sentimento
- [ ] Relatórios de atendimento
- [ ] Kubernetes manifests
- [ ] Helm charts

---

## Convenções

### Tipos de Mudanças
- `Adicionado` - Novas funcionalidades
- `Modificado` - Mudanças em funcionalidades existentes
- `Descontinuado` - Funcionalidades que serão removidas
- `Removido` - Funcionalidades removidas
- `Corrigido` - Correções de bugs
- `Segurança` - Vulnerabilidades corrigidas

### Versionamento
- **MAJOR** (1.x.x): Mudanças incompatíveis na API
- **MINOR** (x.1.x): Novas funcionalidades compatíveis
- **PATCH** (x.x.1): Correções de bugs compatíveis

---

[1.0.0]: https://github.com/arturmelo2/chatbot-tributos/releases/tag/v1.0.0
[Unreleased]: https://github.com/arturmelo2/chatbot-tributos/compare/v1.0.0...HEAD
