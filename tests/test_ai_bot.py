"""Testes para o bot de IA com RAG."""

from unittest.mock import Mock, patch

import pytest

from bot.ai_bot import AIBot


@pytest.fixture
def mock_settings():
    """Fixture com configurações mockadas."""
    with patch("bot.ai_bot.get_settings") as mock:
        settings = Mock()
        settings.LLM_PROVIDER = "groq"
        settings.LLM_MODEL = "llama-3.3-70b-versatile"
        settings.GROQ_API_KEY = "test-groq-key"
        settings.OPENAI_API_KEY = None
        settings.XAI_API_KEY = None
        settings.CHROMA_PATH = "./chroma_data"
        mock.return_value = settings
        yield settings


@pytest.fixture
def mock_chroma():
    """Fixture com Chroma mockado."""
    with patch("bot.ai_bot.Chroma") as mock:
        mock_instance = Mock()
        mock_instance.as_retriever.return_value = Mock()
        mock.return_value = mock_instance
        yield mock


@pytest.fixture
def mock_embeddings():
    """Fixture com embeddings mockados."""
    with patch("bot.ai_ai_bot.HuggingFaceEmbeddings") as mock:
        yield mock


class TestAIBot:
    """Testes para a classe AIBot."""

    @patch("bot.ai_bot.Chroma")
    @patch("bot.ai_bot.HuggingFaceEmbeddings")
    @patch("bot.ai_bot.ChatGroq")
    def test_init_with_groq(self, mock_groq, mock_embeddings, mock_chroma, mock_settings):
        """Testa inicialização com provider Groq."""
        bot = AIBot()

        assert bot.llm is not None
        mock_groq.assert_called_once()

    @patch("bot.ai_bot.Chroma")
    @patch("bot.ai_bot.HuggingFaceEmbeddings")
    @patch("bot.ai_bot.ChatOpenAI")
    def test_init_with_openai(self, mock_openai, mock_embeddings, mock_chroma, mock_settings):
        """Testa inicialização com provider OpenAI."""
        mock_settings.LLM_PROVIDER = "openai"
        mock_settings.OPENAI_API_KEY = "test-openai-key"

        bot = AIBot()

        assert bot.llm is not None
        mock_openai.assert_called_once()

    @patch("bot.ai_bot.Chroma")
    @patch("bot.ai_bot.HuggingFaceEmbeddings")
    @patch("bot.ai_bot.ChatGroq")
    def test_invoke_simple_question(self, mock_groq, mock_embeddings, mock_chroma, mock_settings):
        """Testa invocação com pergunta simples."""
        # Mock do LLM
        mock_llm = Mock()
        mock_llm.invoke.return_value = Mock(content="Resposta do LLM")
        mock_groq.return_value = mock_llm

        # Mock do retriever
        mock_retriever = Mock()
        mock_retriever.invoke.return_value = [
            Mock(page_content="Documento relevante", metadata={}),
        ]
        mock_chroma.return_value.as_retriever.return_value = mock_retriever

        bot = AIBot()
        response = bot.invoke("Qual é o prazo do IPTU?")

        assert "Resposta do LLM" in response
        mock_retriever.invoke.assert_called_once()

    @patch("bot.ai_bot.Chroma")
    @patch("bot.ai_bot.HuggingFaceEmbeddings")
    @patch("bot.ai_bot.ChatGroq")
    def test_invoke_with_history(self, mock_groq, mock_embeddings, mock_chroma, mock_settings):
        """Testa invocação com histórico de conversa."""
        mock_llm = Mock()
        mock_llm.invoke.return_value = Mock(content="Resposta contextualizada")
        mock_groq.return_value = mock_llm

        mock_retriever = Mock()
        mock_retriever.invoke.return_value = []
        mock_chroma.return_value.as_retriever.return_value = mock_retriever

        bot = AIBot()
        history = [
            {"role": "user", "content": "Olá"},
            {"role": "assistant", "content": "Olá! Como posso ajudar?"},
        ]
        response = bot.invoke("E quanto ao IPTU?", history=history)

        assert response is not None
        mock_llm.invoke.assert_called_once()

    @patch("bot.ai_bot.link_router")
    @patch("bot.ai_bot.Chroma")
    @patch("bot.ai_bot.HuggingFaceEmbeddings")
    @patch("bot.ai_bot.ChatGroq")
    def test_invoke_with_menu_keyword(
        self, mock_groq, mock_embeddings, mock_chroma, mock_link_router, mock_settings
    ):
        """Testa invocação com palavra-chave de menu."""
        mock_link_router.route.return_value = "Menu de opções:\n1. IPTU\n2. Certidões"

        bot = AIBot()
        response = bot.invoke("menu")

        assert "Menu de opções" in response
        mock_link_router.route.assert_called_once_with("menu")
