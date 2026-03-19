# Objective 5: Secure Image Distribution Using Private Docker Registry
## Team Assignment: Secure Image Distribution Team

### Goal
Implement a private Docker registry for storing and distributing container images securely.

### Current Setup
Images are built locally and would be distributed via public Docker Hub (insecure for enterprise).

### Solution: Private Docker Registry

### Phase 1: Set Up Local Docker Registry

#### Option A: Docker Registry Service (Recommended)

Create registry/docker-compose-registry.yml:

```yaml
version: '3.8'

services:
  # Private Docker Registry
  registry:
    image: registry:2
    container_name: telecom_registry
    ports:
      - "5000:5000"
    environment:
      REGISTRY_STORAGE: filesystem
      REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY: /var/lib/registry
    volumes:
      - registry_data:/var/lib/registry
      - ./registry/config.yml:/etc/docker/registry/config.yml
    networks:
      - telecom_network
    restart: unless-stopped

  # Registry UI (Optional - Web interface)
  registry-ui:
    image: joxit/docker-registry-ui:latest
    container_name: telecom_registry_ui
    ports:
      - "8080:80"
    environment:
      REGISTRY_TITLE: Telecom Registry
      REGISTRY_URL: http://registry:5000
    depends_on:
      - registry
    networks:
      - telecom_network
    restart: unless-stopped

networks:
  telecom_network:
    driver: bridge

volumes:
  registry_data:
```

#### Option B: Harbor (Enterprise-grade)

```yaml
version: '3.8'

services:
  harbor:
    image: goharbor/harbor-core:latest
    container_name: telecom_harbor
    ports:
      - "80:8080"
      - "443:8443"
    environment:
      HARBOR_ADMIN_PASSWORD: Harbor12345
      HARBOR_DB_PASSWORD: password123
    volumes:
      - /data/harbor/data:/data
      - /data/harbor/config:/etc/harbor
    depends_on:
      - postgres
      - redis
    networks:
      - telecom_network
```

### Phase 2: Configure Registry Authentication

Create registry/config.yml:

```yaml
version: 0.1
log:
  level: info
  formatter: text
storage:
  filesystem:
    rootdirectory: /var/lib/registry
  delete:
    enabled: true
http:
  addr: :5000
  headers:
    X-Content-Type-Options:
      - nosniff
    X-Frame-Options:
      - DENY
auth:
  htpasswd:
    realm: Registry Realm
    path: /auth/htpasswd
middleware:
  registry:
    - name: read-only
      options:
        enabled: false
notifications:
  events:
    includereferences: true
```

Create authentication credentials:

```bash
# Install htpasswd (if needed)
# Ubuntu: apt-get install apache2-utils
# macOS: brew install httpd

# Create credentials file
htpasswd -Bc registry/auth/htpasswd telecom-user telecom-password
```

Docker-compose with auth:

```yaml
registry:
  image: registry:2
  ports:
    - "5000:5000"
  volumes:
    - ./registry/auth:/auth
    - ./registry/config.yml:/etc/docker/registry/config.yml
    - registry_data:/var/lib/registry
```

### Phase 3: Push Images to Private Registry

#### Step 1: Start Registry
```bash
docker-compose -f registry/docker-compose-registry.yml up -d
```

#### Step 2: Login to Registry
```bash
docker login localhost:5000 -u telecom-user -p telecom-password
```

#### Step 3: Tag Images
```bash
# Build images
docker-compose build

# Tag for private registry
docker tag telecom_backend localhost:5000/telecom/backend:1.0.0
docker tag telecom_backend localhost:5000/telecom/backend:latest

docker tag telecom_frontend localhost:5000/telecom/frontend:1.0.0
docker tag telecom_frontend localhost:5000/telecom/frontend:latest
```

#### Step 4: Push to Registry
```bash
# Push images
docker push localhost:5000/telecom/backend:1.0.0
docker push localhost:5000/telecom/backend:latest

docker push localhost:5000/telecom/frontend:1.0.0
docker push localhost:5000/telecom/frontend:latest

# Verify
curl -u telecom-user:telecom-password \
  http://localhost:5000/v2/_catalog
```

### Phase 4: Update Docker Compose to Use Private Registry

Create docker-compose-production.yml:

```yaml
version: '3.8'

services:
  # Backend using private registry
  backend:
    image: localhost:5000/telecom/backend:1.0.0
    container_name: telecom_backend_prod
    # ... rest of configuration

  # Frontend using private registry
  frontend:
    image: localhost:5000/telecom/frontend:1.0.0
    container_name: telecom_frontend_prod
    # ... rest of configuration

  postgres:
    image: postgres:15-alpine
    # ... rest of configuration
```

### Phase 5: Image Signing and Security

#### Using Docker Content Trust (DCT)

```bash
# Enable DCT
export DOCKER_CONTENT_TRUST=1

# Push signed images
docker push localhost:5000/telecom/backend:1.0.0

# Verify signature
docker trust inspect localhost:5000/telecom/backend:1.0.0
```

