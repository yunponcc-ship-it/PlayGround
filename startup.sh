#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
export PROJECT_DIR="$(pwd)"
export OPENCODE_WEB_DIR="/Users/runner/work/_temp/omgithub-web"
export APP_URL="http://127.0.0.1:3000"
export APP_PORT="3000"
mkdir -p "$OPENCODE_WEB_DIR"

/usr/bin/time -p bash -n start.sh
/usr/bin/time -p bash start.sh > "$OPENCODE_WEB_DIR/app.log" 2>&1 &

server_pid=$!
for _ in $(seq 1 30); do
  if curl --silent --fail --max-time 2 "http://127.0.0.1:3000/" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if ! curl --silent --fail --max-time 5 "http://127.0.0.1:3000/" >/dev/null 2>&1; then
  echo "startup verification failed" >&2
  exit 1
fi

wait "$server_pid" || true
