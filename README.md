# Telecom Network Monitoring Platform - Project Documentation

## Project Overview
This is a containerized Three-Tier Telecom Network Monitoring Dashboard that demonstrates modern Docker deployment practices with security considerations.

## Architecture

### System Components
1. **Frontend** (Node.js + Express) - Port 3000
   - Monitoring dashboard UI
   - Communicates with backend API
   - Displays real-time network metrics and alerts

2. **Backend** (Node.js + Express) - Port 5000
   - RESTful API server
   - Business logic and data processing
   - Interfaces with PostgreSQL database

3. **Database** (PostgreSQL 15) - Port 5432
   - Stores all monitored data
   - Network metrics and alerts
   - Service status and base station information

## Getting Started

### Prerequisites
- Docker and Docker Compose installed
- 4GB RAM minimum
- Windows, macOS, or Linux

### Quick Start
```bash
# Navigate to project directory
cd Telco_Project

# Build and start containers
docker-compose up -d

# View logs
docker-compose logs -f

# Access services
# Frontend Dashboard: http://localhost:3000
# Backend API: http://localhost:5000
# Database: localhost:5432
```

### Stopping Services
```bash
# Stop all containers
docker-compose down

# Stop and remove volumes (WARNING: deletes data)
docker-compose down -v
```

## Project File Structure
```
Telco_Project/
├── frontend/                 # Next.js Frontend Dashboard
│   ├── server.js            # Express server
│   ├── package.json
│   ├── Dockerfile
│   ├── public/
│   │   └── styles.css       # Dashboard styling
│   └── views/
│       └── dashboard.ejs    # Dashboard template
├── backend/                  # Node.js Backend API
│   ├── server.js            # Express API server
│   ├── package.json
│   └── Dockerfile
├── database/                 # PostgreSQL Database
│   └── init.sql             # Database initialization script
├── docker-compose.yml       # Docker Compose orchestration
└── README.md               # This file
```

## Backend API Endpoints

### Health & Status
- `GET /api/health` - Backend health check

### Base Stations
- `GET /api/base-stations` - Get all base stations
- `GET /api/base-stations/:id` - Get specific base station

### Network Metrics
- `GET /api/network-metrics` - Get network metrics (last 100 records)

### Alerts
- `GET /api/alerts` - Get recent alerts (last 50 records)
- `POST /api/alerts` - Create new alert
  - Body: `{ base_station_id, severity, message }`

### Service Status
- `GET /api/service-status` - Get all services status

## Database Schema

### Tables
- **base_stations** - Network infrastructure information
- **network_metrics** - Real-time network performance data
- **alerts** - System alerts and notifications
- **service_status** - Telecom services availability

## Security Features for Objectives

### Objective 1: Container Image Size Optimization
- Uses Alpine Linux base images
- Multi-stage builds (can be implemented)
- Minimal dependencies installed

### Objective 2: Container Image Security
- Non-root user execution (can be added)
- Minimal attack surface with Alpine
- Regular security scanning recommended

### Objective 3: Docker Compose Security
- Isolated Docker network (telecom_network)
- Health checks for service dependencies
- Resource limits can be added
- Database not exposed by default in production

### Objective 4: Secret Management using Vault
- Environment variables for configuration
- Ready for Vault integration
- Database credentials externalized

### Objective 5: Secure Image Distribution
- Current setup uses Docker Hub
- Prepare for private registry deployment
- Docker Compose can be updated for registry URLs

## Environment Variables

### Backend (.env)
```
DB_USER=telecom_user
DB_PASSWORD=telecom_password
DB_HOST=postgres
DB_PORT=5432
DB_NAME=telecom_monitoring
PORT=5000
```

### Frontend (.env)
```
BACKEND_API_URL=http://backend:5000
PORT=3000
```

## Common Commands

### View running containers
```bash
docker ps
```

### View container logs
```bash
docker-compose logs frontend
docker-compose logs backend
docker-compose logs postgres
```

### Execute command in container
```bash
docker-compose exec backend npm install
docker-compose exec postgres psql -U telecom_user -d telecom_monitoring
```

### Rebuild containers
```bash
docker-compose build --no-cache
```

## Key Metrics Monitored
- Base station status (online/offline/maintenance)
- Bandwidth usage percentage
- Data traffic volumes
- Service availability percentages
- System alerts and notifications
- Network performance metrics

## Future Enhancements
1. Add GraphQL API layer
2. Implement WebSocket for real-time updates
3. Add authentication/authorization
4. Deploy with Kubernetes
5. Add monitoring with Prometheus and Grafana
6. Implement CI/CD pipeline

## Team Objectives Distribution

### Objective 1 - Container Image Size Optimization (Team A)
- Reduce Alpine-based images from ~150MB to <100MB
- Use .dockerignore files
- Minimize npm dependencies

### Objective 2 - Container Image Security (Team B)
- Implement vulnerability scanning
- Run containers as non-root users
- Use security scanning tools (trivy, snyk)

### Objective 3 - Docker Compose Security (Team C)
- Add resource limits
- Implement proper network policies
- Add read-only filesystems where possible

### Objective 4 - Secret Management (Team D)
- Integrate HashiCorp Vault
- Replace environment variables with Vault secrets
- Implement dynamic secret rotation

### Objective 5 - Secure Image Distribution (Team E)
- Set up private Docker registry
- Implement Docker registry authentication
- Push and pull images from private registry

## Contact & Support
Author: Mohammed Ahmed Ali
Course: Docker
Institution: [Your Institution]

---
Last Updated: March 2024
