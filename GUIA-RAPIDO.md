# 🚀 GUIA RÁPIDO - RAG Completo no n8n

## ⚡ TL;DR

Sistema RAG completo implementado! Aguardando build da API concluir para ativar.

---

## 📋 STATUS ATUAL

```
✅ API Python     - Endpoints /rag/search e /llm/invoke criados
✅ AIBot         - Métodos search_knowledge() e invoke_with_context() adicionados  
✅ Workflow n8n  - 13 nodes importados (ID: Ob3oc2dv4bZRqG8z)
✅ Credenciais   - WAHA API Key configurada
✅ Documentação  - 3 arquivos criados
🔄 Build API     - Em andamento (Terminal ID: c20cd111-6cd2-46e8-84c3-35768c4e60a4)
⏳ Ativação      - Aguardando build concluir
```

---

## 🎯 QUANDO O BUILD CONCLUIR

### 1. Verificar Build
```powershell
Get-TerminalOutput -Id c20cd111-6cd2-46e8-84c3-35768c4e60a4
# Procure por: "Successfully built"
```

### 2. Reiniciar API
```powershell
docker compose restart api
Start-Sleep -Seconds 10
```

### 3. Testar Sistema Completo
```powershell
.\scripts\testar-sistema-completo.ps1
```

**Espere ver**:
```
✅ API saudável
✅ RAG Search funcionando
✅ LLM Invoke funcionando
✅ Workflow RAG encontrado
✅ WAHA conectado
✅ ChromaDB carregado
```

### 4. Ativar Workflow n8n

**Via Interface** (Recomendado):
1. Abra: http://localhost:5679
2. Workflow: "Chatbot RAG Completo - Auto Configurado"
3. Clique no toggle (superior direito)

### 5. Testar via WhatsApp
```
Enviar mensagem: "Como pagar IPTU?"
```

---

## 🔍 ARQUIVOS IMPORTANTES

| Arquivo | Descrição |
|---------|-----------|
| `RAG-COMPLETO-FINALIZADO.md` | 📚 Documentação técnica completa |
| `RESUMO-EXECUTIVO.md` | 📊 Visão geral executiva |
| `CONFIGURAR-WORKFLOW.md` | 🔧 Instruções de configuração |
| `scripts/testar-sistema-completo.ps1` | 🧪 Testes automatizados |
| `scripts/configurar-rag-completo.ps1` | ⚙️ Configuração automática |

---

## 🎨 WORKFLOW RAG (13 Nodes)

```
1. Webhook WAHA              → Recebe mensagens
2. Filtrar Mensagens         → Ignora grupos/self
3. Preparar Dados            → Extrai chatId, question
4. Iniciar Digitando         → Typing indicator ON
5. Buscar Conhecimento (RAG) → POST api:5000/rag/search
6. Formatar Contexto         → Cria system prompt
7. Gerar Resposta (Groq LLM) → POST api:5000/llm/invoke
8. Formatar Resposta Final   → Limita 4000 chars
9. Enviar WhatsApp           → WAHA send
10. Parar Digitando          → Typing indicator OFF
+ 3 Sticky Notes             → Documentação
```

---

## 🆚 SIMPLES vs RAG COMPLETO

### Workflow Simples (Recomendado para início)
```
Webhook → Filtro → HTTP (api:5000/chatbot/webhook)
```
- ✅ 3 nodes apenas
- ✅ Simples e direto
- ✅ Toda lógica na API
- ❌ Caixa preta (não vê RAG)

### RAG Completo (Este guia)
```
Webhook → ... → RAG Search → LLM Invoke → ... → WhatsApp
```
- ✅ 13 nodes com pipeline visual
- ✅ Debug completo (vê cada passo)
- ✅ Customizável sem código
- ⚠️ Mais complexo

**Use RAG Completo quando**:
- Precisa ver o que o RAG está retornando
- Quer ajustar parâmetros (k, lambda, temperature)
- Precisa adicionar mais steps (sentiment, routing)
- Quer melhor debugging

---

## 📊 PARÂMETROS AJUSTÁVEIS

