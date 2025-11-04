"""
Exporta histórico de conversas do WAHA para arquivo JSONL.

Uso:
    python tools/export_waha_history.py --months 6 --out /app/exports/history.jsonl
    python tools/export_waha_history.py --months 12 --include-groups
"""

import argparse
import json
import os
import sys
from datetime import datetime, timezone
from typing import Any, Dict

from dateutil.relativedelta import relativedelta  # type: ignore[import-not-found]

# Ensure we can import the local services package when running in container
sys.path.append("/app")

from services.waha import Waha


def epoch(dt: datetime) -> int:
    return int(dt.replace(tzinfo=timezone.utc).timestamp())


def export_history(
    months: int, out_path: str, chats_limit: int, msgs_limit: int, include_groups: bool
) -> Dict[str, Any]:
    """
    Exporta mensagens dos últimos N meses para um arquivo JSONL.
    Cada linha é um JSON com campos mínimos úteis: chatId, timestamp, from, to, fromMe, body, id.
    """
    w = Waha()
    cutoff_dt = datetime.now(timezone.utc) - relativedelta(months=months)
    cutoff_ts = epoch(cutoff_dt)

    chats = w.list_chats(limit=chats_limit)
    total_chats = 0
    total_msgs = 0

    os.makedirs(os.path.dirname(out_path), exist_ok=True)

    with open(out_path, "w", encoding="utf-8") as f:
        for c in chats or []:
            chat_id = None
            # Extrai id serializado do chat
            try:
                cid = c.get("id") or {}
                if isinstance(cid, dict):
                    chat_id = cid.get("_serialized")
                elif isinstance(cid, str):
                    chat_id = cid
            except Exception:
                chat_id = None

            if not chat_id:
                continue

            # Filtra grupos se necessário
            if not include_groups and chat_id.endswith("@g.us"):
                continue

            total_chats += 1

            # Busca mensagens (brutas)
            msgs = w.get_messages(chat_id=chat_id, limit=msgs_limit, download_media=False)

            for m in msgs or []:
                ts = int(m.get("timestamp") or m.get("_data", {}).get("t") or 0)
                if ts < cutoff_ts:
                    continue
                rec = {
                    "chatId": chat_id,
                    "id": m.get("id"),
                    "timestampEpoch": ts,
                    "timestampISO": datetime.fromtimestamp(ts, tz=timezone.utc).isoformat(),
                    "from": m.get("from"),
                    "to": m.get("to"),
                    "fromMe": m.get("fromMe"),
                    "body": m.get("body"),
                    "hasMedia": m.get("hasMedia", False),
                    "ack": m.get("ack"),
                    "type": m.get("type") or m.get("_data", {}).get("type"),
                }
                f.write(json.dumps(rec, ensure_ascii=False) + "\n")
                total_msgs += 1

    return {
        "out_path": out_path,
        "months": months,
        "cutoff_dt": cutoff_dt.isoformat(),
        "total_chats_processed": total_chats,
        "total_msgs_written": total_msgs,
    }


def main():
    parser = argparse.ArgumentParser(
        description="Exportar histórico WAHA (últimos N meses) para JSONL"
    )
    parser.add_argument(
        "--months", type=int, default=6, help="Número de meses a exportar (default: 6)"
    )
    parser.add_argument(
        "--out",
        type=str,
        default="",
        help="Caminho de saída (default: /app/exports/waha_history_<ts>.jsonl)",
    )
    parser.add_argument(
        "--chats-limit", type=int, default=1000, help="Limite de chats a listar (default: 1000)"
    )
    parser.add_argument(
        "--msgs-limit", type=int, default=5000, help="Limite de mensagens por chat (default: 5000)"
    )
    parser.add_argument(
        "--include-groups",
        action="store_true",
        help="Incluir grupos (@g.us). Por padrão, são ignorados.",
    )

    args = parser.parse_args()

    if not args.out:
        ts = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
        out = f"/app/exports/waha_history_{ts}.jsonl"
    else:
        out = args.out

    info = export_history(
        months=args.months,
        out_path=out,
        chats_limit=args.chats_limit,
        msgs_limit=args.msgs_limit,
        include_groups=args.include_groups,
    )

    print(json.dumps({"status": "ok", **info}, ensure_ascii=False))


if __name__ == "__main__":
    main()
