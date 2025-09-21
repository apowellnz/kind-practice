#!/bin/bash

# This script manages port forwarding for the frontend service

# Define variables
KUBECTL=""
PORT=3002
TARGET_PORT=80
SELECTOR="app.kubernetes.io/component=frontend"
ACTION=$1
PID_FILE="$HOME/frontend-port-forward.pid"

# Find kubectl
if command -v kubectl &>/dev/null; then
    KUBECTL="kubectl"
elif [ -f "/home/linuxbrew/.linuxbrew/bin/kubectl" ]; then
    KUBECTL="/home/linuxbrew/.linuxbrew/bin/kubectl"
else
    echo "kubectl command not found. Please install kubectl or add it to your PATH."
    exit 1
fi

# Function to start port forwarding
start_port_forwarding() {
    echo "Starting port forwarding for the frontend service on port $PORT..."
    
    # Check if the port is already in use
    if lsof -i:$PORT -t &>/dev/null; then
        echo "Port $PORT is already in use. Please free the port and try again."
        exit 1
    fi
    
    # Check if pods exist
    POD_COUNT=$($KUBECTL get pods -l $SELECTOR --no-headers | wc -l)
    if [ "$POD_COUNT" -eq 0 ]; then
        echo "No frontend pods found with selector: $SELECTOR"
        echo "Please make sure the frontend deployment is running."
        exit 1
    fi
    
    # Get the pod name
    POD_NAME=$($KUBECTL get pods -l $SELECTOR -o jsonpath='{.items[0].metadata.name}')
    echo "Found frontend pod: $POD_NAME"
    
    # Start port forwarding in the background with nohup to ensure it stays running
    nohup $KUBECTL port-forward pod/$POD_NAME $PORT:$TARGET_PORT > frontend-port-forward.log 2>&1 &
    
    # Save the PID
    echo $! > $PID_FILE
    
    # Wait a moment to ensure port-forwarding is established
    sleep 2
    
    # Check if port-forwarding is actually running
    if ! ps -p $(cat $PID_FILE) > /dev/null; then
        echo "Port forwarding failed to start. Check frontend-port-forward.log for details."
        cat frontend-port-forward.log
        exit 1
    fi
    
    echo "Port forwarding started with PID: $(cat $PID_FILE)"
    echo "Frontend is accessible at http://localhost:$PORT"
    echo "To stop port forwarding, run: $0 stop"
}

# Function to stop port forwarding
stop_port_forwarding() {
    echo "Stopping port forwarding for the frontend service..."
    
    if [ -f $PID_FILE ]; then
        PID=$(cat $PID_FILE)
        
        if ps -p $PID > /dev/null; then
            kill $PID
            echo "Port forwarding stopped (PID: $PID)."
        else
            echo "No active port forwarding process found with PID: $PID"
        fi
        
        rm $PID_FILE
    else
        echo "No port forwarding PID file found at $PID_FILE"
    fi
}

# Main script
case $ACTION in
    start)
        start_port_forwarding
        ;;
    stop)
        stop_port_forwarding
        ;;
    restart)
        stop_port_forwarding
        sleep 2
        start_port_forwarding
        ;;
    status)
        if [ -f $PID_FILE ] && ps -p $(cat $PID_FILE) > /dev/null; then
            echo "Port forwarding is active with PID: $(cat $PID_FILE)"
            echo "Frontend is accessible at http://localhost:$PORT"
        else
            echo "Port forwarding is not running"
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
