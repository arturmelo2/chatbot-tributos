# 📊 Guia de Setup - Prometheus + Grafana

## 🚀 Quick Start

### 1. Subir Stack Completa
```bash
# PowerShell
docker compose up -d

# Aguardar ~10 segundos para tudo inicializar
```

### 2. Acessar Serviços

#### Grafana (Visualização)
- **URL**: http://localhost:3001
- **Usuário**: `admin`
- **Senha**: `Tributos@2025`

#### Prometheus (Métricas)
- **URL**: http://localhost:9090
- **Targets**: http://localhost:9090/targets

#### API Chatbot (Métricas)
- **Health**: http://localhost:5000/health
- **Metrics**: http://localhost:5000/metrics

---

## 📈 Dashboard Grafana

### Acesso Automático
O dashboard já está provisionado automaticamente em:
- **Nome**: "Chatbot de Tributos - Observabilidade"
- **UID**: `chatbot-tributos`
- **Caminho**: Home → Dashboards → Chatbot de Tributos - Observabilidade

### Painéis Disponíveis

#### 🌐 **HTTP Metrics**
1. **Taxa de Requisições HTTP** - Requests por segundo
2. **Latência HTTP** - Percentis P50, P95, P99

#### 🤖 **Chatbot Metrics**
3. **Total de Mensagens Processadas** - Gauge
4. **Tempo de Resposta (P95)** - Gauge
5. **Latência do Chatbot** - Gráfico de percentis
6. **Taxa de Mensagens** - Messages/s

#### 📚 **RAG Metrics**
7. **Taxa de Consultas RAG** - Queries/s
8. **Total Consultas RAG** - Gauge
9. **Documentos Recuperados** - Histogram

#### 📱 **WAHA Metrics**
10. **Chamadas WAHA API** - Requests por endpoint
11. **Erros WAHA API** - Gauge
12. **Sessões WhatsApp Ativas** - Gauge

#### 💻 **System Metrics**
13. **Uso de Memória** - Residente + Virtual
14. **Uso de CPU** - Percentual
15. **Garbage Collector** - Python GC stats

---

## 🔧 Configuração

### Prometheus (prometheus.yml)

**Scrape Interval**: 15s (padrão), 10s (API)

**Jobs Configurados**:
```yaml
- chatbot-api (api:5000/metrics) - 10s
- prometheus (localhost:9090) - Self-monitoring
```

**Adicionar Novos Jobs**:
```yaml
scrape_configs:
  - job_name: 'meu-servico'
    static_configs:
      - targets: ['host:port']
    metrics_path: '/metrics'
    scrape_interval: 15s
```

### Grafana (Auto-provisionado)

**Datasource**: Prometheus (automático via `grafana/provisioning/datasources/`)

**Dashboards**: Auto-carregados de `grafana/dashboards/`

---

## 📊 Queries Úteis

### Prometheus Query Examples

#### Taxa de Requisições HTTP
```promql
rate(http_requests_total[5m])
```

#### Latência P95 do Chatbot
```promql
histogram_quantile(0.95, rate(chatbot_response_time_seconds_bucket[5m]))
```

#### Taxa de Erro HTTP
```promql
sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) * 100
```

#### Memória Usada (MB)
```promql
process_resident_memory_bytes / 1024 / 1024
```

#### Mensagens por Minuto
```promql
rate(chatbot_messages_total[1m]) * 60
```

#### Taxa de Sucesso WAHA
```promql
sum(rate(waha_api_calls_total{status="success"}[5m])) / sum(rate(waha_api_calls_total[5m])) * 100
```

---

## 🎨 Personalizar Dashboard

### Via Interface Grafana
1. Acessar http://localhost:3001
2. Login com `admin` / `Tributos@2025`
3. Ir em Dashboards → Chatbot de Tributos
4. Clicar em "Edit" no painel desejado
5. Modificar query, visualização, thresholds, etc.
6. Salvar

### Via JSON
1. Editar `grafana/dashboards/chatbot-dashboard.json`
2. Reiniciar Grafana: `docker compose restart grafana`
3. Dashboard será atualizado automaticamente

---

## 🔔 Configurar Alertas

### 1. Via Grafana (Recomendado)

**Criar Alerta de Tempo de Resposta Alto**:
```
1. Dashboard → Latência do Chatbot
2. Edit Panel → Alert tab
3. Criar regra:
   - Nome: "Latência Alta"
   - Query: histogram_quantile(0.95, rate(chatbot_response_time_seconds_bucket[5m]))
   - Condição: WHEN last() OF query(A) IS ABOVE 5
   - For: 2m
   - Notification: Slack/Email/Webhook
```

### 2. Via Prometheus (Avançado)

