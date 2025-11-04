# Guia de Deployment - Chatbot de Tributos

Este guia detalha os procedimentos para deployment do Chatbot de Tributos em diferentes ambientes.

## 📋 Índice

- [Pré-requisitos](#pré-requisitos)
- [Deployment Local (Desenvolvimento)](#deployment-local-desenvolvimento)
- [Deployment Docker (Produção)](#deployment-docker-produção)
- [Deployment Kubernetes](#deployment-kubernetes)
- [Deployment em Nuvem](#deployment-em-nuvem)
- [Configuração Pós-Deployment](#configuração-pós-deployment)
- [Backup e Recuperação](#backup-e-recuperação)
- [Troubleshooting](#troubleshooting)

## 🔧 Pré-requisitos

### Hardware Mínimo

- **CPU**: 2 cores (4 cores recomendado)
- **RAM**: 4GB (8GB recomendado)
- **Disco**: 20GB SSD
- **Rede**: Conexão estável com internet

### Software

- **Docker**: >= 24.0
- **Docker Compose**: >= 2.20
- **Git**: >= 2.40
- **PowerShell**: >= 7.0 (Windows) ou bash (Linux)

### Credenciais Necessárias

- [ ] **Groq API Key** (ou OpenAI/xAI)
  - Obter em: https://console.groq.com
- [ ] **Número de telefone** para WhatsApp Business
- [ ] **Servidor** com IP público (para webhooks)

## 💻 Deployment Local (Desenvolvimento)

### 1. Clone do Repositório

```bash
git clone https://github.com/arturmelo2/chatbot-tributos.git
cd chatbot-tributos/whatsapp-ai-chatbot
```

### 2. Configuração do Ambiente

```bash
# Copiar arquivo de exemplo
cp .env.example .env

# Editar com suas credenciais
notepad .env  # Windows
nano .env     # Linux
```

**Variáveis obrigatórias**:
```env
LLM_PROVIDER=groq
GROQ_API_KEY=gsk_sua_chave_aqui
WAHA_API_KEY=tributos_nova_trento_2025_api_key_fixed
```

### 3. Instalação de Dependências (Modo Python)

```bash
# Criar ambiente virtual
python -m venv venv

# Ativar
.\venv\Scripts\Activate.ps1  # Windows
source venv/bin/activate     # Linux

# Instalar dependências
pip install -r requirements.txt
pip install -r requirements-dev.txt

# Instalar pre-commit hooks
pre-commit install
```

### 4. Executar Localmente

```bash
# Opção 1: Flask dev server
python app.py

# Opção 2: Com Make
make run

# Opção 3: Docker Compose (recomendado)
docker-compose up -d
```

### 5. Carregar Base de Conhecimento

```bash
# Python direto
python rag/load_knowledge.py

# PowerShell script
.\scripts\load-knowledge.ps1

# Docker
docker-compose exec api python rag/load_knowledge.py
```

## 🐳 Deployment Docker (Produção)

### Usando imagem publicada (sem build)

Para subir rapidamente usando a imagem pública multi-arquitetura já publicada no Docker Hub:

```bash
# Login opcional (se o repositório for privado)
docker login

# Subir a stack de produção (usa compose.prod.yml)
docker compose -f compose.prod.yml up -d

# Verificar status
docker compose -f compose.prod.yml ps
```

- A API usará a imagem: `arturmdmm/whatsapp-ai-chatbot:1.0.0` (versão fixada)
- Configure o `.env` com sua `GROQ_API_KEY`/`OPENAI_API_KEY` antes de subir
- Para atualizar para uma nova versão, edite `compose.prod.yml` e troque a tag

Opcional (Windows): use o script PowerShell para iniciar a stack de produção:

```powershell
./scripts/up-prod.ps1
```

### 1. Preparação do Servidor

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y docker.io docker-compose git
sudo systemctl enable --now docker

# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER
```

### 2. Clone e Configuração

```bash
# Clone do repo
git clone https://github.com/arturmelo2/chatbot-tributos.git
cd chatbot-tributos/whatsapp-ai-chatbot

# Configurar .env
cp .env.example .env
nano .env

# Ajustar permissões
chmod 600 .env
```

### 3. Build e Deploy

```bash
# Build das imagens
docker-compose build

# Iniciar serviços
docker-compose up -d

# Verificar status
docker-compose ps

# Ver logs
docker-compose logs -f
```

Observação: quando usar `compose.prod.yml`, você não precisa rodar build no servidor.

### HTTPS automático com Caddy (opcional e recomendado)

Para expor com HTTPS válido (Let’s Encrypt) e proxy reverso por caminho:

1. Crie um A/AAAA record apontando seu domínio para o IP do servidor (ex.: chatbot.seudominio.com)
2. Defina no arquivo `.env` as variáveis:

```env
DOMAIN=chatbot.seudominio.com
LETSENCRYPT_EMAIL=seu-email@dominio.com
# Basic Auth (opcional)
# Para gerar o hash: ./scripts/gen-caddy-passhash.ps1 -Plaintext "sua-senha"
N8N_USER=admin
N8N_PASSWORD_HASH=$2a$14$coloque_aqui_o_hash_gerado
WAHA_USER=admin
WAHA_PASSWORD_HASH=$2a$14$coloque_aqui_o_hash_gerado
```

3. Suba a stack com o proxy Caddy:

```powershell
./scripts/up-prod-https.ps1
```

Ou manualmente via Docker Compose:

```bash
docker compose -f compose.prod.yml -f compose.prod.caddy.yml up -d
```

Rotas expostas no domínio:
- https://$DOMAIN/api → serviço API (porta 5000)
- https://$DOMAIN/waha → WAHA (porta 3000)
- https://$DOMAIN/n8n → n8n (porta 5678 via proxy)

Requisitos:
- Portas 80 e 443 abertas no firewall e no provedor de nuvem
- DNS propagado corretamente para o IP do servidor

Gerar hash para Basic Auth (Windows PowerShell):

```powershell
./scripts/gen-caddy-passhash.ps1 -Plaintext "MinhaSenhaForte123!"
```

Copie o hash gerado para as variáveis *_PASSWORD_HASH no `.env`.

Validação rápida dos endpoints (opcional):

```powershell
./scripts/health-check.ps1 -Domain $env:DOMAIN
```

```bash
./scripts/health-check.sh "$DOMAIN"
```


### 4. Configuração do n8n

```bash
# Acessar n8n
http://seu-servidor:5679

# Criar conta administrativa
# Importar workflow de: n8n/workflows/chatbot_completo_orquestracao.json

# Criar credencial WAHA
# - Tipo: HTTP Header Auth
# - Nome: WAHA API
# - Header: X-Api-Key
# - Value: tributos_nova_trento_2025_api_key_fixed

# Ativar workflow
```

### 5. Conectar WhatsApp

```bash
# Acessar WAHA Dashboard
http://seu-servidor:3000

# Login
# Usuário: admin
# Senha: Tributos@NovaTrento2025

# Conectar sessão via QR Code
# Aguardar conexão estabelecida
```

### 6. Configurar Webhook no WAHA

```bash
# PowerShell
.\scripts\start-waha-session.ps1

# Ou manualmente via API
curl -X POST http://localhost:3000/api/default/start \
  -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed" \
  -H "Content-Type: application/json" \
  -d '{
    "webhook": {
      "url": "http://n8n:5678/webhook/8c0ac011-c46c-4c2c-bab1-ac5e0c3a365b/waha",
      "events": ["message", "session.status"]
    }
  }'
```

## ☸️ Deployment Kubernetes

### 1. Criar Namespace

```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: chatbot-tributos
```

### 2. Secrets

```yaml
# k8s/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: chatbot-secrets
  namespace: chatbot-tributos
type: Opaque
stringData:
  GROQ_API_KEY: "gsk_sua_chave_aqui"
  WAHA_API_KEY: "tributos_nova_trento_2025_api_key_fixed"
  WAHA_DASHBOARD_PASSWORD: "SenhaForte123!"
```

### 3. PersistentVolumeClaims

```yaml
# k8s/pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: chroma-data
  namespace: chatbot-tributos
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: n8n-data
  namespace: chatbot-tributos
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: waha-data
  namespace: chatbot-tributos
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

### 4. Deployments

```yaml
# k8s/api-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chatbot-api
  namespace: chatbot-tributos
spec:
  replicas: 2
  selector:
    matchLabels:
      app: chatbot-api
  template:
    metadata:
      labels:
        app: chatbot-api
    spec:
      containers:
      - name: api
        image: ghcr.io/arturmelo2/chatbot-tributos:latest
        ports:
        - containerPort: 5000
        envFrom:
        - secretRef:
            name: chatbot-secrets
        env:
        - name: LLM_PROVIDER
          value: "groq"
        - name: ENVIRONMENT
          value: "production"
        - name: CHROMA_PATH
          value: "/app/chroma_data"
        volumeMounts:
        - name: chroma-data
          mountPath: /app/chroma_data
        livenessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 10
          periodSeconds: 5
      volumes:
      - name: chroma-data
        persistentVolumeClaim:
          claimName: chroma-data
```

### 5. Services

```yaml
# k8s/services.yaml
apiVersion: v1
kind: Service
metadata:
  name: chatbot-api
  namespace: chatbot-tributos
spec:
  type: ClusterIP
  ports:
  - port: 5000
    targetPort: 5000
  selector:
    app: chatbot-api
---
apiVersion: v1
kind: Service
metadata:
  name: waha
  namespace: chatbot-tributos
spec:
  type: LoadBalancer
  ports:
  - port: 3000
    targetPort: 3000
  selector:
    app: waha
---
apiVersion: v1
kind: Service
metadata:
  name: n8n
  namespace: chatbot-tributos
spec:
  type: LoadBalancer
  ports:
  - port: 5679
    targetPort: 5678
  selector:
    app: n8n
```

### 6. Deploy no Cluster

```bash
# Aplicar manifestos
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/pvc.yaml
kubectl apply -f k8s/api-deployment.yaml
kubectl apply -f k8s/services.yaml

# Verificar status
kubectl get pods -n chatbot-tributos
kubectl get svc -n chatbot-tributos

# Logs
kubectl logs -f -n chatbot-tributos deployment/chatbot-api
```

## ☁️ Deployment em Nuvem

### AWS (EC2 + Docker)

```bash
# 1. Criar instância EC2
# - Tipo: t3.medium (2 vCPU, 4GB RAM)
# - OS: Ubuntu 22.04 LTS
# - Storage: 30GB SSD
# - Security Group: permitir portas 22, 3000, 5000, 5679

# 2. Conectar via SSH
ssh -i sua-chave.pem ubuntu@ip-da-instancia

# 3. Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu

# 4. Deploy (mesmos passos do Docker acima)
```

### Google Cloud (Cloud Run)

```dockerfile
# Ajustar dockerfile para Cloud Run
ENV PORT=8080
EXPOSE 8080
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "app:app"]
```

```bash
# Build e push
gcloud builds submit --tag gcr.io/SEU-PROJECT/chatbot-api

# Deploy
gcloud run deploy chatbot-api \
  --image gcr.io/SEU-PROJECT/chatbot-api \
  --platform managed \
  --region us-central1 \
  --memory 2Gi \
  --cpu 2 \
  --max-instances 5
```

### Azure (Container Instances)

```bash
# Criar resource group
az group create --name chatbot-rg --location eastus

# Deploy container
az container create \
  --resource-group chatbot-rg \
  --name chatbot-api \
  --image ghcr.io/arturmelo2/chatbot-tributos:latest \
  --cpu 2 \
  --memory 4 \
  --ports 5000 \
  --environment-variables \
    LLM_PROVIDER=groq \
    ENVIRONMENT=production
```

## ✅ Configuração Pós-Deployment

### 1. Health Check

```bash
# API
curl http://seu-servidor:5000/health

# WAHA
curl http://seu-servidor:3000/api/sessions

# n8n
curl http://seu-servidor:5679/healthz
```

### 2. Teste de Mensagem

```bash
# Enviar mensagem de teste pelo WhatsApp
# Verificar resposta do bot
# Checar logs para erros
docker-compose logs -f api
```

### 3. Configurar Firewall

```bash
# Ubuntu/Debian (ufw)
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 3000/tcp  # WAHA
sudo ufw allow 5000/tcp  # API
sudo ufw allow 5679/tcp  # n8n
sudo ufw enable
```

### 4. Configurar HTTPS (Nginx Reverse Proxy)

```nginx
# /etc/nginx/sites-available/chatbot
server {
    listen 80;
    server_name chatbot.novatrento.sc.gov.br;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name chatbot.novatrento.sc.gov.br;

    ssl_certificate /etc/letsencrypt/live/chatbot.novatrento.sc.gov.br/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/chatbot.novatrento.sc.gov.br/privkey.pem;

    location /api/ {
        proxy_pass http://localhost:5000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /n8n/ {
        proxy_pass http://localhost:5679/;
        proxy_set_header Host $host;
    }

    location /waha/ {
        proxy_pass http://localhost:3000/;
        proxy_set_header Host $host;
    }
}
```

```bash
# Habilitar site e reload
sudo ln -s /etc/nginx/sites-available/chatbot /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## 💾 Backup e Recuperação

### Backup Automático

```bash
# Criar script de backup
cat > backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/backups/chatbot"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup ChromaDB
docker run --rm -v tributos_chroma_data:/data -v $BACKUP_DIR:/backup \
  alpine tar czf /backup/chroma_$DATE.tar.gz -C /data .

# Backup n8n
docker run --rm -v tributos_n8n_data:/data -v $BACKUP_DIR:/backup \
  alpine tar czf /backup/n8n_$DATE.tar.gz -C /data .

# Backup WAHA
docker run --rm -v tributos_waha_data:/data -v $BACKUP_DIR:/backup \
  alpine tar czf /backup/waha_$DATE.tar.gz -C /data .

# Manter apenas últimos 7 dias
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
EOF

chmod +x backup.sh

# Agendar no cron (diário às 2h)
crontab -e
# Adicionar: 0 2 * * * /caminho/backup.sh
```

### Recuperação

```bash
# Restaurar ChromaDB
docker run --rm -v tributos_chroma_data:/data -v /backups:/backup \
  alpine tar xzf /backup/chroma_20251104_020000.tar.gz -C /data

# Reiniciar serviço
docker-compose restart api
```

## 🔍 Troubleshooting

### API não responde

```bash
# Verificar logs
docker-compose logs api

# Verificar health
curl http://localhost:5000/health

# Reiniciar
docker-compose restart api
```

### WAHA desconectou

```bash
# Verificar sessão
curl http://localhost:3000/api/sessions \
  -H "X-Api-Key: tributos_nova_trento_2025_api_key_fixed"

# Reconectar
.\scripts\start-waha-session.ps1
```

### n8n workflow não executa

```bash
# Verificar logs no dashboard n8n
# Verificar webhook URL
# Testar manualmente:
curl -X POST http://localhost:5679/webhook/8c0ac011-c46c-4c2c-bab1-ac5e0c3a365b/waha \
  -H "Content-Type: application/json" \
  -d '{"event":"message","payload":{"from":"5511999999999@c.us","body":"teste"}}'
```

### ChromaDB corrompido

```bash
# Parar API
docker-compose stop api

# Backup atual
docker run --rm -v tributos_chroma_data:/data -v $(pwd):/backup \
  alpine tar czf /backup/chroma_corrupted.tar.gz -C /data .

# Limpar e recarregar
docker volume rm tributos_chroma_data
docker-compose up -d api
docker-compose exec api python rag/load_knowledge.py
```

## 📞 Suporte

- **Issues**: https://github.com/arturmelo2/chatbot-tributos/issues
- **Email**: ti@novatrento.sc.gov.br
- **Documentação**: https://github.com/arturmelo2/chatbot-tributos

---

**Última atualização**: Novembro 2025
