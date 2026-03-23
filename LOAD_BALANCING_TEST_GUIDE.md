# Load Balancing Test Guide

This guide explains how to verify load balancing in the Telco project using Docker Compose and Nginx.

## Prerequisites

- Docker Desktop / Docker Engine + Docker Compose
- Project started from `Telco_Project/`

## 1) Start and scale backend replicas

```bash
docker compose -f docker-compose.yml up -d --scale backend=3
```

## 2) Confirm all services are running

```bash
docker compose -f docker-compose.yml ps
```

You should see:
- `telecom_nginx`
- `telecom_frontend`
- `telco_project-backend-1`, `-2`, `-3`

## 3) Send repeated requests through Nginx

Use the health endpoint (it returns backend instance hostname):

### Windows CMD
```cmd
for /L %i in (1,1,20) do curl -s http://localhost/api/health
```

### Windows PowerShell
```powershell
1..20 | % { curl.exe -s http://localhost/api/health }
```

## 4) Verify distribution

Check the `instance` value in responses. Different hostnames over multiple calls indicate requests are being distributed across backend replicas.

Optional log check:

```bash
docker compose -f docker-compose.yml logs backend --tail=100
```

## 5) If traffic seems sticky

Restart Nginx and test again:

```bash
docker compose -f docker-compose.yml restart nginx
```

---

## Test Evidence Screenshot

The following screenshot was provided for the load-balancing test documentation:

![Load Balancing Test Screenshot](docs/images/load-balancing-test.png)
