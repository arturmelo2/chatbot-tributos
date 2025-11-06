# 🔄 Configurar Chatbot com n8n (WAHA Trigger)

> Política: não usar mais o “webhook normal” (nó Webhook genérico). Padronizamos o uso do nó WAHA Trigger do pacote oficial, com URL de produção baseada em webhookId.

---

## 🚀 Passo 1: Subir os containers

Execute `docker compose up -d` na raiz do projeto. O serviço `n8n-bootstrap` roda uma única vez para:

- Criar a base de dados do n8n;
- Importar e ativar automaticamente o workflow `WAHA → API (mensagens)`;
- Garantir que o webhookId padrão (`8c0ac011-c46c-4c2c-bab1-ac5e0c3a365b`) esteja ativo.

Quando o bootstrap já tiver sido executado anteriormente, o container termina imediatamente e não reimporta nada.

---

## 📋 Passo 2: Verificar o n8n

1. Abra http://localhost:5679.
2. Como o `N8N_USER_MANAGEMENT_DISABLED` está habilitado, você acessa diretamente o painel sem precisar criar usuário. (Em produção, reative o controle de acesso definindo `N8N_USER_MANAGEMENT_DISABLED=false` e criando um usuário proprietário.)
3. O workflow **WAHA → API (mensagens) [8c0ac011]** já aparece como **Active**.

Se precisar editar o fluxo, basta duplicá-lo ou salvar com outro nome. O arquivo original continua disponível em `./n8n/workflows/waha_to_api_8c0ac011.json`.

---

## 🔗 Passo 3: Conferir o webhook do WAHA

O `compose.yml` já injeta a URL correta no serviço `waha`:

```yaml
environment:
  - WHATSAPP_HOOK_URL=http://n8n:5678/webhook/8c0ac011-c46c-4c2c-bab1-ac5e0c3a365b/waha
  - WHATSAPP_HOOK_EVENTS=message,session.status
```

Se você decidir gerar um novo `webhookId`, atualize essa variável e recrie os containers com `docker compose up -d` para aplicar.

---

## 🔁 Passo 4: Fluxo até a API

O workflow automático envia todo o payload recebido do WAHA diretamente para a API `chatbot/webhook/`:

- Método: POST
- URL: `http://api:5000/chatbot/webhook/`
- Corpo JSON: `{{$json}}`

O processamento de resposta continua centralizado na API (`app.py`), evitando duplicidade de lógica no n8n.

---

## 🧪 Testes

1) Envie uma mensagem real pelo WhatsApp conectado
2) Veja a execução no n8n (Executions → deve ficar verde no HTTP Request)
3) Nos logs da API, procure por `WEBHOOK PAYLOAD` e `✅ Resposta enviada`

---

## 🔍 Troubleshooting

- Mensagem “Received request for unknown webhook” no n8n: o workflow não está “Active” ou o webhookId da URL do WAHA não corresponde ao do nó WAHA Trigger.
- 404 temporário no WAHA: normal enquanto o workflow não está ativado.
- API 400/422: a API aceita `{event,payload}` e corrige dois formatos comuns; ver `app.py`.

---

## ✅ Checklist Final

- [ ] n8n rodando (http://localhost:5679)
- [ ] Workflow importado e ATIVO (verificar sem login)
- [ ] WAHA configurado com a URL do WAHA Trigger (UUID correto)
- [ ] Execução aparecendo no n8n
- [ ] Bot respondendo pelo WhatsApp

---

Nota: o guia antigo com “Webhook (genérico)” foi descontinuado. Caso ainda exista algum workflow com nó Webhook, desative-o para evitar conflitos.
