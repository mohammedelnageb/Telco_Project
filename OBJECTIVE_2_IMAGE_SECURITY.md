# Objective 2: Container Image Security
## Team Assignment: Image Security Team

### Goal
Improve container image security by reducing vulnerabilities, implementing security best practices, and ensuring secure runtime behavior.

### Security Scanning & Vulnerabilities

#### Key Focus Areas
1. Vulnerability scanning
2. Non-root user execution
3. Security hardening
4. Compliance and best practices

### Implementation Strategies

#### 1. Non-Root User Execution
Add to Dockerfiles:
```dockerfile
# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Set permissions and switch user
COPY --chown=appuser:appgroup . .
USER appuser
```

#### 2. Minimize Attack Surface
- Use minimal base images (Alpine) ✓
- Keep dependencies up-to-date
- Remove unnecessary packages
- Use specific version tags (not 'latest')

#### 3. Implement Security Scanning

##### Trivy (Recommended - Free & Powerful)
```bash
# Install trivy
# Windows: choco install trivy
# macOS: brew install trivy
# Linux: apt-get install trivy

# Scan Docker image
trivy image <image-name>

# Scan Dockerfile
trivy config Dockerfile

# Generate report
trivy image --format json <image-name> > scan_report.json
```

##### Docker Scout (Built-in)
```bash
# Enable Docker Scout (Docker Extension)
docker scout cves <image-name>
docker scout recommendations <image-name>
```

##### Snyk (Free tier available)
```bash
# Install snyk
npm install -g snyk

# Test Docker image
snyk container test <image-name>

# Test Node dependencies
snyk test
```

#### 4. Read-Only Root Filesystem
Update docker-compose.yml:
```yaml
frontend:
  read_only: true
  tmpfs:
    - /tmp
    - /var/tmp
```

#### 5. Drop Unnecessary Capabilities
```yaml
backend:
  cap_drop:
    - ALL
  cap_add:
    - NET_BIND_SERVICE
```

#### 6. Security Context in docker-compose.yml
```yaml
services:
  backend:
    security_opt:
      - no-new-privileges:true
```

### Security Checklist

- [ ] Non-root user implemented
- [ ] Trivy scan results < 5 vulnerabilities
- [ ] No CRITICAL severity vulnerabilities
- [ ] Security scanning integrated into workflow
- [ ] Capabilities restricted
- [ ] Read-only filesystem implemented where possible
- [ ] Base image security verified

### Measurement Tools

#### Before Security Improvements
```bash
# Set baseline
docker-compose build
trivy image telecom_backend > baseline_security.txt
trivy image telecom_frontend >> baseline_security.txt
```

#### After Security Improvements
```bash
# Rebuild with security improvements
docker-compose build --no-cache
trivy image telecom_backend > improved_security.txt
trivy image telecom_frontend >> improved_security.txt

# Compare results
diff baseline_security.txt improved_security.txt
```

### Documentation Required

1. **Scan Results**:
   - Before improvements
   - After improvements
   - Vulnerability count by severity

2. **Applied Improvements**:
   - List of security modifications
   - Rationale for each change
   - Performance impact

3. **Compliance Report**:
   - CIS Docker Benchmark compliance
   - OWASP container security recommendations

### Success Criteria
- ✓ All CRITICAL vulnerabilities resolved
- ✓ Non-root users implemented
- ✓ Security scanning automated
- ✓ Documentation complete
- ✓ <5 medium/low vulnerabilities remaining
- ✓ Services still function correctly

### Additional Resources
- [OWASP Container Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker/)
- [Docker Security Best Practices](https://docs.docker.com/develop/dev-best-practices/)
