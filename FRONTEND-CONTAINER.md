# Containerized Frontend Documentation

This document provides details on the containerized React frontend setup for the AJP project.

## Overview

The frontend can be run in two different ways:
1. **Local Development**: Using `npm start` in the `AJP.Frontend/ClientApp` directory (port 3000)
2. **Containerized**: Running in a Docker container inside Kubernetes (port 3002)

Both methods communicate with the same API endpoint.

## Containerized Frontend

### Architecture

- **Docker Image**: `ajp-frontend` based on `Dockerfile.frontend`
- **Base Image**: Multi-stage build using Node.js for building and Nginx for serving
- **Kubernetes Deployment**: Managed through DevSpace in `frontend-deployment.yaml`
- **Network**: Exposed via port forwarding on port 3002
- **Configuration**: Environment variables set in `.env.production`

### Files

- **Dockerfile.frontend**: Multi-stage build for compiling React app and serving with Nginx
- **nginx.conf**: Nginx configuration for serving the static React application
- **frontend-deployment.yaml**: Kubernetes deployment manifest
- **frontend-port-forward.sh**: Script to manage port forwarding
- **.env.production**: Environment configuration for production builds

### Environment Configuration

The frontend uses environment variables to determine the API endpoint:
- Development: `REACT_APP_API_URL` in `.env.local` or `.env.development`
- Production: `REACT_APP_API_URL` in `.env.production`

Current API endpoint in production: `http://localhost:31481`

### Starting the Containerized Frontend

You can use the following methods to start the containerized frontend:

1. **Port forwarding script**:
   ```bash
   ./frontend-port-forward.sh start
   ```

2. **VS Code task**:
   ```
   Ctrl+Shift+P > Tasks: Run Task > start-kubernetes-dev
   ```

This will start the necessary components and forward port 3002 to the frontend service.

### Accessing the Frontend

- **Containerized**: http://localhost:3002
- **Local Development**: http://localhost:3000

Both versions of the frontend connect to the same API (http://localhost:31481).

## Development Workflow

### Building the Frontend Container

To rebuild the frontend container after making changes:

```bash
devspace run build-frontend
devspace run deploy-frontend
./frontend-port-forward.sh restart
```

### Stopping All Services

To stop all port forwarding and development services:

```bash
./stop-all.sh
```

## Troubleshooting

### Cannot Access Frontend

If you cannot access the frontend at http://localhost:3002:

1. Check if port forwarding is active:
   ```bash
   ./frontend-port-forward.sh status
   ```

2. If it's not active, restart it:
   ```bash
   ./frontend-port-forward.sh restart
   ```

3. If port 3002 is in use by another process, edit `frontend-port-forward.sh` to use a different port.

### API Connection Issues

If the frontend can't connect to the API:

1. Verify API is running:
   ```bash
   curl http://localhost:31481/health
   ```

2. Check the frontend environment configuration:
   ```bash
   cat AJP.Frontend/ClientApp/.env.production
   ```

3. Rebuild and redeploy the frontend if needed:
   ```bash
   devspace run build-frontend
   devspace run deploy-frontend
   ```

## CORS Issues

If you experience CORS errors:

1. Verify the API's CORS configuration includes both frontend origins:
   - `http://localhost:3000` (local development)
   - `http://localhost:3002` (containerized)

2. Check browser console for specific CORS error details

3. Restart the API to apply CORS configuration changes:
   ```bash
   kubectl rollout restart deployment ajp-api
   ```
