#!/bin/bash

# This is a wrapper script for frontend-port-forward.sh that ensures PATH includes LinuxBrew
# This is needed when running from VS Code tasks

# Add LinuxBrew to PATH if it exists
if [ -d "/home/linuxbrew/.linuxbrew/bin" ]; then
    export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
fi

# Run the actual port forwarding script with the provided arguments
$(dirname "$0")/frontend-port-forward.sh "$@"

# If the start action was requested, check the status after a moment
if [ "$1" = "start" ]; then
    sleep 2
    $(dirname "$0")/frontend-port-forward.sh status
fi
