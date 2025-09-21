#!/bin/bash

# This is a wrapper script to ensure proper PATH for VS Code tasks

# Export the full path to LinuxBrew
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

# Run the actual script with all arguments
exec /home/anthony/Documents/Projects/POCs/kind-practice/db-port-forward.sh "$@"
