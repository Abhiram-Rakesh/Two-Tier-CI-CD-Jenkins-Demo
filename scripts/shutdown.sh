#!/bin/bash
set -e

# Banner

echo -e "\n\033[1;36m===============================================\033[0m"
echo -e "\033[1;36m   Flask + MySQL CI/CD Demo – Shutdown Script  \033[0m"
echo -e "\033[1;36m   (Docker Compose Graceful Teardown)          \033[0m"
echo -e "\033[1;36m   Created by Abhiram                          \033[0m"
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

if [[ ! -f "docker-compose.yml" ]]; then
    error "docker-compose.yml not found in project root"
    exit 1
fi

command -v docker >/dev/null 2>&1 || {
    error "Docker is not installed"
    exit 1
}

docker compose version >/dev/null 2>&1 || {
    error "Docker Compose is not available"
    exit 1
}

# Shutdown process

info "Stopping application stack..."

docker compose down

# Post-shutdown verification

info "Verifying containers are stopped..."

if docker ps | grep -q flask-app; then
    warn "Flask container still running"
else
    info "Flask container stopped"
fi

if docker ps | grep -q mysql-db; then
    warn "MySQL container still running"
else
    info "MySQL container stopped"
fi

# Completion

echo -e "\n\033[1;36m===============================================\033[0m"
echo -e "\033[1;36m Application Shutdown Complete                 \033[0m"
echo -e "\033[1;36m-----------------------------------------------\033[0m"
echo -e "\033[1;36m Containers stopped successfully               \033[0m"
echo -e "\033[1;36m Volumes preserved (no data loss)              \033[0m"
echo -e "\033[1;36m-----------------------------------------------\033[0m"
echo -e "\033[1;36m To start again:                               \033[0m"
echo -e "\033[1;36m ./scripts/start.sh                            \033[0m"
echo -e "\033[1;36m===============================================\033[0m\n"
