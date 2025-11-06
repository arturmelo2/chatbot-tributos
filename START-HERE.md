# 🚀 COMECE AQUI - Deploy em 5 Minutos

> **Tudo já está configurado!** Apenas execute os comandos abaixo.

---

## ⚡ Início Ultrarrápido

### Opção A: Deploy Automático (Recomendado)

```powershell
.\scripts\deploy-completo.ps1
```

Este script faz tudo automaticamente:
- ✅ Verifica pré-requisitos
- ✅ Para containers antigos
- ✅ Faz build das imagens
- ✅ Inicia todos os serviços
- ✅ Carrega base de conhecimento
- ✅ Mostra próximos passos

---

### Opção B: Passo a Passo Manual

#### 1️⃣ Verificar se está tudo OK
```powershell
.\scripts\pre-deploy-check.ps1
```

#### 2️⃣ Iniciar containers
```powershell
docker-compose up -d
```

#### 3️⃣ Carregar conhecimento
```powershell
docker-compose exec api python rag/load_knowledge.py
```

#### 4️⃣ Verificar status
```powershell
docker-compose ps
curl http://localhost:5000/health
```

---

## 🔗 Acessar Serviços

Após iniciar, acesse:

- **API:** http://localhost:5000
- **WAHA:** http://localhost:3000 (admin / Tributos@NovaTrento2025)
- **n8n:** http://localhost:5679

---

## ⚙️ Configurar n8n (5 minutos)

1. **Acessar:** http://localhost:5679

2. **Criar conta** (primeira vez)

3. **Instalar community node:**
   - Settings → Community Nodes
   - Instalar: `n8n-nodes-waha`
   - Restart n8n (automático)

4. **Importar workflow:**
   - Menu → Import from File
   - Arquivo: `n8n/workflows/chatbot_completo_orquestracao.json`

5. **Configurar credencial WAHA:**
   - No workflow, clicar no nó WAHA
   - Credential: Create New
   - Type: Header Auth
   - Header Name: `X-Api-Key`
   - Header Value: `tributos_nova_trento_2025_api_key_fixed`
   - Salvar

6. **Ativar workflow:**
   - Toggle no topo: OFF → ON
   - Deve ficar verde ✅

---

## 📱 Conectar WhatsApp (2 minutos)

### Opção A: Script Automático
```powershell
.\scripts\start-waha-session.ps1
```

### Opção B: Manual
1. Acessar: http://localhost:3000
2. Login: `admin` / `Tributos@NovaTrento2025`
3. Sessions → Add → Default
4. Scan QR Code com WhatsApp
5. Aguardar status: "WORKING" ✅

---

## ✅ Testar Sistema

Envie uma mensagem de teste do seu WhatsApp para o número conectado:

```
Olá, quanto é o IPTU?
```

**Resposta esperada:** O bot deve responder com informações sobre IPTU.

---

## 📊 Monitorar

### Ver logs em tempo real
```powershell
# API
docker-compose logs -f api

# Todos
docker-compose logs -f
```

### Status
```powershell
# Containers
docker-compose ps

# Health
curl http://localhost:5000/health

# WAHA
.\scripts\waha-status.ps1
```

---

## 🆘 Problemas?

### Container não inicia
```powershell
docker-compose logs [container-name]
```

### Porta em uso
```powershell
netstat -ano | findstr :3000
netstat -ano | findstr :5000
netstat -ano | findstr :5679
```

### Reset completo
```powershell
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
docker-compose exec api python rag/load_knowledge.py
```

---

## 📚 Documentação Completa

- **Produção:** [PRODUCTION-README.md](PRODUCTION-README.md)
- **Deploy:** [DEPLOY.md](DEPLOY.md)
- **Arquitetura:** [ARCHITECTURE.md](ARCHITECTURE.md)
- **README:** [README.md](README.md)

---

## 🎯 Checklist Final

- [ ] Docker Desktop rodando
- [ ] Executar `.\scripts\deploy-completo.ps1`
- [ ] Acessar n8n e importar workflow
- [ ] Configurar credencial WAHA no n8n
- [ ] Ativar workflow
- [ ] Conectar WhatsApp via WAHA
- [ ] Testar enviando mensagem
- [ ] ✅ **Sistema em produção!**

---

**Pronto! Seu chatbot está operacional! 🎉**

Para dúvidas, consulte [PRODUCTION-README.md](PRODUCTION-README.md)
