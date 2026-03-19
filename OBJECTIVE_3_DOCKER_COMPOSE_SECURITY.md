# Objective 3: Docker Compose Security
## Team Assignment: Docker Compose Security Team

### Goal
Secure the orchestration layer by implementing network isolation, resource controls, and service access restrictions.

### Key Focus Areas
1. Network isolation and policies
2. Resource limits (CPU, Memory)
3. Controlled service exposure
4. Health checks and dependency management
5. Volume security

### Current Security Features ✓
- Custom Docker network (telecom_network)
- Service dependencies with health checks
- Port exposure restrictions
- Named volume for database persistence

### Implementation Strategies

#### 1. Add Resource Limits

Update docker-compose.yml:
```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M

  frontend:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M

  postgres:
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
```

#### 2. Read-Only Filesystems
```yaml
services:
  backend:
    read_only: true
    tmpfs:
      - /tmp
      - /var/tmp

  frontend:
    read_only: true
    tmpfs:
      - /tmp
      - /var/tmp
```

#### 3. Remove Unnecessary Port Exposure

**Before (Dangerous):**
```yaml
services:
  postgres:
    ports:
      - "5432:5432"  # Exposes database to external access
```

**After (Secure):**
```yaml
services:
  postgres:
    # No ports section - only accessible via internal network
```

For accessing database from host during development:
```bash
docker-compose exec postgres psql -U telecom_user -d telecom_monitoring
```

#### 4. Add Restart Policies ✓ (Already implemented)
```yaml
services:
  backend:
    restart: unless-stopped
```

Options:
- `no`: Do not automatically restart
- `always`: Always restart unless explicitly stopped
- `unless-stopped`: Always restart unless stopped
- `on-failure`: Restart only on failure

#### 5. Security Options
```yaml
services:
  backend:
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE

  frontend:
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
      - NET_BIND_SERVICE
```

#### 6. Environment Variable Security
Instead of hardcoding, use .env file:
```bash
# .env file (never commit to git)
POSTGRES_USER=telecom_user
POSTGRES_PASSWORD=secure_password_here
```

Reference in docker-compose.yml:
```yaml
services:
  postgres:
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
```

#### 7. Volume Security

```yaml
volumes:
  postgres_data:
    driver: local
    driver_opts:
      type: tmpfs
      device: tmpfs

# Or use named volumes with specific permissions
postgres_data:
  driver: local
```

#### 8. Add Enhanced Health Checks

```yaml
services:
  backend:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  frontend:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

#### 9. Network Policies (Advanced)

For Swarm mode or Kubernetes:
```yaml
networks:
  telecom_network:
    driver: bridge
    driver_opts:
      com.docker.network.bridge.name: telecom_br0
      com.docker.network.driver.mtu: 1500
```

#### 10. Logging Configuration
```yaml
services:
  backend:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### Security Checklist

- [ ] Resource limits configured for all services
- [ ] Read-only filesystems implemented
- [ ] Database port not exposed externally
- [ ] Health checks operational
- [ ] Restart policies configured
- [ ] Security options enabled
- [ ] Non-root users in containers
- [ ] Logging configured
- [ ] Environment variables externalized
- [ ] No sensitive data in docker-compose.yml

### Verification Commands

```bash
# Start services
docker-compose up -d

# Check container stats
docker stats

# View resource usage
docker-compose exec backend ps aux

# Verify network isolation
docker network inspect telecom_project_telecom_network

# Check health status
docker-compose ps

# View logs
docker-compose logs --tail=50
```

### Expected Outcomes

1. **Network Isolation**: Services communicate only via internal network
2. **Resource Control**: CPU and memory usage limited
3. **Port Exposure**: Only necessary ports exposed (3000, 5000)
4. **Data Persistence**: PostgreSQL data stored securely
5. **Service Reliability**: Health checks ensure uptime

### Deliverables

1. Updated docker-compose.yml with security features
2. .env file template for sensitive data
3. Network topology diagram
4. Security configuration documentation
5. Testing and verification results
6. Performance impact report

### Success Criteria
- ✓ Services isolated on custom network
- ✓ Resource limits enforced
- ✓ Database not exposed externally
- ✓ All services pass health checks
- ✓ No unnecessary capabilities
- ✓ Read-only filesystems functional
- ✓ Logging configured

### Testing Scenarios

```bash
# Test 1: Verify database is not accessible from host
mysql -h localhost -P 5432 -u telecom_user  # Should fail

# Test 2: Verify service communication works
docker-compose exec backend curl http://postgres:5432  # Should work internally

# Test 3: Check resource limits
docker stats

# Test 4: Verify health status
docker-compose ps
```
