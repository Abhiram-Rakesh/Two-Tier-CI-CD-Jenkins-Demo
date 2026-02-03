#!/bin/bash
set -e

# Banner

echo -e "\n\033[1;36m===============================================\033[0m"
echo -e "\033[1;36m   Flask + MySQL CI/CD Demo – Installer         \033[0m"
echo -e "\033[1;36m   (Docker + Compose + Jenkins on EC2)          \033[0m"
echo -e "\033[1;36m   Created by Abhiram                           \033[0m"
echo -e "\033[1;36m===============================================\033[0m\n"

# Logging helpers

info() { echo -e "\033[1;32m[INFO]\033[0m $1"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $1"; }

# OS Detection

info "Detecting operating system..."

if [[ ! -f /etc/os-release ]]; then
    error "Cannot detect OS (missing /etc/os-release)"
    exit 1
fi

. /etc/os-release

case "$ID" in
ubuntu | debian)
    PKG=apt
    ;;
amzn | rhel | centos | almalinux | rocky)
    PKG=yum
    ;;
opensuse* | sles)
    PKG=zypper
    ;;
*)
    error "Unsupported OS: $ID"
    exit 1
    ;;
esac

info "Detected OS: $PRETTY_NAME"
info "Using package manager: $PKG"

# System Update

info "Updating system packages..."

case $PKG in
apt)
    sudo apt update -y
    ;;
yum)
    sudo yum update -y
    ;;
zypper)
    sudo zypper refresh
    ;;
esac

# Docker Installation

if command -v docker &>/dev/null; then
    info "Docker already installed"
else
    info "Installing Docker..."

    case $PKG in
    apt)
        sudo apt install -y docker.io
        ;;
    yum)
        sudo yum install -y docker
        ;;
    zypper)
        sudo zypper install -y docker
        ;;
    esac

    sudo systemctl start docker
    sudo systemctl enable docker
fi

# Docker Permissions

info "Configuring Docker permissions..."

if groups "$USER" | grep -q docker; then
    info "User already in docker group"
else
    sudo usermod -aG docker "$USER"
    warn "Docker group added. Log out and log back in required."
fi

# Docker Compose Installation

if docker compose version &>/dev/null; then
    info "Docker Compose already installed"
else
    info "Installing Docker Compose plugin..."

    curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 -o docker-compose
    chmod +x docker-compose
    sudo mv docker-compose /usr/local/bin/docker-compose
fi

# Jenkins Installation

if systemctl list-units --type=service | grep -q jenkins; then
    info "Jenkins already installed"
else
    info "Installing Jenkins..."

    case $PKG in
apt)
        # Base deps + Java
        sudo apt update -y
        sudo apt install -y ca-certificates curl gnupg openjdk-17-jdk

        # Jenkins GPG key (safe + idempotent)
        sudo install -d -m 0755 /usr/share/keyrings
        curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
          | sudo tee /usr/share/keyrings/jenkins-keyring.asc >/dev/null
        sudo chmod 0644 /usr/share/keyrings/jenkins-keyring.asc

        # Fail fast if key is missing
        if [[ ! -s /usr/share/keyrings/jenkins-keyring.asc ]]; then
            error "Jenkins GPG key installation failed"
            exit 1
        fi

        # Jenkins repo (single-line, no escapes)
        echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
          | sudo tee /etc/apt/sources.list.d/jenkins.list >/dev/null

        # Install Jenkins
        sudo apt update -y
        sudo apt install -y jenkins
        ;;
    yum)
        sudo yum install -y java-17-amazon-corretto
        sudo wget -O /etc/yum.repos.d/jenkins.repo \
            https://pkg.jenkins.io/redhat-stable/jenkins.repo
        sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
        sudo yum install -y jenkins
        ;;
    zypper)
        sudo zypper install -y java-17-openjdk
        sudo zypper addrepo https://pkg.jenkins.io/opensuse-stable/ jenkins
        sudo zypper refresh
        sudo zypper install -y jenkins
        ;;
    esac

    sudo systemctl start jenkins
    sudo systemctl enable jenkins
fi

# Jenkins Docker Access

info "Granting Jenkins access to Docker..."

if groups jenkins | grep -q docker; then
    info "Jenkins already in docker group"
else
    sudo usermod -aG docker jenkins
    sudo systemctl restart jenkins
fi

# Validation

info "Validating installations..."

docker --version
docker-compose --version
systemctl status docker --no-pager
systemctl status jenkins --no-pager

# Completion

echo -e "\n\033[1;36m===============================================\033[0m"
echo -e "\033[1;36m Installation Complete                         \033[0m"
echo -e "\033[1;36m-----------------------------------------------\033[0m"
echo -e "\033[1;36m Next Steps:                                   \033[0m"
echo -e "\033[1;36m 1. Log out & log back in (Docker permissions) \033[0m"
echo -e "\033[1;36m 2. Configure Jenkins                          \033[0m"
echo -e "\033[1;36m 3. Run ./scripts/start.sh                     \033[0m"
echo -e "\033[1;36m===============================================\033[0m\n"
