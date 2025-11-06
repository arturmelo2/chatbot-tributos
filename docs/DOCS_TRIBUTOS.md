# 🤖 Chatbot de Tributos - Nova Trento/SC

Chatbot especializado para o **Setor de Tributos da Prefeitura Municipal de Nova Trento/SC**, utilizando IA com RAG (Retrieval-Augmented Generation) e integração com WhatsApp via WAHA.

## ✨ Características

### 🎯 Especialização Tributária
- **Prompt especializado** para atendimento tributário municipal
- **Escopo definido**: IPTU, ISS, ITBI, TLL, Certidões, Parcelamentos, Taxas, NFS-e
- **Conformidade legal**: Cita apenas dispositivos presentes na base de conhecimento
- **LGPD**: Coleta mínima de dados pessoais

### 🔗 Integração com Fluxo de Atendimento
- **Roteamento automático** de links e mensagens do fluxo existente
- **Modo Menu**: Respostas baseadas em escolhas numéricas (1, 2, 3...)
- **Modo Keywords**: Detecção de intenções por palavras-chave (IPTU, ISS, CND, etc.)
- **Placeholders**: Suporte a variáveis {{name}}, {{protocol}} nas mensagens

### 🧠 RAG (Retrieval-Augmented Generation)
- **Base vetorial Chroma** com embeddings HuggingFace
- **MMR (Maximal Marginal Relevance)**: Reduz redundância e melhora diversidade
- **Chunking inteligente**: Divide documentos grandes para melhor recuperação
- **Metadata tracking**: Rastreia fontes dos documentos (leis, manuais, FAQs)

### 💬 Histórico de Conversa
- **Context-aware**: Usa histórico completo da conversa
- **Suporte a multi-turn**: Lembra interações anteriores
- **Formato compatível**: `[{'role': 'user'|'assistant', 'content': '...'}]`

### ⚙️ Multi-Provider LLM
Suporte a múltiplos provedores de IA:
- **OpenAI** (gpt-4o, gpt-4-turbo)
- **Groq** (llama-3.3-70b-versatile) ⚡ Recomendado: rápido e econômico
- **xAI Grok** (grok-2-latest)

---

## 📋 Pré-requisitos

- Python 3.9+
- Docker & Docker Compose (para deploy)
- API Key de um provedor LLM (OpenAI, Groq ou xAI)

---

## 🚀 Instalação e Configuração

### 1. Clone o repositório

```bash
cd whatsapp-ai-chatbot
```

### 2. Configure as variáveis de ambiente

```bash
cp .env.example .env
```

Edite o arquivo `.env` e configure:

```env
# Provedor LLM (recomendado: groq)
LLM_PROVIDER=groq
LLM_MODEL=llama-3.3-70b-versatile
GROQ_API_KEY=gsk_sua_chave_aqui

# Embeddings
EMBEDDING_MODEL=sentence-transformers/all-MiniLM-L6-v2
CHROMA_DIR=/app/chroma_data

# Fluxo
FLOW_JSON_PATH=fluxo_novatrento.json
```

### 3. Prepare a base de conhecimento

Crie a estrutura de pastas:

```bash
mkdir -p rag/data/{leis,manuais,faqs,procedimentos}
```

Adicione seus documentos:

```
rag/data/
├── leis/
│   ├── LC_661_2017_Codigo_Tributario.pdf
│   └── LC_705_2023_Alteracoes.pdf
├── manuais/
│   ├── Manual_IPTU.pdf
│   └── Manual_ISS.pdf
├── faqs/
│   ├── FAQ_Certidoes.md
│   └── FAQ_Parcelamento.txt
└── procedimentos/
    └── Fluxo_Atendimento.txt
```

### 4. Popule a base vetorial

```bash
python rag/load_knowledge.py
```

Opções avançadas:

```bash
# Limpar base existente antes de carregar
python rag/load_knowledge.py --clear

# Ajustar tamanho dos chunks
python rag/load_knowledge.py --chunk-size 1500 --chunk-overlap 300

# Usar pasta diferente
python rag/load_knowledge.py --data-path ./documentos
```

### 5. Execute com Docker Compose

```bash
docker-compose up -d
```

Ou em desenvolvimento local:

```bash
pip install -r requirements.txt
python app.py
```

---

## 📖 Uso

### Exemplo básico (sem estado)

```python
from bot.ai_bot import AIBot

bot = AIBot()

# Pergunta simples
resposta = bot.invoke(
    history_messages=[],
    question="Como emitir a 2ª via do IPTU?"
)
print(resposta)
```

### Exemplo com histórico

```python
historico = [
    {"role": "user", "content": "Preciso consultar meus débitos"},
    {"role": "assistant", "content": "Você pode acessar..."},
]

resposta = bot.invoke(
    history_messages=historico,
    question="E como faço para parcelar?"
)
```

### Exemplo com modo Menu (estado)

```python
# Usuário está no nó "Menu Principal" e digitou "1"
resposta = bot.invoke(
    history_messages=[],
    question="1",
    menu_node_name="Menu Principal",
    vars_fmt={"name": "João Silva", "protocol": "12345"}
)
```

### Exemplo com modo Keywords

```python
# Detecta automaticamente a intenção
resposta = bot.invoke(
    history_messages=[],
    question="preciso de uma certidão negativa de débitos"
)
# Retorna links para CND automaticamente
```

---

## 🏗️ Arquitetura

