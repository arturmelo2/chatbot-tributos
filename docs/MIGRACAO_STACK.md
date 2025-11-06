# 🔁 Troca de Softwares ou Estrutura Própria

Este guia descreve caminhos para substituir componentes do chatbot ou construir uma stack própria, comparando alternativas, apresentando prós e contras e sugerindo playbooks de migração.

## 🧱 Opções de Stack

### Canais WhatsApp

| Opção | Quando Usar | Pontos Fortes | Pontos de Atenção |
|-------|-------------|---------------|-------------------|
| **WAHA (WhatsApp HTTP API)** | Prototipagem rápida e custo previsível | Self-hosted completo, compatível com o workflow atual, suporte a múltiplas instâncias | Depende de um número conectado via WhatsApp Web; sujeito a bloqueios; latência maior |
| **WhatsApp Cloud API (Meta)** | Escala oficial com alta confiabilidade | Infraestrutura oficial, estabilidade, analytics nativos, templates aprovados | Limites de mensagens por categoria, custos por conversa, necessidade de aprovação de negócio |
| **Business Solution Provider (BSP)** | Operação enterprise com suporte | Suporte dedicado, recursos adicionais (chat-handoff, CRM, múltiplos números) | Contratos e custos maiores, menos flexibilidade técnica |

### Orquestração de Workflows

| Opção | Quando Usar | Pontos Fortes | Pontos de Atenção |
|-------|-------------|---------------|-------------------|
| **n8n** | Orquestração visual com baixa complexidade | Interface no-code, comunidade ativa, integração direta com WAHA | Escalabilidade manual, difícil versionar workflows complexos |
| **Camunda 8** | Processos core com regras claras e SLA | Motor BPMN completo, versionamento, task lists humanas | Curva de aprendizado maior, custos se usar SaaS, exige modelagem BPMN |
| **Temporal** | Processos programáveis e resilientes | Garantia de execução (retries, stateful), SDKs em várias linguagens | Depende de código (menos visual), precisa provisionar serviços adicionais (frontend, worker) |

### Armazenamento Vetorial

| Opção | Quando Usar | Pontos Fortes | Pontos de Atenção |
|-------|-------------|---------------|-------------------|
| **ChromaDB (atual)** | POCs e ambientes controlados | Embutido no projeto, zero setup, rápido localmente | Escalabilidade limitada, recursos de busca básicos |
| **Qdrant** | Índice dedicado com alta performance | Vectors + payloads ricos, filtragem híbrida, hospedagem gerenciada disponível | Precisa manter cluster, tuning de memória |
| **pgvector (PostgreSQL)** | Desejo de unificar dados operacionais e vetoriais | Banco relacional robusto, replicação conhecida, suporte a SQL padrão | Performance menor que vetor nativo, requer ajustes de índice e manutenção de VACUUM |

## ⚖️ Prós e Contras das Trocas

### Migrar para WhatsApp Cloud API
- **Prós**: entrega oficial da Meta, menos risco de banimento, suporte a mensagens template e métricas nativas, melhor SLA.
- **Contras**: requer verificação de negócios, custos por sessão de conversa, limites de throughput nas fases iniciais.

### Migrar n8n → Camunda/Temporal
- **Prós**: maior governança de processos, versionamento formal, escalabilidade horizontal de workers, testes automatizados em código (Temporal) ou BPMN (Camunda).
- **Contras**: migração demanda refatoração do fluxo, equipe precisa dominar BPMN ou SDKs, custos adicionais de infraestrutura.

### Migrar ChromaDB → Qdrant/pgvector
- **Prós**: indexação mais robusta, filtros e ranking customizáveis, maior controle de desempenho.
- **Contras**: operação mais complexa, necessidade de pipelines de ingestão e backup dedicados.

## 🚚 Playbooks de Migração

