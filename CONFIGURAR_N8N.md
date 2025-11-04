# 🔄 Configurar Chatbot com n8n (WAHA Trigger)

> Política: não usar mais o “webhook normal” (nó Webhook genérico). Padronizamos o uso do nó WAHA Trigger do pacote oficial, com URL de produção baseada em webhookId.

---

## 🚀 Passo 1: Acessar n8n

1. Abrir: http://localhost:5679
2. Criar conta (primeiro acesso) e logar

---

## 📋 Passo 2: Importar o workflow pronto (recomendado)

1. Menu → Import from File
2. Selecione: `./n8n/workflows/waha_to_api_8c0ac011.json`
3. Abra o nó “WAHA Trigger” e confirme o `webhookId`.
4. Ative o workflow (botão Activate).

Resultado esperado: O n8n mostra a URL de produção do webhook no formato:

```
http://n8n:5678/webhook/8c0ac011-c46c-4c2c-bab1-ac5e0c3a365b/waha
``

---

## 🔗 Passo 3: Apontar o WAHA para o WAHA Trigger (n8n)

Já deixamos o `compose.yml` com a variável correta no serviço `waha`:

```yaml
environment:
  - WHATSAPP_HOOK_URL=http://n8n:5678/webhook/8c0ac011-c46c-4c2c-bab1-ac5e0c3a365b/waha
  - WHATSAPP_HOOK_EVENTS=message,session.status
```

Se você editar o webhookId no n8n, atualize a URL acima no `compose.yml` e recrie os containers.

---

## 🔁 Passo 4: Encaminhar para a API

O workflow importado já contém o nó HTTP Request configurado para enviar o JSON integral do evento para a API:

- Método: POST
- URL: `http://api:5000/chatbot/webhook/`
- JSON/RAW Parameters: ON
- JSON/RAW Body: `{{$json}}`

Observação: Não use nós de “Send Text” no n8n; a API (`app.py`) envia as respostas e controla o typing.

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
- [ ] Workflow importado e ATIVO
- [ ] WAHA configurado com a URL do WAHA Trigger (UUID correto)
- [ ] Execução aparecendo no n8n
- [ ] Bot respondendo pelo WhatsApp

---

Nota: o guia antigo com “Webhook (genérico)” foi descontinuado. Caso ainda exista algum workflow com nó Webhook, desative-o para evitar conflitos.
