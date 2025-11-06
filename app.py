"""
Chatbot de Tributos - Prefeitura Municipal de Nova Trento/SC.
Aplicação Flask com integração WhatsApp via WAHA.
"""

import json
import logging
import time

from flask import Flask, jsonify, request

from bot.ai_bot import AIBot
from services.config import get_settings
from services.logging_setup import setup_logging
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
# Health Check Endpoint
# =============================================================================
@app.route("/health", methods=["GET"])
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
# Webhook do WhatsApp (WAHA)
# =============================================================================
@app.route("/chatbot/webhook/", methods=["POST"])
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

        logger.info(f"✅ Resposta enviada para {chat_id} em {time.time() - start_time:.2f}s")

        return jsonify({"status": "success"}), 200

    except Exception as e:
        logger.error(f"❌ Erro ao processar webhook: {e}", exc_info=True)
        return jsonify({"status": "error", "message": str(e)}), 500


# =============================================================================
# Rota Principal (info da API)
# =============================================================================
@app.route("/rag/search", methods=["POST"])
def rag_search():
    """Endpoint para busca RAG no ChromaDB."""
    try:
        data = request.json
        query = data.get("query", "")
        k = data.get("k", 10)
        search_type = data.get("search_type", "mmr")
        lambda_mult = data.get("lambda_mult", 0.5)

        if not query:
            return jsonify({"error": "Query é obrigatória"}), 400

        logger.info(f"🔍 Busca RAG: '{query[:50]}...' (k={k}, type={search_type})")

        # Usar AIBot para fazer a busca
        ai_bot = AIBot()
        results = ai_bot.search_knowledge(
            query=query,
            k=k,
            search_type=search_type,
            lambda_mult=lambda_mult,
        )

        return jsonify({"query": query, "results": results, "count": len(results)}), 200

    except Exception as e:
        logger.error(f"❌ Erro na busca RAG: {e}", exc_info=True)
        return jsonify({"error": str(e)}), 500


@app.route("/llm/invoke", methods=["POST"])
def llm_invoke():
    """Endpoint para invocar o LLM diretamente."""
    try:
        data = request.json
        messages = data.get("messages", [])
        temperature = data.get("temperature", 0.3)
        max_tokens = data.get("max_tokens", 1500)

        if not messages:
            return jsonify({"error": "Messages são obrigatórias"}), 400

        logger.info(f"🤖 Invocando LLM (temp={temperature}, max_tokens={max_tokens})")

        # Usar AIBot para invocar LLM
        ai_bot = AIBot()
        
        # Converter para formato esperado
        history = []
        question = ""
        for msg in messages:
            if msg.get("role") == "system":
                continue  # System prompt será usado internamente
            elif msg.get("role") == "user":
                question = msg.get("content", "")
            elif msg.get("role") == "assistant":
                if question:
                    history.append({"role": "user", "content": question})
                    question = ""
                history.append({"role": "assistant", "content": msg.get("content", "")})

        # Invocar com o último user message
        response = ai_bot.invoke_with_context(
            history_messages=history,
            question=question,
            context=messages[0].get("content", "") if messages else "",
            temperature=temperature,
        )

        return jsonify({"response": response, "model": ai_bot.model_name}), 200

    except Exception as e:
        logger.error(f"❌ Erro ao invocar LLM: {e}", exc_info=True)
        return jsonify({"error": str(e)}), 500


@app.route("/", methods=["GET"])
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
                "rag_search": "/rag/search",
                "llm_invoke": "/llm/invoke",
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
