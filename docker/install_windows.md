# Docker Installation on Windows

# Author: Víctor Barceló

## Overview

On Windows, Docker is installed through **Docker Desktop**, an application that bundles the Docker Engine, Docker Compose, Docker CLI, and a graphical dashboard. Docker Desktop uses the **WSL 2** (Windows Subsystem for Linux 2) backend, which provides near-native Linux performance.

This guide covers installation on Windows 10 and Windows 11.

---

## Prerequisites

| Requirement | Detail |
|-------------|--------|
| OS version | Windows 10 64-bit version 21H2 or later, or Windows 11 |
| Architecture | x86-64 (AMD64) |
| RAM | 4 GB minimum, 8 GB recommended |
| BIOS/UEFI | Hardware virtualisation enabled (Intel VT-x / AMD-V) |
| Windows features | WSL 2 and Virtual Machine Platform |
| Disk space | At least 2 GB free for Docker Desktop itself |

---

## Step 1 — Enable WSL 2

Docker Desktop requires WSL 2. Open **PowerShell as Administrator** and run:

```powershell
wsl --install
```

This command installs WSL 2 and the default Ubuntu distribution in a single step. Restart your computer when prompted.

> If your system already has WSL installed, ensure you are on WSL 2:
> ```powershell
> wsl --set-default-version 2
> ```

To confirm WSL 2 is active after restart:

```powershell
wsl --list --verbose
```

The `VERSION` column should show `2` for your distribution.

---

## Step 2 — Download Docker Desktop

Download the Docker Desktop installer from the official Docker website:

```
https://docs.docker.com/desktop/install/windows-install/
```

Click **Docker Desktop for Windows** to download the installer (`Docker Desktop Installer.exe`).

---

## Step 3 — Run the Installer

1. Double-click `Docker Desktop Installer.exe`.
2. On the configuration screen, ensure **Use WSL 2 instead of Hyper-V** is selected (it should be selected by default on supported systems).
3. Click **OK** and wait for the installation to complete.
4. When prompted, click **Close and restart** to reboot your computer.

---

## Step 4 — Start Docker Desktop

After restarting:

1. Open Docker Desktop from the Start menu or the system tray icon.
2. Accept the Docker Subscription Service Agreement when prompted.
3. Wait for Docker Desktop to finish starting. The whale icon in the system tray will become steady (not animated) when Docker is ready.

---

## Step 5 — Verify the Installation

Open **PowerShell** or **Command Prompt** and run:

```powershell
docker --version
docker compose version
docker run hello-world
```

Expected output for `docker run hello-world`:

```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

---

## Using Docker from WSL 2 (Recommended)

Docker Desktop automatically integrates with WSL 2 distributions. You can run Docker commands directly inside your Linux terminal:

1. Open your WSL 2 terminal (e.g., Ubuntu from the Start menu).
2. Run:

```bash
docker --version
docker run hello-world
```

This is the recommended workflow for development, as it provides a full Linux environment alongside Docker.

---

## Docker Desktop Dashboard

Docker Desktop provides a graphical interface to:

- View and manage running containers
- Browse local images
- Inspect container logs and resource usage
- Manage volumes and networks
- Access Docker Hub

The dashboard is accessible from the system tray icon or from the Start menu.

---

## Post-installation Configuration

### Allocate more resources to Docker

By default, Docker Desktop uses a portion of the host's CPU and memory. To adjust:

1. Open Docker Desktop.
2. Go to **Settings** (gear icon) > **Resources**.
3. Adjust the **CPU**, **Memory**, and **Disk image size** sliders as needed.
4. Click **Apply & restart**.

### Enable auto-start on login

In **Settings** > **General**, enable **Start Docker Desktop when you sign in** if you want Docker to launch automatically.

---

## Uninstalling Docker Desktop

To remove Docker Desktop and all its data:

1. Open **Settings** > **Apps** > **Installed apps** (Windows 11) or **Add or remove programs** (Windows 10).
2. Search for **Docker Desktop** and click **Uninstall**.
3. Optionally, remove leftover data:

```powershell
# Remove Docker Desktop data directories (run in PowerShell)
Remove-Item -Recurse -Force "$env:APPDATA\Docker"
Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Docker"
```

---

## Troubleshooting

**Docker Desktop fails to start — "WSL 2 installation is incomplete"**
Run `wsl --install` in an elevated PowerShell, restart, and try again. Also ensure Windows is up to date.

**Hardware virtualisation is disabled**
Restart the computer, enter the BIOS/UEFI setup, and enable **Intel VT-x** or **AMD-V** (also called AMD SVM). The exact option and location vary by manufacturer.

**"An unexpected error was encountered while executing a WSL command"**
Try restarting WSL from an elevated PowerShell:
```powershell
wsl --shutdown
```
Then reopen Docker Desktop.

**Docker commands are not recognised in PowerShell after installation**
Ensure Docker Desktop is running (check the system tray). Docker CLI is only available when the daemon is active.

**Slow file I/O when accessing Windows drives from containers**
This is expected behaviour when accessing Windows filesystems (e.g., `C:\`) from within WSL 2. Store project files inside the WSL 2 filesystem (e.g., `~/projects`) for significantly better performance.
