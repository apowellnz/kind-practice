#!/bin/bash

# This script helps switch the React app between pointing to the local API or the Kubernetes API

# Define colors for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if the frontend is running
check_frontend_running() {
  if pgrep -f "npm.*start" > /dev/null; then
    echo -e "${YELLOW}Warning: Frontend is currently running.${NC}"
    echo -e "${YELLOW}Changes will take effect after restarting the frontend.${NC}"
  fi
}

# Function to start the API locally
start_local_api() {
  echo -e "${BLUE}Starting local API...${NC}"
  # First check if PostgreSQL port forwarding is active
  if ! pgrep -f "kubectl port-forward.*postgres" > /dev/null; then
    echo -e "${YELLOW}Setting up PostgreSQL port forwarding...${NC}"
    kubectl port-forward service/postgres 5432:5432 &
    sleep 2
  fi
  
  # Start the API
  echo -e "${GREEN}Starting .NET API locally...${NC}"
  cd "$(dirname "$0")/AJP.API" || exit
  dotnet run &
  echo -e "${GREEN}Local API starting at http://localhost:5000${NC}"
}

# Function to stop the local API
stop_local_api() {
  echo -e "${BLUE}Stopping local API...${NC}"
  pkill -f "dotnet.*AJP.API.dll" || true
  echo -e "${GREEN}Local API stopped${NC}"
}

# Function to start the frontend with specified API URL
start_frontend_with_api() {
  API_URL=$1
  echo -e "${BLUE}Starting frontend pointing to ${API_URL}...${NC}"
  cd "$(dirname "$0")/AJP.Frontend/ClientApp" || exit
  BROWSER=none REACT_APP_API_URL="${API_URL}" npm start &
  echo -e "${GREEN}Frontend starting at http://localhost:3000${NC}"
}

# Function to stop the frontend
stop_frontend() {
  echo -e "${BLUE}Stopping frontend...${NC}"
  pkill -f "node.*react-scripts" || true
  echo -e "${GREEN}Frontend stopped${NC}"
}

# Main menu
show_menu() {
  echo -e "${BLUE}=== API Connection Manager ===${NC}"
  echo -e "${GREEN}1. Switch React to use local API (http://localhost:5000)${NC}"
  echo -e "${GREEN}2. Switch React to use Kubernetes API (http://localhost:31481)${NC}"
  echo -e "${GREEN}3. Start local API${NC}"
  echo -e "${GREEN}4. Stop local API${NC}"
  echo -e "${GREEN}5. Restart frontend with current API setting${NC}"
  echo -e "${RED}6. Exit${NC}"
  echo -e "${BLUE}===========================${NC}"
  echo -n "Enter your choice [1-6]: "
}

# Handle user input
handle_choice() {
  local choice=$1
  case $choice in
    1)
      check_frontend_running
      echo -e "${GREEN}Setting API URL to http://localhost:5000${NC}"
      echo "REACT_APP_API_URL=http://localhost:5000" > "$(dirname "$0")/AJP.Frontend/ClientApp/.env.local"
      echo -e "${YELLOW}You need to restart the frontend for changes to take effect.${NC}"
      ;;
    2)
      check_frontend_running
      echo -e "${GREEN}Setting API URL to http://localhost:31481${NC}"
      echo "REACT_APP_API_URL=http://localhost:31481" > "$(dirname "$0")/AJP.Frontend/ClientApp/.env.local"
      
      # Check if the NodePort service is applied
      if ! kubectl get service api-nodeport &>/dev/null; then
        echo -e "${YELLOW}NodePort service not found. Applying...${NC}"
        kubectl apply -f "$(dirname "$0")/api-nodeport-service.yaml"
      fi
      
      echo -e "${YELLOW}You need to restart the frontend for changes to take effect.${NC}"
      ;;
    3)
      start_local_api
      ;;
    4)
      stop_local_api
      ;;
    5)
      stop_frontend
      API_URL=$(grep REACT_APP_API_URL "$(dirname "$0")/AJP.Frontend/ClientApp/.env.local" 2>/dev/null | cut -d= -f2)
      if [ -z "$API_URL" ]; then
        API_URL="http://localhost:5000"
      fi
      start_frontend_with_api "$API_URL"
      ;;
    6)
      echo -e "${BLUE}Exiting...${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}Invalid choice. Please try again.${NC}"
      ;;
  esac
}

# Main script execution
if [ "$1" == "local" ]; then
  # Quick switch to local API
  echo -e "${GREEN}Setting API URL to http://localhost:5000${NC}"
  echo "REACT_APP_API_URL=http://localhost:5000" > "$(dirname "$0")/AJP.Frontend/ClientApp/.env.local"
  echo -e "${YELLOW}You need to restart the frontend for changes to take effect.${NC}"
elif [ "$1" == "k8s" ]; then
  # Quick switch to Kubernetes API
  echo -e "${GREEN}Setting API URL to http://localhost:31481${NC}"
  echo "REACT_APP_API_URL=http://localhost:31481" > "$(dirname "$0")/AJP.Frontend/ClientApp/.env.local"
  
  # Check if the NodePort service is applied
  if ! kubectl get service api-nodeport &>/dev/null; then
    echo -e "${YELLOW}NodePort service not found. Applying...${NC}"
    kubectl apply -f "$(dirname "$0")/api-nodeport-service.yaml"
  fi
  
  echo -e "${YELLOW}You need to restart the frontend for changes to take effect.${NC}"
else
  # Interactive menu
  show_menu
  read -r choice
  handle_choice "$choice"
fi
