"""Cliente WAHA (WhatsApp HTTP API) com suporte a múltiplos endpoints."""

import logging
import os
from typing import Any, Dict, List

import requests

from services.config import get_settings

logger = logging.getLogger(__name__)


class Waha:
    """Cliente para API do WAHA com fallback de endpoints e autenticação."""

    def __init__(self):
        settings = get_settings()
        # Permite override por variável de ambiente
        self.__api_url = (os.getenv("WAHA_API_URL") or settings.WAHA_API_URL).strip()
        self.__timeout = float(os.getenv("WAHA_TIMEOUT") or settings.WAHA_TIMEOUT)
        self.__settings = settings

    def _headers(self) -> Dict[str, str]:
        """Retorna headers HTTP com autenticação opcional."""
        headers = {"Content-Type": "application/json"}
        api_key = os.environ.get("WAHA_API_KEY") or self.__settings.WAHA_API_KEY
        if api_key:
            headers["X-Api-Key"] = api_key
        return headers

    def send_message(self, chat_id: str, message: str) -> None:
        """Envia mensagem de texto para um chat."""
        url = f"{self.__api_url}/api/sendText"
        payload = {"session": "default", "chatId": chat_id, "text": message}
        try:
            resp = requests.post(url, json=payload, headers=self._headers(), timeout=self.__timeout)
            resp.raise_for_status()
            logger.debug(f"Mensagem enviada para {chat_id}")
        except Exception as e:
            logger.error(f"Falha ao enviar mensagem para {chat_id}: {e}")
            raise

    def get_history_messages(self, chat_id: str, limit: int) -> List[Dict[str, str]]:
        """
        Busca histórico do WAHA e transforma no formato esperado pelo AIBot.

        Retorna lista de mensagens no formato:
        [{"role": "user"|"assistant", "content": "..."}, ...]

        Nota: Retorna lista vazia se WAHA retornar 401 (autenticação ausente).
        """
        url = f"{self.__api_url}/api/default/chats/{chat_id}/messages?limit={limit}&downloadMedia=false"
        try:
            resp = requests.get(url, headers=self._headers(), timeout=self.__timeout)

            if resp.status_code == 401:
                logger.warning("WAHA retornou 401 ao buscar histórico. Configure WAHA_API_KEY.")
                return []

            resp.raise_for_status()
            data: Any = resp.json()

            # WAHA pode retornar lista direta ou objeto com lista dentro
            messages = data.get("messages", []) if isinstance(data, dict) else data

            history: List[Dict[str, str]] = []
            for m in messages or []:
                if not isinstance(m, dict):
                    continue

                body = m.get("body") or m.get("text") or ""
                if not body:
                    continue

                role = "assistant" if m.get("fromMe") else "user"
                history.append({"role": role, "content": body})

            logger.debug(f"Histórico obtido para {chat_id}: {len(history)} mensagens")
            return history
        except Exception as e:
            logger.warning(f"Falha ao obter histórico de {chat_id}: {e}")
            return []

    def list_chats(self, limit: int = 1000) -> List[Dict[str, Any]]:
        """
        Lista conversas (chats) da sessão padrão.

        Tenta múltiplos endpoints para compatibilidade com diferentes versões do WAHA.
        """
        candidates = [
            f"{self.__api_url}/api/default/chats?limit={limit}",
            f"{self.__api_url}/api/chats?session=default&limit={limit}",
            f"{self.__api_url}/api/sessions/default/chats?limit={limit}",
        ]

        for url in candidates:
            try:
                resp = requests.get(url, headers=self._headers(), timeout=self.__timeout)
                if resp.status_code == 401:
                    logger.warning("WAHA retornou 401 ao listar chats. Configure WAHA_API_KEY.")
                    return []
                if resp.status_code >= 400:
                    logger.debug(f"list_chats: endpoint {url} retornou {resp.status_code}")
                    continue

                data: Any = resp.json()
                logger.debug(f"Chats listados: {len(data) if isinstance(data, list) else 'N/A'}")
                if isinstance(data, dict):
                    result: List[Dict[str, Any]] = data.get("result", []) or data.get("chats", [])
                    return result
                return list(data) if data else []
            except Exception as e:
                logger.debug(f"list_chats: falha no endpoint {url}: {e}")
                continue

        logger.warning("Falha ao listar chats: todos os endpoints testados retornaram erro")
        return []

    def get_messages(
        self, chat_id: str, limit: int = 1000, download_media: bool = False
    ) -> List[Dict[str, Any]]:
        """
        Busca mensagens brutas de um chat específico.

        Tenta múltiplos endpoints para compatibilidade.
        """
        q = f"limit={limit}&downloadMedia={'true' if download_media else 'false'}"
        candidates = [
            f"{self.__api_url}/api/default/chats/{chat_id}/messages?{q}",
            f"{self.__api_url}/api/chats/{chat_id}/messages?session=default&{q}",
            f"{self.__api_url}/api/sessions/default/chats/{chat_id}/messages?{q}",
        ]

        for url in candidates:
            try:
                resp = requests.get(url, headers=self._headers(), timeout=self.__timeout)
                if resp.status_code == 401:
                    logger.warning("WAHA retornou 401 ao buscar mensagens.")
                    return []
                if resp.status_code >= 400:
                    logger.debug(f"get_messages: endpoint {url} retornou {resp.status_code}")
                    continue

                data: Any = resp.json()
                if isinstance(data, list):
                    result: List[Dict[str, Any]] = list(data)
                    return result
                messages: List[Dict[str, Any]] = data.get("messages", []) or data.get("result", [])
                return messages
            except Exception as e:
                logger.debug(f"get_messages: falha no endpoint {url}: {e}")
                continue

        logger.warning(f"Falha ao obter mensagens de {chat_id}: todos endpoints falharam")
        return []

    def start_typing(self, chat_id: str) -> None:
        """Inicia indicador de digitação (não crítico se falhar)."""
        url = f"{self.__api_url}/api/startTyping"
        payload = {"session": "default", "chatId": chat_id}
        try:
            resp = requests.post(url, json=payload, headers=self._headers(), timeout=self.__timeout)
            if resp.status_code == 401:
                logger.debug("start_typing retornou 401 - autenticação não configurada")
                return
            resp.raise_for_status()
        except Exception as e:
            logger.debug(f"start_typing falhou para {chat_id}: {e}")

    def stop_typing(self, chat_id: str) -> None:
        """Para indicador de digitação (não crítico se falhar)."""
        url = f"{self.__api_url}/api/stopTyping"
        payload = {"session": "default", "chatId": chat_id}
        try:
            resp = requests.post(url, json=payload, headers=self._headers(), timeout=self.__timeout)
            if resp.status_code == 401:
                logger.debug("stop_typing retornou 401 - autenticação não configurada")
                return
            resp.raise_for_status()
        except Exception as e:
            logger.debug(f"stop_typing falhou para {chat_id}: {e}")
