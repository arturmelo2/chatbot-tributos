# 🤖 Chatbot de Tributos - Prefeitura de Nova Trento/SC

> **Assistente Virtual Inteligente para Atendimento Tributário via WhatsApp**

Um chatbot especializado em tributos municipais, desenvolvido com Python, LangChain e RAG (Retrieval-Augmented Generation), integrado ao WhatsApp via WAHA. Totalmente dockerizado e pronto para produção.

---

## 🚀 Quick Start (Docker-only)

**Coloque o sistema rodando em 3 passos!** Veja [QUICK_START_DOCKER.md](./QUICK_START_DOCKER.md)

```powershell
# 1) Configure sua chave API no .env
# 2) Suba os containers
./scripts/up.ps1

# 3) Carregue/atualize a base de conhecimento
./scripts/load-knowledge.ps1 -Clear
```

**Pronto!** Acesse http://localhost:5000/health para verificar.

---

## 📋 Visão Geral

![image](./image.png)

Este projeto fornece um chatbot especializado em tributos municipais (IPTU, ISS, taxas, certidões) com:

- **RAG (Retrieval-Augmented Generation)**: Busca contextual em documentos de leis, FAQs e manuais
- **LLM via Groq**: Respostas rápidas e precisas com modelos LLama 3.3
- **Integração WhatsApp**: Via WAHA (WhatsApp HTTP API)
- **Docker**: Deploy simplificado e isolado
- **Base Vetorial Chroma**: Armazenamento eficiente de conhecimento

## ✨ Funcionalidades

### 🧠 Inteligência Artificial
- **RAG (Retrieval-Augmented Generation)**: Busca semântica em base de conhecimento vetorial
- **LLM via Groq**: Modelos LLama 3.3 70B com respostas em <1s
- **Embeddings Multilíngue**: Suporte a documentos em português
- **Contexto Histórico**: Mantém conversa contextual

### 💬 WhatsApp
- **Integração WAHA**: Conexão estável e oficial
- **Múltiplas Sessões**: Suporta vários números simultaneamente
- **Webhook Automático**: Recebe mensagens em tempo real
- **Typing Indicator**: Simula digitação para melhor UX

### 📚 Base de Conhecimento
- **Documentos Suportados**: PDF, TXT, Markdown
- **Categorização**: Leis, FAQs, Manuais, Procedimentos
- **Chunking Inteligente**: Divide documentos grandes otimamente
- **Versionamento**: Base vetorial persistente em volume Docker

### 🔧 Operação
- **Healthcheck**: Monitora saúde da API automaticamente
- **Logs Estruturados**: Facilita debug e auditoria
- **Docker Volumes**: Dados persistentes entre restarts
- **Hot Reload**: Atualização de conhecimento sem downtime

## 🛠️ Stack Tecnológica

### Backend
- **Python 3.11**: Linguagem principal
- **Flask**: Framework web para API REST
- **LangChain**: Orquestração de LLMs e RAG

### IA & ML
- **Groq API**: Inferência LLM ultrarrápida (LLama 3.3 70B)
- **HuggingFace**: Modelos de embeddings multilíngue
- **ChromaDB**: Banco vetorial para RAG
- **Sentence Transformers**: Geração de embeddings

### Infraestrutura
- **Docker & Docker Compose**: Containerização
- **WAHA**: WhatsApp HTTP API oficial
- **Volumes Persistentes**: Armazenamento de dados
- **Healthchecks**: Monitoramento automático

### Ferramentas
- **python-decouple**: Gestão de variáveis de ambiente
- **PyPDF**: Leitura de documentos PDF
- **Markdown**: Processamento de docs técnicos
 - **Ruff/Black/Mypy (dev)**: Lint/format/type-check via `pyproject.toml`

## 📁 Estrutura do Projeto (essencial)

