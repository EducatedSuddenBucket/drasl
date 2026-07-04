#!/bin/sh
set -e

REMOTE="hf://buckets/${HF_BUCKET}"
LOCAL="/var/lib/drasl"
INTERVAL="${SYNC_INTERVAL:-90}"
DB="$LOCAL/drasl.db"

mkdir -p "$LOCAL"

echo "Restoring state from $REMOTE ..."
hf sync "$REMOTE" "$LOCAL" || echo "No existing bucket data — starting fresh"

sync_up() {
  if [ -f "$DB" ]; then
    sqlite3 "$DB" "PRAGMA wal_checkpoint(TRUNCATE);" 2>/dev/null || true
  fi
  hf sync "$LOCAL" "$REMOTE" --delete --quiet 2>&1 || echo "sync failed, will retry next interval"
}

sync_loop() {
  while true; do
    sleep "$INTERVAL"
    sync_up
  done
}

sync_loop &
SYNC_PID=$!

term_handler() {
  echo "Shutting down — final sync..."
  sync_up
  kill "$SYNC_PID" 2>/dev/null
  kill "$DRASL_PID" 2>/dev/null
  wait "$DRASL_PID" 2>/dev/null
  exit 0
}
trap term_handler TERM INT

drasl &
DRASL_PID=$!
wait "$DRASL_PID"
