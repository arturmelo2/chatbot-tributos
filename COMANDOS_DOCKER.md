# 🎯 Comandos Úteis - Chatbot de Tributos

> **Referência rápida para operação do dia a dia**

---

## 🚀 Operações Básicas

### Iniciar Sistema
```powershell
# Iniciar tudo (detached)
docker-compose up -d

# Iniciar com logs visíveis
docker-compose up

# Iniciar apenas um serviço
docker-compose up -d api
docker-compose up -d waha
```

### Parar Sistema
```powershell
# Parar tudo (mantém volumes)
docker-compose down

# Parar e remover volumes (CUIDADO!)
docker-compose down -v

# Parar apenas um serviço
docker-compose stop api
docker-compose stop waha
```

### Reiniciar
```powershell
# Reiniciar tudo
docker-compose restart

# Reiniciar apenas API
docker-compose restart api

# Reiniciar apenas WAHA
docker-compose restart waha
```

---

## 📊 Monitoramento

### Status
```powershell
# Ver status dos containers
docker-compose ps

# Ver processos rodando
docker-compose top

# Estatísticas de uso (CPU, RAM, I/O)
docker stats

# Estatísticas de um container específico
docker stats tributos_api
```

### Logs
```powershell
# Logs em tempo real (todos)
docker-compose logs -f

# Logs apenas da API
docker-compose logs -f api

# Logs apenas do WAHA
docker-compose logs -f waha

# Últimas 100 linhas
docker-compose logs --tail=100

# Últimas 100 linhas da API
docker-compose logs --tail=100 api

# Salvar logs em arquivo
docker-compose logs > logs.txt
docker-compose logs api > logs-api.txt
```

### Health Checks
```powershell
# Health da API (JSON)
curl http://localhost:5000/health

# Health da API (formatado)
curl -s http://localhost:5000/health | ConvertFrom-Json | ConvertTo-Json

# WAHA (HTML)
curl http://localhost:3000

# Verificar porta aberta
Test-NetConnection localhost -Port 5000
Test-NetConnection localhost -Port 3000
```

---

## 🔧 Build e Deploy

### Build
```powershell
# Build completo (usa cache)
docker-compose build

# Build sem cache (mais lento, mas limpo)
docker-compose build --no-cache

# Build apenas da API
docker-compose build api

# Build em paralelo (mais rápido)
docker-compose build --parallel

# Build com output detalhado
docker-compose build --progress=plain
```

### Deploy (Build + Start)
```powershell
# Build e start em um comando
docker-compose up -d --build

# Force recreate (mesmo se não mudou)
docker-compose up -d --force-recreate

# Recreate apenas se mudou
docker-compose up -d --build api
```

---

## 💻 Executar Comandos

### Shell Interativo
```powershell
# Bash no container API
docker-compose exec api bash

# Bash no container WAHA
docker-compose exec waha bash

# PowerShell (se disponível)
docker-compose exec api pwsh
```

### Comandos Diretos (API)
```powershell
# Python version
docker-compose exec api python --version

# Pip list
docker-compose exec api pip list

# Ver variáveis de ambiente
docker-compose exec api env

# Listar arquivos
docker-compose exec api ls -la

# Ver conteúdo do .env
docker-compose exec api cat .env

# Testar importação Python
docker-compose exec api python -c "import langchain; print(langchain.__version__)"
```

### Comandos RAG
```powershell
# Carregar conhecimento (primeira vez)
docker-compose exec api python rag/load_knowledge.py --clear

# Adicionar novos documentos (sem limpar)
docker-compose exec api python rag/load_knowledge.py

# Ver help do script
docker-compose exec api python rag/load_knowledge.py --help

# Carregar com chunk size customizado
docker-compose exec api python rag/load_knowledge.py --chunk-size 500
```

---

## 📁 Volumes e Dados

### Listar Volumes
```powershell
# Todos os volumes
docker volume ls

# Apenas do projeto
docker volume ls | Select-String "whatsapp-ai-chatbot"
```

### Inspecionar Volume
```powershell
# Detalhes do volume Chroma
docker volume inspect whatsapp-ai-chatbot_chroma_data

# Detalhes do volume WAHA
docker volume inspect whatsapp-ai-chatbot_waha_data
```

### Backup de Volumes
```powershell
# Backup manual do Chroma
docker run --rm -v whatsapp-ai-chatbot_chroma_data:/data -v ${PWD}:/backup alpine tar czf /backup/chroma-backup.tar.gz -C /data .

# Backup manual do WAHA
docker run --rm -v whatsapp-ai-chatbot_waha_data:/data -v ${PWD}:/backup alpine tar czf /backup/waha-backup.tar.gz -C /data .
```

### Restaurar Volumes
```powershell
# Restaurar Chroma
docker run --rm -v whatsapp-ai-chatbot_chroma_data:/data -v ${PWD}:/backup alpine sh -c "cd /data && tar xzf /backup/chroma-backup.tar.gz"

# Restaurar WAHA
docker run --rm -v whatsapp-ai-chatbot_waha_data:/data -v ${PWD}:/backup alpine sh -c "cd /data && tar xzf /backup/waha-backup.tar.gz"
```

### Limpar Volumes (CUIDADO!)
```powershell
# Remover volumes do projeto
docker-compose down -v

# Remover volume específico (manual)
docker volume rm whatsapp-ai-chatbot_chroma_data
docker volume rm whatsapp-ai-chatbot_waha_data

# Limpar volumes órfãos (não usados)
docker volume prune
```

---

## 🌐 Redes

### Listar Redes
```powershell
# Todas as redes
docker network ls

# Apenas do projeto
docker network ls | Select-String "whatsapp-ai-chatbot"
```