```
whatsapp-ai-chatbot/
├── bot/
│   ├── __init__.py
│   ├── ai_bot.py           # Bot principal com RAG
│   └── link_router.py      # Roteador de links do fluxo
├── rag/
│   ├── rag.py              # (legado)
│   ├── load_knowledge.py   # Script de ingestão
│   └── data/               # Documentos (PDFs, TXTs, MDs)
├── services/
│   └── waha.py             # Integração WhatsApp
├── chroma_data/            # Base vetorial (gerada)
├── fluxo_novatrento.json   # Fluxo de atendimento
├── .env                    # Configurações (criar do .env.example)
├── docker-compose.yml      # Deploy
└── requirements.txt        # Dependências Python
```

---

## 🔧 Configuração Avançada

### Ajustar busca RAG

No arquivo `bot/ai_bot.py`, método `__build_retriever`:

```python
return vector_store.as_retriever(
    search_type='mmr',  # ou 'similarity'
    search_kwargs={
        'k': 18,           # número de chunks recuperados
        'lambda_mult': 0.25  # diversidade (0=max diversidade, 1=max relevância)
    }
)
```

### Personalizar prompt

Edite a variável `SPECIALIZED_SYSTEM_TEMPLATE` em `bot/ai_bot.py`.

### Adicionar novos buckets de keywords

No arquivo `bot/link_router.py`, método `_build`:

```python
self.keyword_buckets = [
    (p(r"\bitbi\b|transmiss(ã|a)o"), "5 - Taxas e NFS-e"),
    # Adicione mais padrões aqui
]
```

---

## 📊 Boas Práticas para Base de Conhecimento

### 1. Estrutura de Documentos

- **Leis**: Use PDFs oficiais com OCR de qualidade
- **Manuais**: Markdown ou TXT para fácil edição
- **FAQs**: Formato pergunta/resposta claro
- **Procedimentos**: Passo a passo numerado

### 2. Metadata

O script adiciona automaticamente:

```python
{
    "source": "LC_661_2017.pdf",     # Nome do arquivo
    "type": "pdf",                    # Tipo (pdf, text, markdown)
    "path": "leis/LC_661_2017.pdf"   # Caminho relativo
}
```

### 3. Chunking

- **Chunk size**: 1000 caracteres (ajustável)
- **Overlap**: 200 caracteres (garante continuidade)
- **Separadores**: Prioriza parágrafos > sentenças > palavras

### 4. Atualização

Sempre que atualizar documentos:

```bash
python rag/load_knowledge.py --clear
```

---

## 🎯 Exemplos de Perguntas Atendidas

### Diretas (Links automáticos)
- "Como emitir guia de IPTU?"
- "Preciso de CND"
- "Quero parcelar meus débitos"
- "Como cancelar NFS-e?"

### Consultivas (RAG)
- "Qual o prazo para pagar IPTU em cota única?"
- "Existe desconto para pagamento antecipado?"
- "Quais documentos preciso para ITBI?"
- "Como funciona a substituição tributária no ISS?"

### Contextuais (Histórico)
```
Usuário: Tenho uma empresa de serviços
Bot: Entendi. Em que posso ajudar?
Usuário: Preciso regularizar o ISS
Bot: [usa contexto "empresa de serviços" + ISS]
```

---

## 🐛 Troubleshooting

### Erro: "Import could not be resolved"

Instale as dependências:

```bash
pip install -r requirements.txt
```

### Base vetorial vazia

Verifique se há documentos em `rag/data/` e execute:

```bash
python rag/load_knowledge.py
```

### LinkRouter não funciona

Verifique se o arquivo `fluxo_novatrento.json` existe e está válido:

```bash
python -c "import json; json.load(open('fluxo_novatrento.json'))"
```

### Respostas genéricas demais

1. Adicione mais documentos específicos em `rag/data/`
2. Aumente o número de chunks recuperados (`k=18` → `k=30`)
3. Ajuste o prompt no `SPECIALIZED_SYSTEM_TEMPLATE`

---

## 📝 Dependências Principais

```
langchain>=0.1.0
langchain-chroma>=0.1.0
langchain-huggingface>=0.0.1
langchain-openai>=0.0.5
langchain-groq>=0.0.1
langchain-community>=0.0.20
chromadb>=0.4.22
sentence-transformers>=2.2.2
python-decouple>=3.8
```

---

## 🤝 Contribuindo

1. Adicione novos documentos em `rag/data/`
2. Melhore os padrões de keywords em `link_router.py`
3. Ajuste o prompt especializado conforme feedback dos atendentes
4. Documente casos de uso específicos

---

## 📄 Licença

Este projeto é mantido pela **Prefeitura Municipal de Nova Trento/SC**.

---

## 📞 Suporte

Para dúvidas sobre o sistema, entre em contato com o Setor de TI da Prefeitura.

**Horário de atendimento**: Segunda a Sexta, 07h00 às 13h00

---

## 🔄 Changelog

### v2.0.0 - Especialização Tributária
- ✅ Prompt especializado Setor de Tributos
- ✅ Integração com fluxo de atendimento (JSON)
- ✅ Roteador de links automático
- ✅ Suporte a histórico de conversa
- ✅ MMR search para melhor RAG
- ✅ Script de ingestão de conhecimento
- ✅ Metadata tracking de fontes

### v1.0.0 - Base Original
- Bot genérico com RAG
- Multi-provider LLM
- Integração WAHA
