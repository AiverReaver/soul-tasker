#!/usr/bin/env bash
# The Stage 7 scripted gate (plan step 11): starts PostgreSQL in Docker and
# the real server on a free port, runs the app's tagged two-device test
# against it, and stops what it started. Needs Docker, Node and Flutter.
set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
log="$(mktemp)"
server_pid=""
started_db=0

cleanup() {
  if [ -n "$server_pid" ]; then kill "$server_pid" 2>/dev/null || true; wait "$server_pid" 2>/dev/null || true; fi
  if [ "$started_db" = 1 ]; then (cd "$root/server" && docker compose down >/dev/null 2>&1) || true; fi
  rm -f "$log"
}
trap cleanup EXIT

cd "$root/server"
if ! docker compose ps --status running --services 2>/dev/null | grep -q '^db$'; then
  docker compose up -d --wait
  started_db=1
fi

node --import tsx test/gate_server.ts >"$log" 2>"$log.err" &
server_pid=$!

# The server prints one JSON line when it is listening.
for _ in $(seq 1 100); do
  if grep -q '"url"' "$log" 2>/dev/null; then break; fi
  if ! kill -0 "$server_pid" 2>/dev/null; then cat "$log.err" >&2; echo "gate server died" >&2; exit 1; fi
  sleep 0.2
done
grep -q '"url"' "$log" || { echo "gate server did not start" >&2; exit 1; }

url="$(node -e 'const l=require("fs").readFileSync(process.argv[1],"utf8").split("\n").find(x=>x.includes("\"url\""));console.log(JSON.parse(l).url)' "$log")"
tokens="$(node -e 'const l=require("fs").readFileSync(process.argv[1],"utf8").split("\n").find(x=>x.includes("\"url\""));console.log(JSON.parse(l).tokens.join(","))' "$log")"

cd "$root/app"
GATE_BASE_URL="$url" GATE_ID_TOKENS="$tokens" flutter test test/gate_stage7_test.dart --tags sync-gate --reporter expanded
rm -f "$log.err"
