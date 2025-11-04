#!/usr/bin/env bash
set -euo pipefail

DOMAIN=${1:-}
EXPECTED=${2:-}
if [[ -z "$DOMAIN" ]]; then
  echo "usage: $0 <domain> [expected-ip]" >&2
  exit 1
fi

echo "Resolving DNS for $DOMAIN ..."

resolve() {
  local name="$1"
  if command -v getent >/dev/null 2>&1; then
    getent ahostsv4 "$name" | awk '{print $1}' | sort -u
    getent ahostsv6 "$name" | awk '{print $1}' | sort -u
  elif command -v dig >/dev/null 2>&1; then
    dig +short A "$name"
    dig +short AAAA "$name"
  else
    nslookup "$name" 2>/dev/null | awk '/Address: /{print $2}' | tail -n +2
  fi
}

IPS=$(resolve "$DOMAIN" | tr '\n' ' ')
if [[ -z "$IPS" ]]; then
  echo "No A/AAAA records found." >&2
  exit 1
fi
echo "IPs: $IPS"

if [[ -n "$EXPECTED" ]]; then
  if echo "$IPS" | grep -qw "$EXPECTED"; then
    echo "OK: expected IP $EXPECTED found."
    exit 0
  else
    echo "WARN: expected IP $EXPECTED not found in: $IPS" >&2
    exit 2
  fi
fi
exit 0
