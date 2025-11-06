# n8n Bootstrap Scripts

Scripts para configuração automatizada do n8n em deployment zero-touch.

## 📁 Arquivos

### 1. `n8n-bootstrap.sh`
**Script principal** que executa no primeiro boot do container n8n.

**Funcionalidades:**
- ✅ Cria usuário owner automaticamente
- ✅ Instala community packages (`n8n-nodes-waha`)
- ✅ Importa workflows do diretório
- ✅ Cria marker para evitar re-execução

**Variáveis de Ambiente:**
```bash
N8N_OWNER_EMAIL=admin@localhost
N8N_OWNER_PASSWORD=SecurePassword123!
N8N_OWNER_FIRST_NAME=Admin
N8N_OWNER_LAST_NAME=User
N8N_COMMUNITY_PACKAGES=n8n-nodes-waha
```

**Uso no docker-compose.yml:**
```yaml
n8n:
  image: n8nio/n8n:latest
  volumes:
    - ./deploy/bootstrap/n8n-bootstrap.sh:/bootstrap.sh:ro
  entrypoint: ["/bin/sh", "-c"]
  command:
    - |
      /bootstrap.sh &
      exec n8n start
  environment:
    - N8N_OWNER_EMAIL=${N8N_OWNER_EMAIL}
    - N8N_OWNER_PASSWORD=${N8N_OWNER_PASSWORD}
    - N8N_COMMUNITY_PACKAGES=n8n-nodes-waha
```

### 2. `n8n-api-config.sh`
**Script avançado** que usa a API REST do n8n para configuração completa.

**Funcionalidades:**
- ✅ Autenticação via API
- ✅ Cria credencial WAHA programaticamente
- ✅ Ativa todos os workflows automaticamente
- ✅ Validação de configuração

**Variáveis de Ambiente:**
```bash
N8N_URL=http://localhost:5678
N8N_OWNER_EMAIL=admin@localhost
N8N_OWNER_PASSWORD=SecurePassword123!
WAHA_API_KEY=tributos_nova_trento_2025_api_key_fixed
```

**Uso:**
```bash
# Executar após n8n estar rodando
./deploy/bootstrap/n8n-api-config.sh
```

## 🚀 Integração com Docker Compose

### Opção 1: Bootstrap no Entrypoint (Recomendado)

```yaml
services:
  n8n:
    image: n8nio/n8n:latest
    environment:
      - N8N_OWNER_EMAIL=${N8N_OWNER_EMAIL}
      - N8N_OWNER_PASSWORD=${N8N_OWNER_PASSWORD}
      - N8N_COMMUNITY_PACKAGES=n8n-nodes-waha
    volumes:
      - ./deploy/bootstrap/n8n-bootstrap.sh:/bootstrap.sh:ro
      - ./n8n/workflows:/home/node/.n8n/workflows:ro
      - n8n_data:/home/node/.n8n
    entrypoint: ["/bin/sh", "-c"]
    command:
      - |
        # Run bootstrap in background
        /bootstrap.sh &
        # Start n8n normally
        exec n8n start
```

### Opção 2: Script Separado Pós-Deploy

```yaml
services:
  n8n:
    image: n8nio/n8n:latest
    # ... configuração normal
    
  n8n-config:
    image: curlimages/curl:latest
    depends_on:
      n8n:
        condition: service_healthy
    volumes:
      - ./deploy/bootstrap/n8n-api-config.sh:/config.sh:ro
    entrypoint: ["/bin/sh"]
    command: ["/config.sh"]
    environment:
      - N8N_URL=http://n8n:5678
      - N8N_OWNER_EMAIL=${N8N_OWNER_EMAIL}
      - N8N_OWNER_PASSWORD=${N8N_OWNER_PASSWORD}
      - WAHA_API_KEY=${WAHA_API_KEY}
```

## 📋 Checklist de Configuração

