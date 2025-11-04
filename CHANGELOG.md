# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

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
