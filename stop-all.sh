#!/bin/bash
# stop-all.sh - Stops all port forwarding and related processes

echo "===== Stopping All Services ====="

# Stop API port forwarding
echo "Stopping API port forwarding..."
if [ -f "./api-port-forward.sh" ]; then
    ./api-port-forward.sh stop
fi

# Stop DB port forwarding
echo "Stopping DB port forwarding..."
if [ -f "./db-port-forward.sh" ]; then
    ./db-port-forward.sh stop
fi

# Stop Frontend port forwarding
echo "Stopping Frontend port forwarding..."
if [ -f "./frontend-port-forward.sh" ]; then
    ./frontend-port-forward.sh stop
fi

# Cleanup React development server if running locally
echo "Cleaning up frontend React processes..."
pkill -f "react-scripts/scripts/start.js" || true

# Kill devspace process if running
echo "Stopping DevSpace processes..."
DEVSPACE_PIDS=$(ps aux | grep "devspace dev" | grep -v grep | awk '{print $2}')
if [ ! -z "$DEVSPACE_PIDS" ]; then
    for PID in $DEVSPACE_PIDS; do
        echo "Killing DevSpace process (PID: $PID)..."
        kill $PID
    done
fi

echo "===== All Services Stopped ====="
