"""Configurações centralizadas do aplicativo."""

from __future__ import annotations

from dataclasses import dataclass
from functools import lru_cache
from typing import Optional

from decouple import config as dconfig


@dataclass(frozen=True)
class Settings:
    """Configurações da aplicação com valores padrão."""

    # App
    PORT: int = dconfig("PORT", default=5000, cast=int)
    DEBUG: bool = dconfig("DEBUG", default="false").lower() == "true"
    ENVIRONMENT: str = dconfig("ENVIRONMENT", default="development")

    # LLM
    LLM_PROVIDER: str = dconfig("LLM_PROVIDER", default="groq")
    LLM_MODEL: str = dconfig("LLM_MODEL", default="")
    GROQ_API_KEY: Optional[str] = dconfig("GROQ_API_KEY", default=None)
    OPENAI_API_KEY: Optional[str] = dconfig("OPENAI_API_KEY", default=None)
    XAI_API_KEY: Optional[str] = dconfig("XAI_API_KEY", default=None)

    # Embeddings / RAG
    EMBEDDING_MODEL: str = dconfig(
        "EMBEDDING_MODEL", default="sentence-transformers/all-MiniLM-L6-v2"
    )
    CHROMA_DIR: str = dconfig("CHROMA_DIR", default="/app/chroma_data")

    # WAHA
    WAHA_API_URL: str = dconfig("WAHA_API_URL", default="http://waha:3000")
    WAHA_API_KEY: Optional[str] = dconfig("WAHA_API_KEY", default=None)
    WAHA_TIMEOUT: float = float(dconfig("WAHA_TIMEOUT", default=10))

    # Link router
    FLOW_JSON_PATH: str = dconfig("FLOW_JSON_PATH", default="fluxo_novatrento.json")

    # Logging
    LOG_LEVEL: str = dconfig("LOG_LEVEL", default="INFO")


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Retorna instância cached de Settings para reuso."""
    return Settings()
