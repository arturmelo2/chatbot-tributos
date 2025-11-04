# 🚀 Guia Rápido - Configurar n8n

## ✅ Status Atual

- ✅ Todos os containers rodando
- ✅ Base de conhecimento carregada
- ✅ WhatsApp conectado (via script)
- ⚠️ **Falta**: Configurar workflow no n8n

---

## 📋 Passo a Passo

### 1. Acessar n8n

Abra no navegador: **http://localhost:5679**

### 2. Criar Conta (Primeiro Acesso)

- Email: seu-email@exemplo.com
- Senha: (escolha uma senha forte)
- Nome: Admin Nova Trento

### 3. Importar Workflow

1. No menu lateral, clique em **"Workflows"**
2. Clique em **"+ Add workflow"**
3. Clique em **"⋮"** (três pontos) > **"Import from file"**
4. Selecione o arquivo:
   ```
   n8n\workflows\chatbot_webhook_simples.json
   ```
5. Clique em **"Import"**

### 4. Configurar Credencial WAHA

#### No nó "Start Typing":

1. Clique no nó **"Start Typing"**
2. Role até **"Authentication"**
3. Selecione: **"Generic Credential Type"**
4. Em **"Generic Auth Type"**: **"Header Auth"**
5. Clique em **"+"** ao lado de **"Credential to connect with"**

#### Criar Credencial:

6. **Credential Name**: `WAHA API`
7. **Header Name**: `X-Api-Key`
8. **Header Value**: `tributos_nova_trento_2025_api_key_fixed`
9. Clique em **"Save"**

#### Aplicar nos Outros Nós:

10. Clique no nó **"Stop Typing"**
11. Em Authentication, selecione a credencial **"WAHA API"** criada
12. Salve

### 5. Ativar Workflow

1. No canto superior direito, clique no toggle **"Inactive"** para **"Active"**
2. O workflow agora está ativo! 🎉

### 6. Testar

Envie uma mensagem pelo WhatsApp conectado e veja:

- ✅ Indicador "digitando..." aparece
- ✅ Bot responde com base no conhecimento
- ✅ Logs aparecem no n8n

---

## 🎯 URLs Importantes

| Serviço | URL | Credenciais |
|---------|-----|-------------|
| **n8n** | http://localhost:5679 | (sua conta criada) |
| **WAHA** | http://localhost:3000 | admin / Tributos@NovaTrento2025 |
| **API** | http://localhost:5000/health | - |

---

## 📊 Fluxo do Workflow

```
WhatsApp → WAHA → n8n Webhook
                    ↓
              Filtrar Grupos
                    ↓
              Start Typing
                    ↓
          API Python (RAG+LLM)
                    ↓
              Stop Typing
                    ↓
                  Log
                    ↓
            Retorna Sucesso
```

---

## 🔍 Troubleshooting

### Workflow não ativa

- Verifique se credencial WAHA está configurada
- Verifique logs do n8n: `docker-compose logs n8n`

### Bot não responde

- Verifique se WhatsApp está conectado no WAHA
- Verifique webhook no WAHA está apontando para n8n
- Execute: `.\scripts\waha-status.ps1`

### Erro na API

- Verifique logs: `docker-compose logs api`
- Teste health: http://localhost:5000/health

---

## ✅ Checklist Final

- [ ] n8n acessível em http://localhost:5679
- [ ] Conta criada no n8n
- [ ] Workflow importado
- [ ] Credencial WAHA configurada
- [ ] Workflow ativado
- [ ] Teste enviado pelo WhatsApp
- [ ] Bot respondeu corretamente

---

**Pronto! Seu chatbot está 100% funcional!** 🎉

Para suporte: ti@novatrento.sc.gov.br