```
whatsapp-ai-chatbot/
├── 🐳 Docker
│   ├── dockerfile              # Imagem Python 3.11 otimizada
│   ├── compose.yml             # Orquestração de containers
│   └── .dockerignore           # Otimização de build
│
├── 🤖 Aplicação
│   ├── app.py                  # Flask API (webhook + health)
│   ├── bot/
│   │   ├── ai_bot.py          # Chatbot principal (RAG + LLM)
│   │   └── link_router.py     # Roteador de links oficiais
│   └── services/
│       └── waha.py            # Cliente WAHA (WhatsApp)
│
├── 📚 RAG (Knowledge Base)
│   ├── rag/
│   │   ├── load_knowledge.py  # Indexador de documentos
│   │   ├── rag.py             # Lógica de recuperação
│   │   └── data/              # Documentos fonte
│   │       ├── faqs/          # Perguntas frequentes
│   │       ├── leis/          # Legislação tributária
│   │       ├── manuais/       # Manuais de procedimento
│   │       └── procedimentos/
│   └── chroma_data/           # Base vetorial (volume Docker)
│
├── 📖 Documentação
│   ├── README.md              # Este arquivo
│   ├── QUICK_START_DOCKER.md  # Guia rápido (3 passos)
│   ├── DOCKER_DESKTOP.md      # Guia Docker Desktop (UI)
│   ├── DOCKER.md              # Documentação Docker completa
│   ├── ARQUITETURA.md         # Visão técnica do sistema
│   └── DOCS_TRIBUTOS.md       # Docs de desenvolvimento
│
├── 🔧 Configuração
│   ├── .env                   # Variáveis de ambiente (crie do .env.example)
│   ├── .env.example           # Template de configuração
│   ├── requirements.txt       # Dependências Python
│
├── 🧰 Scripts (Windows)
│   └── scripts/
│       ├── up.ps1               # Sobes containers
│       ├── rebuild.ps1          # Rebuild + restart
│       ├── load-knowledge.ps1   # Carrega base
│       ├── logs-api.ps1         # Logs da API
│       └── test-n8n-webhook.ps1 # Testa webhook do n8n
│
└── 🧪 Testes & Scripts
    ├── test.ps1              # Suite de testes (Windows)
    └── deploy.ps1            # Script de deploy automatizado
```

## 🚀 Instalação e Uso (Docker-only)

### Pré-requisitos

- **Docker Desktop** instalado e rodando
- **Chave API do Groq** (grátis em https://console.groq.com)
- 4GB+ RAM alocada para Docker
- Windows 10/11 com WSL2 (ou Linux/macOS)

### Quick Start 🎯

**3 passos para rodar:**

1. **Configure a chave API**
   ```powershell
   # Edite .env e substitua GROQ_API_KEY pela sua chave
   notepad .env
   ```

2. **Build e Start**
   ```powershell
   ./scripts/rebuild.ps1
   ```

3. **Carregue conhecimento**
   ```powershell
   ./scripts/load-knowledge.ps1 -Clear
   ```

**Pronto!** API rodando em http://localhost:5000

**Guia completo:** [QUICK_START_DOCKER.md](./QUICK_START_DOCKER.md)

---

## 🚦 Manter sempre rodando (Windows)

Os containers já usam `restart: unless-stopped` no `compose.yml`, então reiniciam automaticamente quando o Docker inicia. Para garantir que tudo suba sozinho após reinicializar o Windows:

1) Habilite o Docker iniciar com o Windows:
   - Docker Desktop → Settings → General → "Start Docker Desktop when you log in"

2) Instale a Tarefa Agendada que sobe os containers no boot (aguardando o Docker):

```powershell
./scripts/install-auto-start.ps1 -DelaySeconds 60
```

3) Para remover depois, use:

```powershell
./scripts/uninstall-auto-start.ps1
```

Notas:
- A tarefa roda como SYSTEM (elevada) e chama `./scripts/up.ps1` no diretório do projeto.
- Ajuste `-DelaySeconds` (30–120s) conforme a velocidade da sua máquina.
- Se você parar os containers manualmente, `unless-stopped` não os reiniciará até um novo `up`/`start`.

### Docker Desktop (Interface Gráfica) 🖱️

1. Abra **Docker Desktop**
2. Localize o projeto `whatsapp-ai-chatbot` em **Containers**
3. Clique **Start** ▶
4. Veja logs, execute comandos, monitore recursos

**Guia visual completo:** [DOCKER_DESKTOP.md](./DOCKER_DESKTOP.md)

---

### Scripts úteis (Windows)

```powershell
./scripts/up.ps1                 # sobe containers
./scripts/rebuild.ps1            # rebuild + restart
./scripts/load-knowledge.ps1 -Clear  # carrega base (limpa e reindexa)
./scripts/logs-api.ps1           # tail logs API
./scripts/test-n8n-webhook.ps1   # envia evento de teste ao n8n
./scripts/export-history.ps1 -Months 6  # exporta conversas (JSONL)
./scripts/install-auto-start.ps1  # instala auto-start no boot do Windows
./scripts/uninstall-auto-start.ps1 # remove auto-start
./scripts/test.ps1               # lint (ruff/black) + testes (pytest)
```

### Exportar conversas (últimos 6 meses)

