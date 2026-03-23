#!/bin/bash

# Telecom Monitoring Platform - Build and Deploy Script
# This script automates the build and deployment process

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Telecom Monitoring Platform${NC}"
echo -e "${GREEN}Docker Build & Deploy Script${NC}"
echo -e "${GREEN}========================================${NC}"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Check if Docker Compose plugin is installed
if ! docker compose version &> /dev/null; then
    echo -e "${RED}Docker Compose (plugin) is not installed. Please install/update Docker Desktop or Docker Compose plugin first.${NC}"
    exit 1
fi

echo -e "${YELLOW}Step 1: Checking prerequisites...${NC}"
docker --version
docker compose version

echo -e "\n${YELLOW}Step 2: Stopping any existing containers...${NC}"
docker compose down || true

echo -e "\n${YELLOW}Step 3: Building services...${NC}"
docker compose build

echo -e "\n${YELLOW}Step 4: Starting services...${NC}"
docker compose up -d

echo -e "\n${YELLOW}Step 5: Waiting for services to be ready...${NC}"
sleep 10

echo -e "\n${YELLOW}Step 6: Verifying services...${NC}"
docker compose ps

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Services Status:${NC}"
echo -e "${GREEN}========================================${NC}"
docker compose exec postgres pg_isready -U ${POSTGRES_USER:-telecom_user} || echo "PostgreSQL starting..."

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"

echo -e "\n${GREEN}Access Services:${NC}"
echo -e "  Frontend Dashboard (via Nginx): ${YELLOW}http://localhost${NC}"
echo -e "  Frontend (direct debug): ${YELLOW}http://localhost:3001${NC}"
echo -e "  Backend API (via Nginx): ${YELLOW}http://localhost/api/health${NC}"
echo -e "  Database: ${YELLOW}localhost:5432${NC}"

echo -e "\n${GREEN}Quick Commands:${NC}"
echo -e "  View logs: ${YELLOW}docker compose logs -f${NC}"
echo -e "  Stop services: ${YELLOW}docker compose down${NC}"
echo -e "  Check status: ${YELLOW}docker compose ps${NC}"

echo -e "\n${GREEN}Documentation:${NC}"
echo -e "  Quick Start: ${YELLOW}cat QUICK_START.md${NC}"
echo -e "  Full Guide: ${YELLOW}cat DEPLOYMENT_GUIDE.md${NC}"
echo -e "  Team Info: ${YELLOW}cat TEAM_ASSIGNMENTS.md${NC}"