### Inspecionar Rede
```powershell
# Detalhes da rede
docker network inspect whatsapp-ai-chatbot_tributos_network

# Ver IPs dos containers
docker network inspect whatsapp-ai-chatbot_tributos_network | ConvertFrom-Json | Select-Object -ExpandProperty Containers
```

---

## 🧹 Limpeza

### Limpeza Básica
```powershell
# Remover containers parados
docker container prune

# Remover imagens não usadas
docker image prune

# Remover volumes não usados
docker volume prune

# Remover redes não usadas
docker network prune
```

### Limpeza Completa (CUIDADO!)
```powershell
# Limpar TUDO (containers, imagens, volumes, redes)
docker system prune -a --volumes

# Limpar apenas do projeto
docker-compose down -v
docker rmi whatsapp-ai-chatbot-api
```

### Liberar Espaço
```powershell
# Ver espaço usado
docker system df

# Detalhado
docker system df -v

# Limpar build cache
docker builder prune
```

---

## 🔍 Debug e Troubleshooting

### Logs de Erro
```powershell
# Filtrar apenas erros
docker-compose logs | Select-String "ERROR"
docker-compose logs api | Select-String "ERROR"

# Filtrar warnings
docker-compose logs | Select-String "WARNING"

# Buscar texto específico
docker-compose logs | Select-String "GROQ"
docker-compose logs | Select-String "webhook"
```

### Inspecionar Container
```powershell
# Detalhes completos
docker inspect tributos_api
docker inspect tributos_waha

# Apenas IP
docker inspect tributos_api | ConvertFrom-Json | Select-Object -ExpandProperty NetworkSettings | Select-Object -ExpandProperty IPAddress

# Apenas portas
docker inspect tributos_api | ConvertFrom-Json | Select-Object -ExpandProperty NetworkSettings | Select-Object -ExpandProperty Ports
```

### Testar Conectividade
```powershell
# Ping entre containers (API → WAHA)
docker-compose exec api ping -c 3 waha

# Curl entre containers
docker-compose exec api curl -s http://waha:3000

# Testar porta específica
Test-NetConnection localhost -Port 5000
Test-NetConnection localhost -Port 3000
```

### Rebuild Completo (Reset)
```powershell
# Parar tudo
docker-compose down -v

# Limpar imagens antigas
docker rmi whatsapp-ai-chatbot-api

# Rebuild sem cache
docker-compose build --no-cache

# Subir novamente
docker-compose up -d

# Recarregar conhecimento
docker-compose exec api python rag/load_knowledge.py --clear
```

---

## 📦 Imagens Docker

### Listar Imagens
```powershell
# Todas as imagens
docker images

# Apenas do projeto
docker images | Select-String "whatsapp-ai-chatbot"
docker images | Select-String "waha"
```

### Gerenciar Imagens
```powershell
# Remover imagem antiga
docker rmi whatsapp-ai-chatbot-api

# Remover imagem com force
docker rmi -f whatsapp-ai-chatbot-api

# Remover todas não usadas
docker image prune -a

# Ver histórico de camadas
docker history whatsapp-ai-chatbot-api
```

---

## 🎯 Atalhos Úteis

### Alias (Adicione ao seu perfil PowerShell)
```powershell
# Edite: notepad $PROFILE

# Aliases úteis
function dcu { docker-compose up -d }
function dcd { docker-compose down }
function dcl { docker-compose logs -f }
function dcr { docker-compose restart }
function dcp { docker-compose ps }
function dcb { docker-compose build }

# Reload conhecimento
function rag-reload { docker-compose exec api python rag/load_knowledge.py }
function rag-clear { docker-compose exec api python rag/load_knowledge.py --clear }

# Logs específicos
function logs-api { docker-compose logs -f api }
function logs-waha { docker-compose logs -f waha }

# Shell rápido
function shell-api { docker-compose exec api bash }

# Health check
function health { curl -s http://localhost:5000/health | ConvertFrom-Json | ConvertTo-Json }
```

Depois carregue:
```powershell
. $PROFILE
```

---

## 🚨 Comandos de Emergência

### Sistema Travado
```powershell
# Forçar parada de todos os containers
docker-compose kill

# Remover containers forçadamente
docker-compose rm -f

# Restart do Docker Engine (Windows)
Restart-Service docker
```

### Container com Problema
```powershell
# Ver últimos eventos
docker events --since 10m

# Logs de startup
docker-compose logs --tail=200 api

# Forçar restart
docker-compose kill api
docker-compose up -d api
```

### Reset Total (Último Recurso)
```powershell
# CUIDADO: Remove TUDO do projeto!
docker-compose down -v
docker rmi whatsapp-ai-chatbot-api
docker system prune -f
docker-compose build --no-cache
docker-compose up -d
docker-compose exec api python rag/load_knowledge.py --clear
```

---

## 📚 Referências Rápidas

### URLs Importantes
- API: http://localhost:5000
- API Health: http://localhost:5000/health
- WAHA Dashboard: http://localhost:3000
- Groq Console: https://console.groq.com

### Arquivos Importantes
- `.env` - Variáveis de ambiente
- `compose.yml` - Configuração Docker
- `dockerfile` - Imagem da API
- `requirements.txt` - Dependências Python
- `rag/data/` - Documentos para indexar

### Documentação
- [README.md](./README.md)
- [QUICK_START_DOCKER.md](./QUICK_START_DOCKER.md)
- [DOCKER_DESKTOP.md](./DOCKER_DESKTOP.md)
- [STATUS.md](./STATUS.md)

---

**💡 Dica:** Marque esta página como favorita para referência rápida!

**Última atualização:** Novembro 2025
