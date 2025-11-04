# 🔧 Troubleshooting - Porta 3000 WAHA não acessível

## Problema

Ao tentar acessar http://localhost:3000, a conexão falha ou retorna erro "Response ended prematurely".

## Causa

Docker Desktop no Windows às vezes tem problemas com port forwarding, especialmente quando o container escuta apenas em IPv6 (`[::1]:3000`).

## Verificação

```powershell
# 1. Container está rodando?
docker ps --filter "name=tributos_waha"

# 2. WAHA funciona internamente?
docker exec tributos_api python -c "import requests; print(requests.get('http://waha:3000/api/version').status_code)"
# Deve retornar: 401 (Unauthorized - OK!)

# 3. Porta está mapeada?
docker port tributos_waha
# Se vazio ou só mostrar "3000/tcp", a porta não está acessível externamente
```

## Solução 1: Proxy Socat (Recomendado)

Crie um container proxy que faz o forward da porta 3000 para 3001:

```powershell
docker run -d `
  --name waha_proxy `
  -p 3001:3001 `
  --network whatsapp-ai-chatbot_tributos_network `
  --restart unless-stopped `
  alpine/socat TCP-LISTEN:3001,fork,reuseaddr TCP:tributos_waha:3000
```

**Acesse:** http://localhost:3001

## Solução 2: Restart do Docker Desktop

```powershell
# Windows
Restart-Service docker

# Ou via interface gráfica:
# Docker Desktop → Settings → General → Restart
```

Depois:
```powershell
docker-compose down
docker-compose up -d
```

## Solução 3: Alterar para porta diferente

Se a porta 3000 está em conflito, mude no `compose.yml`:

```yaml
waha:
  ports:
    - '3001:3000'  # Porta externa 3001
```

Depois:
```powershell
docker-compose down
docker-compose up -d
```

**Acesse:** http://localhost:3001

## Solução 4: WSL2 (Avançado)

Se usar WSL2, pode acessar via IP do WSL:

```powershell
# No WSL2
ip addr show eth0 | grep inet

# No Windows, acesse
# http://<IP_WSL>:3000
```

## Verificar se funcionou

```powershell
# Deve retornar 401 (Unauthorized - OK!)
Invoke-WebRequest -Uri "http://localhost:3001" -UseBasicParsing
```

Resposta esperada:
```
Invoke-WebRequest: Response status code does not indicate success: 401 (Unauthorized).
```

**Isso é CORRETO!** 401 significa que WAHA está respondendo, só precisa de autenticação.

## Credenciais

Pegue as credenciais dos logs:

```powershell
docker logs tributos_waha | Select-String "WAHA_DASHBOARD"
```

Exemplo:
```
WAHA_DASHBOARD_USERNAME=admin
WAHA_DASHBOARD_PASSWORD=abc123def456
```

## Tornar Proxy Permanente

Adicione o proxy ao `compose.yml`:

```yaml
services:
  waha_proxy:
    image: alpine/socat
    container_name: waha_proxy
    restart: unless-stopped
    ports:
      - '3001:3001'
    command: TCP-LISTEN:3001,fork,reuseaddr TCP:tributos_waha:3000
    networks:
      - tributos_network
    depends_on:
      - waha
```

Depois:
```powershell
docker-compose down
docker-compose up -d
```

## Alternativa: Docker Compose override

Crie `docker-compose.override.yml`:

```yaml
services:
  waha:
    ports:
      - '3001:3000'  # Tenta porta 3001 em vez de 3000
```

## Logs Úteis

```powershell
# Ver em qual porta WAHA está escutando
docker logs tributos_waha | Select-String "running on"

# Ver processos no container
docker exec tributos_waha ps aux

# Ver todas as conexões de rede
docker network inspect whatsapp-ai-chatbot_tributos_network
```

## Resumo

| Solução | Complexidade | Recomendação |
|---------|--------------|--------------|
| Proxy socat | Baixa | ⭐⭐⭐⭐⭐ Melhor |
| Restart Docker | Baixa | ⭐⭐⭐ Temporário |
| Mudar porta | Média | ⭐⭐⭐⭐ Permanente |
| WSL2 IP | Alta | ⭐⭐ Avançado |

---

**Status:** Resolvido com proxy socat na porta 3001
**Data:** Novembro 2025
**Plataforma:** Windows 11 + Docker Desktop + WSL2
