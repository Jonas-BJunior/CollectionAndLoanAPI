#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

PID_FILE="tmp/pids/dev_server.pid"
PORT="${PORT:-3000}"

stop_pid() {
  local pid="$1"
  if ps -p "$pid" >/dev/null 2>&1; then
    kill "$pid" || true
    sleep 1

    if ps -p "$pid" >/dev/null 2>&1; then
      echo "Process $pid did not stop gracefully. Forcing..."
      kill -9 "$pid" || true
      sleep 1
    fi

    if ps -p "$pid" >/dev/null 2>&1; then
      echo "Could not stop process $pid"
      return 1
    fi

    echo "Stopped API process $pid"
    return 0
  fi

  return 1
}

stopped=false

if [[ -f "$PID_FILE" ]]; then
  pid_from_file="$(cat "$PID_FILE" || true)"
  if [[ -n "${pid_from_file:-}" ]]; then
    if stop_pid "$pid_from_file"; then
      stopped=true
    fi
  fi
  rm -f "$PID_FILE"
fi

if [[ "$stopped" == false ]]; then
  # Fallback: find listener on configured port (usually 3000)
  pids_on_port="$(lsof -tiTCP:$PORT -sTCP:LISTEN || true)"
  if [[ -n "$pids_on_port" ]]; then
    for pid in $pids_on_port; do
      stop_pid "$pid" || true
      stopped=true
    done
  fi
fi

if [[ "$stopped" == true ]]; then
  echo "API stopped successfully."
else
  echo "No running API process found."
fi
