#!/bin/bash

# This script copies migration files from the host to the Flyway container
# Usage: ./copy-migrations.sh

# Set kubectl path explicitly
KUBECTL_CMD="/home/linuxbrew/.linuxbrew/bin/kubectl"

# Find the Flyway pod
FLYWAY_POD=$($KUBECTL_CMD get pods -l app.kubernetes.io/component=flyway -o jsonpath='{.items[0].metadata.name}')

if [ -z "$FLYWAY_POD" ]; then
  echo "Error: Flyway pod not found"
  exit 1
fi

echo "Copying migration files to Flyway pod..."

# Copy all migration files from host to Flyway pod
for file in migrations/*.sql; do
  echo "Copying $file"
  $KUBECTL_CMD cp "$file" "$FLYWAY_POD:/flyway/sql/"
done

echo "Migration files copied successfully!"
