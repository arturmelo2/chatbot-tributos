"""Configuração centralizada de logging."""

import logging
import os
from typing import Optional

from .config import get_settings


def setup_logging(level: Optional[str] = None) -> None:
    """
    Configura logging raiz com formato consistente.

    Args:
        level: Nível de log (DEBUG, INFO, WARNING, ERROR).
               Se None, usa LOG_LEVEL do env/config.
    """
    settings = get_settings()
    log_level = (level or os.getenv("LOG_LEVEL") or settings.LOG_LEVEL).upper()

    # Evita handlers duplicados se chamado múltiplas vezes
    root = logging.getLogger()
    if root.handlers:
        for h in list(root.handlers):
            root.removeHandler(h)

    logging.basicConfig(
        level=getattr(logging, log_level, logging.INFO),
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )
