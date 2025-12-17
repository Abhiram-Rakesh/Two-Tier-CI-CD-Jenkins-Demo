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

<img width="812" height="802" alt="Two-Tier-CI-CD(Jenkins)-Demo(1)" src="https://github.com/user-attachments/assets/2b907eb2-db3f-4fe8-9617-4936ab83a1ed" />


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

### 1. Clone the Repository

```bash
git clone https://github.com/Abhiram-Rakesh/Two-Tier-CI-CD-Jenkins--Demo.git
cd Two-Tier-CI-CD-Jenkins--Demo
```

---

### 2. Run the Installer Script

The installer performs **all privileged system setup**:

- Docker installation
- Docker Compose installation
- User permissions
- (Optional) Jenkins installation

```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

> NOTE: `install.sh` is the **only script that uses sudo**. All other scripts are non-interactive and CI-safe.

---

### 3. Start the Application Manually (Validation Step)

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

### 4. Jenkins Setup

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

### 5. Jenkins Build Pipeline

This section explains **how to create and configure the Jenkins pipeline job** that drives the CI/CD process for this project.

#### Step 1: Create a New Jenkins Job

1. Open Jenkins in your browser:

   ```
   http://<EC2_PUBLIC_IP>:8080
   ```

2. Click **New Item**
3. Enter a job name (example):

   ```
   Two-Tier-CI-CD-Jenkins--Demo
   ```

4. Select **Pipeline**
5. Click **OK**

---

#### Step 2: Configure Pipeline Source

In the job configuration page:

1. Scroll to **Pipeline** section
2. Under **Definition**, select:

   ```
   Pipeline script from SCM
   ```

3. Select **SCM**: `Git`
4. Repository URL:

   ```
   https://github.com/Abhiram-Rakesh/Two-Tier-CI-CD-Jenkins--Demo.git
   ```

5. Branch to build:

   ```
   */main
   ```

6. Script Path:

   ```
   Jenkinsfile
   ```

---

#### Step 3: Enable GitHub Webhook Trigger

1. Scroll to **Build Triggers**
2. Enable:

   ```
   GitHub hook trigger for GITScm polling
   ```

3. Leave **SCM Polling** disabled

---

#### Step 4: Save and Run Initial Build

1. Click **Save**
2. Click **Build Now**
3. Observe the pipeline stages:
   - Checkout Code
   - Pre-Deployment Check
   - Prepare Environment
   - Shutdown Existing Application
   - Deploy Application

A successful build confirms that Jenkins can:

- Pull code from GitHub
- Execute deployment scripts
- Start the application stack correctly

---

#### Pipeline Design Notes

- All deployment logic lives in shell scripts (`start.sh`, `shutdown.sh`)
- Jenkins acts only as an orchestrator
- No `sudo` commands are executed inside Jenkins
- The pipeline is safe for non-interactive execution

---

### 6. GitHub Webhook (Auto Deploy)

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

---
