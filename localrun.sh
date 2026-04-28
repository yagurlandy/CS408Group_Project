#!/usr/bin/env bash
set -euo pipefail

PORT=8080

# Kill anything on port 8080
PID=$(lsof -ti :$PORT 2>/dev/null || true)
if [ -n "$PID" ]; then
  echo "Stopping process on port $PORT (PID $PID)..."
  kill -9 $PID
fi

echo "Starting PlanIT on http://localhost:$PORT"
cd "$(dirname "${BASH_SOURCE[0]}")/app"
go run .
