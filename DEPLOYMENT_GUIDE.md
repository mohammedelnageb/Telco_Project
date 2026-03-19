# Deployment Guide
## Telecom Monitoring Platform - Complete Setup Instructions

---

## Table of Contents
1. Prerequisites
2. Initial Setup
3. Running with Docker Compose
4. Services Access
5. Database Management
6. Troubleshooting
7. Production Deployment Considerations

---

## Prerequisites

### Required Software
- Docker (20.10 or higher)
- Docker Compose (2.0 or higher)
- Git
- Text Editor or IDE

### Installation Guides

#### Windows
```powershell
# Install Docker Desktop
choco install docker-desktop

# Or download from https://www.docker.com/products/docker-desktop

# Verify installation
docker --version
docker-compose --version
```

#### macOS
```bash
# Install Docker Desktop
brew install docker
brew install docker-compose

# Or download from https://www.docker.com/products/docker-desktop

# Verify installation
docker --version
docker-compose --version
```

#### Linux (Ubuntu/Debian)
```bash
# Install Docker
sudo apt-get update
sudo apt-get install docker.io
sudo apt-get install docker-compose

# Add current user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify installation
docker --version
docker-compose --version
```

---

## Initial Setup

### Step 1: Clone/Navigate to Project

```bash
cd /path/to/Telco_Project
ls -la

# Expected structure:
# docker-compose.yml
# frontend/
# backend/
# database/
# README.md
```

### Step 2: Verify Project Structure

```bash
# Check for required files
ls frontend/Dockerfile
ls backend/Dockerfile
ls database/init.sql
ls docker-compose.yml

# All should exist
```

### Step 3: Environment Configuration

The project uses environment files for configuration:

**Frontend (.env)**
```
BACKEND_API_URL=http://backend:5000
PORT=3000
```

**Backend (.env)**
```
DB_USER=telecom_user
DB_PASSWORD=telecom_password
DB_HOST=postgres
DB_PORT=5432
DB_NAME=telecom_monitoring
PORT=5000
```

These are already configured in the project directories.

---

## Running with Docker Compose

### Build Services

#### First Time Build
```bash
# Navigate to project directory
cd Telco_Project

# Build all services (this may take 5-10 minutes)
docker-compose build

# View build output
# Should complete without errors
```

#### Rebuild Specific Service
```bash
# Rebuild only backend
docker-compose build backend

# Rebuild only frontend
docker-compose build frontend

# Rebuild without cache
docker-compose build --no-cache
```

### Start Services

#### Start in Background
```bash
# Start all services
docker-compose up -d

# Expected output:
# Creating telecom_postgres ... done
# Creating telecom_backend ... done
# Creating telecom_frontend ... done
```

#### Start with Logs Visible
```bash
# Start and view logs
docker-compose up

# Press Ctrl+C to stop and see logs
```

#### Start Specific Services
```bash
# Start only database
docker-compose up -d postgres

# Start backend and database
docker-compose up -d postgres backend

# Then start frontend
docker-compose up -d frontend
```

### Monitor Services

#### Check Service Status
```bash
# View all running containers
docker-compose ps

# Expected output:
# NAME                COMMAND             STATUS
# telecom_postgres    docker-entrypoint   Up (healthy)
# telecom_backend     node server.js      Up
# telecom_frontend    node server.js      Up
```

#### View Logs

```bash
# View all logs
docker-compose logs

# Follow logs in real-time
docker-compose logs -f

# View specific service logs
docker-compose logs backend
docker-compose logs frontend
docker-compose logs postgres

# View last 50 lines
docker-compose logs --tail=50

# View logs from last 10 minutes
docker-compose logs --since=10m
```

#### Monitor Resource Usage
```bash
# Real-time resource usage
docker stats

# For specific containers
docker stats telecom_backend telecom_frontend
```

---

## Services Access

### Frontend Dashboard
- **URL**: http://localhost:3000
- **Port**: 3000
- **Description**: Monitoring dashboard UI

**Access a**
- Open browser
- Navigate to http://localhost:3000
- See real-time monitoring data

### Backend API

- **Base URL**: http://localhost:5000
- **Port**: 5000

#### API Endpoints

```bash
# Health Check
curl http://localhost:5000/api/health

# Get Base Stations
curl http://localhost:5000/api/base-stations

# Get Network Metrics
curl http://localhost:5000/api/network-metrics

# Get Alerts
curl http://localhost:5000/api/alerts

# Get Service Status
curl http://localhost:5000/api/service-status

# Create Alert (POST)
curl -X POST http://localhost:5000/api/alerts \
  -H "Content-Type: application/json" \
  -d '{
    "base_station_id": 1,
    "severity": "warning",
    "message": "High bandwidth usage detected"
  }'
```

### PostgreSQL Database

- **Host**: localhost (from Docker host)
- **Host**: postgres (from within containers)
- **Port**: 5432
- **User**: telecom_user
- **Password**: telecom_password
- **Database**: telecom_monitoring

#### Connect to Database

```bash
# Using psql (if installed)
psql -h localhost -U telecom_user -d telecom_monitoring

# Within Docker container
docker-compose exec postgres psql -U telecom_user -d telecom_monitoring

# Common SQL commands
\dt                 # List tables
SELECT * FROM base_stations;
SELECT * FROM alerts;
\q                  # Exit psql
```

