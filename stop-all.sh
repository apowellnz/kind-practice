#!/bin/bash

echo "Stopping all port forwarding services..."

# Stop API port forwarding
if [ -f "$HOME/api-port-forward.pid" ]; then
    API_PID=$(cat "$HOME/api-port-forward.pid")
    if ps -p $API_PID > /dev/null; then
        echo "Stopping API port forwarding (PID: $API_PID)..."
        kill $API_PID
    fi
    rm "$HOME/api-port-forward.pid"
fi

# Stop database port forwarding
if [ -f "$HOME/db-port-forward.pid" ]; then
    DB_PID=$(cat "$HOME/db-port-forward.pid")
    if ps -p $DB_PID > /dev/null; then
        echo "Stopping database port forwarding (PID: $DB_PID)..."
        kill $DB_PID
    fi
    rm "$HOME/db-port-forward.pid"
fi

# Stop frontend port forwarding
if [ -f "$HOME/frontend-port-forward.pid" ]; then
    FRONTEND_PID=$(cat "$HOME/frontend-port-forward.pid")
    if ps -p $FRONTEND_PID > /dev/null; then
        echo "Stopping frontend port forwarding (PID: $FRONTEND_PID)..."
        kill $FRONTEND_PID
    fi
    rm "$HOME/frontend-port-forward.pid"
fi

# Stop devspace dev
DEVSPACE_PIDS=$(ps aux | grep "devspace dev" | grep -v grep | awk '{print $2}')
if [ ! -z "$DEVSPACE_PIDS" ]; then
    echo "Stopping DevSpace processes..."
    for PID in $DEVSPACE_PIDS; do
        echo "Killing DevSpace process (PID: $PID)..."
        kill $PID
    done
fi

echo "All port forwarding services have been stopped."