### Pré-requisitos
- [ ] Docker Compose v2
- [ ] Variáveis de ambiente configuradas no `.env`
- [ ] Workflows em `n8n/workflows/*.json`
- [ ] Scripts com permissão de execução: `chmod +x deploy/bootstrap/*.sh`

### Primeiro Deploy
1. [ ] Configurar `.env` com credenciais
2. [ ] Subir stack: `docker compose up -d`
3. [ ] Aguardar bootstrap (2-3 minutos)
4. [ ] Verificar logs: `docker compose logs n8n | grep bootstrap`
5. [ ] Acessar n8n: http://localhost:5678
6. [ ] Fazer login com credenciais do `.env`
7. [ ] Verificar workflows importados
8. [ ] **Configurar credencial WAHA manualmente** (ainda necessário)
9. [ ] Ativar workflows

### Verificação

```bash
# Check se bootstrap completou
docker compose exec n8n cat /home/node/.n8n/.bootstrap_complete

# Check community packages instalados
docker compose exec n8n npm list -g n8n-nodes-waha

# Check workflows importados
docker compose exec n8n ls -la /home/node/.n8n/workflows/
```

## 🐛 Troubleshooting

### Bootstrap não executa
```bash
# Verificar logs
docker compose logs n8n | grep bootstrap

# Verificar permissões
ls -la deploy/bootstrap/*.sh

# Dar permissão se necessário
chmod +x deploy/bootstrap/*.sh
```

### Usuário não criado
```bash
# Verificar variáveis de ambiente
docker compose exec n8n env | grep N8N_OWNER

# Criar manualmente
docker compose exec n8n n8n user:create \
  --email admin@localhost \
  --password SecurePass123 \
  --firstName Admin \
  --lastName User
```

### Community package não instalado
```bash
# Instalar manualmente
docker compose exec n8n npm install -g n8n-nodes-waha

# Verificar instalação
docker compose exec n8n npm list -g n8n-nodes-waha
```

### Workflows não importados
```bash
# Verificar se workflows existem
ls -la n8n/workflows/

# Importar manualmente
docker compose exec n8n n8n import:workflow \
  --input=/home/node/.n8n/workflows/seu_workflow.json
```

## 🔄 Atualizações

### Re-executar Bootstrap

```bash
# Remover marker
docker compose exec n8n rm /home/node/.n8n/.bootstrap_complete

# Reiniciar container
docker compose restart n8n

# Verificar logs
docker compose logs -f n8n
```

### Atualizar Workflows

```bash
# Adicionar novos workflows em n8n/workflows/

# Remover marker
docker compose exec n8n rm /home/node/.n8n/.bootstrap_complete

# Reiniciar
docker compose restart n8n
```

## 📝 Notas

### Limitações Atuais

1. **Credencial WAHA**: Ainda requer configuração manual na UI do n8n
   - Tipo: Header Auth
   - Nome: `X-Api-Key`
   - Valor: `tributos_nova_trento_2025_api_key_fixed`

2. **Ativação de Workflows**: Workflows importados ficam inativos
   - Use `n8n-api-config.sh` para ativar via API
   - Ou ative manualmente na UI

### Melhorias Futuras

- [ ] Configuração completa de credenciais via API
- [ ] Ativação automática de workflows no bootstrap
- [ ] Health check que valida configuração completa
- [ ] Backup/restore automático de workflows
- [ ] Notificações de erro via webhook

## 🔗 Referências

- [n8n CLI Docs](https://docs.n8n.io/hosting/cli-commands/)
- [n8n API Docs](https://docs.n8n.io/api/)
- [n8n-nodes-waha](https://www.npmjs.com/package/n8n-nodes-waha)

## 📞 Suporte

- **Issues**: https://github.com/arturmelo2/chatbot-tributos/issues
- **Docs**: ../docs/N8N_CHATBOT_COMPLETO.md
- **AI Help**: ../.github/copilot-instructions.md
