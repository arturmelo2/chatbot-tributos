"""Testes para o cliente WAHA."""

from unittest.mock import Mock, patch

import pytest
import requests

from services.waha import Waha


@pytest.fixture
def waha():
    """Fixture que retorna uma instância do cliente Waha."""
    with patch("services.waha.get_settings") as mock_settings:
        mock_settings.return_value = Mock(
            WAHA_API_URL="http://localhost:3000",
            WAHA_API_KEY="test-key",
            WAHA_SESSION="default",
            WAHA_TIMEOUT=30.0,
        )
        yield Waha()


class TestWaha:
    """Testes para a classe Waha."""

    def test_init(self, waha):
        """Testa a inicialização do cliente."""
        assert waha.base_url == "http://localhost:3000"
        assert waha.session == "default"
        assert waha.headers["X-Api-Key"] == "test-key"

    @patch("services.waha.requests.post")
    def test_send_message_success(self, mock_post, waha):
        """Testa o envio de mensagem com sucesso."""
        mock_post.return_value = Mock(
            status_code=200,
            json=lambda: {"id": "msg123"},
        )

        result = waha.send_message("5511999999999", "Olá!")

        assert result == {"id": "msg123"}
        mock_post.assert_called_once()
        args, kwargs = mock_post.call_args
        assert "sendText" in args[0]
        assert kwargs["json"]["chatId"] == "5511999999999@c.us"
        assert kwargs["json"]["text"] == "Olá!"

    @patch("services.waha.requests.post")
    def test_send_message_fallback_endpoint(self, mock_post, waha):
        """Testa fallback para endpoint alternativo."""
        # Primeira chamada falha, segunda funciona
        mock_post.side_effect = [
            requests.exceptions.RequestException(),
            Mock(status_code=200, json=lambda: {"id": "msg456"}),
        ]

        result = waha.send_message("5511999999999", "Teste")

        assert result == {"id": "msg456"}
        assert mock_post.call_count == 2

    @patch("services.waha.requests.get")
    def test_get_history_messages(self, mock_get, waha):
        """Testa a recuperação do histórico de mensagens."""
        mock_get.return_value = Mock(
            status_code=200,
            json=lambda: [
                {"id": "msg1", "body": "Olá"},
                {"id": "msg2", "body": "Tudo bem?"},
            ],
        )

        result = waha.get_history_messages("5511999999999", limit=10)

        assert len(result) == 2
        assert result[0]["body"] == "Olá"
        mock_get.assert_called_once()

    @patch("services.waha.requests.get")
    def test_list_chats(self, mock_get, waha):
        """Testa a listagem de chats."""
        mock_get.return_value = Mock(
            status_code=200,
            json=lambda: [
                {"id": "chat1", "name": "João"},
                {"id": "chat2", "name": "Maria"},
            ],
        )

        result = waha.list_chats()

        assert len(result) == 2
        assert result[0]["name"] == "João"

    @patch("services.waha.requests.post")
    def test_start_typing(self, mock_post, waha):
        """Testa o início da indicação de digitação."""
        mock_post.return_value = Mock(status_code=200)

        waha.start_typing("5511999999999", duration=3)

        mock_post.assert_called_once()
        args, kwargs = mock_post.call_args
        assert "startTyping" in args[0]
        assert kwargs["json"]["chatId"] == "5511999999999@c.us"
