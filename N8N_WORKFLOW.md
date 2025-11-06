# Integração com n8n (WAHA → API)

Este guia mostra como usar o n8n como intermediário entre o WAHA (WhatsApp HTTP API) e a API do chatbot.

## 1) Configurar WAHA → n8n

No `compose.yml` (serviço `waha`), aponte o webhook do WAHA para o nó **WAHA Trigger** do n8n e habilite os eventos necessários (não usar mais o Webhook genérico):

```yaml
environment:
  - WHATSAPP_HOOK_URL=http://n8n:5678/webhook/8c0ac011-c46c-4c2c-bab1-ac5e0c3a365b/waha
  - WHATSAPP_HOOK_EVENTS=message,session.status
```

Observações:
- O `8c0ac011-c46c-4c2c-bab1-ac5e0c3a365b` é o `webhookId` do nó WAHA Trigger dentro do n8n. Se criar outro nó, use o novo `webhookId`.
- O n8n está exposto em `http://localhost:5679` para interface Web.

## 2) Workflow pronto

O `docker compose up -d` executa o bootstrap automático que instala `n8n-nodes-waha` e ativa o arquivo `./n8n/workflows/waha_to_api_8c0ac011.json`.

Ele contém três nós:
- **WAHA Trigger**: recebe eventos do WAHA
- **Só mensagens? (IF)**: deixa passar somente `event == "message"`
- **Enviar para API (HTTP Request)**: envia o JSON inteiro para `http://api:5000/chatbot/webhook/`
  - JSON/RAW Parameters: ON
  - Content-Type: application/json
  - JSON/RAW Body: `{{$json}}`

O workflow já sobe **Active**. Se importar outra variação, lembre-se de ativá-la e desativar versões antigas para evitar conflitos.

## 3) Testar ponta a ponta

1. Envie uma mensagem real para o WhatsApp conectado (ex.: `IPTU 2025`).
2. No n8n, veja a execução: o IF deve passar e o HTTP Request ficar verde.
3. Na API, os logs devem mostrar `WEBHOOK PAYLOAD ...` e em seguida `✅ Resposta enviada ...`.
4. A resposta chega no WhatsApp do munícipe.

## 4) Troubleshooting

- `Received request for unknown webhook` no n8n:
  - O workflow não está **Activated** ou o `WHATSAPP_HOOK_URL` não corresponde ao `webhookId` do WAHA Trigger.
- WAHA registra 404 ao enviar webhook:
  - Normal se o workflow ainda não está ativado; ao ativar, passa a 200.
- API 400 por corpo inválido:
  - A API (`app.py`) aceita o formato padrão `{event, payload}` e corrige automaticamente dois casos comuns:
    1) `{payload:{from,body}}` (assume `event = "message"`).
    2) `{from,body}` (envolve em `{event:"message", payload:{...}}`).

## 5) Alternativa: sem IF

Se quiser simplificar, ligue o **WAHA Trigger** diretamente no **Enviar para API** e mantenha `JSON/RAW Body = {{$json}}`. A API vai ignorar eventos que não sejam `message`.