```powershell
# Exporta mensagens dos últimos 6 meses para ./exports/waha_history_<timestamp>.jsonl
./scripts/export-history.ps1 -Months 6

# Opções:
#   -ChatsLimit 1000   # quantos chats listar
#   -MsgsLimit 5000    # limite de mensagens por chat (aumente se necessário)
#   -IncludeGroups     # inclui grupos (@g.us)
```

---

## 🔧 Configuração

### 1. Variáveis de Ambiente (.env)

Copie o template e edite:
```powershell
cp .env.example .env
notepad .env
```

**Configurações essenciais:**
```env
# LLM Provider
LLM_PROVIDER=groq
LLM_MODEL=llama-3.3-70b-versatile   # (Groq: recomendado)
GROQ_API_KEY=gsk_sua_chave_aqui  # ← OBRIGATÓRIO

# Alternativas:
# - xAI (Grok):
#   LLM_PROVIDER=xai
#   LLM_MODEL=grok-4-fast-reasoning
#   XAI_API_KEY=xai_sua_chave
# - OpenAI:
#   LLM_PROVIDER=openai
#   LLM_MODEL=gpt-4.1   # ou o4-mini
#   OPENAI_API_KEY=sk_sua_chave

# Embeddings
EMBEDDING_MODEL=sentence-transformers/all-MiniLM-L6-v2

# Chroma (base vetorial)
CHROMA_DIR=/app/chroma_data

# WAHA (WhatsApp)
WAHA_API_URL=http://waha:3000

### Desenvolvimento (lint e testes)

Ambiente local opcional para desenvolvimento:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements-dev.txt
./scripts/test.ps1              # ruff + black --check + pytest
./scripts/test.ps1 -LintOnly    # apenas lint
```
```

### 2. Adicionar Documentos

Coloque PDFs, TXTs ou Markdown em:
```
rag/data/
├── faqs/              ← Perguntas frequentes
├── leis/              ← Código Tributário, leis complementares
├── manuais/           ← Manuais de procedimentos
└── procedimentos/     ← Fluxos de atendimento
```

Depois recarregue:
```powershell
docker-compose exec api python rag/load_knowledge.py
```

---

## 📊 Uso e Operação

### Conectar WhatsApp

1. Acesse http://localhost:3000
2. Copie credenciais dos logs:
   ```powershell
   docker-compose logs waha | Select-String "WAHA_DASHBOARD"
   ```
3. Login no dashboard WAHA
4. Criar sessão → Escanear QR Code com WhatsApp
5. Aguardar confirmação ✅

### Testar o Chatbot

Envie mensagem para o número conectado:
```
Olá! Como pago o IPTU?
```

Resposta esperada (baseada nos FAQs):
```
📋 **Pagamento de IPTU em Nova Trento/SC**

Você pode pagar o IPTU de 3 formas:

1️⃣ **Carnê Físico**: Boletos enviados pelo correio...
2️⃣ **Online**: Acesse o portal da Prefeitura...
3️⃣ **Presencial**: Setor de Tributos (Rua...)

Tem mais alguma dúvida sobre tributos? 😊
```

### Comandos Úteis (alternativo sem scripts)

Observação: você pode usar tanto `docker compose` (recomendado) quanto `docker-compose`. Os scripts já detectam automaticamente qual está disponível.

```powershell
# Ver logs em tempo real
docker-compose logs -f api

# Verificar saúde da API
curl http://localhost:5000/health

# Recarregar conhecimento
docker-compose exec api python rag/load_knowledge.py

# Limpar e recarregar
docker-compose exec api python rag/load_knowledge.py --clear

# Reiniciar apenas a API
docker-compose restart api

# Ver status dos containers
docker-compose ps

# Parar tudo
docker-compose down

# Parar E remover volumes (CUIDADO!)
docker-compose down -v
```

---

## ⚙️ Integração via n8n (opcional, recomendado)

Quando quiser desacoplar o WAHA da API e ganhar observabilidade/roteamento, use o n8n como intermediário de webhooks.

### 1) Configurar WAHA → n8n

No `compose.yml` (serviço `waha`), aponte o webhook do WAHA para o nó “WAHA Trigger” do n8n e inclua os eventos necessários:

```
environment:
   - WHATSAPP_HOOK_URL=http://n8n:5678/webhook/<UUID_DO_NO_WAHA_TRIGGER>/waha
   - WHATSAPP_HOOK_EVENTS=message,session.status