### Node "Buscar Conhecimento (RAG)"
```json
{
  "k": 10,              // Quantos documentos buscar (padrão: 10)
  "search_type": "mmr", // "mmr" ou "similarity"
  "lambda_mult": 0.5    // Diversidade: 0=max, 1=min relevância
}
```

### Node "Gerar Resposta (Groq LLM)"
```json
{
  "temperature": 0.3,   // 0=determinístico, 1=criativo
  "max_tokens": 1500    // Tamanho máximo da resposta
}
```

---

## 🔧 TROUBLESHOOTING

### Problema: API retorna 404 nos novos endpoints

**Causa**: Build não concluído

**Solução**:
```powershell
# Verificar progresso
Get-TerminalOutput -Id c20cd111-6cd2-46e8-84c3-35768c4e60a4

# Após "Successfully built", reiniciar
docker compose restart api
```

### Problema: Workflow não ativa

**Causa**: Credencial WAHA faltando

**Solução**:
1. No n8n, abra node "Iniciar Digitando"
2. Em "Credential", selecione "WAHA API Key"
3. Se não existir, crie:
   - Name: `WAHA API Key`
   - Type: `Header Auth`
   - Header: `X-Api-Key`
   - Value: `tributos_nova_trento_2025_api_key_fixed`

### Problema: RAG retorna 0 documentos

**Causa**: ChromaDB vazio

**Solução**:
```powershell
.\scripts\load-knowledge.ps1
```

---

## 📱 TESTE MANUAL

### 1. Via Webhook Direto
```powershell
$test = '{"event":"message","payload":{"from":"5547999999999@c.us","body":"Como pagar IPTU?","fromMe":false}}'
curl -X POST "http://localhost:5679/webhook/94a8adfc-1dba-41e7-be61-4c13b51fa08e" `
     -H "Content-Type: application/json" -d $test
```

### 2. Via WhatsApp
```
Enviar para o número conectado: "Como pagar IPTU?"
```

### 3. Monitorar Execução
1. Abra: http://localhost:5679
2. Sidebar → **Executions**
3. Veja última execução com dados de cada node

---

## 🎓 PRÓXIMAS MELHORIAS

### Curto Prazo:
- [ ] Adicionar histórico de conversa (Window Buffer Memory)
- [ ] Implementar feedback de qualidade (thumbs up/down)
- [ ] Adicionar logs estruturados

### Médio Prazo:
- [ ] Intent detection (classificar tipo de pergunta)
- [ ] Sentiment analysis (detectar urgência)
- [ ] Multi-LLM comparison (Groq vs OpenAI)

### Longo Prazo:
- [ ] Fine-tuning do modelo com conversas reais
- [ ] Dashboard de analytics
- [ ] Integração com sistema tributário municipal

---

## 📞 LINKS ÚTEIS

| Serviço | URL |
|---------|-----|
| **n8n** | http://localhost:5679 |
| **WAHA Dashboard** | http://localhost:3000 |
| **API Health** | http://localhost:5000/health |
| **API Docs** | http://localhost:5000/ |

---

## ✅ CHECKLIST DE PRODUÇÃO

Antes de colocar em produção:

- [ ] Build API concluído
- [ ] Todos os testes passando (`.\scripts\testar-sistema-completo.ps1`)
- [ ] Workflow ativado no n8n
- [ ] Teste via WhatsApp bem-sucedido
- [ ] Monitoramento configurado (logs, health checks)
- [ ] Backup da base de conhecimento (`.\scripts\backup.ps1`)
- [ ] Documentação atualizada
- [ ] Treinamento da equipe

---

## 🎉 CONCLUSÃO

Você implementou um sistema RAG completo e profissional com:

✅ **3 camadas**: WhatsApp → n8n → API Python  
✅ **RAG transparente**: Veja cada passo no workflow  
✅ **Base conhecimento**: 65 docs, 461 chunks  
✅ **LLM de produção**: Groq llama-3.3-70b  
✅ **Debug visual**: Executions n8n  
✅ **Customizável**: Sem mexer em código  

**Aguardando apenas**: Build da API concluir → Reiniciar → Ativar → Testar! 🚀

---

**Criado em**: 06/11/2025 22:25  
**Versão**: 1.0  
**Status**: ✅ 95% completo (aguardando build)
