#!/bin/bash

# Script to manage React development server

# Help message function
show_help() {
    echo "Usage: $0 [start|status|stop]"
    echo ""
    echo "Commands:"
    echo "  start    Start React development server"
    echo "  status   Check if React server is running"
    echo "  stop     Stop React server"
    echo ""
    echo "This script manages the React development server."
}

# Check if React server is running
check_status() {
    PID=$(pgrep -f "react-scripts/scripts/start.js")
    if [ -n "$PID" ]; then
        echo "✅ React development server is running (PID: $PID)"
        echo "   URL: http://localhost:3000"
        return 0
    else
        echo "❌ No React development server running"
        return 1
    fi
}

# Start React server
start_server() {
    # Check if already running
    if check_status > /dev/null; then
        echo "React development server is already running."
        check_status
        return 0
    fi

    echo "Starting React development server..."
    cd AJP.Frontend/ClientApp && npm start &
    
    # Give it a moment to start
    sleep 3
    
    # Check if it started successfully
    if check_status > /dev/null; then
        echo "React development server started successfully."
        return 0
    else
        echo "Failed to start React development server."
        return 1
    fi
}

# Stop React server
stop_server() {
    PID=$(pgrep -f "react-scripts/scripts/start.js")
    if [ -n "$PID" ]; then
        echo "Stopping React development server (PID: $PID)..."
        kill $PID
        sleep 1
        if ! check_status > /dev/null; then
            echo "React development server stopped."
            return 0
        else
            echo "Failed to stop React development server gracefully, trying force kill..."
            kill -9 $PID
            echo "React development server force stopped."
            return 0
        fi
    else
        echo "No React development server running."
        return 1
    fi
}

# Process command line arguments
case "$1" in
    start)
        start_server
        ;;
    status)
        check_status
        ;;
    stop)
        stop_server
        ;;
    help|--help|-h)
        show_help
        ;;
    "")
        # Default action if no arguments provided
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