#### Using Notary (Recommended)

```bash
# Install Notary
# https://github.com/notaryproject/notary/releases

# Initialize repository
notary key list
notary repository init localhost:5000/telecom/backend

# Sign and push
notary key list
notary publish localhost:5000/telecom/backend \
  --publish localhost:5000/telecom/backend:1.0.0
```

### Phase 6: Registry Security Hardening

#### Add SSL/TLS Certificate

```bash
# Generate self-signed certificate (development)
openssl req -x509 -newkey rsa:4096 -keyout registry_key.pem \
  -out registry_cert.pem -days 365 -nodes

# Update docker-compose
registry:
  volumes:
    - ./registry_cert.pem:/certs/domain.crt
    - ./registry_key.pem:/certs/domain.key
  environment:
    REGISTRY_HTTP_TLS_CERTIFICATE: /certs/domain.crt
    REGISTRY_HTTP_TLS_KEY: /certs/domain.key
```

#### Add Registry Garbage Collection

```bash
# Configure automatic cleanup
registry:
  environment:
    REGISTRY_STORAGE_DELETE_ENABLED: "true"
    REGISTRY_GARBAGE_COLLECTION_ENABLED: "true"
```

Run garbage collection:

```bash
docker exec telecom_registry registry garbage-collect \
  /etc/docker/registry/config.yml
```

### Phase 7: Image Pull Policies

Update docker-compose.yml:

```yaml
services:
  backend:
    image: localhost:5000/telecom/backend:1.0.0
    pull_policy: always  # Always pull latest from registry
    # or
    pull_policy: if_not_present
```

### Registry Management Commands

```bash
# List repositories
curl -u telecom-user:telecom-password \
  http://localhost:5000/v2/_catalog

# List tags for an image
curl -u telecom-user:telecom-password \
  http://localhost:5000/v2/telecom/backend/tags/list

# Delete image (if delete enabled)
curl -u telecom-user:telecom-password -X DELETE \
  http://localhost:5000/v2/telecom/backend/manifests/sha256:...

# Check registry health
curl -u telecom-user:telecom-password \
  http://localhost:5000/v2/

# View registry logs
docker logs telecom_registry
```

### Access Control

Create registry-auth policy:

```yaml
version: '3.8'

services:
  registry:
    environment:
      REGISTRY_AUTH: htpasswd
      REGISTRY_AUTH_HTPASSWD_REALM: "Registry Realm"
      REGISTRY_AUTH_HTPASSWD_PATH: /auth/htpasswd
    volumes:
      - ./registry/auth:/auth
```

Manage users:

```bash
# Add user
htpasswd -b registry/auth/htpasswd new-user password

# Remove user
htpasswd -D registry/auth/htpasswd user-to-remove

# Change password
htpasswd -B registry/auth/htpasswd existing-user
```

### CI/CD Integration

Example GitHub Actions workflow:

```yaml
name: Docker Image Build and Push

on:
  push:
    branches: [main]

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Build backend image
        run: |
          docker build -t localhost:5000/telecom/backend:${{ github.sha }} ./backend
      
      - name: Login to registry
        run: |
          docker login localhost:5000 \
            -u ${{ secrets.REGISTRY_USER }} \
            -p ${{ secrets.REGISTRY_PASSWORD }}
      
      - name: Push to registry
        run: |
          docker push localhost:5000/telecom/backend:${{ github.sha }}
          docker tag localhost:5000/telecom/backend:${{ github.sha }} \
                   localhost:5000/telecom/backend:latest
          docker push localhost:5000/telecom/backend:latest
```

### Deliverables

1. **Registry Setup**:
   - Docker Registry configuration
   - Authentication setup
   - TLS/SSL certificates

2. **Image Management**:
   - Build and push scripts
   - Tag management strategy
   - Version control procedures

3. **Documentation**:
   - Registry setup guide
   - Image push/pull procedures
   - Authentication management
   - Troubleshooting guide

4. **Security Implementation**:
   - Image signing/verification
   - Access control policies
   - SSL/TLS configuration
   - Backup procedures

### Success Criteria
- ✓ Private registry running and accessible
- ✓ All images pushed to registry
- ✓ Docker Compose pulls from private registry
- ✓ Authentication required for access
- ✓ SSL/TLS configured
- ✓ Image versioning implemented
- ✓ Documentation complete

### Testing

```bash
# Test 1: Registry accessibility
curl -u telecom-user:telecom-password \
  http://localhost:5000/v2/_catalog

# Test 2: Pull image from registry
docker pull localhost:5000/telecom/backend:latest

# Test 3: Deploy using private registry
docker-compose -f docker-compose-production.yml up -d

# Test 4: Verify images came from registry
docker images
docker image history localhost:5000/telecom/backend:latest
```

### References
- [Docker Registry Documentation](https://docs.docker.com/registry/)
- [Docker Authorization](https://docs.docker.com/registry/spec/auth/)
- [Harbor Project](https://goharbor.io/)
- [Image Signing Best Practices](https://docs.docker.com/engine/security/trust/)