```

Observações:
- O `<UUID_DO_NO_WAHA_TRIGGER>` é mostrado nas propriedades do nó “WAHA Trigger” dentro do n8n (campo webhookId).
- A UI do n8n está exposta em http://localhost:5679.

### 2) Fluxo no n8n

Crie um workflow com 2 ou 3 nós:
- WAHA Trigger (recebe todos os eventos do WAHA)
- IF (opcional): deixe passar apenas `{{$json.event}} == "message"`
- HTTP Request → POST `http://api:5000/chatbot/webhook/`
   - JSON/RAW Parameters: ON
   - Content-Type: application/json
   - JSON/RAW Body: `{{$json}}` (o objeto inteiro)

Ative o workflow (Activate) para registrar o webhook de produção.

### 3) Testar ponta a ponta

1. Envie uma mensagem real no WhatsApp conectado (ex.: “IPTU 2025”).
2. Veja uma execução no n8n (IF passa e HTTP Request verde).
3. Nos logs da API aparecerá “WEBHOOK PAYLOAD …” e depois “✅ Resposta enviada …”.
4. O munícipe recebe a resposta no WhatsApp.

Importante: Quem envia a resposta ao WhatsApp é a API (`app.py`). Não adicione nós de "Send Text" no n8n; o n8n apenas encaminha os eventos para a API.

### 4) Troubleshooting n8n/WAHA

- `Received request for unknown webhook` no n8n:
   - O workflow não está “Activated” ou o caminho/UUID está diferente.
   - Corrija o `WHATSAPP_HOOK_URL` no compose para o mesmo webhookId do nó “WAHA Trigger”.
- WAHA mostra 404 temporários:
   - Normal quando o workflow ainda não está ativado; ao ativar, os POSTs ficam 200.
- API 400 por corpo inválido:
   - O `app.py` aceita o formato padrão `{event, payload}` e também corrige 2 casos comuns:
      1) Chegar apenas `{payload:{from,body}}` (assume `event="message"`).
      2) Chegar apenas `{from,body}` (envolve em `{event:"message", payload:{...}}`).

---

## 🧪 Testes

### Suite de Testes (PowerShell)

> Observação: todos os comandos e testes recomendados estão encapsulados em scripts PowerShell na pasta `scripts/`.

### Testes Manuais

```powershell
# Health check
curl http://localhost:5000/health

# Endpoint raiz
curl http://localhost:5000

# WAHA dashboard
curl http://localhost:3000
```

---

## 🏗️ Arquitetura

```
┌─────────────┐
│  WhatsApp   │ ← Usuário envia mensagem
└──────┬──────┘
       │
       ↓ (webhook)
┌──────────────────────────────────────┐
│         Container: WAHA              │
│  (devlikeapro/waha:latest)          │
│                                      │
│  ✓ Gerencia sessões WhatsApp        │
│  ✓ Envia webhook para API           │
│  ✓ Dashboard web (porta 3000)       │
└──────────┬───────────────────────────┘
           │
           ↓ POST /chatbot/webhook/
┌──────────────────────────────────────┐
│      Container: tributos_api         │
│      (Python 3.11 + Flask)           │
│                                      │
│  ┌────────────────────────────────┐ │
│  │  app.py (Flask)                │ │
│  │  ├─ /health                    │ │
│  │  └─ /chatbot/webhook/          │ │
│  └────────┬───────────────────────┘ │
│           │                          │
│           ↓                          │
│  ┌────────────────────────────────┐ │
│  │  bot/ai_bot.py                 │ │
│  │  ├─ RAG (Chroma retrieval)     │ │
│  │  ├─ LLM (Groq API)             │ │
│  │  └─ Prompt Engineering         │ │
│  └────────┬───────────────────────┘ │
│           │                          │
│           ↓                          │
│  ┌────────────────────────────────┐ │
│  │  Chroma Vector Store           │ │
│  │  (sentence-transformers)       │ │
│  └────────────────────────────────┘ │
│                                      │
└──────────────────────────────────────┘
           │
           ↓ (resposta)
┌──────────────────────────────────────┐
│         Container: WAHA              │
│  (envia mensagem de volta)          │
└──────────┬───────────────────────────┘
           │
           ↓
┌──────────────┐
│  WhatsApp    │ ← Usuário recebe resposta
└──────────────┘
```

**Fluxo de dados:**
1. Usuário → WhatsApp → WAHA (webhook)
2. WAHA → Flask API (`/chatbot/webhook/`)
3. API → RAG (busca contexto em Chroma)
4. API → LLM Groq (gera resposta)
5. API → WAHA (envia resposta)
6. WAHA → WhatsApp → Usuário

