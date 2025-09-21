#!/bin/bash

# Create a new migration file with timestamp
create_migration() {
  local migration_name=$1
  if [ -z "$migration_name" ]; then
    echo "Error: Migration name is required"
    echo "Usage: $0 create <migration_name>"
    exit 1
  fi

  # Format migration name to snake_case
  local formatted_name=$(echo "$migration_name" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')
  local timestamp=$(date +%Y%m%d%H%M%S)
  local file_name="V${timestamp}__${formatted_name}.sql"
  local file_path="AJP.Infrastructure.Persistence/Migrations/$file_name"

  echo "-- Migration: $migration_name" > "$file_path"
  echo "-- Created: $(date)" >> "$file_path"
  echo "" >> "$file_path"
  echo "-- Write your SQL migration here" >> "$file_path"
  
  echo "Created migration file: $file_path"
  echo "You can now edit this file to add your migration SQL"
}

# Apply migrations using Flyway through DevSpace
apply_migrations() {
  echo "Applying migrations using DevSpace..."
  devspace run migrate-db
}

# Show migration info
show_info() {
  echo "Showing migration info..."
  FLYWAY_POD=$(kubectl get pods -l app.kubernetes.io/component=flyway -o jsonpath='{.items[0].metadata.name}')
  if [ -z "$FLYWAY_POD" ]; then
    echo "Flyway pod not found. Please make sure the deployment is running."
    exit 1
  fi
  
  kubectl exec $FLYWAY_POD -- flyway -url=jdbc:postgresql://postgres:5432/ajp_db -user=postgres -password=postgres info
}

# Main script execution
case "$1" in
  create)
    create_migration "$2"
    ;;
  apply)
    apply_migrations
    ;;
  info)
    show_info
    ;;
  *)
    echo "Usage: $0 {create|apply|info}"
    echo ""
    echo "  create <migration_name>  Create a new migration file"
    echo "  apply                    Apply all pending migrations"
    echo "  info                     Show migration information"
    exit 1
    ;;
esac

exit 0
