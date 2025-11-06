# Comandos Úteis Pós-Refatoração

## 🔍 Explorar Mudanças

```powershell
# Ver resumo da refatoração
cat REFACTORING-SUMMARY.md

# Ver detalhes completos
cat REFACTORING.md

# Ver changelog atualizado
cat CHANGELOG.md

# Explorar índice de documentação
cat docs/INDEX.md

# Ver instruções AI expandidas
cat .github/copilot-instructions.md | Select-Object -First 300
```

## ✅ Validar Estrutura

```powershell
# Validar repositório (automatizado)
.\scripts\validate-refactoring.ps1

# Ver estrutura de pastas
tree /F /A docs
tree /F /A reverse-proxy
tree /F /A scripts
```

## 📊 Ver Status Git

```powershell
# Ver arquivos novos/modificados
git status

# Ver diff dos arquivos modificados
git diff Makefile
git diff CHANGELOG.md
git diff .gitignore

# Ver arquivos não rastreados
git status --porcelain | Select-String "^\?\?"
```

## 🚀 Testar Funcionalidade

```powershell
# Ver comandos make disponíveis
make help

# Testar comando de up
make up

# Testar health check
make health

# Testar logs
make logs-api

# Parar tudo
make down
```

## 📚 Navegar Documentação

```powershell
# Documentação principal (raiz)
ls *.md | Select-Object Name

# Documentação consolidada (docs/)
ls docs/*.md | Select-Object Name

# Scripts disponíveis
ls scripts/*.ps1 | Select-Object Name

# Workflows n8n
ls n8n/workflows/*.json | Select-Object Name
```

## 🔧 Desenvolvimento

```powershell
# Instalar dependências
make install

# Rodar testes
make test

# Rodar lint
make lint

# Formatar código
make format

# Verificar tudo (CI)
make check
```

## 📦 Backup & Restore

```powershell
# Criar backup
make backup

# Ver backups disponíveis
ls backups/*.tar.gz

# Restaurar (interativo)
make restore
```

## 🌐 Acessar Serviços

```powershell
# WAHA dashboard
start http://localhost:3000

# n8n dashboard  
start http://localhost:5679

# API health
start http://localhost:5000/health

# Ver status de todos
make status
```

## 🐛 Troubleshooting

```powershell
# Logs da API
.\scripts\logs-api.ps1

# Status WAHA
.\scripts\waha-status.ps1

# Health check local
.\scripts\health-check-local.ps1

# Rebuild completo
.\scripts\rebuild.ps1
```

## 🔄 Próximos Passos Recomendados

```powershell
# 1. Revisar toda documentação movida
Get-ChildItem docs/*.md | ForEach-Object { 
    Write-Host "`n📄 $($_.Name)" -ForegroundColor Cyan
    Get-Content $_.FullName | Select-Object -First 5
}

# 2. Testar deployment zero-touch local
# (Depois de criar compose.prod.yml do template)

# 3. Configurar CI/CD
# Ver: .github/workflows/ci.yml

# 4. Atualizar README de projeto pai (se existir)
```

## 📋 Checklist Pós-Refatoração

- [ ] ✅ Validação executada: `.\scripts\validate-refactoring.ps1`
- [ ] ✅ Documentação revisada: `docs/INDEX.md`
- [ ] ✅ Makefile testado: `make help`
- [ ] ✅ Services iniciam: `make up`
- [ ] ✅ Health checks passam: `make health`
- [ ] ✅ Testes passam: `make test`
- [ ] ✅ Lint passa: `make lint`
- [ ] ✅ Git status limpo
- [ ] ✅ Commit criado
- [ ] ✅ Push para remoto

## 🎓 Aprender Mais

```powershell
# Ver arquitetura
cat ARCHITECTURE.md

# Ver guia de desenvolvimento
cat DEVELOPMENT.md

# Ver guia de contribuição
cat CONTRIBUTING.md

# Ver instruções AI completas
cat .github/copilot-instructions.md | more
```

## 💡 Dicas

### Para encontrar algo rapidamente:
```powershell
# Buscar em toda documentação
Get-ChildItem -Recurse -Filter "*.md" | Select-String "zero-touch" | Select-Object -First 10

# Buscar em scripts
Get-ChildItem scripts/*.ps1 | Select-String "docker" | Select-Object -First 10
```

### Para gerar relatório de mudanças:
```powershell
# Ver todas as mudanças da refatoração
git log --oneline --since="2025-11-06" --pretty=format:"%h - %s (%an)"

# Ver arquivos modificados
git diff --name-status HEAD~1
```

## 🔗 Links Importantes

- **GitHub Repo**: https://github.com/arturmelo2/chatbot-tributos
- **Issues**: https://github.com/arturmelo2/chatbot-tributos/issues
- **Documentação Local**: `docs/INDEX.md`
- **AI Instructions**: `.github/copilot-instructions.md`

---

**Última atualização**: November 6, 2025  
**Versão**: 1.1.0  
