@echo off
REM Telecom Monitoring Platform - Build and Deploy Script (Windows)
REM This script automates the build and deployment process

setlocal enabledelayedexpansion

cls
echo ========================================
echo Telecom Monitoring Platform
echo Docker Build and Deploy Script
echo ========================================
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not installed. Please install Docker Desktop first.
    pause
    exit /b 1
)

REM Check if Docker Compose is installed
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker Compose is not installed. Please install Docker Desktop first.
    pause
    exit /b 1
)

echo Step 1: Checking prerequisites...
docker --version
docker-compose --version
echo.

echo Step 2: Stopping any existing containers...
docker-compose down
echo.

echo Step 3: Building services (this may take several minutes)...
docker-compose build
if errorlevel 1 (
    echo ERROR: Build failed
    pause
    exit /b 1
)
echo.

echo Step 4: Starting services...
docker-compose up -d
if errorlevel 1 (
    echo ERROR: Failed to start services
    pause
    exit /b 1
)
echo.

echo Step 5: Waiting for services to be ready (10 seconds)...
timeout /t 10 /nobreak
echo.

echo Step 6: Verifying services...
docker-compose ps
echo.

echo ========================================
echo Deployment Complete!
echo ========================================
echo.

echo Access Services:
echo   Frontend Dashboard: http://localhost:3000
echo   Backend API: http://localhost:5000
echo   Database: localhost:5432
echo.

echo Quick Commands:
echo   View logs: docker-compose logs -f
echo   Stop services: docker-compose down
echo   Check status: docker-compose ps
echo.

echo Documentation:
echo   Quick Start: QUICK_START.md
echo   Full Guide: DEPLOYMENT_GUIDE.md
echo   Team Info: TEAM_ASSIGNMENTS.md
echo.

pause
