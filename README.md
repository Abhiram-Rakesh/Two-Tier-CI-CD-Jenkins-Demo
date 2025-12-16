# Two-Tier Flask Application with CI/CD using Jenkins

## Overview

This project demonstrates a **production-style CI/CD pipeline** for a two-tier web application using **Flask (application layer)** and **MySQL (database layer)**, fully containerized with **Docker** and automated using **Jenkins**.

The goal of this project is to showcase **real DevOps practices**, not just tool usage. The focus is on:

- Clear separation of responsibilities
- Script-driven deployments
- Non-interactive, CI-safe automation
- Real-world constraints (resource limits, permissions, secrets handling)

This project is designed to be **resume-ready** and mirrors how small-to-medium teams deploy containerized applications on cloud infrastructure.

---

## Architecture

```
+-----------------+        +----------------------+        +-----------------------------+
|   Developer     | -----> |     GitHub Repo      | -----> |        Jenkins Server       |
| (git push)      |        | (Source Control)     |        |  (CI/CD Orchestrator)      |
+-----------------+        +----------------------+        |                             |
                                                             | 1. Clones Repository       |
                                                             | 2. Prepares Environment    |
                                                             | 3. Executes Scripts        |
                                                             +--------------+--------------+
                                                                            |
                                                                            | Deploys
                                                                            v
                                                             +-----------------------------+
                                                             |      Application Server     |
                                                             |        (Same EC2)            |
                                                             |                             |
                                                             | +-------------------------+ |
                                                             | | Flask App (Gunicorn)    | |
                                                             | | Port 5000 -> 80         | |
                                                             | +-------------------------+ |
                                                             |              |              |
                                                             |              v              |
                                                             | +-------------------------+ |
                                                             | | MySQL Database          | |
                                                             | | Persistent Volume       | |
                                                             | +-------------------------+ |
                                                             +-----------------------------+
```

### Key Design Decisions

- **Docker Compose** manages multi-container orchestration
- **Gunicorn** is used instead of Flask’s dev server
- **Jenkins** acts only as an orchestrator, not a deployment engine
- **Shell scripts** are the single source of truth for deployments

---

## Prerequisites

### Cloud / Host

- AWS EC2 instance (Ubuntu / Debian / Amazon Linux)
- Minimum recommended:
  - 2 GB RAM (or Jenkins disabled when not in use)
  - Open inbound ports:
    - `22` (SSH)
    - `80` (Application)
    - `8080` (Jenkins)

### Local Machine

- Git
- SSH key configured for EC2 access

### Accounts

- GitHub account
- AWS account

---

## Installation Instructions

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/<your-username>/Two-Tier-CI-CD-Jenkins--Demo.git
cd Two-Tier-CI-CD-Jenkins--Demo
```

---

### 2️⃣ Run the Installer Script

The installer performs **all privileged system setup**:

- Docker installation
- Docker Compose installation
- User permissions
- (Optional) Jenkins installation

```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

> `install.sh` is the **only script that uses sudo**. All other scripts are non-interactive and CI-safe.

---

### 3️⃣ Start the Application Manually (Validation Step)

Before using Jenkins, validate the runtime manually:

```bash
chmod +x scripts/start.sh
./scripts/start.sh
```

Verify in browser:

```
http://<EC2_PUBLIC_IP>
```

---

### 4️⃣ Jenkins Setup

Start Jenkins **only when needed**:

```bash
sudo systemctl start jenkins
```

Access Jenkins:

```
http://<EC2_PUBLIC_IP>:8080
```

Unlock Jenkins:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Required Jenkins setup:

- Install suggested plugins
- Add Jenkins user to `docker` group
- Restart Jenkins once

---

### 5️⃣ CI/CD Pipeline Configuration

- The pipeline is defined in the `Jenkinsfile`
- Jenkins performs:
  - Code checkout
  - Environment preparation
  - Controlled shutdown
  - Fresh deployment

The pipeline **reuses the same scripts** used for manual deployments.

---

### 6️⃣ GitHub Webhook (Auto Deploy)

Webhook endpoint:

```
http://<EC2_PUBLIC_IP>:8080/github-webhook/
```

Webhook settings:

- Content type: `application/json`
- Trigger: `push` events

Once configured:

```bash
git push origin main
```

Automatically triggers a Jenkins deployment.

---

## Troubleshooting Guide

### Jenkins build fails due to sudo

**Cause:** `sudo` used in runtime scripts

**Fix:**

- Only `install.sh` may use sudo
- `start.sh` and `shutdown.sh` must be non-interactive

---

### `.env file not found`

**Cause:** `.env` is gitignored and missing in Jenkins workspace

**Fix:**

- Jenkins pipeline creates `.env` from `.env.example`

---

### SSH becomes unresponsive

**Cause:** Resource exhaustion (Jenkins + Docker on small instance)

**Fix:**

- Disable Jenkins auto-start
- Reboot instance
- Start Jenkins only when required

---

### `curl: (56) Connection reset by peer`

**Cause:** Gunicorn workers initializing

**Fix:**

- Expected behavior during startup
- Not an application failure

---

## Recap

This project demonstrates:

- A real two-tier containerized application
- Script-driven deployments
- CI/CD automation using Jenkins
- Proper handling of permissions and secrets
- Awareness of infrastructure limitations

### What this project proves

- You understand **how deployments actually work**
- You can debug real infrastructure issues
- You design automation that is **safe, repeatable, and realistic**
