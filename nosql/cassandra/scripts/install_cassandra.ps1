# Run this script as Administrator
# Install Apache Cassandra on Windows
#
# IMPORTANT: Windows support notice
# - Cassandra 4.x can run natively on Windows but is NOT officially supported for production.
# - Cassandra 5.x dropped Windows support entirely.
# - Docker is the recommended and most reliable option for Windows students.
#
# This script will ask whether to install via Docker (recommended) or natively.

function Pause-AndExit($code) {
    Write-Host ""
    Read-Host "Press Enter to close"
    exit $code
}

# Configuration
$cassandraVersion = "4.1.8"   # Adjust version as needed
$installDir = "C:\cassandra"
$javaVersion = "11"

# Download URLs
$cassandraUrl = "https://downloads.apache.org/cassandra/$cassandraVersion/apache-cassandra-$cassandraVersion-bin.tar.gz"
$cassandraArchive = "$env:TEMP\apache-cassandra-$cassandraVersion-bin.tar.gz"

# ---------------------------------------------------------------
# Choose installation method
# ---------------------------------------------------------------
Write-Host ""
Write-Host "Cassandra installation method" -ForegroundColor Cyan
Write-Host "------------------------------" -ForegroundColor Cyan
Write-Host "[1] Docker (recommended for Windows - reliable, no Java config needed)"
Write-Host "[2] Native (Cassandra 4.x only, not officially supported on Windows)"
Write-Host "[3] Start web UI (DbGate - requires Cassandra already running via Docker)"
Write-Host ""
$choice = Read-Host "Enter your choice (1, 2, or 3)"

if ($choice -eq "3") {
    # ---------------------------------------------------------------
    # Web UI via Docker (DbGate)
    # ---------------------------------------------------------------
    Write-Host ""
    Write-Host "Starting DbGate web UI..." -ForegroundColor Green

    $dockerInstalled = Get-Command docker -ErrorAction SilentlyContinue
    if (-not $dockerInstalled) {
        Write-Host "Docker not found. Please install Docker Desktop first:" -ForegroundColor Red
        Write-Host "  https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
        Pause-AndExit 1
    }

    docker info 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Docker daemon is not running. Please start Docker Desktop first." -ForegroundColor Red
        Pause-AndExit 1
    }

    # Remove existing container if present
    docker rm -f dbgate 2>$null

    docker run --name dbgate `
        -p 3000:3000 `
        -d dbgate/dbgate:latest

    Write-Host ""
    Write-Host "DbGate is starting..." -ForegroundColor Green
    Start-Sleep -Seconds 5
    Write-Host ""
    Write-Host "Open your browser at: http://localhost:3000" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To connect to Cassandra inside DbGate:" -ForegroundColor Yellow
    Write-Host "  1. Click 'Add connection'"
    Write-Host "  2. Select 'Cassandra'"
    Write-Host "  3. Host: host.docker.internal   Port: 9042"
    Write-Host "  4. Click 'Connect'"
    Write-Host ""
    Write-Host "Stop UI:    docker stop dbgate"  -ForegroundColor Cyan
    Write-Host "Start UI:   docker start dbgate" -ForegroundColor Cyan
    Pause-AndExit 0
}