### WAHA → WhatsApp Cloud API
1. **Avaliação de requisitos**: verificar volume diário, tipos de mensagens e compliance LGPD.
2. **Configurar conta Meta**: criar/app WhatsApp no [Meta for Developers](https://developers.facebook.com/), verificar empresa no Business Manager e obter número dedicado.
3. **Criar tokens**: gerar token permanente e webhook verify token.
4. **Substituir conector**: atualizar orquestrador (n8n/Camunda/Temporal) para consumir os endpoints REST oficiais (`/messages`, `/media`, `/templates`).
5. **Mapear eventos**: registrar webhook no Cloud API e ajustar parsing de eventos (statuses, messages, errors).
6. **Templates e opt-in**: migrar mensagens template para aprovação da Meta, garantir coleta de consentimento.
7. **Testes e rollout gradual**: executar sandbox → produção, liberar por faixas de usuários e monitorar métricas (erro, throughput).
8. **Desativar WAHA**: após validação, desligar containers WAHA e remover dependências do compose atual.

### n8n → Camunda 8
1. **Inventariar workflows**: exportar workflows n8n (`.json`) e mapear gatilhos, estados e integrações.
2. **Modelar BPMN**: traduzir fluxo para BPMN 2.0 usando Camunda Modeler (start event WhatsApp, service tasks API, gateways).
3. **Provisionar stack Camunda**: iniciar Zeebe broker, Tasklist, Operate (Docker Compose ou SaaS) e autenticação.
4. **Implementar workers**: criar microserviços (Python/Node/Java) para cada service task (ex.: chamada ao LLM, persistência de histórico).
5. **Orquestrar integrações**: substituir nós n8n por tasks (REST, Webhook, timers) e configurar retries/timeouts.
6. **Testes de processo**: usar Camunda Operate para simular instâncias e validar variáveis.
7. **Cutover**: apontar webhook do WhatsApp (WAHA/Cloud) para novo endpoint de start process, manter fallback no n8n durante período de coexistência.
8. **Descomissionar n8n**: após estabilidade, arquivar workflows legados e remover containers.

### n8n → Temporal
1. **Mapear fluxos**: listar triggers e jobs recorrentes do n8n.
2. **Definir workflows/activities**: transformar cada fluxo em `Workflow` Temporal e cada integração em `Activity` idempotente.
3. **Subir Temporal Server**: provisionar Temporal Frontend, Matching, History e Worker (via Helm ou Docker Compose).
4. **Desenvolver workers**: implementar em TypeScript/Python/Go, garantindo replays determinísticos.
5. **Integração com WhatsApp**: expor endpoint HTTP que enfileira execução no Temporal (ex.: `client.start(workflow, args)`).
6. **Gerenciar estados**: usar `Signals` para mensagens do usuário e `Queries` para estado atual da conversa.
7. **Observabilidade**: configurar Prometheus + Grafana ou Temporal Web para monitorar runs.
8. **Migração gradual**: rodar flows críticos em Temporal e manter n8n para tarefas ad-hoc até estabilização.

## 🧩 Docker Compose de Referência (Estrutura Própria)

```yaml
version: "3.9"
services:
  whatsapp-gateway:
    image: ghcr.io/ultramsg/whatsapp-cloud-proxy:latest
    env_file: .env.whatsapp
    restart: unless-stopped

  orchestrator:
    image: camunda/zeebe:8.5.5
    environment:
      - ZEEBE_LOG_LEVEL=info
    ports:
      - "26500:26500"
    volumes:
      - zeebe-data:/usr/local/zeebe/data

  orchestrator-tasklist:
    image: camunda/tasklist:8.5.5
    environment:
      - ZEEBE_GATEWAY_ADDRESS=orchestrator:26500
    depends_on:
      - orchestrator
    ports:
      - "8081:8080"

  vector-db:
    image: qdrant/qdrant:v1.7.3
    volumes:
      - qdrant-data:/qdrant/storage
    ports:
      - "6333:6333"

  api:
    build: ../
    command: uvicorn app:app --host 0.0.0.0 --port 8000
    environment:
      - VECTOR_DB_HOST=vector-db
      - ORCHESTRATOR_ENDPOINT=orchestrator:26500
    depends_on:
      - vector-db
      - orchestrator
    ports:
      - "8000:8000"

volumes:
  zeebe-data:
  qdrant-data:
```

> Ajuste as imagens conforme o provedor escolhido (ex.: usar Temporal server ou outro gateway WhatsApp) e mantenha variáveis sensíveis fora do repositório.

## ✅ Próximos Passos
- Defina critérios de sucesso (SLA, custo, governança) para justificar a troca.
- Faça provas de conceito isoladas antes de migrar todo o tráfego.
- Documente novos fluxos e atualize scripts de deploy conforme a stack selecionada.
