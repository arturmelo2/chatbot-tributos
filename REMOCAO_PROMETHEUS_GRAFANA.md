# Remoção do Prometheus e Grafana

**Data:** 04/11/2025  
**Motivo:** Ferramentas de observabilidade excessivas para um chatbot simples

## 📋 Mudanças Realizadas

### ✅ Arquivos Modificados

1. **compose.yml**
   - Removidos serviços `prometheus` e `grafana`
   - Removidos volumes `prometheus_data` e `grafana_data`
   - Configuração simplificada

2. **app.py**
   - Removido import de `services.metrics`
   - Removido decorator `@track_metrics`
   - Removido endpoint `/metrics`
   - Mantidos logs estruturados com tempo de resposta

3. **services/waha.py**
   - Removidas chamadas `record_waha_call()`
   - Substituídas por `logger.debug()` simples
   - Funcionalidade mantida, apenas sem métricas Prometheus

4. **requirements.txt**
   - Removida dependência `prometheus-client==0.21.0`

5. **README.md**
   - Removida seção "Métricas Prometheus"
   - Atualizada seção de funcionalidades
   - Atualizada estrutura do projeto

### 🗑️ Arquivos para Remover (Manual)

Execute o script de limpeza:

```bash
./scripts/cleanup-observabilidade.ps1
```

Ou remova manualmente:

- `prometheus.yml`
- `grafana/` (diretório completo)
- Volumes Docker: `prometheus_data`, `grafana_data`

### 📊 Alternativa: Logs Estruturados

O sistema **continua com logs estruturados em JSON**, incluindo:

- Tempo de resposta de cada mensagem
- Status de processamento (sucesso/erro)
- Detalhes de cada requisição HTTP
- Informações de histórico e conversas

**Exemplo de log:**

```json
{
  "timestamp": "2025-11-04T12:34:56Z",
  "level": "INFO",
  "message": "✅ Resposta enviada para 5511999999999@c.us em 1.23s",
  "chat_id": "5511999999999@c.us",
  "response_time": 1.23
}
```

## 🎯 Benefícios

✅ **Menos containers** - De 5 para 3 (waha, n8n, api)  
✅ **Menos recursos** - Sem Prometheus/Grafana consumindo memória  
✅ **Mais simples** - Menos configuração e manutenção  
✅ **Logs suficientes** - Informações essenciais via logs estruturados  

## 🔄 Como Reverter (Se Necessário)

Se precisar do Prometheus/Grafana no futuro:

1. Restaure a versão anterior do Git:
   ```bash
   git checkout HEAD~1 -- compose.yml app.py services/waha.py requirements.txt
   ```

2. Restaure os arquivos de configuração:
   ```bash
   git checkout HEAD~1 -- prometheus.yml grafana/
   ```

3. Reinstale dependências:
   ```bash
   pip install -r requirements.txt
   ```

## 📌 Notas

- **services/metrics.py** pode ser mantido no repositório (não causa problemas se não for importado)
- Testes automatizados continuam funcionando normalmente
- Logs em `./logs/` continuam sendo gerados
- Health check em `/health` continua funcionando

---

**Conclusão:** Sistema mais enxuto e focado no essencial! 🚀
