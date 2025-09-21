#!/bin/bash

# Exit on error
set -e

echo "🔨 Building solution..."
dotnet build

echo "🧪 Running unit tests..."
dotnet test

if [ $? -eq 0 ]; then
    echo "✅ Build and tests completed successfully"
else
    echo "❌ Tests failed!"
    exit 1
fi
