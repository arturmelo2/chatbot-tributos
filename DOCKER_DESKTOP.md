# 🐳 Guia Docker Desktop - Chatbot de Tributos Nova Trento/SC

> **Guia completo para usar o Docker Desktop (interface gráfica) com o projeto**

## 📋 Pré-requisitos

1. **Docker Desktop instalado e rodando**
   - Download: https://www.docker.com/products/docker-desktop
   - Windows: versão WSL2 habilitada
   - Mínimo 4GB RAM alocada para Docker

2. **Chave API do Groq configurada**
   - Obtenha gratuitamente em: https://console.groq.com
   - Edite o arquivo `.env` e substitua `GROQ_API_KEY=gsk_demo_key...` pela sua chave real

---

## 🚀 Guia Passo a Passo

### 1️⃣ Abrir Docker Desktop

1. Inicie o **Docker Desktop** no Windows
2. Aguarde até o ícone da baleia ficar verde (Docker Engine rodando)
3. Clique no ícone da baleia na bandeja do sistema → **Dashboard**

---

### 2️⃣ Localizar o Projeto

Na aba **Containers**, você verá:

```
📦 whatsapp-ai-chatbot
   ├── 🟢 tributos_api     (porta 5000)
   └── 🟠 tributos_waha    (porta 3000)
```

**Status esperado:**
- `tributos_api`: **healthy** ✅
- `tributos_waha`: **running** (pode aparecer unhealthy, mas está OK se rodando) 🟢

---

### 3️⃣ Iniciar/Parar Containers

#### **Iniciar a Stack (Start)**
1. Clique no nome do projeto `whatsapp-ai-chatbot`
2. Clique no botão **▶ Start** (triângulo verde)
3. Aguarde 20-30 segundos até os containers iniciarem

#### **Parar a Stack (Stop)**
1. Clique no nome do projeto
2. Clique no botão **⏹ Stop** (quadrado vermelho)

#### **Remover Tudo (Delete)**
⚠️ **Cuidado:** Isso apaga os containers, mas **mantém os volumes** (base de dados)
1. Clique em `whatsapp-ai-chatbot`
2. Clique no botão **🗑 Delete**
3. Para apagar volumes também: marque "Also delete volumes"

---

### 4️⃣ Visualizar Logs

#### **Logs da API (Chatbot)**
1. Clique no container `tributos_api`
2. Aba **Logs**
3. Você verá:
   ```
   🚀 Iniciando Chatbot de Tributos em production mode
   🌐 Porta: 5000
   🔧 Debug: False
   * Running on http://0.0.0.0:5000
   ```

#### **Logs do WAHA (WhatsApp)**
1. Clique no container `tributos_waha`
2. Aba **Logs**
3. Procure por credenciais geradas:
   ```
   WAHA_API_KEY=...
   WAHA_DASHBOARD_USERNAME=admin
   WAHA_DASHBOARD_PASSWORD=...
   ```
   **Importante:** Salve essas credenciais para acessar o dashboard!

#### **Filtrar Logs**
- Use a caixa de busca no topo para filtrar (ex: "error", "webhook", "mensagem")
- Clique em **⟳ Refresh** para atualizar

---

### 5️⃣ Executar Comandos (Terminal)

#### **Acessar Shell do Container API**
1. Clique em `tributos_api`
2. Aba **Exec**
3. Digite comandos:
   ```bash
   # Verificar Python
   python --version

   # Listar arquivos
   ls -la

   # Ver variáveis de ambiente
   env | grep GROQ
   ```

#### **Carregar/Atualizar Base de Conhecimento**
Na aba **Exec** do `tributos_api`:
```bash
# Primeira carga (com limpeza)
python rag/load_knowledge.py --clear

# Adicionar novos documentos (sem limpar)
python rag/load_knowledge.py
```

Você verá:
```
🤖 CARREGADOR DE CONHECIMENTO
📂 Encontrados X arquivo(s)
✅ X documento(s) carregado(s)
✂️  X chunk(s) criado(s)
✅ CONCLUÍDO!
```

---

### 6️⃣ Inspecionar Recursos

#### **Volumes (Dados Persistentes)**
1. Aba **Volumes** no lado esquerdo
2. Localize:
   - `whatsapp-ai-chatbot_chroma_data` → Base vetorial RAG
   - `whatsapp-ai-chatbot_waha_data` → Sessões WhatsApp
3. Clique para ver tamanho e data de criação
4. **⚠️ Não delete** a menos que queira perder todos os dados!

#### **Images (Imagens Docker)**
1. Aba **Images**
2. Você verá:
   - `whatsapp-ai-chatbot-api` (imagem customizada, ~5GB)
   - `devlikeapro/waha:latest` (imagem oficial WAHA)

#### **Networks (Rede Interna)**
1. Aba **Networks**
2. `whatsapp-ai-chatbot_tributos_network` → Rede privada entre API e WAHA

---

### 7️⃣ Acessar Aplicações

#### **API do Chatbot**
- URL: http://localhost:5000
- Health Check: http://localhost:5000/health
- Esperado:
  ```json
  {
    "status": "healthy",
    "service": "Chatbot de Tributos Nova Trento/SC",
    "environment": "production",
    "llm_provider": "groq"
  }
  ```

