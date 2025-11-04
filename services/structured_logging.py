"""Configuração de structured logging em JSON."""

import json
import logging
import sys
from datetime import datetime
from typing import Any, Dict


class JSONFormatter(logging.Formatter):
    """Formatter que converte logs para formato JSON estruturado."""

    def format(self, record: logging.LogRecord) -> str:
        """
        Formata o log record como JSON.

        Args:
            record: Record de log a ser formatado.

        Returns:
            String JSON com os dados do log.
        """
        log_data: Dict[str, Any] = {
            "timestamp": datetime.utcfromtimestamp(record.created).isoformat() + "Z",
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
            "line": record.lineno,
        }

        # Adiciona informações de exceção se houver
        if record.exc_info:
            log_data["exception"] = self.formatException(record.exc_info)

        # Adiciona campos extras
        if hasattr(record, "extra_fields"):
            log_data.update(record.extra_fields)

        return json.dumps(log_data, ensure_ascii=False)


def setup_structured_logging(level: str = "INFO") -> None:
    """
    Configura logging estruturado em JSON.

    Args:
        level: Nível de log (DEBUG, INFO, WARNING, ERROR, CRITICAL).
    """
    # Remove handlers existentes
    root_logger = logging.getLogger()
    for handler in root_logger.handlers[:]:
        root_logger.removeHandler(handler)

    # Configura handler com JSON formatter
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(JSONFormatter())

    root_logger.addHandler(handler)
    root_logger.setLevel(getattr(logging, level.upper()))


class StructuredLogger:
    """Logger que facilita o uso de campos estruturados."""

    def __init__(self, name: str):
        """
        Inicializa o logger estruturado.

        Args:
            name: Nome do logger.
        """
        self.logger = logging.getLogger(name)

    def _log(self, level: int, message: str, **kwargs):
        """
        Registra um log com campos extras.

        Args:
            level: Nível do log.
            message: Mensagem do log.
            **kwargs: Campos extras para o log.
        """
        extra = {"extra_fields": kwargs}
        self.logger.log(level, message, extra=extra)

    def debug(self, message: str, **kwargs):
        """Registra log de debug."""
        self._log(logging.DEBUG, message, **kwargs)

    def info(self, message: str, **kwargs):
        """Registra log de info."""
        self._log(logging.INFO, message, **kwargs)

    def warning(self, message: str, **kwargs):
        """Registra log de warning."""
        self._log(logging.WARNING, message, **kwargs)

    def error(self, message: str, **kwargs):
        """Registra log de error."""
        self._log(logging.ERROR, message, **kwargs)

    def critical(self, message: str, **kwargs):
        """Registra log de critical."""
        self._log(logging.CRITICAL, message, **kwargs)
