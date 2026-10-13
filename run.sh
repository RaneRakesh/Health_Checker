#!/usr/bin/env bash
set -e

# Determine script root directory
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

# Configuration
BACKEND_PORT="${BACKEND_PORT:-8001}"
WEB_PORT="${WEB_PORT:-8080}"
DEVICE="${1:-web-server}"

echo "===================================================="
echo " Starting Health Assistant Project"
echo " Backend Port : $BACKEND_PORT"
echo " Web Port     : $WEB_PORT"
echo " Target Device: $DEVICE"
echo "===================================================="

# Helper function to kill existing processes occupying a port
kill_port() {
  local port=$1
  local pids
  pids=$(lsof -ti :"$port" 2>/dev/null || true)
  if [ -n "$pids" ]; then
    echo "⚠️  Port $port is currently in use by PID(s): $pids. Stopping them..."
    for pid in $pids; do
      kill -9 "$pid" 2>/dev/null || true
    done
    sleep 1
  fi
}

# 1. Clean up ports before starting
kill_port "$BACKEND_PORT"
if [ "$DEVICE" = "web-server" ]; then
  kill_port "$WEB_PORT"
fi

# 2. Select Python executable
PYTHON_BIN="python3"
if [ -d "$ROOT_DIR/backend/venv" ] && [ -x "$ROOT_DIR/backend/venv/bin/python3" ]; then
  PYTHON_BIN="$ROOT_DIR/backend/venv/bin/python3"
elif [ -d "$ROOT_DIR/venv" ] && [ -x "$ROOT_DIR/venv/bin/python3" ]; then
  PYTHON_BIN="$ROOT_DIR/venv/bin/python3"
fi

# Verify Python dependencies
if ! $PYTHON_BIN -c "import fastapi, uvicorn, pydantic" 2>/dev/null; then
  echo "📦 Installing required Python dependencies..."
  $PYTHON_BIN -m pip install -r "$ROOT_DIR/backend/requirements.txt"
fi

# 3. Start Python FastAPI backend in the background
echo "🚀 Starting FastAPI backend on port $BACKEND_PORT..."
$PYTHON_BIN "$ROOT_DIR/backend/main.py" "$BACKEND_PORT" &
BACKEND_PID=$!

# Trap signals for graceful shutdown
cleanup() {
  echo ""
  echo "🛑 Shutting down Health Assistant services..."
  if [ -n "$BACKEND_PID" ] && kill -0 "$BACKEND_PID" 2>/dev/null; then
    echo "Stopping backend (PID $BACKEND_PID)..."
    kill "$BACKEND_PID" 2>/dev/null || true
  fi
  echo "✅ Shutdown complete."
}
trap cleanup INT TERM EXIT

# 4. Wait for backend to be healthy
echo "⏳ Waiting for backend to start up..."
READY=0
for i in {1..20}; do
  if curl -s "http://localhost:$BACKEND_PORT/" >/dev/null 2>&1 || curl -s "http://localhost:$BACKEND_PORT/docs" >/dev/null 2>&1; then
    READY=1
    break
  fi
  sleep 0.5
done

if [ $READY -eq 1 ]; then
  echo "✅ Backend is healthy at http://localhost:$BACKEND_PORT"
  echo "📖 API documentation: http://localhost:$BACKEND_PORT/docs"
else
  echo "⚠️  Backend did not report ready in time, continuing with Flutter launch..."
fi

# 5. Launch Flutter application
echo "📱 Launching Flutter client on device: $DEVICE..."

if [ "$DEVICE" = "web-server" ]; then
  echo "🌐 Flutter Web app will be accessible at: http://localhost:$WEB_PORT"
  flutter run -d web-server --no-dds --web-port "$WEB_PORT" --web-hostname 0.0.0.0 --dart-define=BACKEND_PORT="$BACKEND_PORT"
else
  flutter run -d "$DEVICE" --web-port "$WEB_PORT" --dart-define=BACKEND_PORT="$BACKEND_PORT"
fi
