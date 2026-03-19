# Objective 4: Secret Management Using HashiCorp Vault
## Team Assignment: Secret Management Team

### Goal
Implement secure secret management using HashiCorp Vault instead of storing secrets in environment variables or configuration files.

### Current Issue
Currently, secrets are stored in:
- .env files (VERSION CONTROLLED - DANGEROUS)
- Environment variables (VISIBLE TO CONTAINERS)
- docker-compose.yml (PLAIN TEXT)

### Solution: HashiCorp Vault

#### What is Vault?
HashiCorp Vault is a tool for securely storing and accessing sensitive data:
- Database credentials
- API tokens
- SSH keys
- TLS certificates
- Any secret data

### Implementation Strategy

#### Phase 1: Set Up Vault

```bash
# Install Vault (Windows - using Chocolatey)
choco install vault

# Or download from https://www.vaultproject.io/downloads

# Verify installation
vault --version
```

#### Phase 2: Add Vault Service to Docker Compose

Create updated docker-compose-vault.yml:

```yaml
version: '3.8'

services:
  # HashiCorp Vault Service
  vault:
    image: vault:latest
    container_name: telecom_vault
    ports:
      - "8200:8200"
    environment:
      VAULT_DEV_ROOT_TOKEN_ID: "dev-token-12345"
      VAULT_DEV_LISTEN_ADDRESS: "0.0.0.0:8200"
    volumes:
      - vault_data:/vault/data
      - ./vault/config.hcl:/vault/config/config.hcl
    cap_add:
      - IPC_LOCK
    networks:
      - telecom_network
    entrypoint: vault server -dev

  # Backend service (updated for Vault)
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: telecom_backend
    environment:
      VAULT_ADDR: http://vault:8200
      VAULT_TOKEN: dev-token-12345
      DB_CREDENTIALS_PATH: secret/data/telecom/database
    ports:
      - "5000:5000"
    depends_on:
      - vault
      - postgres
    volumes:
      - ./backend:/app
      - ./scripts/vault-secret-init.sh:/app/vault-init.sh
    networks:
      - telecom_network
    restart: unless-stopped

  # ... other services ...

volumes:
  vault_data:

networks:
  telecom_network:
    driver: bridge
```

#### Phase 3: Vault Configuration

Create vault/config.hcl:
```hcl
storage "file" {
  path = "/vault/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

ui = true
```

#### Phase 4: Store Secrets in Vault

```bash
# Set Vault address and token
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=dev-token-12345

# Enable key-value secrets engine (v2)
vault secrets enable -version=2 kv

# Store database credentials
vault kv put secret/telecom/database \
  username="telecom_user" \
  password="secure_password_123" \
  host="postgres" \
  port=5432 \
  dbname="telecom_monitoring"

# Store API keys
vault kv put secret/telecom/api \
  backend_secret="backend-secret-key" \
  frontend_secret="frontend-secret-key"

# Verify secrets
vault kv get secret/telecom/database
```

#### Phase 5: Update Backend to Fetch Secrets from Vault

Create backend/vault-client.js:
```javascript
const axios = require('axios');

const vaultAddr = process.env.VAULT_ADDR || 'http://vault:8200';
const vaultToken = process.env.VAULT_TOKEN;
const secretPath = process.env.DB_CREDENTIALS_PATH || 'secret/data/telecom/database';

async function getSecretsFromVault() {
  try {
    const response = await axios.get(
      `${vaultAddr}/v1/${secretPath}`,
      {
        headers: {
          'X-Vault-Token': vaultToken,
          'Content-Type': 'application/json'
        }
      }
    );
    
    const secrets = response.data.data.data;
    return {
      user: secrets.username,
      password: secrets.password,
      host: secrets.host,
      port: secrets.port,
      database: secrets.dbname
    };
  } catch (error) {
    console.error('Failed to retrieve secrets from Vault:', error.message);
    throw new Error('Secret retrieval failed');
  }
}

module.exports = { getSecretsFromVault };
```

