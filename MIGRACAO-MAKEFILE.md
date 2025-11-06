# 🔄 Guia de Migração: Scripts PowerShell → Makefile

## ✅ Migração Completa

A pasta `scripts/` foi **removida** e toda a funcionalidade foi migrada para o **Makefile**.

### 📋 Tabela de Conversão

| Script PowerShell Antigo | Comando Makefile Novo | Descrição |
|--------------------------|----------------------|-----------|
| `.\scripts\up-n8n.ps1` | `make up` | Inicia todos os containers |
| `.\scripts\down.ps1` | `make down` | Para todos os containers |
| `.\scripts\rebuild.ps1` | `make rebuild` | Reconstrói API |
| `.\scripts\logs-api.ps1` | `make logs-api` | Logs da API |
| `.\scripts\logs-n8n.ps1` | `make logs-n8n` | Logs do n8n |
| `.\scripts\logs-waha.ps1` | `make logs-waha` | Logs do WAHA |
| `.\scripts\load-knowledge.ps1` | `make load-knowledge` | Carrega base de conhecimento |
| `.\scripts\health-check.ps1` | `make health` | Verifica health dos serviços |
| `.\scripts\test.ps1` | `make test` | Executa testes |
| - | `make status` | Mostra status dos containers |
| - | `make backup` | Backup de dados persistentes |
| - | `make lint` | Executa linting |
| - | `make format` | Formata código |
| - | `make check` | Todas as verificações (CI) |

### 🚀 Como Usar o Makefile

#### Ver todos os comandos disponíveis:
```bash
make help
```

ou simplesmente:
```bash
make
```

#### Comandos mais usados:

```bash
# Iniciar tudo
make up

# Carregar conhecimento
make load-knowledge

# Ver logs
make logs-api

# Parar tudo
make down

# Testar
make test
```

### 🔧 Vantagens do Makefile

1. **Multiplataforma**: Funciona em Windows (via Git Bash, WSL, Make for Windows), Linux e macOS
2. **Padrão da indústria**: Usado em milhares de projetos
3. **Auto-documentação**: `make help` mostra todos os comandos
4. **Mais simples**: Um arquivo centralizado em vez de dezenas de scripts
5. **Cores e emojis**: Output formatado e legível
6. **Integração CI/CD**: Fácil de usar em pipelines

### 📦 Instalação do Make (Windows)

Se você não tem `make` no Windows:

#### Opção 1: Git Bash (Recomendado)
Make já vem com Git for Windows. Use Git Bash para executar comandos `make`.

#### Opção 2: Chocolatey
```powershell
choco install make
```

#### Opção 3: WSL (Windows Subsystem for Linux)
```powershell
wsl --install
# Dentro do WSL:
sudo apt install make
```

#### Opção 4: Make for Windows (Standalone)
Download: http://gnuwin32.sourceforge.net/packages/make.htm

### 🐳 Comandos Docker Diretos (Alternativa)

Se você não quiser usar Make, pode usar Docker Compose diretamente:

```bash
# Iniciar
docker compose up -d

# Parar
docker compose down

# Logs
docker compose logs -f api

# Status
docker compose ps

# Rebuild
docker compose build --no-cache api
docker compose up -d api
```

### ⚠️ Notas Importantes

1. **Automação do n8n**: O arquivo `deploy/bootstrap/n8n-bootstrap.sh` ainda é usado pelo Docker Compose automaticamente
2. **Variáveis de ambiente**: Continuam no `.env` (não mudou)
3. **Docker Compose**: Continue usando `compose.yml` (não mudou)
4. **Workflows n8n**: Continue em `n8n/workflows/` (não mudou)

### 📚 Documentação Atualizada

A documentação também foi limpa e consolidada:

#### ✅ **Mantidos (Documentação Principal)**:
- `README.md` - Ponto de entrada principal
- `ARCHITECTURE.md` - Arquitetura do sistema
- `DEVELOPMENT.md` - Guia de desenvolvimento
- `DEPLOY-PRODUCTION.md` - Deploy em produção
- `AUTOMACAO-N8N.md` - Automação do n8n
- `TESTE-AUTOMACAO.md` - Testes da automação
- `MIGRATION-GUIDE.md` - Guias de migração
- `docs/DEPLOY.md` - Detalhes de deploy
- `docs/INDEX.md` - Índice da documentação
- `docs/TROUBLESHOOTING_PORTA_3000.md` - Troubleshooting

#### ❌ **Removidos (Obsoletos/Redundantes)**:
- `scripts/` - **Toda a pasta** (migrado para Makefile)
- `reverse-proxy/` - Traefik não utilizado
- `deploy/caddy/` - Caddy não utilizado
- Arquivos de refatoração temporários:
  - `CHECKLIST.md`
  - `READY-TO-COMMIT.md`
  - `REFACTORING*.md`
  - `POST-REFACTORING-GUIDE.md`
  - `STATUS.md`
- Documentação obsoleta de n8n manual:
  - `docs/CONFIGURAR_N8N.md`
  - `docs/CONFIGURAR_WEBHOOK.md`
  - `docs/SETUP_N8N.md`
  - `docs/N8N_CHATBOT_COMPLETO.md`
  - `docs/N8N_WORKFLOW.md`
- Documentação duplicada:
  - `docs/DEPLOYMENT.md`
  - `docs/PRODUCTION-README.md`
  - `docs/CREDENCIAIS_WAHA.md`
  - `docs/STATUS.md`
  - `docs/RESUMO-FINAL.md`
  - `docs/ORGANIZATION_SUMMARY.md`
  - `docs/INDICE.md`

### 🎯 Resultado

**Antes da limpeza:**
- ~100 arquivos na raiz e docs/
- ~30 scripts PowerShell em scripts/
- Documentação espalhada e redundante

**Depois da limpeza:**
- ~20 arquivos essenciais
- 1 Makefile com todos os comandos
- Documentação consolidada e organizada

**Redução:** ~80% menos arquivos! 🎉

### 📖 Próximos Passos

1. **Use `make help`** para ver todos os comandos
2. **Leia `README.md`** atualizado com instruções do Makefile
3. **Consulte `AUTOMACAO-N8N.md`** para entender a automação
4. **Execute `make up`** para iniciar o sistema

---

**Data da migração:** 2025-01-06  
**Versão:** 2.0.0 (Clean Architecture)
