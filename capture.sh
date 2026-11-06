#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

start_ts="$(date +%s%3N)"
LOG_DIR="/private/var/folders/n6/hn37q6pj7sj_9dmqqc2113800000gn/T/opencode"
mkdir -p "$LOG_DIR"

if [[ -z "${CAPTURE_URL:-}" || -z "${CAPTURE_DIR:-}" ]]; then
  echo "CAPTURE_URL and CAPTURE_DIR environment variables are required." >&2
  exit 1
fi

mkdir -p "$CAPTURE_DIR"

browser_open=false
cleanup() {
  if [[ "$browser_open" == true ]]; then
    /usr/bin/time -p playwright-cli close >"$LOG_DIR/playwright-close.log" 2>&1 || true
  fi
  finish_ts="$(date +%s%3N)"
  elapsed=$((finish_ts - start_ts))
  echo "capture.sh elapsed_ms=${elapsed}" >&2
}
trap cleanup EXIT

# Try to open a browser session and capture both desktop and mobile renders.
# Exit 75 for temporary navigation/browser infrastructure problems.
# Exit 1 for script or rendering defects.
if ! /usr/bin/time -p playwright-cli open "$CAPTURE_URL" >"$LOG_DIR/playwright-open.log" 2>&1; then
  cat "$LOG_DIR/playwright-open.log" >&2 || true
  echo "Browser open failed; likely temporary infra issue." >&2
  exit 75
fi

browser_open=true

if ! /usr/bin/time -p playwright-cli screenshot --filename "$CAPTURE_DIR/final-desktop.png" >"$LOG_DIR/playwright-screenshot-desktop.log" 2>&1; then
  cat "$LOG_DIR/playwright-screenshot-desktop.log" >&2 || true
  echo "Desktop capture failed." >&2
  exit 1
fi

if ! /usr/bin/time -p playwright-cli resize 390 844 >"$LOG_DIR/playwright-resize.log" 2>&1; then
  cat "$LOG_DIR/playwright-resize.log" >&2 || true
  echo "Viewport resize failed; likely temporary infra issue." >&2
  exit 75
fi

if ! /usr/bin/time -p playwright-cli screenshot --filename "$CAPTURE_DIR/final-mobile.png" >"$LOG_DIR/playwright-screenshot-mobile.log" 2>&1; then
  cat "$LOG_DIR/playwright-screenshot-mobile.log" >&2 || true
  echo "Mobile capture failed." >&2
  exit 1
fi

if [[ ! -s "$CAPTURE_DIR/final-desktop.png" || ! -s "$CAPTURE_DIR/final-mobile.png" ]]; then
  echo "Capture output missing or empty." >&2
  exit 1
fi

exit 0