Update backend/server.js:
```javascript
const { getSecretsFromVault } = require('./vault-client');

// Instead of:
// const pool = new Pool({ ... process.env ... })

// Use:
(async () => {
  const secrets = await getSecretsFromVault();
  const pool = new Pool({
    user: secrets.user,
    password: secrets.password,
    host: secrets.host,
    port: secrets.port,
    database: secrets.database
  });

  // Start server...
})();
```

#### Phase 6: Dynamic Secret Rotation

Create vault-secret-rotation.sh:
```bash
#!/bin/bash

# Script to rotate database credentials in Vault

VAULT_ADDR=${VAULT_ADDR:-http://localhost:8200}
VAULT_TOKEN=${VAULT_TOKEN}

# Generate new password
NEW_PASSWORD=$(openssl rand -base64 32)

# Update secret in Vault
curl --request POST \
  --header "X-Vault-Token: $VAULT_TOKEN" \
  --data "{\"data\": {\"password\": \"$NEW_PASSWORD\"}}" \
  $VAULT_ADDR/v1/secret/data/telecom/database

echo "Password rotated successfully"
```

### Vault UI Access

Access Vault dashboard:
- URL: http://localhost:8200
- Token: dev-token-12345

### Authentication Methods

#### Token-Based (Current - Development Only)
```yaml
environment:
  VAULT_TOKEN: dev-token-12345
```

#### AppRole (Recommended for Production)
```bash
# Enable AppRole auth method
vault auth enable approle

# Create AppRole
vault write auth/approle/role/telecom-backend \
  policies="telecom-policy" \
  token_ttl=1h \
  token_max_ttl=4h

# Get role ID and secret ID
vault read auth/approle/role/telecom-backend/role-id
vault write -f auth/approle/role/telecom-backend/secret-id
```

#### JWT/OIDC (For Cloud Environments)
```bash
vault auth enable jwt

vault write auth/jwt/config \
  jwks_url="https://your-provider/.well-known/jwks.json"
```

### Security Policies

Create vault/policies/telecom-policy.hcl:
```hcl
# Allow read-only access to secrets
path "secret/data/telecom/*" {
  capabilities = ["read", "list"]
}

# Allow lease renewal
path "auth/token/renew-self" {
  capabilities = ["update"]
}
```

Apply policy:
```bash
vault policy write telecom-policy vault/policies/telecom-policy.hcl
```

### Vault Management Commands

```bash
# List all secrets
vault kv list secret/telecom/

# Get a specific secret
vault kv get secret/telecom/database

# Delete a secret
vault kv delete secret/telecom/old-credentials

# Rotate a secret
vault kv put secret/telecom/database password=new-password

# View audit logs
vault audit list
vault read audit/file
```

### Deliverables

1. **Vault Server Setup**:
   - Docker Compose with Vault service
   - Vault configuration files
   - Policy definitions

2. **Application Integration**:
   - Vault client code
   - Secret retrieval logic
   - Environment configuration

3. **Documentation**:
   - Setup instructions
   - Secret management procedures
   - Troubleshooting guide
   - Policy documentation

4. **Operational Procedures**:
   - Secret rotation scripts
   - Backup and recovery procedures
   - Audit logging setup

### Success Criteria
- ✓ Vault server running and accessible
- ✓ Secrets stored in Vault
- ✓ Applications retrieve secrets from Vault
- ✓ No hardcoded secrets in code/configs
- ✓ Audit logging enabled
- ✓ Documentation complete

### Testing

```bash
# Test 1: Verify Vault is running
curl -s http://localhost:8200/v1/sys/health | jq

# Test 2: Retrieve secret using API
curl -H "X-Vault-Token: dev-token-12345" \
  http://localhost:8200/v1/secret/data/telecom/database

# Test 3: Backend can retrieve secrets
docker-compose logs backend

# Test 4: Application functions correctly
curl http://localhost:5000/api/base-stations
```

### References
- [HashiCorp Vault Documentation](https://www.vaultproject.io/docs)
- [Vault Docker Integration](https://www.vaultproject.io/docs/commands/server)
- [Secret Management Best Practices](https://www.vaultproject.io/docs/concepts)
