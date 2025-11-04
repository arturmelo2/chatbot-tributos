"""Módulo de observabilidade com métricas Prometheus."""

from typing import Optional

from prometheus_client import Counter, Gauge, Histogram, generate_latest

# Métricas de requisições
http_requests_total = Counter(
    "http_requests_total",
    "Total de requisições HTTP",
    ["method", "endpoint", "status"],
)

http_request_duration_seconds = Histogram(
    "http_request_duration_seconds",
    "Duração das requisições HTTP em segundos",
    ["method", "endpoint"],
)

# Métricas do chatbot
chatbot_messages_total = Counter(
    "chatbot_messages_total",
    "Total de mensagens processadas pelo chatbot",
    ["status"],
)

chatbot_response_time_seconds = Histogram(
    "chatbot_response_time_seconds",
    "Tempo de resposta do chatbot em segundos",
)

# Métricas do RAG
rag_queries_total = Counter(
    "rag_queries_total",
    "Total de consultas ao sistema RAG",
)

rag_documents_retrieved = Histogram(
    "rag_documents_retrieved",
    "Número de documentos recuperados por consulta",
)

# Métricas do WAHA
waha_api_calls_total = Counter(
    "waha_api_calls_total",
    "Total de chamadas à API do WAHA",
    ["endpoint", "status"],
)

waha_api_errors_total = Counter(
    "waha_api_errors_total",
    "Total de erros na API do WAHA",
    ["endpoint", "error_type"],
)

# Métricas de sistema
active_sessions = Gauge(
    "active_sessions",
    "Número de sessões ativas do WhatsApp",
)


def get_metrics() -> bytes:
    """
    Retorna as métricas no formato Prometheus.

    Returns:
        Métricas em formato texto para o Prometheus.
    """
    return bytes(generate_latest())


def record_request(method: str, endpoint: str, status: int, duration: Optional[float] = None):
    """
    Registra uma requisição HTTP.

    Args:
        method: Método HTTP (GET, POST, etc).
        endpoint: Endpoint acessado.
        status: Status code da resposta.
        duration: Duração da requisição em segundos.
    """
    http_requests_total.labels(method=method, endpoint=endpoint, status=status).inc()
    if duration is not None:
        http_request_duration_seconds.labels(method=method, endpoint=endpoint).observe(duration)


def record_chatbot_message(status: str, response_time: Optional[float] = None):
    """
    Registra uma mensagem processada pelo chatbot.

    Args:
        status: Status do processamento (success, error, ignored).
        response_time: Tempo de resposta em segundos.
    """
    chatbot_messages_total.labels(status=status).inc()
    if response_time is not None:
        chatbot_response_time_seconds.observe(response_time)


def record_rag_query(num_documents: int):
    """
    Registra uma consulta ao sistema RAG.

    Args:
        num_documents: Número de documentos recuperados.
    """
    rag_queries_total.inc()
    rag_documents_retrieved.observe(num_documents)


def record_waha_call(endpoint: str, status: str, error_type: Optional[str] = None):
    """
    Registra uma chamada à API do WAHA.

    Args:
        endpoint: Endpoint da API chamado.
        status: Status da chamada (success, error).
        error_type: Tipo de erro (se houver).
    """
    waha_api_calls_total.labels(endpoint=endpoint, status=status).inc()
    if error_type:
        waha_api_errors_total.labels(endpoint=endpoint, error_type=error_type).inc()
