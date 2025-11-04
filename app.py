"""
Chatbot de Tributos - Prefeitura Municipal de Nova Trento/SC.
Aplicação Flask com integração WhatsApp via WAHA.
"""

import json
import logging
import time
from functools import wraps

from flask import Flask, Response, jsonify, request

from bot.ai_bot import AIBot
from services.config import get_settings
from services.logging_setup import setup_logging
from services.metrics import (
    get_metrics,
    record_chatbot_message,
    record_request,
)
from services.version import __version__
from services.waha import Waha

# =============================================================================
# Configuração de Logging
# =============================================================================
setup_logging()
logger = logging.getLogger(__name__)


# =============================================================================
# Aplicação Flask
# =============================================================================
app = Flask(__name__)

# Configurações
settings = get_settings()
PORT = settings.PORT
DEBUG = settings.DEBUG
ENVIRONMENT = settings.ENVIRONMENT


# =============================================================================
# Middleware de Métricas
# =============================================================================
def track_metrics(f):
    """Decorator para rastrear métricas de requisições."""

    @wraps(f)
    def decorated_function(*args, **kwargs):
        start_time = time.time()
        method = request.method
        endpoint = request.path

        try:
            response = f(*args, **kwargs)
            status = response[1] if isinstance(response, tuple) else 200
            duration = time.time() - start_time
            record_request(method, endpoint, status, duration)
            return response
        except Exception as e:
            duration = time.time() - start_time
            record_request(method, endpoint, 500, duration)
            raise e

    return decorated_function


# =============================================================================
# Health Check Endpoint
# =============================================================================
@app.route("/health", methods=["GET"])
@track_metrics
def health():
    """Endpoint de health check para Docker e monitoramento."""
    try:
        # Verificar se consegue instanciar o bot (valida configuração)
        _ = AIBot()  # Apenas valida a configuração
        return jsonify(
            {
                "status": "healthy",
                "service": "Chatbot de Tributos Nova Trento/SC",
                "environment": ENVIRONMENT,
                "llm_provider": settings.LLM_PROVIDER,
                "version": __version__,
            }
        ), 200
    except Exception as e:
        logger.error(f"Health check falhou: {e}")
        return jsonify({"status": "unhealthy", "error": str(e)}), 503


# =============================================================================
# Metrics Endpoint (Prometheus)
# =============================================================================
@app.route("/metrics", methods=["GET"])
def metrics():
    """Endpoint de métricas para Prometheus."""
    return Response(get_metrics(), mimetype="text/plain")


# =============================================================================
# Webhook do WhatsApp (WAHA)
# =============================================================================
@app.route("/chatbot/webhook/", methods=["POST"])
@track_metrics
def webhook():
    """Recebe mensagens do WAHA e processa com o chatbot."""
    start_time = time.time()
    try:
        data = request.json

        # Log payload recebido
        logger.info("=" * 80)
        logger.info(f"WEBHOOK PAYLOAD: {json.dumps(data, indent=2)}")
        logger.info("=" * 80)

        # Validar/coagir payload - WAHA envia {"event": "message", "payload": {...}}
        if not data:
            logger.warning("Payload vazio")
            return jsonify({"status": "error", "message": "Payload inválido"}), 400

        # Tolerância a formatos comuns incorretos vindos do n8n
        # Caso 1: Recebemos apenas o objeto da mensagem (sem wrapper {event, payload})
        if isinstance(data, dict) and "event" not in data and "payload" not in data:
            if "from" in data and "body" in data:
                logger.warning(
                    "Coerção de payload: recebido objeto de mensagem puro; envolvendo em {event,payload} (event='message')"
                )
                data = {
                    "event": "message",
                    "payload": data,
                }
            else:
                logger.warning(f"Payload inválido - keys presentes: {list(data.keys())}")
                return jsonify({"status": "error", "message": "Payload inválido"}), 400

        # Caso 2: Veio 'payload' correto mas faltou o 'event'
        if isinstance(data, dict) and "payload" in data and "event" not in data:
            payload_obj = data.get("payload") or {}
            if isinstance(payload_obj, dict) and "from" in payload_obj and "body" in payload_obj:
                logger.warning("Coerção de payload: 'event' ausente; assumindo event='message'")
                data = {
                    "event": "message",
                    "payload": payload_obj,
                }
            else:
                logger.warning("Payload inválido: 'payload' presente porém sem campos esperados")
                return jsonify({"status": "error", "message": "Payload inválido"}), 400

        # Caso padrão: deve existir 'event' e 'payload'
        if "event" not in data or "payload" not in data:
            logger.warning(f"Payload inválido - keys presentes: {list(data.keys())}")
            return jsonify({"status": "error", "message": "Payload inválido"}), 400

        # Ignorar eventos que não sejam mensagens
        if data["event"] != "message":
            logger.info(f"Evento ignorado: {data['event']}")
            return jsonify({"status": "success", "message": "Evento ignorado"}), 200

        message_data = data["payload"]
        chat_id = message_data.get("from")
        received_message = message_data.get("body", "")

        if not chat_id or not received_message:
            logger.warning("Mensagem sem chat_id ou body")
            return jsonify({"status": "error", "message": "Dados incompletos"}), 400

        # Ignorar grupos
        is_group = "@g.us" in chat_id
        if is_group:
            logger.info(f"Mensagem de grupo ignorada: {chat_id}")
            record_chatbot_message("ignored")
            return jsonify({"status": "success", "message": "Mensagem de grupo ignorada"}), 200

        logger.info(f"📨 Nova mensagem de {chat_id}: {received_message[:50]}...")

        # Processar mensagem
        waha = Waha()
        ai_bot = AIBot()

        waha.start_typing(chat_id=chat_id)
        try:
            # Buscar histórico de conversas (formato já normalizado)
            history_messages = waha.get_history_messages(
                chat_id=chat_id,
                limit=10,
            )

            # Gerar resposta
            response_message = ai_bot.invoke(
                history_messages=history_messages,
                question=received_message,
            )

            # Enviar resposta
            waha.send_message(
                chat_id=chat_id,
                message=response_message,
            )
        finally:
            # Garante que o typing é interrompido mesmo em caso de erro
            waha.stop_typing(chat_id=chat_id)

        logger.info(f"✅ Resposta enviada para {chat_id}")

        # Registrar métrica de sucesso
        response_time = time.time() - start_time
        record_chatbot_message("success", response_time)

        return jsonify({"status": "success"}), 200

    except Exception as e:
        logger.error(f"❌ Erro ao processar webhook: {e}", exc_info=True)

        # Registrar métrica de erro
        response_time = time.time() - start_time
        record_chatbot_message("error", response_time)

        return jsonify({"status": "error", "message": str(e)}), 500


# =============================================================================
# Rota Principal (info da API)
# =============================================================================
@app.route("/", methods=["GET"])
@track_metrics
def index():
    """Página inicial com informações da API."""
    return jsonify(
        {
            "service": "Chatbot de Tributos - Nova Trento/SC",
            "version": __version__,
            "status": "running",
            "environment": ENVIRONMENT,
            "endpoints": {
                "health": "/health",
                "webhook": "/chatbot/webhook/",
                "metrics": "/metrics",
            },
        }
    ), 200


# =============================================================================
# Inicialização
# =============================================================================
if __name__ == "__main__":
    logger.info(f"🚀 Iniciando Chatbot de Tributos em {ENVIRONMENT} mode")
    logger.info(f"🌐 Porta: {PORT}")
    logger.info(f"🔧 Debug: {DEBUG}")

    app.run(host="0.0.0.0", port=PORT, debug=DEBUG)
