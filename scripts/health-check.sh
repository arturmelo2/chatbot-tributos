#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${1:-}"
if [[ -z "$DOMAIN" ]]; then
  echo "usage: $0 <domain>" >&2
  exit 1
fi

echo "Health check in https://$DOMAIN ..."

check() {
  local url="$1"
  if curl -fsS --max-time 10 "$url" >/dev/null; then
    echo "OK: $url"
  else
    echo "FAIL: $url" >&2
    return 1
  fi
}

rc=0
check "https://$DOMAIN/api/health" || rc=1
check "https://$DOMAIN/waha"       || true
check "https://$DOMAIN/n8n"        || true
exit $rc
