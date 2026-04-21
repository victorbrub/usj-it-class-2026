# Docker Installation on Linux

# Author: Víctor Barceló

## Overview

This guide covers installing Docker Engine and Docker Compose on Linux. Instructions are provided for the two most common distribution families:

- **Debian/Ubuntu** (and derivatives such as Linux Mint, Pop!\_OS)
- **RHEL/Fedora** (and derivatives such as CentOS Stream, AlmaLinux, Rocky Linux)

Docker Engine is the core daemon. Docker Compose is a tool for defining and running multi-container applications from a single `docker-compose.yml` file.

---

## Prerequisites

- A 64-bit Linux installation
- Kernel version 3.10 or higher (`uname -r` to check)
- A user account with `sudo` privileges
- Internet access

---

## Debian / Ubuntu

### Step 1 — Remove old versions

If any older Docker packages are present, remove them first:

```bash
sudo apt remove docker docker-engine docker.io containerd runc
```

It is safe to run this even if none of those packages are installed.

### Step 2 — Install required dependencies

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
```

### Step 3 — Add Docker's official GPG key

```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

> For Debian, replace `ubuntu` with `debian` in the URL above.

### Step 4 — Set up the Docker repository

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

> For Debian, replace `ubuntu` with `debian` in the URL above.

### Step 5 — Install Docker Engine

```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Step 6 — Verify the installation

```bash
sudo docker run hello-world
```

You should see a message confirming that Docker is working correctly.

---

## RHEL / Fedora

### Step 1 — Remove old versions

```bash
sudo dnf remove docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine \
    podman \
    runc
```

### Step 2 — Add the Docker repository

```bash
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
```

> For RHEL/CentOS Stream, replace `fedora` with `rhel` or `centos` in the URL.

### Step 3 — Install Docker Engine

```bash
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Step 4 — Start and enable the Docker service

```bash
sudo systemctl enable --now docker
```

### Step 5 — Verify the installation

```bash
sudo docker run hello-world
```

---

## Post-installation Steps (all distributions)

### Run Docker without sudo

By default, the Docker daemon requires `sudo`. To run Docker commands as a regular user, add your user to the `docker` group:

```bash
sudo usermod -aG docker $USER
```

Log out and back in (or run `newgrp docker`) for the change to take effect.

```bash
# Confirm you can run Docker without sudo
docker run hello-world
```

> **Security note**: Members of the `docker` group have privileges equivalent to the `root` user. Only add trusted users to this group.

### Enable Docker to start on boot (Debian/Ubuntu)

On Debian/Ubuntu, Docker is usually enabled automatically. To confirm:

```bash
sudo systemctl enable docker
sudo systemctl enable containerd
```

---

## Verifying Docker Compose

Docker Compose ships as a plugin alongside Docker Engine in the installation above. Verify it is available:

```bash
docker compose version
```

Expected output (version numbers may differ):

```
Docker Compose version v2.x.x
```

---

## Uninstalling Docker

If you need to remove Docker from the system:

### Debian / Ubuntu

```bash
sudo apt purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
sudo rm /etc/apt/sources.list.d/docker.list
sudo rm /etc/apt/keyrings/docker.gpg
```

### RHEL / Fedora

```bash
sudo dnf remove docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
```

---

## Troubleshooting

**Cannot connect to the Docker daemon**
Ensure the service is running:
```bash
sudo systemctl status docker
sudo systemctl start docker
```

**Permission denied when running docker**
You have not yet logged out after adding your user to the `docker` group. Run `newgrp docker` or start a new terminal session.

**Package not found after adding repository**
Run `sudo apt update` (Debian/Ubuntu) or `sudo dnf makecache` (RHEL/Fedora) to refresh the package index before installing.

**Kernel version too old**
Run `uname -r` to check. Docker requires kernel 3.10+. Update your OS or kernel before proceeding.