**Criar arquivo `alerts/chatbot.yml`**:
```yaml
groups:
  - name: chatbot
    interval: 30s
    rules:
      - alert: ChatbotLatencyHigh
        expr: histogram_quantile(0.95, rate(chatbot_response_time_seconds_bucket[5m])) > 5
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "Latência alta no chatbot"
          description: "P95 latency is {{ $value }}s"

      - alert: WAHAApiErrors
        expr: rate(waha_api_errors_total[5m]) > 0.1
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Erros na API WAHA"
          description: "{{ $value }} erros/s"
```

**Atualizar prometheus.yml**:
```yaml
rule_files:
  - "alerts/*.yml"
```

---

## 🐛 Troubleshooting

### Prometheus não está coletando métricas

**Verificar Targets**:
```bash
# Acessar: http://localhost:9090/targets
# Status esperado: UP (verde)
```

**Se o target estiver DOWN**:
```bash
# Verificar se API está rodando
curl http://localhost:5000/metrics

# Ver logs do Prometheus
docker logs tributos_prometheus

# Verificar conectividade na rede Docker
docker exec -it tributos_prometheus ping api
```

### Grafana não mostra dados

**Verificar Datasource**:
```
1. Grafana → Configuration → Data Sources
2. Prometheus deve estar listado
3. Clicar em "Test" → "Data source is working"
```

**Verificar Query**:
```
1. Dashboard → Panel → Edit
2. Query Inspector → Verificar se query retorna dados
3. Ajustar time range (última 1h, 6h, 24h)
```

### Dashboard não aparece

**Recarregar Provisioning**:
```bash
# Reiniciar Grafana
docker compose restart grafana

# Verificar logs
docker logs tributos_grafana
```

---

## 📦 Volumes Persistentes

### Dados Preservados
```yaml
volumes:
  prometheus_data: # Métricas históricas
  grafana_data:    # Dashboards, usuários, configurações
```

### Backup
```bash
# Backup Prometheus
docker run --rm -v whatsapp-ai-chatbot_prometheus_data:/data -v $(pwd):/backup alpine tar czf /backup/prometheus-backup.tar.gz /data

# Backup Grafana
docker run --rm -v whatsapp-ai-chatbot_grafana_data:/data -v $(pwd):/backup alpine tar czf /backup/grafana-backup.tar.gz /data
```

### Restore
```bash
# Restore Prometheus
docker run --rm -v whatsapp-ai-chatbot_prometheus_data:/data -v $(pwd):/backup alpine tar xzf /backup/prometheus-backup.tar.gz -C /

# Restore Grafana
docker run --rm -v whatsapp-ai-chatbot_grafana_data:/data -v $(pwd):/backup alpine tar xzf /backup/grafana-backup.tar.gz -C /
```

---

## 🔐 Segurança

### Alterar Senha do Grafana
```bash
# Via docker-compose.yml
environment:
  - GF_SECURITY_ADMIN_PASSWORD=SuaSenhaSegura123

# Reiniciar
docker compose up -d grafana
```

### Alterar Senha via CLI
```bash
# Entrar no container
docker exec -it tributos_grafana grafana-cli admin reset-admin-password NovaSenha123
```

### Prometheus com Autenticação
Adicionar reverse proxy (Nginx/Traefik) com basic auth

---

## 📚 Recursos Adicionais

### Documentação
- [Prometheus Docs](https://prometheus.io/docs/)
- [Grafana Docs](https://grafana.com/docs/)
- [PromQL Guide](https://prometheus.io/docs/prometheus/latest/querying/basics/)

### Dashboards Prontos
- [Grafana Dashboard Library](https://grafana.com/grafana/dashboards/)
- [Python Application Dashboard](https://grafana.com/grafana/dashboards/14058)
- [Flask Dashboard](https://grafana.com/grafana/dashboards/12544)

### Plugins Úteis
```bash
# Instalar no compose.yml
environment:
  - GF_INSTALL_PLUGINS=grafana-piechart-panel,grafana-worldmap-panel
```

---

## ✅ Checklist de Configuração

- [ ] Prometheus rodando em http://localhost:9090
- [ ] Targets UP em http://localhost:9090/targets
- [ ] Grafana rodando em http://localhost:3001
- [ ] Login funcionando (admin/Tributos@2025)
- [ ] Datasource Prometheus configurado
- [ ] Dashboard "Chatbot de Tributos" carregado
- [ ] Painéis mostrando dados (aguardar ~1 min)
- [ ] Métricas sendo coletadas (/metrics respondendo)
- [ ] Alertas configurados (opcional)
- [ ] Senha do Grafana alterada (recomendado)

---

**Setup concluído!** 🎉

Agora você tem observabilidade completa do seu chatbot!