**Volumes persistentes:**
- `chroma_data`: Base vetorial (conhecimento)
- `waha_data`: Sessões WhatsApp

---

## 🐛 Troubleshooting

### API unhealthy / erro 503

**Causa:** Chave API inválida ou modelo não carregou.

**Solução:**
```powershell
# 1. Verifique a chave
cat .env | Select-String "GROQ_API_KEY"

# 2. Teste a chave no console Groq (https://console.groq.com)

# 3. Reconstrua o container
docker-compose down
docker-compose up -d

# 4. Verifique logs
docker-compose logs api
```

### WAHA unhealthy (mas funciona)

**Normal!** WAHA pode reportar unhealthy se nenhuma sessão foi conectada.

**Teste:**
```powershell
curl http://localhost:3000
# Se retornar HTML, está OK
```

### Build lento (primeira vez)

**Normal!** PyTorch + Transformers são pesados (~5GB).

**Dicas:**
- Use SSD (não HD)
- Aumente RAM do Docker (Settings → Resources → Memory: 4GB+)
- Builds subsequentes usam cache e são rápidos

### "Cannot load knowledge" - sem documentos

**Causa:** Pasta `rag/data/` vazia.

**Solução:**
```powershell
# Adicione PDFs em rag/data/faqs/ ou rag/data/leis/
# Depois:
docker-compose exec api python rag/load_knowledge.py
```

### Porta 5000 ou 3000 já em uso

**Solução:**
```powershell
# Edite compose.yml
# Mude "5000:5000" para "5001:5000" (por exemplo)
docker-compose down
docker-compose up -d
```

---

## 📚 Documentação Adicional

- **[QUICK_START_DOCKER.md](./QUICK_START_DOCKER.md)**: Guia rápido (3 passos)
- **[DOCKER_DESKTOP.md](./DOCKER_DESKTOP.md)**: Uso via interface gráfica
- **[DOCKER.md](./DOCKER.md)**: Documentação Docker completa
- **[ARQUITETURA.md](./ARQUITETURA.md)**: Visão técnica detalhada
- **[DOCS_TRIBUTOS.md](./DOCS_TRIBUTOS.md)**: Docs de desenvolvimento
 - **[DEVELOPMENT.md](./DEVELOPMENT.md)**: Fluxo de desenvolvimento, lint, testes e comandos úteis

### Links Externos

- [WAHA Documentation](https://waha.devlike.pro/)
- [Groq API Docs](https://console.groq.com/docs)
- [LangChain Docs](https://python.langchain.com/)
- [Chroma DB](https://www.trychroma.com/)

---

## 🤝 Contribuição

Contribuições são bem-vindas! Siga o fluxo:

1. **Fork** o projeto
2. Crie uma **feature branch**:
   ```bash
   git checkout -b feature/nova-funcionalidade
   ```
3. **Commit** suas mudanças:
   ```bash
   git commit -m 'feat: adiciona suporte a voz'
   ```
4. **Push** para o branch:
   ```bash
   git push origin feature/nova-funcionalidade
   ```
5. Abra um **Pull Request**

### Guidelines

- Use commits semânticos (`feat:`, `fix:`, `docs:`, etc.)
- Adicione testes quando aplicável
- Atualize documentação se necessário
- Mantenha código limpo e formatado (black, flake8)

---

## 📄 Licença

Este projeto é de código aberto e disponível sob a licença MIT.

---

## 📞 Contato & Suporte

**Dúvidas, sugestões ou colaborações:**

- 🐛 **Issues**: Reporte bugs e solicite features no GitHub
- 💬 **Discussões**: Use GitHub Discussions para perguntas gerais
- 📧 **Email**: Para questões privadas ou parcerias

**Desenvolvido para:** Prefeitura Municipal de Nova Trento/SC
**Mantenedor:** [arturmelo2](https://github.com/arturmelo2)
**Baseado em:** [esscova/whatsapp-ai-chatbot](https://github.com/esscova/whatsapp-ai-chatbot)

---

## ⭐ Agradecimentos

- **WAHA** - WhatsApp HTTP API
- **Groq** - Inferência LLM ultrarrápida
- **LangChain** - Framework RAG
- **ChromaDB** - Vector store
- **HuggingFace** - Modelos de embeddings

---

<div align="center">

**🎉 Projeto totalmente Dockerizado e pronto para produção!**

[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](.)
[![Python](https://img.shields.io/badge/Python-3.11-green?logo=python)](.)
[![License](https://img.shields.io/badge/License-MIT-yellow)](.)</div>
