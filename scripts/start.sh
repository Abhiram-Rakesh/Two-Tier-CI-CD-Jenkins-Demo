#!/bin/bash
set -e

# Banner

echo -e "\n\033[1;36m===============================================\033[0m"
echo -e "\033[1;36m   Flask + MySQL CI/CD Demo – Startup Script   \033[0m"
echo -e "\033[1;36m   (Docker Compose Application Bootstrap)     \033[0m"
echo -e "\033[1;36m   Created by Abhiram                         \033[0m"
echo -e "\033[1;36m===============================================\033[0m\n"

# Logging helpers

info() { echo -e "\033[1;32m[INFO]\033[0m $1"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $1"; }

# Project root detection

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

info "Project root detected at: $PROJECT_ROOT"

# Pre-flight checks

info "Running pre-flight checks..."

command -v docker >/dev/null 2>&1 || {
    error "Docker is not installed"
    exit 1
}

docker compose version >/dev/null 2>&1 || {
    error "Docker Compose is not available"
    exit 1
}

if [[ ! -f ".env" ]]; then
    error ".env file not found. Create it from .env.example"
    exit 1
fi

if [[ ! -f "docker-compose.yml" ]]; then
    error "docker-compose.yml not found in project root"
    exit 1
fi

info "All required files found"

# Docker service check

info "Checking Docker daemon..."

if ! systemctl is-active --quiet docker; then
    warn "Docker is not running. Starting Docker..."
    sudo systemctl start docker
fi

# Build & start containers

info "Building Docker images..."
docker compose build

info "Starting application stack..."
docker compose up -d

# Post-start verification

info "Verifying container status..."

docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Application health check

info "Waiting for application to become available..."

ATTEMPTS=20
SLEEP=3

for i in $(seq 1 $ATTEMPTS); do
    if curl -fsS http://127.0.0.1 >/dev/null; then
        info "Application is up and responding on port 80"
        break
    else
        warn "Waiting for application... ($i/$ATTEMPTS)"
        sleep $SLEEP
    fi
done

# Final status

echo -e "\n\033[1;36m===============================================\033[0m"
echo -e "\033[1;36m Application Started Successfully              \033[0m"
echo -e "\033[1;36m-----------------------------------------------\033[0m"
echo -e "\033[1;36m To stop the app:                              \033[0m"
echo -e "\033[1;36m ./scripts/shutdown.sh                         \033[0m"
echo -e "\033[1;36m===============================================\033[0m\n"
