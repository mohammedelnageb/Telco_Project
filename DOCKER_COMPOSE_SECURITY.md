# Telecom Monitoring Platform - Docker Compose Security Configuration

# This docker-compose.yml file includes security best practices:

## 1. Network Isolation
# - Services communicate through a dedicated Docker network (telecom_network)
# - Only necessary ports are exposed to the host
# - Frontend (port 3000) and Backend (port 5000) are exposed for access
# - Database (port 5432) is exposed but in production should be removed

## 2. Service Dependencies
# - Frontend depends on Backend
# - Backend depends on PostgreSQL with health checks
# - Ensures proper startup sequence

## 3. Environment Variables
# - Database credentials are configured via environment variables
# - Never hardcode sensitive data in Dockerfile or scripts
# - Can be moved to .env file for additional security

## 4. Health Checks
# - PostgreSQL includes a health check
# - Backend won't start until database is ready
# - Improves reliability and startup order

## 5. Volume Management
# - Database data persists in named volume (postgres_data)
# - Application files mounted with code hot-reloading capability
# - node_modules isolated to prevent conflicts

## 6. Restart Policy
# - Services restart automatically on failure
# - Improves availability and resilience

# To deploy:
# docker-compose up -d

# To view logs:
# docker-compose logs -f

# To stop:
# docker-compose down

# To clean up everything (including volumes):
# docker-compose down -v