if ($choice -eq "1") {
    # ---------------------------------------------------------------
    # Docker installation
    # ---------------------------------------------------------------
    Write-Host ""
    Write-Host "Checking Docker installation..." -ForegroundColor Green

    $dockerInstalled = Get-Command docker -ErrorAction SilentlyContinue
    if (-not $dockerInstalled) {
        Write-Host "Docker not found. Please install Docker Desktop first:" -ForegroundColor Red
        Write-Host "  https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
        Write-Host "Then re-run this script." -ForegroundColor Yellow
        Pause-AndExit 1
    }

    # Verify the Docker daemon is actually running
    docker info 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Docker is installed but the daemon is not running." -ForegroundColor Red
        Write-Host "Please start Docker Desktop and wait for it to fully load, then re-run this script." -ForegroundColor Yellow
        Pause-AndExit 1
    }

    Write-Host "Docker found. Pulling Cassandra image..." -ForegroundColor Green
    docker pull cassandra:4.1

    Write-Host "Starting Cassandra container..." -ForegroundColor Green
    docker run --name cassandra `
        -p 9042:9042 `
        -e CASSANDRA_CLUSTER_NAME="USJCluster" `
        -d cassandra:4.1

    Write-Host ""
    Write-Host "Waiting for Cassandra to be ready (30 seconds)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30

    $status = docker inspect -f "{{.State.Status}}" cassandra 2>$null
    if ($status -ne "running") {
        Write-Host "Container failed to start. Check logs with: docker logs cassandra" -ForegroundColor Red
        exit 1
    }

    Write-Host ""
    Write-Host "Cassandra is running via Docker!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Useful commands:" -ForegroundColor Yellow
    Write-Host "  Connect:   docker exec -it cassandra cqlsh"       -ForegroundColor Cyan
    Write-Host "  Stop:      docker stop cassandra"                  -ForegroundColor Cyan
    Write-Host "  Start:     docker start cassandra"                 -ForegroundColor Cyan
    Write-Host "  Remove:    docker rm -f cassandra"                 -ForegroundColor Cyan
    Write-Host "  Logs:      docker logs cassandra"                  -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Default port:  9042" -ForegroundColor Yellow
    Pause-AndExit 0
}

# ---------------------------------------------------------------
# Native installation (Cassandra 4.x, unsupported on Windows)
# ---------------------------------------------------------------
Write-Host ""
Write-Host "Proceeding with native installation (Cassandra $cassandraVersion)..." -ForegroundColor Yellow
Write-Host "Note: This is not officially supported by the Apache Cassandra project on Windows." -ForegroundColor Yellow
Write-Host ""

# Step 1: Check/Install Java
Write-Host "Checking Java installation..." -ForegroundColor Green

$javaInstalled = Get-Command java -ErrorAction SilentlyContinue
if (-not $javaInstalled) {
    Write-Host "Java not found. Installing OpenJDK $javaVersion via winget..." -ForegroundColor Yellow
    winget install --id Microsoft.OpenJDK.$javaVersion --silent --accept-package-agreements --accept-source-agreements
    $env:JAVA_HOME = "C:\Program Files\Microsoft\jdk-$javaVersion"
    [Environment]::SetEnvironmentVariable("JAVA_HOME", $env:JAVA_HOME, [System.EnvironmentVariableTarget]::Machine)
    $env:Path += ";$env:JAVA_HOME\bin"
    [Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)
} else {
    Write-Host "Java is already installed:" -ForegroundColor Green
    java -version
}

# ---------------------------------------------------------------
# Step 2: Download Cassandra
# ---------------------------------------------------------------
Write-Host "Downloading Cassandra $cassandraVersion..." -ForegroundColor Green
Invoke-WebRequest -Uri $cassandraUrl -OutFile $cassandraArchive

# ---------------------------------------------------------------
# Step 3: Extract archive
# ---------------------------------------------------------------
Write-Host "Extracting Cassandra to $installDir..." -ForegroundColor Green

if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir | Out-Null
}

# tar is available on Windows 10/11 build 17063+
tar -xzf $cassandraArchive -C $installDir --strip-components=1

Remove-Item $cassandraArchive -Force

# ---------------------------------------------------------------
# Step 4: Set environment variables
# ---------------------------------------------------------------
Write-Host "Configuring environment variables..." -ForegroundColor Green

[Environment]::SetEnvironmentVariable("CASSANDRA_HOME", $installDir, [System.EnvironmentVariableTarget]::Machine)
$env:CASSANDRA_HOME = $installDir

$machinePath = [Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
if ($machinePath -notlike "*$installDir\bin*") {
    [Environment]::SetEnvironmentVariable("Path", "$machinePath;$installDir\bin", [System.EnvironmentVariableTarget]::Machine)
    $env:Path += ";$installDir\bin"
}

# ---------------------------------------------------------------
# Step 5: Install as a Windows service (optional)
# ---------------------------------------------------------------
Write-Host "Installing Cassandra as a Windows service..." -ForegroundColor Green
& "$installDir\bin\cassandra.ps1" install

# Start the service
Start-Service -Name "cassandra" -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Cassandra installation complete!" -ForegroundColor Green
Write-Host "Install directory: $installDir"            -ForegroundColor Yellow
Write-Host "Default CQL port:  9042"                   -ForegroundColor Yellow
Write-Host "Config file:       $installDir\conf\cassandra.yaml" -ForegroundColor Yellow
Write-Host "Log directory:     $installDir\logs\"      -ForegroundColor Yellow
Write-Host ""
Write-Host "Connect with: cqlsh" -ForegroundColor Cyan
Write-Host "Start manually: cassandra -f" -ForegroundColor Cyan

Pause-AndExit 0
