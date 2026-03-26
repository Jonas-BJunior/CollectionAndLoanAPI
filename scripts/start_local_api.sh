#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

export PATH="/opt/homebrew/bin:$PATH"

PORT="${PORT:-3000}"
HOST="${HOST:-127.0.0.1}"
EMAIL="${API_EMAIL:-jonas@example.com}"
PASSWORD="${API_PASSWORD:-123456}"
NAME="${API_NAME:-Jonas}"
PID_FILE="tmp/pids/dev_server.pid"
LOG_FILE="tmp/dev_server.log"

mkdir -p tmp/pids tmp

echo "[1/6] Starting PostgreSQL service..."
brew services start postgresql@16 >/dev/null || true

echo "[2/6] Installing gems (if needed)..."
bundle install >/dev/null

echo "[3/6] Preparing database..."
bin/rails db:prepare >/dev/null

echo "[4/6] Starting Rails API on http://$HOST:$PORT ..."
if [[ -f "$PID_FILE" ]] && ps -p "$(cat "$PID_FILE")" >/dev/null 2>&1; then
  echo "Rails is already running with PID $(cat "$PID_FILE")"
else
  rm -f "$PID_FILE"
  nohup bin/rails server -b "$HOST" -p "$PORT" > "$LOG_FILE" 2>&1 &
  echo $! > "$PID_FILE"
fi

echo "[5/6] Waiting for API health endpoint..."
for i in {1..30}; do
  if curl -sS "http://$HOST:$PORT/up" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if ! curl -sS "http://$HOST:$PORT/up" >/dev/null 2>&1; then
  echo "API did not start correctly. Check log: $LOG_FILE"
  exit 1
fi

echo "[6/6] Registering user (idempotent) and logging in..."
REGISTER_RESPONSE=$(curl -sS -X POST "http://$HOST:$PORT/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"user\":{\"name\":\"$NAME\",\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\",\"password_confirmation\":\"$PASSWORD\"}}") || true

LOGIN_RESPONSE=$(curl -sS -X POST "http://$HOST:$PORT/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")

TOKEN=$(ruby -rjson -e 'data = JSON.parse(STDIN.read) rescue {}; puts(data["token"].to_s)' <<< "$LOGIN_RESPONSE")

if [[ -z "$TOKEN" ]]; then
  echo "Could not authenticate. Login response:"
  echo "$LOGIN_RESPONSE"
  exit 1
fi

echo

echo "API running at: http://$HOST:$PORT"
echo "Postgres service: started"
echo "User email: $EMAIL"
echo "JWT token:"
echo "$TOKEN"
echo

echo "Quick test with token:"
echo "curl -sS http://$HOST:$PORT/api/v1/auth/me -H \"Authorization: Bearer $TOKEN\""
echo

echo "To stop the API server:"
echo "kill $(cat "$PID_FILE")"
