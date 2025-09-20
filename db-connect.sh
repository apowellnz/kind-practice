#!/bin/bash

# Get the postgres pod name
POSTGRES_POD=$(kubectl get pods -l app.kubernetes.io/component=postgres -o jsonpath='{.items[0].metadata.name}')

if [ -z "$POSTGRES_POD" ]; then
    echo "Error: PostgreSQL pod not found. Make sure the deployment is running."
    exit 1
fi

# Check if an argument was provided
if [ $# -eq 0 ]; then
    # No argument, start interactive psql session
    echo "Starting interactive psql session..."
    kubectl exec -it "$POSTGRES_POD" -- psql -U postgres -d ajp_db
else
    # Argument provided, run it as a SQL command
    echo "Executing SQL command..."
    kubectl exec -it "$POSTGRES_POD" -- psql -U postgres -d ajp_db -c "$1"
fi

echo "Done."
