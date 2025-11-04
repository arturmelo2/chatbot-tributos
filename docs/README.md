# 📚 Documentação Adicional

Esta pasta contém documentação detalhada e guias específicos para diferentes aspectos do Chatbot de Tributos.

## 📋 Índice de Documentos

### 🚀 Guias de Início Rápido

- **[QUICK_START_DOCKER.md](QUICK_START_DOCKER.md)** - Início rápido com Docker
  - Instalação do Docker Desktop
  - Configuração básica
  - Primeiro deploy
  - Testes iniciais

### 🐳 Docker & Infraestrutura

- **[DOCKER_DESKTOP.md](DOCKER_DESKTOP.md)** - Instalação e configuração do Docker
  - Windows, Linux, macOS
  - Configuração de recursos
  - Troubleshooting comum

### 🔄 n8n (Workflow Automation)

- **[CONFIGURAR_N8N.md](CONFIGURAR_N8N.md)** - Configuração completa do n8n
  - Instalação
  - Criação de conta
  - Importação de workflows
  - Configuração de credenciais

- **[N8N_WORKFLOW.md](N8N_WORKFLOW.md)** - Detalhes dos workflows
  - Estrutura dos workflows
  - Nós principais
  - Customização

- **[N8N_CHATBOT_COMPLETO.md](N8N_CHATBOT_COMPLETO.md)** - Workflow completo
  - Orquestração avançada
  - Anti-spam
  - Horário comercial
  - Handoff humano
  - Engine de menus

### 📱 WhatsApp & WAHA

- **[CREDENCIAIS_WAHA.md](CREDENCIAIS_WAHA.md)** - Credenciais e configuração WAHA
  - API Keys
  - Dashboard login
  - Segurança

- **[CONFIGURAR_WEBHOOK.md](CONFIGURAR_WEBHOOK.md)** - Configuração de webhooks
  - Webhook WAHA → n8n
  - Eventos suportados
  - Debugging

### 💻 Desenvolvimento

- **[DEVELOPMENT.md](DEVELOPMENT.md)** - Guia completo de desenvolvimento
  - Setup do ambiente
  - Estrutura do código
  - Padrões de código
  - Testes
  - Debug

### 📖 Documentação Técnica

- **[DOCS_TRIBUTOS.md](DOCS_TRIBUTOS.md)** - Documentação sobre tributos
  - IPTU
  - Certidões
  - ISS
  - Outros tributos municipais

### 📊 Status & Acompanhamento

- **[STATUS.md](STATUS.md)** - Status do projeto
  - Funcionalidades implementadas
  - Roadmap
  - Issues conhecidos

### 🔧 Troubleshooting

- **[TROUBLESHOOTING_PORTA_3000.md](TROUBLESHOOTING_PORTA_3000.md)** - Resolver conflitos de porta
  - Identificar processo usando porta 3000
  - Matar processo
  - Alternativas

## 📖 Documentação Principal (Raiz do Projeto)

Os documentos mais importantes estão na **raiz do repositório**:

- **[../README.md](../README.md)** - ⭐ Guia principal com visão geral
- **[../ARCHITECTURE.md](../ARCHITECTURE.md)** - Arquitetura completa do sistema
- **[../DEPLOYMENT.md](../DEPLOYMENT.md)** - Guias de deployment (Docker, K8s, Cloud)
- **[../CONTRIBUTING.md](../CONTRIBUTING.md)** - Como contribuir
- **[../CHANGELOG.md](../CHANGELOG.md)** - Histórico de versões
- **[../PROJECT_STRUCTURE.md](../PROJECT_STRUCTURE.md)** - Estrutura do repositório
- **[../ORGANIZATION_SUMMARY.md](../ORGANIZATION_SUMMARY.md)** - Resumo da organização
- **[../LICENSE](../LICENSE)** - Licença MIT

## 🎯 Como Usar Esta Documentação

### Sou Novo no Projeto

1. Leia **[../README.md](../README.md)** primeiro
2. Siga **[QUICK_START_DOCKER.md](QUICK_START_DOCKER.md)**
3. Configure n8n com **[CONFIGURAR_N8N.md](CONFIGURAR_N8N.md)**
4. Conecte WhatsApp com **[CREDENCIAIS_WAHA.md](CREDENCIAIS_WAHA.md)**

### Quero Desenvolver

1. Leia **[DEVELOPMENT.md](DEVELOPMENT.md)**
2. Veja **[../CONTRIBUTING.md](../CONTRIBUTING.md)**
3. Estude **[../ARCHITECTURE.md](../ARCHITECTURE.md)**

### Vou Fazer Deploy

1. Escolha seu ambiente em **[../DEPLOYMENT.md](../DEPLOYMENT.md)**
2. Configure Docker: **[DOCKER_DESKTOP.md](DOCKER_DESKTOP.md)**
3. Configure n8n: **[CONFIGURAR_N8N.md](CONFIGURAR_N8N.md)**
4. Conecte WAHA: **[CREDENCIAIS_WAHA.md](CREDENCIAIS_WAHA.md)**

### Tenho um Problema

1. Verifique **[TROUBLESHOOTING_PORTA_3000.md](TROUBLESHOOTING_PORTA_3000.md)**
2. Consulte **[STATUS.md](STATUS.md)** para issues conhecidos
3. Veja logs: `docker-compose logs -f`
4. Abra issue no GitHub

## 📝 Convenções de Documentação

### Formato

- Todos os documentos em **Markdown (.md)**
- Cabeçalhos hierárquicos (H1 → H6)
- Code blocks com syntax highlighting
- Emojis para melhor visualização

### Estrutura Padrão

```markdown
# Título do Documento

Breve descrição do conteúdo.

## Índice

- [Seção 1](#seção-1)
- [Seção 2](#seção-2)

## Seção 1

Conteúdo...

### Subseção 1.1

Detalhes...

## Conclusão

Resumo e próximos passos.
```

### Code Blocks

```bash
# Comandos de terminal
docker-compose up -d
```

```python
# Código Python
def hello():
    print("Hello, World!")
```

```yaml
# Configuração YAML
services:
  api:
    image: chatbot-api
```

## 🔄 Manutenção da Documentação

### Quando Atualizar

- ✅ Nova funcionalidade implementada
- ✅ Mudança na arquitetura
- ✅ Novo procedimento de deploy
- ✅ Correção de bug importante
- ✅ Mudança de configuração

### Como Atualizar

1. Edite o documento relevante
2. Atualize data no rodapé
3. Adicione entry no **[../CHANGELOG.md](../CHANGELOG.md)**
4. Commit com mensagem descritiva: `docs: atualiza guia de X`

### Revisão

- Documentos revisados a cada release
- Feedback de usuários incorporado
- Links verificados periodicamente

## 📞 Contribuir com a Documentação

Encontrou um erro? Tem sugestão de melhoria?

1. Abra issue: https://github.com/arturmelo2/chatbot-tributos/issues
2. Ou envie PR com correção
3. Ou contate: ti@novatrento.sc.gov.br

## 🏷️ Tags dos Documentos

- 🚀 **Início Rápido** - Para começar rapidamente
- 🔧 **Configuração** - Setup e configuração
- 💻 **Desenvolvimento** - Para desenvolvedores
- 🐳 **DevOps** - Deploy e infraestrutura
- 📖 **Referência** - Documentação técnica detalhada
- 🔍 **Troubleshooting** - Solução de problemas

---

**Última atualização**: Novembro 2025  
**Mantido por**: Prefeitura Municipal de Nova Trento/SC  
**Licença**: MIT
