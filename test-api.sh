#!/bin/bash

# Test the API endpoints
echo "Testing API endpoints..."

# Get all products
echo -e "\n=== GET /products ==="
curl -s http://localhost:8080/products | jq

# Create a new product
echo -e "\n=== POST /products ==="
curl -s -X POST http://localhost:8080/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Product",
    "description": "A test product created via API",
    "price": 19.99
  }' | jq

# Wait a moment
sleep 1

# Get all products again to see the new one
echo -e "\n=== GET /products (after creation) ==="
curl -s http://localhost:8080/products | jq

# Get product by ID (assuming ID 1 exists)
echo -e "\n=== GET /products/1 ==="
curl -s http://localhost:8080/products/1 | jq

# Update the product
echo -e "\n=== PUT /products/1 ==="
curl -s -X PUT http://localhost:8080/products/1 \
  -H "Content-Type: application/json" \
  -d '{
    "id": 1,
    "name": "Updated Product",
    "description": "This product was updated via API",
    "price": 29.99
  }' | jq

# Get the updated product
echo -e "\n=== GET /products/1 (after update) ==="
curl -s http://localhost:8080/products/1 | jq

echo -e "\nAPI testing complete!"
