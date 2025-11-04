# 🚀 Quick Start - Rodar por IP (sem domínio)

> **Este guia mostra como subir o chatbot direto no servidor via IP público, sem HTTPS.**  
> Você pode migrar para HTTPS depois configurando DNS e usando o `compose.prod.caddy.yml`.

---

## ✅ Pré-requisitos no servidor

- Docker e Docker Compose instalados
- Portas abertas no firewall:
  - **5000** → API Python
  - **3000** → WAHA (WhatsApp)
  - **5679** → n8n
- Chave de API do Groq (https://console.groq.com)

---

## 📦 1. Clonar repositório

```bash
git clone https://github.com/arturmelo2/chatbot-tributos.git
cd chatbot-tributos
```

---

## ⚙️ 2. Configurar .env

Copie o exemplo e preencha:

```bash
cp .env.production.example .env
```

Edite `.env` com suas chaves:

```bash
# LLM
LLM_PROVIDER=groq
LLM_MODEL=llama-3.3-70b-versatile
GROQ_API_KEY=sua_chave_aqui

# APP
PORT=5000
ENVIRONMENT=production
DEBUG=false
LOG_LEVEL=INFO

# WAHA
WAHA_API_URL=http://waha:3000
WAHA_API_KEY=tributos_nova_trento_2025_api_key_fixed
WAHA_SESSION=default

# (Deixe DOMAIN e LETSENCRYPT_EMAIL vazios ou comente)
# DOMAIN=
# LETSENCRYPT_EMAIL=
```

---

## 🐳 3. Subir a stack (modo rápido)

Opção A — script automatizado (recomendado em Windows Server):

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\bootstrap-no-domain.ps1 -WaitSeconds 20 -AutoStart
```

Opção B — manual:

```bash
docker compose -f compose.prod.yml up -d
```

Aguarde 20-60s para os containers iniciarem.

---

## 🧪 4. Validar serviços

Se estiver no servidor Windows, teste localmente:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\health-check-local.ps1
```

Resultados esperados: ✓ API OK, ✓ WAHA OK, ✓ n8n OK

---

## 📱 5. Conectar WhatsApp

1. Acesse no servidor: **http://localhost:3000**
2. Login:
   - User: `admin`
   - Pass: `Tributos@NovaTrento2025`
3. Clique em **"Start Session"** → escanear QR com WhatsApp
4. Status deve ficar **WORKING**

---

## 🔄 6. Importar workflow n8n

1. Acesse no servidor: **http://localhost:5679**
2. Crie conta (primeira vez)
3. Clique em **Workflows** → **Import from File**
4. Selecione: `n8n/workflows/chatbot_orquestracao_plus_menu.json`
5. Ative o workflow (toggle ON)

---

## ✅ 7. Testar o chatbot

Envie uma mensagem para o número conectado no WAHA:

```
Olá
```

Você deve receber o menu principal do chatbot de tributos.

---

## 🔒 Migrar para HTTPS (opcional - depois)

Quando tiver um domínio (ex.: chatbot.novatrento.sc.gov.br):

1. Criar registro DNS A apontando para `177.200.219.170`
2. Editar `.env`:
   ```bash
   DOMAIN=chatbot.novatrento.sc.gov.br
   LETSENCRYPT_EMAIL=ti@novatrento.sc.gov.br
   ```
3. Subir com proxy Caddy:
   ```bash
   docker compose down
   docker compose -f compose.prod.yml -f compose.prod.caddy.yml up -d
   ```
4. Validar DNS e HTTPS:
   ```bash
   ./scripts/check-dns.ps1 -Domain "chatbot.novatrento.sc.gov.br"
   ./scripts/health-check.ps1 -Domain "chatbot.novatrento.sc.gov.br"
   ```

---

## 🛠️ Comandos úteis

### Ver logs
```bash
docker compose -f compose.prod.yml logs -f api
docker compose -f compose.prod.yml logs -f waha
docker compose -f compose.prod.yml logs -f n8n
```

### Parar tudo
```bash
docker compose -f compose.prod.yml down
```

### Atualizar imagem
```bash
docker compose -f compose.prod.yml pull
docker compose -f compose.prod.yml up -d
```

---

## 📞 Suporte

- Issues: https://github.com/arturmelo2/chatbot-tributos/issues
- Email: ti@novatrento.sc.gov.br

---

**Pronto!** Seu chatbot está rodando em **http://177.200.219.170** nas portas 5000, 3000 e 5679.