---

## Database Management

### Backup Database

```bash
# Backup to file
docker-compose exec postgresql pg_dump -U telecom_user telecom_monitoring > backup.sql

# Backup with compression
docker-compose exec postgres pg_dump -U telecom_user telecom_monitoring | gzip > backup.sql.gz
```

### Restore Database

```bash
# Restore from backup
docker-compose exec -T postgres psql -U telecom_user telecom_monitoring < backup.sql

# Restore from compressed backup
gunzip < backup.sql.gz | docker-compose exec -T postgres psql -U telecom_user telecom_monitoring
```

### Reset Database

```bash
# Stop services
docker-compose down

# Remove database volume (WARNING: deletes all data)
docker volume rm Telco_Project_postgres_data

# Start services (database will reinitialize)
docker-compose up -d
```

### Query Database

```bash
# Execute SQL query
docker-compose exec postgres psql -U telecom_user -d telecom_monitoring -c "SELECT * FROM base_stations;"

# Run SQL file
docker-compose exec postgres psql -U telecom_user -d telecom_monitoring < query.sql
```

---

## Stopping and Cleanup

### Stop Services

```bash
# Stop all services (keeps containers)
docker-compose stop

# Stop specific service
docker-compose stop backend

# Remove containers
docker-compose down

# Remove containers and volumes (WARNING: deletes data)
docker-compose down -v

# Remove everything including images
docker-compose down -v --remove-orphans --rmi all
```

### Clean Up

```bash
# Remove unused volumes
docker volume prune

# Remove unused networks
docker network prune

# Remove unused images
docker image prune

# Complete cleanup (keep only active containers)
docker system prune
```

---

## Development Workflow

### Making Code Changes

```bash
# 1. Edit frontend code
# 2. Edit backend code
# 3. Restart services
docker-compose restart

# View changes
docker-compose logs -f

# Or rebuild if package.json changed
docker-compose down
docker-compose build
docker-compose up -d
```

### Testing Changes

```bash
# Terminal 1: View logs
docker-compose logs -f backend

# Terminal 2: Make requests
curl http://localhost:5000/api/base-stations

# Terminal 3: Check database
docker-compose exec postgres psql -U telecom_user -d telecom_monitoring \
  -c "SELECT * FROM base_stations;"
```

### Debugging Issues

```bash
# Access backend container shell
docker-compose exec backend sh

# View backend files
docker-compose exec backend ls -la

# Check node version
docker-compose exec backend node --version

# Install additional dependencies
docker-compose exec backend npm install packagename
```

---

## Production Deployment Considerations

### Pre-Deployment Checklist

- [ ] All services health checks passing
- [ ] Database backups created
- [ ] Security scanning completed
- [ ] Environment variables verified
- [ ] Resource limits configured
- [ ] SSL/TLS certificates ready
- [ ] Monitoring configured
- [ ] Disaster recovery plan created

### Production Environment Variables

```bash
# .env.production
DB_PASSWORD=strong_random_password_here
BACKEND_API_URL=https://api.yourdomain.com
NODE_ENV=production
```

### Docker Compose Production Override

Create `docker-compose.production.yml`:

```yaml
version: '3.8'

services:
  postgres:
    # Don't expose port in production
    ports: []
    
  backend:
    restart: on-failure:5
    environment:
      NODE_ENV: production
    
  frontend:
    restart: on-failure:5
    environment:
      NODE_ENV: production
```

Deploy with:
```bash
docker-compose -f docker-compose.yml -f docker-compose.production.yml up -d
```

### Monitoring and Logging

```bash
# Configure logging driver
docker-compose logs --driver json-file

# Export logs
docker-compose logs --timestamps > deployment.log

# Monitor in real-time
watch docker-compose ps
```

---

## Troubleshooting

### Services Not Starting

```bash
# Check logs
docker-compose logs

# Check specific service
docker-compose logs backend

# Rebuild and restart
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Database Connection Issues

```bash
# Test database connectivity
docker-compose exec backend curl postgres:5432

# Check database logs
docker-compose logs postgres

# Verify database status
docker-compose exec postgres pg_isready -U telecom_user
```

### Port Already in Use

```bash
# Find what's using the port
netstat -ano | findstr :3000  # Windows
lsof -i :3000                  # macOS/Linux

# Change docker-compose port mapping
# Modify docker-compose.yml:
# frontend:
#   ports:
#     - "3001:3000"
```

### Container Out of Disk Space

```bash
# Clean up Docker system
docker system prune -a

# Remove old images
docker image prune -a
```

---

## Performance Optimization

### Increase Resource Limits

Edit `docker-compose.yml`:

```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 1G
```

### Enable Caching

```bash
# Docker layer caching already enabled
# To force rebuild without cache:
docker-compose build --no-cache
```

### Monitor Performance

```bash
# Real-time metrics
docker stats

# Save metrics to file
docker stats --no-stream > metrics.txt
```

---

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Node.js Documentation](https://nodejs.org/docs/)

---

## Support

For issues or questions:
1. Check logs: `docker-compose logs`
2. Verify services: `docker-compose ps`
3. Test connectivity: `docker network inspect`
4. Review project README.md

Last Updated: March 2024