#### **Dashboard WAHA (WhatsApp)**
- URL: http://localhost:3000
- Use as credenciais dos logs do container `tributos_waha`
- Siga o guia WAHA para conectar o WhatsApp:
  1. Crie uma nova sessão (botão "Add Session")
  2. Escaneie o QR Code com seu WhatsApp
  3. Aguarde confirmação de conexão

---

### 8️⃣ Rebuild (Reconstruir Imagens)

**Quando usar:**
- Após alterar `requirements.txt`
- Após modificar `dockerfile`
- Após mudanças no código Python

**Via Docker Desktop:**
1. Pare os containers (botão **Stop**)
2. Abra o **PowerShell** na pasta do projeto
3. Execute:
   ```powershell
   docker-compose build --no-cache
   ```
4. No Docker Desktop, clique **Start** novamente

**Via Terminal Integrado (Docker Desktop):**
1. Aba **Containers** → `whatsapp-ai-chatbot`
2. Menu **⋮** (três pontos) → **Open in terminal**
3. Digite:
   ```bash
   docker-compose build api
   docker-compose up -d api
   ```

---

## 🔧 Comandos Úteis no Terminal

Abra **PowerShell** na raiz do projeto (`C:\Users\artur\chatbot-tributos\whatsapp-ai-chatbot`):

```powershell
# Ver status dos containers
docker-compose ps

# Iniciar tudo
docker-compose up -d

# Parar tudo
docker-compose down

# Ver logs em tempo real (API)
docker-compose logs -f api

# Ver logs em tempo real (WAHA)
docker-compose logs -f waha

# Executar comando dentro do container API
docker-compose exec api python rag/load_knowledge.py

# Acessar shell do container API
docker-compose exec api bash

# Rebuild apenas a API (mais rápido)
docker-compose build api
docker-compose up -d api

# Rebuild completo (limpa cache)
docker-compose build --no-cache
docker-compose up -d

# Limpar tudo (CUIDADO: apaga volumes!)
docker-compose down -v
```

---

## 📊 Monitoramento

### **Uso de Recursos (Docker Desktop)**
1. Aba **Containers** → clique no projeto
2. Veja gráficos de:
   - CPU
   - Memória
   - Rede
   - Disco

### **Esperado em Produção:**
- **API**: 500MB - 2GB RAM (depende do modelo de embeddings)
- **WAHA**: 200MB - 500MB RAM

### **Se consumir muito:**
- Verifique se há loops infinitos nos logs
- Considere trocar `EMBEDDING_MODEL` por um mais leve:
  ```env
  EMBEDDING_MODEL=sentence-transformers/all-MiniLM-L6-v2
  ```

---

## 🐛 Troubleshooting

### ❌ Container não inicia
1. Verifique logs (aba **Logs**)
2. Procure por:
   - `Error: ...`
   - `ModuleNotFoundError`
   - `Connection refused`
3. Soluções comuns:
   - **Falta de memória**: aumente RAM do Docker (Settings → Resources → Memory)
   - **Porta ocupada**: mude `PORT=5001` no `.env` e em `compose.yml`
   - **Chave API inválida**: verifique `GROQ_API_KEY` no `.env`

### ⚠️ API "unhealthy"
1. Verifique logs: `docker-compose logs api`
2. Teste manualmente:
   ```powershell
   curl http://localhost:5000/health
   ```
3. Se retornar erro 503:
   - Chave API pode estar inválida
   - Modelo não carregou (falta memória)

### 🟠 WAHA "unhealthy" (mas rodando)
**Isso é normal!** O WAHA pode reportar unhealthy se:
- Nenhuma sessão WhatsApp foi conectada ainda
- O healthcheck interno falhou (mas a API está OK)

**Teste:**
```powershell
curl http://localhost:3000
```
Se retornar HTML/JSON, está funcionando.

### 🔴 "Cannot connect to Docker daemon"
1. Abra Docker Desktop
2. Aguarde o ícone da baleia ficar verde
3. Reinicie o PowerShell

---

## 🎯 Checklist de Produção

Antes de colocar em produção:

- [ ] `.env` configurado com **chave API real** (não demo)
- [ ] Base de conhecimento populada (`rag/load_knowledge.py`)
- [ ] Healthcheck da API retornando `200 OK`
- [ ] WAHA conectado ao WhatsApp (QR Code escaneado)
- [ ] Teste enviando mensagem para o número conectado
- [ ] Logs sem erros críticos (últimos 100 linhas)
- [ ] Volumes persistidos (não usar `-v` no `docker-compose down`)

---

## 📚 Recursos Adicionais

- [Docker Compose Docs](https://docs.docker.com/compose/)
- [WAHA Documentation](https://waha.devlike.pro/)
- [Groq API Docs](https://console.groq.com/docs)
- [LangChain Docs](https://python.langchain.com/)

---

## 🆘 Suporte

**Logs completos para debug:**
```powershell
docker-compose logs --tail=500 > logs.txt
```

**Resetar tudo (fresh start):**
```powershell
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
docker-compose exec api python rag/load_knowledge.py --clear
```

---

**Última atualização:** Novembro 2025
**Versão Docker:** 20.10+
**Versão Docker Compose:** 2.x
