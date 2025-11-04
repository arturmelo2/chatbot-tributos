# 🚀 Quick Start - Docker em 3 Passos

> **Coloque o Chatbot de Tributos rodando em menos de 5 minutos!**

---

## ✅ Pré-requisitos Rápidos

1. **Docker Desktop instalado e rodando** (ícone da baleia verde)
2. **Chave API do Groq** (grátis em https://console.groq.com)

---

## 📝 Passo 1: Configurar Chave API

1. Abra o arquivo `.env` na raiz do projeto
2. Localize a linha:
   ```env
   GROQ_API_KEY=gsk_demo_key_configure_sua_chave_real_aqui
   ```
3. Substitua pela sua chave real obtida em https://console.groq.com:
   ```env
   GROQ_API_KEY=gsk_sua_chave_aqui_1234567890abcdef
   ```
4. Salve o arquivo

---

## 🐳 Passo 2: Buildar e Iniciar

Abra o **PowerShell** na pasta do projeto e execute:

```powershell
# Build das imagens (primeira vez: ~10-15 min)
docker-compose build

# Iniciar containers
docker-compose up -d
```

**Aguarde até ver:**
```
✔ Container tributos_waha  Started
✔ Container tributos_api   Started
```

---

## 📚 Passo 3: Carregar Conhecimento

Popule a base vetorial com documentos de tributos:

```powershell
docker-compose exec api python rag/load_knowledge.py --clear
```

**Esperado:**
```
🤖 CARREGADOR DE CONHECIMENTO - Chatbot de Tributos Nova Trento/SC
...
✅ CONCLUÍDO!
📊 Estatísticas finais:
   Documentos originais: 6
   Chunks gerados: 33
```

---

## ✅ Pronto! Teste Agora

### 1. Verificar API
```powershell
curl http://localhost:5000/health
```
**Resposta esperada:**
```json
{
  "status": "healthy",
  "service": "Chatbot de Tributos Nova Trento/SC",
  "llm_provider": "groq"
}
```

### 2. Conectar WhatsApp

1. Abra http://localhost:3000 no navegador
2. Clique em **"Add Session"** ou **"default"**
3. Escanear o **QR Code** com seu WhatsApp:
   - WhatsApp → Menu ⋮ → "Aparelhos conectados" → "Conectar aparelho"
4. Aguarde confirmação de conexão ✅

### 3. Testar Chatbot

Envie uma mensagem para o número conectado:
```
Olá! Como pago o IPTU?
```

O chatbot deve responder com informações sobre pagamento de IPTU! 🎉

---

## 🔍 Ver Logs

```powershell
# Logs da API (chatbot)
docker-compose logs -f api

# Logs do WAHA (WhatsApp)
docker-compose logs -f waha
```

Pressione `Ctrl+C` para sair.

---

## 🛑 Parar/Reiniciar

```powershell
# Parar containers (mantém dados)
docker-compose down

# Iniciar novamente
docker-compose up -d

# Ver status
docker-compose ps
```

---

## 🐛 Problemas Comuns

### ❌ Build falha com "dependency conflict"
**Solução:** Já resolvido! Se ocorrer, verifique `requirements.txt`:
```properties
openai==1.54.0
```

### ❌ API fica "unhealthy"
**Causa:** Chave API inválida ou modelo não carregou.

**Solução:**
1. Verifique `.env`:
   ```powershell
   cat .env | Select-String "GROQ_API_KEY"
   ```
2. Teste a chave no console Groq
3. Reconstrua:
   ```powershell
   docker-compose down
   docker-compose up -d
   ```

### ⚠️ WAHA fica "unhealthy" mas funciona
**Normal!** WAHA pode reportar unhealthy se nenhuma sessão foi conectada.

**Teste:**
```powershell
curl http://localhost:3000
```
Se retornar conteúdo, está OK.

### 🟡 "Cannot load knowledge" - sem documentos
**Causa:** Pasta `rag/data/` vazia.

**Solução:** Adicione PDFs/TXTs em `rag/data/faqs/` ou `rag/data/leis/`, depois:
```powershell
docker-compose exec api python rag/load_knowledge.py
```

---

## 📁 Adicionar Documentos

1. Coloque arquivos (PDF, TXT, MD) em:
   ```
   rag/data/
   ├── faqs/         ← Perguntas frequentes
   ├── leis/         ← Leis e códigos tributários
   ├── manuais/      ← Manuais de procedimento
   └── procedimentos/
   ```

2. Recarregue a base:
   ```powershell
   docker-compose exec api python rag/load_knowledge.py
   ```

---

## 🎯 Próximos Passos

✅ Sistema rodando com Docker
⬜ Personalizar respostas em `bot/ai_bot.py`
⬜ Adicionar mais documentos de tributos
⬜ Configurar backup dos volumes
⬜ Deploy em servidor (VPS/Cloud)

**Documentação completa:** `DOCKER_DESKTOP.md`

---

## 🆘 Ainda com Problemas?

**Resetar tudo (fresh start):**
```powershell
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
docker-compose exec api python rag/load_knowledge.py --clear
```

**Salvar logs para análise:**
```powershell
docker-compose logs > debug.txt
```

---

**🎉 Sucesso? Envie sua primeira mensagem de teste!**

---

**Atualizado:** Novembro 2025
**Tempo estimado:** 5-10 minutos (primeira vez)
