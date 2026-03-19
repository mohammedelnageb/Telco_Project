# Quick Start Guide
## Telecom Monitoring Platform - 5 Minutes to Running

---

## Super Quick (No Configuration Needed)

### 1. Start Services
```bash
# Navigate to project
cd Telco_Project

# Start everything
docker-compose up -d
```

### 2. Access the Dashboard
- Open browser: **http://localhost:3000**
- See monitoring dashboard!

### 3. Check API
```bash
# Test API
curl http://localhost:5000/api/health
```

---

## Verify Everything's Running

```bash
# Check container status
docker-compose ps

# Should show 3 containers: frontend, backend, postgres (all Up)

# View logs
docker-compose logs --tail=20

# Should show successful connections
```

---

## What You Can Do

### Access Services

| Service | URL | Purpose |
|---------|-----|---------|
| **Frontend** | http://localhost:3000 | Monitoring Dashboard |
| **Backend** | http://localhost:5000/api | REST API |
| **Database** | localhost:5432 | PostgreSQL |

### Common API Calls

```bash
# Get base stations
curl http://localhost:5000/api/base-stations

# Get alerts
curl http://localhost:5000/api/alerts

# Get metrics
curl http://localhost:5000/api/network-metrics

# Get service status
curl http://localhost:5000/api/service-status

# Create alert
curl -X POST http://localhost:5000/api/alerts \
  -H "Content-Type: application/json" \
  -d '{"base_station_id": 1, "severity": "warning", "message": "Test alert"}'
```

### Access Database

```bash
# Query database
docker-compose exec postgres psql -U telecom_user -d telecom_monitoring

# In psql shell:
SELECT * FROM base_stations;
SELECT * FROM alerts;
\q  # Exit
```

---

## Stop Services

```bash
# Stop all
docker-compose down

# Remove data too (WARNING: deletes database)
docker-compose down -v
```

---

## Next Steps

1. **Review Architecture**: See [README.md](README.md)
2. **Team Assignments**: See [TEAM_ASSIGNMENTS.md](TEAM_ASSIGNMENTS.md)
3. **Deep Dive**: See objective files (OBJECTIVE_1 through OBJECTIVE_5)
4. **Full Guide**: See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)

---

## Common Issues

### Services won't start?
```bash
docker-compose logs
# Check the error messages
```

### Can't access dashboard?
```bash
# Ensure containers are running
docker-compose ps

# Check port 3000 is open
curl http://localhost:3000
```

### Database not initializing?
```bash
# Check database logs
docker-compose logs postgres

# Restart database
docker-compose restart postgres
```

---

## Need Help?

- 📖 Full documentation: [README.md](README.md)
- 🛠️ Detailed setup: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- 🚀 Development: See objective documents

**That's it! You're ready to go!** 🎉
