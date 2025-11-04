# 📚 Guia Completo do Chatbot de Tributos

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura do Sistema](#arquitetura-do-sistema)
3. [Componentes Principais](#componentes-principais)
4. [Fluxo de Mensagens](#fluxo-de-mensagens)
5. [Tecnologias Utilizadas](#tecnologias-utilizadas)
6. [Estrutura de Pastas](#estrutura-de-pastas)
7. [Como Funciona o RAG](#como-funciona-o-rag)
8. [Configuração e Deploy](#configuração-e-deploy)
9. [Manutenção e Troubleshooting](#manutenção-e-troubleshooting)

---

## 🎯 Visão Geral

Este projeto é um **chatbot inteligente para WhatsApp** que responde automaticamente perguntas sobre tributos municipais (IPTU, certidões, taxas, etc.) da cidade de Nova Trento.

### O que ele faz?

- ✅ Recebe mensagens do WhatsApp
- ✅ Entende a pergunta do usuário
- ✅ Busca informações relevantes na base de conhecimento
- ✅ Gera respostas personalizadas usando Inteligência Artificial
- ✅ Envia a resposta automaticamente de volta ao WhatsApp

### Por que é especial?

Utiliza **RAG (Retrieval-Augmented Generation)**, uma técnica moderna de IA que:
1. Busca informações precisas em documentos oficiais
2. Usa essas informações para gerar respostas contextualizadas
3. Garante que as respostas sejam baseadas em dados reais (não inventa informações)

---

## 🏗️ Arquitetura do Sistema

O projeto é composto por **3 serviços principais** rodando em containers Docker:

```
┌─────────────────────────────────────────────────────────────┐
│                        WHATSAPP                              │
│                     (Usuário envia mensagem)                 │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                     WAHA (Porta 3000)                        │
│          WhatsApp HTTP API - Conecta ao WhatsApp             │
│                                                               │
│  • Recebe mensagens do WhatsApp                              │
│  • Envia eventos para o n8n via webhook                      │
│  • Envia respostas de volta ao WhatsApp                      │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                      n8n (Porta 5678)                        │
│              Orquestrador de Workflows                       │
│                                                               │
│  • Recebe eventos do WAHA                                    │
│  • Filtra apenas mensagens de texto                          │
│  • Encaminha para a API Python                               │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   API Python (Porta 5000)                    │
│                  Cérebro do Chatbot                          │
│                                                               │
│  ┌───────────────────────────────────────────────┐          │
│  │ 1. Recebe mensagem                             │          │
│  └───────────────────────────────────────────────┘          │
│                         │                                     │
│                         ▼                                     │
│  ┌───────────────────────────────────────────────┐          │
│  │ 2. RAG - Busca em ChromaDB                    │          │
│  │    (Vetorização + Busca Semântica)            │          │
│  └───────────────────────────────────────────────┘          │
│                         │                                     │
│                         ▼                                     │
│  ┌───────────────────────────────────────────────┐          │
│  │ 3. LLM xAI - Gera resposta                    │          │
│  │    (Usa contexto encontrado)                  │          │
│  └───────────────────────────────────────────────┘          │
│                         │                                     │
│                         ▼                                     │
│  ┌───────────────────────────────────────────────┐          │
│  │ 4. Envia resposta via WAHA                    │          │
│  └───────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 Componentes Principais

### 1. WAHA (WhatsApp HTTP API)

**O que é?**  
Um servidor que conecta ao WhatsApp Web e expõe uma API HTTP para enviar/receber mensagens.

**Como funciona?**
- Você escaneia um QR Code (como no WhatsApp Web)
- O WAHA mantém a sessão ativa
- Cada mensagem recebida vira um evento HTTP enviado para o n8n

**Configuração Principal:**
```yaml
# compose.yml
environment:
  WHATSAPP_HOOK_URL: http://n8n:5678/webhook/8c0ac011.../waha
  WHATSAPP_HOOK_EVENTS: message,message.any,state.change,session.status
```

**Porta:** 3000 (http://localhost:3000)

---

### 2. n8n (Orquestrador)

**O que é?**  
Uma ferramenta de automação visual que conecta diferentes serviços através de workflows.

**Por que usar?**
- Interface gráfica para criar fluxos de dados
- Facilita manutenção e debugging
- Permite adicionar lógicas complexas sem código
- Pode integrar com outros serviços no futuro

**Workflows Ativos:**

#### a) Chatbot Tributos - Webhook Simples v3 (Produção)
```
[Webhook] → [Filtro] → [HTTP Request para API] → [Fim]
    │           │              │
    │           │              └─ POST http://api:5000/chatbot/webhook/
    │           │
    │           └─ Só processa se event = "message"
    │
    └─ Recebe eventos do WAHA
```

#### b) Chatbot Orquestração - Plus + Menu Engine
- Workflow mais complexo com sistema de menus
- Ainda não em uso na produção atual

**Porta:** 5678 (http://localhost:5679 - mapeado para 5679 externamente)

---

### 3. API Python (Flask)

**O que é?**  
O cérebro do sistema - processa mensagens e gera respostas inteligentes.

**Estrutura do Código:**

```python
# app.py
@app.route('/chatbot/webhook/', methods=['POST'])
def chatbot_webhook():
    # 1. Recebe evento do n8n
    data = request.get_json()
    
    # 2. Extrai mensagem
    message = data['payload']['body']
    from_number = data['payload']['from']
    
    # 3. Busca contexto relevante (RAG)
    context = rag_search(message)
    
    # 4. Gera resposta com LLM
    response = generate_response(message, context)
    
    # 5. Envia de volta via WAHA
    send_to_whatsapp(from_number, response)
    
    return jsonify({"status": "ok"})
```

**Tecnologias:**
- **Flask**: Framework web Python
- **ChromaDB**: Banco de dados vetorial para RAG
- **Sentence Transformers**: Gera embeddings (vetores) dos textos
- **xAI API**: LLM para gerar respostas naturais

**Porta:** 5000 (http://localhost:5000)

---

## 📨 Fluxo de Mensagens (Passo a Passo)

### Exemplo: Usuário pergunta "Como emitir segunda via do IPTU?"

```
1️⃣ USUÁRIO ENVIA MENSAGEM
   WhatsApp: "Como emitir segunda via do IPTU?"
   
   ↓

2️⃣ WAHA RECEBE E CRIA EVENTO
   {
     "event": "message",
     "session": "default",
     "payload": {
       "from": "5548999999999@c.us",
       "body": "Como emitir segunda via do IPTU?",
       "timestamp": 1730761234567
     }
   }
   
   ↓

3️⃣ WAHA ENVIA WEBHOOK PARA n8n
   POST http://n8n:5678/webhook/8c0ac011.../waha
   
   ↓

4️⃣ n8n PROCESSA WORKFLOW v3
   • Verifica: event == "message" ✓
   • Extrai: payload.body
   • Encaminha para API
   
   ↓

5️⃣ API PYTHON RECEBE
   POST http://api:5000/chatbot/webhook/
   Body: {
     "event": "message",
     "payload": {
       "from": "5548999999999@c.us",
       "body": "Como emitir segunda via do IPTU?"
     }
   }
   
   ↓

6️⃣ RAG - BUSCA NO CHROMADB
   • Transforma pergunta em vetor (embedding)
   • Busca documentos similares no ChromaDB
   • Encontra: FAQ_IPTU.md
   • Extrai trecho relevante:
     "Para emitir 2ª via do IPTU, acesse o portal..."
   
   ↓

7️⃣ LLM GERA RESPOSTA
   Prompt para xAI:
   """
   Contexto: [trecho do FAQ_IPTU.md]
   
   Pergunta: Como emitir segunda via do IPTU?
   
   Responda de forma clara e objetiva.
   """
   
   Resposta gerada:
   "Olá! Para emitir a segunda via do IPTU, você pode:
   1. Acessar o portal da prefeitura em...
   2. Ou comparecer presencialmente na secretaria..."
   
   ↓

8️⃣ API ENVIA PARA WAHA
   POST http://waha:3000/api/sendText
   {
     "chatId": "5548999999999@c.us",
     "text": "Olá! Para emitir a segunda via..."
   }
   
   ↓

9️⃣ WAHA ENVIA PARA WHATSAPP
   WhatsApp recebe mensagem automaticamente
   
   ↓

🔟 USUÁRIO RECEBE RESPOSTA
   ✅ "Olá! Para emitir a segunda via do IPTU..."
```

---

## 🤖 Como Funciona o RAG

**RAG = Retrieval-Augmented Generation**  
(Geração Aumentada por Recuperação)

### Conceito

Imagine que você tem uma biblioteca gigante e um assistente muito inteligente:
1. 📚 **Biblioteca** = ChromaDB (base de conhecimento)
2. 🔍 **Busca** = Sentence Transformers (encontra documentos relevantes)
3. 🧠 **Assistente** = xAI LLM (gera respostas naturais)

### Passo 1: Preparação da Base (Executado uma vez)

```python
# rag/load_knowledge.py

# 1. Lê documentos das pastas
docs = [
    "rag/data/faqs/FAQ_IPTU.md",
    "rag/data/faqs/FAQ_Certidoes.md",
    # ... mais documentos
]

# 2. Divide em pedaços menores (chunks)
chunks = [
    "Para emitir IPTU acesse...",
    "Certidão negativa pode ser obtida...",
    # ...
]

# 3. Transforma cada chunk em vetor (embedding)
# Vetor = sequência de números que representa o significado
embeddings = model.encode(chunks)
# Ex: [0.23, -0.15, 0.87, ...] (384 números)

# 4. Salva no ChromaDB
chroma_collection.add(
    documents=chunks,
    embeddings=embeddings,
    ids=["chunk_1", "chunk_2", ...]
)
```

### Passo 2: Busca em Tempo Real

```python
# bot/ai_bot.py

def process_message(user_message):
    # 1. Transforma pergunta em vetor
    query_embedding = model.encode(user_message)
    
    # 2. Busca chunks similares no ChromaDB
    # (usa distância cosseno entre vetores)
    results = chroma_collection.query(
        query_embeddings=[query_embedding],
        n_results=3  # Top 3 mais relevantes
    )
    
    # 3. Monta contexto
    context = "\n".join(results['documents'])
    
    # 4. Envia para LLM
    prompt = f"""
    Baseado no contexto abaixo, responda a pergunta:
    
    CONTEXTO:
    {context}
    
    PERGUNTA:
    {user_message}
    """
    
    response = llm.generate(prompt)
    return response
```

### Por que isso é poderoso?

❌ **Sem RAG**: LLM pode inventar informações ("alucinação")  
✅ **Com RAG**: LLM responde baseado em documentos reais

---

## 🛠️ Tecnologias Utilizadas

### Backend
- **Python 3.11**: Linguagem principal
- **Flask**: Framework web leve
- **ChromaDB**: Banco de dados vetorial
- **Sentence Transformers**: Modelo de embeddings (all-MiniLM-L6-v2)
- **xAI API**: LLM Grok para geração de texto

### Infraestrutura
- **Docker**: Containerização
- **Docker Compose**: Orquestração de containers
- **n8n**: Automação de workflows
- **WAHA**: API para WhatsApp

### Ferramentas
- **PowerShell**: Scripts de automação (Windows)
- **Git**: Controle de versão

---

## 📁 Estrutura de Pastas

```
whatsapp-ai-chatbot/
│
├── app.py                      # 🚀 Aplicação Flask principal
├── compose.yml                 # 🐳 Configuração Docker Compose
├── dockerfile                  # 🐳 Imagem Docker da API
├── requirements.txt            # 📦 Dependências Python
├── pyproject.toml             # 🔧 Configuração do projeto
│
├── bot/                        # 🤖 Lógica do chatbot
│   ├── __init__.py
│   ├── ai_bot.py              # Processamento de mensagens + RAG
│   └── link_router.py         # Detecção de links
│
├── services/                   # 🔧 Serviços auxiliares
│   ├── config.py              # Configurações (env vars)
│   ├── waha.py                # Cliente WAHA
│   ├── logging_setup.py       # Sistema de logs
│   └── version.py             # Versionamento
│
├── rag/                        # 🧠 Sistema RAG
│   ├── load_knowledge.py      # Script para carregar documentos
│   └── data/                  # 📚 Base de conhecimento
│       ├── faqs/
│       │   ├── FAQ_IPTU.md
│       │   └── FAQ_Certidoes.md
│       ├── leis/
│       ├── manuais/
│       └── procedimentos/
│
├── chroma_data/               # 💾 Banco vetorial (persistente)
│   └── chroma.sqlite3
│
├── n8n/                       # 🔄 Workflows
│   └── workflows/
│       ├── chatbot_webhook_simples.json (v3) ✅ ATIVO
│       └── chatbot_completo_orquestracao.json
│
├── scripts/                   # 📜 Scripts PowerShell
│   ├── up.ps1                # Inicia stack completo
│   ├── waha-status.ps1       # Status do WAHA
│   ├── test-n8n-webhook.ps1  # Testa webhook
│   ├── load-knowledge.ps1    # Carrega documentos no RAG
│   └── logs-api.ps1          # Monitora logs da API
│
├── logs/                      # 📋 Logs da aplicação
├── exports/                   # 💾 Histórico de conversas (WAHA)
└── tests/                     # 🧪 Testes automatizados
```

---

## ⚙️ Configuração e Deploy

### Pré-requisitos

1. **Docker Desktop** instalado e rodando
2. **PowerShell** (Windows)
3. **Chaves API**:
   - xAI API Key (https://console.x.ai/)

### Passo 1: Configurar Variáveis de Ambiente

Crie/edite o arquivo `.env` na raiz:

```env
# xAI (LLM)
XAI_API_KEY=xai-sua-chave-aqui

# WAHA
WAHA_API_KEY=tributos_nova_trento_2025_api_key_fixed
WAHA_BASE_URL=http://waha:3000

# n8n
N8N_WEBHOOK_URL=http://n8n:5678/webhook/8c0ac011-c46c-4c2c-bab1-ac5e0c3a365b/waha
```

### Passo 2: Carregar Base de Conhecimento

```powershell
# Adicione seus documentos em rag/data/faqs/
# Depois execute:
.\scripts\load-knowledge.ps1
```

Isso vai:
- Ler todos os arquivos `.md` em `rag/data/`
- Gerar embeddings
- Salvar no ChromaDB

### Passo 3: Iniciar Stack

```powershell
# Inicia todos os containers
.\scripts\up.ps1

# Aguarde ~30 segundos para tudo inicializar
```

### Passo 4: Conectar WhatsApp

```powershell
# Verifica status
.\scripts\waha-status.ps1
```

1. Acesse http://localhost:3000
2. Vá em "Sessions" → "default"
3. Escaneie o QR Code com WhatsApp
4. Status mudará para "WORKING"

### Passo 5: Ativar Workflows n8n

```powershell
# Ativa workflow v3
docker exec tributos_n8n n8n update:workflow --id=4H3Q54gMUNflJUNO --active=true

# Reinicia n8n
docker-compose restart n8n
```

### Passo 6: Testar

```powershell
# Testa webhook
.\scripts\test-n8n-webhook.ps1 -Body "Como emitir IPTU?"

# Monitora logs em tempo real
.\scripts\logs-api.ps1
```

Ou envie uma mensagem real pelo WhatsApp!

---

## 🔍 Manutenção e Troubleshooting

### Comandos Úteis

```powershell
# Ver status de todos containers
docker-compose ps

# Logs de um serviço específico
docker-compose logs api -f        # API
docker-compose logs waha -f       # WAHA
docker-compose logs n8n -f        # n8n

# Reiniciar um serviço
docker-compose restart api
docker-compose restart n8n
docker-compose restart waha

# Parar tudo
docker-compose down

# Parar e limpar volumes (⚠️ perde dados)
docker-compose down -v
```

### Problemas Comuns

#### 1. Webhook retorna 404

**Causa**: Workflow não ativado

**Solução**:
```powershell
docker exec tributos_n8n n8n update:workflow --id=4H3Q54gMUNflJUNO --active=true
docker-compose restart n8n
```

#### 2. WAHA desconecta

**Causa**: Sessão expirou ou WhatsApp Web fez logout

**Solução**:
1. Acesse http://localhost:3000
2. Delete sessão "default"
3. Crie nova sessão
4. Escaneie QR Code novamente

#### 3. API não responde

**Verificar logs**:
```powershell
docker-compose logs api --tail 100
```

**Causas possíveis**:
- ChromaDB não inicializado → Execute `load-knowledge.ps1`
- xAI API Key inválida → Verifique `.env`
- Container parado → `docker-compose restart api`

#### 4. Mensagens não chegam

**Checklist**:
```powershell
# 1. WAHA conectado?
.\scripts\waha-status.ps1
# Deve retornar "Status: WORKING"

# 2. Workflow ativo?
docker-compose logs n8n | Select-String "Activated"
# Deve mostrar "Chatbot Tributos - Webhook Simples v3"

# 3. API respondendo?
curl http://localhost:5000/health
# Deve retornar 200 OK

# 4. Webhook registrado?
.\scripts\test-n8n-webhook.ps1 -Body "teste"
# Deve processar (não retornar 404)
```

### Monitoramento em Produção

```powershell
# Terminal 1: Logs da API
docker-compose logs api -f

# Terminal 2: Logs do WAHA
docker-compose logs waha -f | Select-String "message|error"

# Terminal 3: Logs do n8n
docker-compose logs n8n -f | Select-String "workflow|error"
```

---

## 📊 Métricas e Performance

### Tempos Esperados

- **Recebimento mensagem**: < 1s
- **Busca RAG (ChromaDB)**: 0.5-2s
- **Geração LLM (xAI)**: 3-8s
- **Envio resposta**: < 1s
- **Total**: 5-12s

### Capacidade

- **ChromaDB**: Milhares de documentos
- **Concurrent requests**: ~10 mensagens/segundo
- **WAHA**: 1 sessão WhatsApp por container

### Otimizações Futuras

1. **Cache de respostas**: Guardar perguntas frequentes
2. **Batch processing**: Processar múltiplas mensagens juntas
3. **Load balancing**: Múltiplas instâncias da API
4. **CDN para embeddings**: Pré-computar vetores

---

## 🚀 Próximos Passos

### Features Sugeridas

1. **Sistema de Menus Interativos**
   - Usar workflow "Menu Engine"
   - Botões clicáveis no WhatsApp
   
2. **Multi-tenancy**
   - Suportar múltiplas cidades
   - Bases de conhecimento separadas

3. **Analytics Dashboard**
   - Perguntas mais frequentes
   - Tempo de resposta
   - Taxa de satisfação

4. **Fallback Humano**
   - Detectar quando IA não sabe responder
   - Encaminhar para atendente humano

5. **Integração com Sistemas**
   - Consultar débitos em tempo real
   - Gerar boletos automaticamente
   - Agendar atendimentos

---

## 📝 Licença e Créditos

**Desenvolvido para**: Prefeitura de Nova Trento  
**Tecnologias**: Python, Docker, n8n, ChromaDB, xAI  
**Arquitetura**: RAG (Retrieval-Augmented Generation)

---

## 📞 Suporte

Para dúvidas ou problemas:
1. Verifique a seção [Troubleshooting](#manutenção-e-troubleshooting)
2. Consulte os logs com os scripts em `scripts/`
3. Revise a documentação técnica em `docs/`

**Última atualização**: Novembro 2025
