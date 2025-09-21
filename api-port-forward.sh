#!/bin/bash

# Script to manage API port-forwarding from Kubernetes

# DIRECT HARDCODED PATH - specific to this environment
KUBECTL_CMD="/home/linuxbrew/.linuxbrew/bin/kubectl"

# Print debug info
echo "DEBUG: Current PATH: $PATH"
echo "Using kubectl from: $KUBECTL_CMD"

# Default port
LOCAL_PORT=31481
REMOTE_PORT=80
SERVICE_NAME="api-nodeport"

# Skip the fancy detection since we have hardcoded the path
if [ ! -x "$KUBECTL_CMD" ]; then
    echo "Error: kubectl not found at $KUBECTL_CMD"
    echo "Please modify this script to point to the correct kubectl location."
    exit 1
fi

echo "Using kubectl: $KUBECTL_CMD"

echo "Using kubectl: $KUBECTL_CMD"

# Help message function
show_help() {
    echo "Usage: $0 [start|status|stop]"
    echo ""
    echo "Commands:"
    echo "  start    Start port forwarding (default if no command specified)"
    echo "  status   Check if port forwarding is active"
    echo "  stop     Stop port forwarding"
    echo ""
    echo "This script manages port forwarding for the API running in Kubernetes."
    echo "It creates a connection from localhost:$LOCAL_PORT to the $SERVICE_NAME service on port $REMOTE_PORT."
}

# Check if port forwarding is already running
check_status() {
    PID=$(pgrep -f "$KUBECTL_CMD port-forward svc/$SERVICE_NAME $LOCAL_PORT:$REMOTE_PORT")
    if [ -n "$PID" ]; then
        echo "✅ API port forwarding is active (PID: $PID)"
        echo "   Connection: localhost:$LOCAL_PORT → $SERVICE_NAME:$REMOTE_PORT"
        return 0
    else
        echo "❌ No active port forwarding for $SERVICE_NAME"
        return 1
    fi
}

# Check if service exists or create it if not
ensure_service() {
    if ! $KUBECTL_CMD get service $SERVICE_NAME > /dev/null 2>&1; then
        echo "Service '$SERVICE_NAME' not found, creating it..."
        $KUBECTL_CMD apply -f - << EOF
apiVersion: v1
kind: Service
metadata:
  name: api-nodeport
  labels:
    app.kubernetes.io/component: api
spec:
  selector:
    app.kubernetes.io/component: api
  ports:
  - port: 80
    targetPort: 80
    nodePort: 31481
  type: NodePort
EOF
        
        # Verify it was created
        if ! $KUBECTL_CMD get service $SERVICE_NAME > /dev/null 2>&1; then
            echo "Error: Failed to create service '$SERVICE_NAME'."
            return 1
        fi
        
        echo "Service '$SERVICE_NAME' created successfully."
    else
        echo "Service '$SERVICE_NAME' already exists."
    fi
    
    return 0
}

# Start port forwarding
start_port_forward() {
    # Check if already running
    if check_status > /dev/null; then
        echo "API port forwarding is already active."
        check_status
        return 0
    fi

    # Ensure service exists
    if ! ensure_service; then
        echo "Error: Could not ensure API NodePort service exists."
        return 1
    fi

    # Start port forwarding in the background
    echo "Starting API port forwarding in the background..."
    nohup $KUBECTL_CMD port-forward svc/$SERVICE_NAME $LOCAL_PORT:$REMOTE_PORT > /tmp/api-port-forward.log 2>&1 &
    
    # Give it a moment to establish
    sleep 2
    
    # Check if it started successfully
    if check_status > /dev/null; then
        echo "API port forwarding started successfully."
        echo "API is accessible at: http://localhost:$LOCAL_PORT"
        
        # Check if API is responding
        if curl -s http://localhost:$LOCAL_PORT/health > /dev/null 2>&1; then
            echo "✅ API health check passed."
        else
            echo "⚠️  API not responding to health check. It may still be starting up."
        fi
        
        return 0
    else
        echo "Failed to start API port forwarding. Check /tmp/api-port-forward.log for details."
        return 1
    fi
}

# Stop port forwarding
stop_port_forward() {
    PID=$(pgrep -f "$KUBECTL_CMD port-forward svc/$SERVICE_NAME $LOCAL_PORT:$REMOTE_PORT")
    if [ -n "$PID" ]; then
        echo "Stopping API port forwarding (PID: $PID)..."
        kill $PID
        echo "API port forwarding stopped."
        return 0
    else
        echo "No active API port forwarding to stop."
        return 1
    fi
}

# Process command line arguments
case "$1" in
    start)
        start_port_forward
        ;;
    status)
        check_status
        ;;
    stop)
        stop_port_forward
        ;;
    help|--help|-h)
        show_help
        ;;
    "")
        # Default action if no arguments provided
        start_port_forward
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
