# Development Workflow

This project supports two main development workflows to keep things simple:

## 1. Local Frontend & API Development

This workflow is ideal for day-to-day development of both frontend and API code. It runs:
- PostgreSQL in Kubernetes (for data persistence)
- .NET API locally (for quick debugging)
- React frontend locally (with hot reload)

### How to Start:
1. In VS Code, open the **Run and Debug** panel
2. Select **Local Development** from the dropdown
3. Click the Play button to start everything

Or use individual tasks:
- `db-port-forward-start`: Starts database port forwarding (5433 -> Kubernetes PostgreSQL)
- `build-api`: Builds the .NET API
- `start-frontend`: Starts the React development server with hot reload

### Accessing Services:
- API: http://localhost:5000
- Frontend: http://localhost:3000
- Database: localhost:5433 (PostgreSQL)

### To Stop:
- Press Ctrl+C in the terminal or use the Stop button in VS Code
- Run the `stop-all-services` task to clean up all port forwarding

## 2. Full Kubernetes Deployment

This workflow deploys and runs everything in Kubernetes, which is ideal for:
- Testing the complete system as it would run in production
- Verifying configuration and deployment settings
- Testing Kubernetes-specific functionality

### How to Start:
1. In VS Code, open the **Run and Debug** panel
2. Select **Kubernetes Development** from the dropdown
3. Click the Play button to start everything

Or use the `start-kubernetes-dev` task which:
1. Starts DevSpace deployment
2. Sets up API port forwarding (31481)
3. Sets up DB port forwarding (5433)
4. Sets up Frontend port forwarding (3002)

### Accessing Services:
- API: http://localhost:31481
- Frontend: http://localhost:3002
- Database: localhost:5433 (PostgreSQL)

### To Stop:
- Press Ctrl+C in the terminal or use the Stop button in VS Code
- Run the `stop-all-services` task to clean up all port forwarding

## Script Reference

| Script | Purpose |
|--------|---------|
| `api-port-forward.sh` | Manages port forwarding for the API service |
| `db-port-forward.sh` | Manages port forwarding for the PostgreSQL database |
| `frontend-port-forward.sh` | Manages port forwarding for the frontend service |
| `stop-all.sh` | Stops all port forwarding and related processes |
| `build-and-test.sh` | Builds the API and runs unit tests |

## Task Reference

| Task Category | Task Name | Description |
|---------------|-----------|-------------|
| **Build & Test** | `build-api` | Builds the .NET API |
| | `test` | Runs unit tests |
| | `build-and-test` | Builds API and runs tests |
| | `publish-api` | Publishes API for deployment |
| **Database** | `run-migrations` | Runs database migrations |
| | `create-migration` | Creates a new migration |
| | `db-info` | Shows database info |
| | `db-port-forward-start` | Starts database port forwarding |
| **API** | `api-port-forward-start` | Starts API port forwarding |
| **Frontend** | `start-frontend` | Starts the React frontend locally |
| | `frontend-port-forward-start` | Starts frontend port forwarding |
| **DevSpace** | `devspace-dev` | Runs DevSpace deployment |
| **Workflows** | `start-local-dev` | Starts local development environment |
| | `start-kubernetes-dev` | Starts full Kubernetes deployment |
| | `stop-all-services` | Stops all services and port forwarding |
