#!/bin/sh
# wait-for.sh - Wait for service to be available
# Usage: wait-for.sh host:port [-t timeout] [-- command args]

TIMEOUT=15
QUIET=0

while [ $# -gt 0 ]; do
  case "$1" in
    *:* )
    HOST=$(echo $1 | cut -d: -f1)
    PORT=$(echo $1 | cut -d: -f2)
    shift 1
    ;;
    -t)
    TIMEOUT="$2"
    shift 2
    ;;
    -q)
    QUIET=1
    shift 1
    ;;
    --)
    shift
    break
    ;;
    *)
    echo "Unknown argument: $1"
    exit 1
    ;;
  esac
done

start_ts=$(date +%s)
while :; do
  if nc -z "$HOST" "$PORT" > /dev/null 2>&1; then
    end_ts=$(date +%s)
    [ $QUIET -eq 0 ] && echo "$HOST:$PORT is available after $((end_ts - start_ts)) seconds"
    break
  fi
  
  elapsed=$(($(date +%s) - start_ts))
  if [ $elapsed -ge $TIMEOUT ]; then
    echo "Timeout waiting for $HOST:$PORT"
    exit 1
  fi
  
  sleep 1
done

exec "$@"
