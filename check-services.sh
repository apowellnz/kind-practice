#!/bin/bash

# Script to check all relevant services and ports

echo "Checking services and ports..."
echo ""

# Check API ports
echo "=== API Ports ==="
PORTS=("5000" "7188" "31481")
for PORT in "${PORTS[@]}"; do
    if nc -z localhost $PORT 2>/dev/null; then
        echo "✅ Port $PORT is OPEN ($(curl -s http://localhost:$PORT/health 2>/dev/null || echo "No health endpoint"))"
    else
        echo "❌ Port $PORT is CLOSED"
    fi
done
echo ""

# Check React port
echo "=== React App ==="
if nc -z localhost 3000 2>/dev/null; then
    echo "✅ React app is running on port 3000"
else
    echo "❌ React app is not running on port 3000"
fi
echo ""

echo "=== API Port Forwarding ==="
if nc -z localhost 31481 2>/dev/null; then
    echo "✅ API port forwarding active on port 31481"
    
    # Get the PID of the port forwarding process
    PF_PID=$(pgrep -f "kubectl port-forward svc/api-nodeport 31481:80")
    if [ -n "$PF_PID" ]; then
        echo "   Port forwarding process: PID $PF_PID"
    else
        echo "   Warning: Port is open but no kubectl port-forward process found"
    fi

    # Check if API is responding
    HEALTH=$(curl -s http://localhost:31481/health 2>/dev/null)
    if [ -n "$HEALTH" ]; then
        echo "   API response: $HEALTH"
    else
        echo "   Warning: API not responding to health check"
    fi
else
    echo "❌ API port forwarding not active on port 31481"
fi
echo ""

# Check database port forwarding
echo "=== Database Port Forwarding ==="
if nc -z localhost 5432 2>/dev/null; then
    echo "✅ PostgreSQL port forwarding active on port 5432"
    
    # Get the PID of the port forwarding process
    PF_PID=$(pgrep -f "kubectl port-forward svc/postgres 5432:5432")
    if [ -n "$PF_PID" ]; then
        echo "   Port forwarding process: PID $PF_PID"
    else
        echo "   Warning: Port is open but no kubectl port-forward process found"
    fi
else
    echo "❌ PostgreSQL port forwarding not active on port 5432"
fi
echo ""

# Check Kubernetes services
echo "=== Kubernetes Services ==="
if command -v kubectl &>/dev/null; then
    echo "API service:"
    kubectl get service api-nodeport -o wide 2>/dev/null || echo "❌ api-nodeport service not found"
    echo ""
    echo "PostgreSQL service:"
    kubectl get service postgres -o wide 2>/dev/null || echo "❌ postgres service not found"
else
    echo "❌ kubectl not found, can't check Kubernetes services"
fi
echo ""

echo "=== Running Processes ==="
echo "React process:"
pgrep -f "react-scripts/scripts/start.js" || echo "❌ No React process found"
echo ""
echo "API process:"
pgrep -f "AJP.API.dll" || echo "❌ No API process found"
echo ""

echo "Done."
