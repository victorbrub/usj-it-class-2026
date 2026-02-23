# Run this script as Administrator

# Configuration
$postgresVersion = "18"  # Adjust version as needed
$installDir = "C:\Program Files\PostgreSQL\18"
$dataDir = "C:\Program Files\PostgreSQL\18\data"
$postgresPassword = "postgres" 
$port = 5432

# Download URL (adjust version number as needed)
$downloadUrl = "https://get.enterprisedb.com/postgresql/postgresql-$postgresVersion-windows-x64.exe"
$installerPath = "$env:TEMP\postgresql-installer.exe"

Write-Host "Downloading PostgreSQL installer..." -ForegroundColor Green
Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath

Write-Host "Installing PostgreSQL with pgAdmin..." -ForegroundColor Green

# Silent installation arguments
$arguments = @(
    "--mode unattended",
    "--unattendedmodeui minimal",
    "--install_dir `"$installDir`"",
    "--datadir `"$dataDir`"",
    "--superpassword `"$postgresPassword`"",
    "--serverport $port",
    "--servicename postgresql",
    "--enable-components server,pgAdmin,commandlinetools"
)

Start-Process -FilePath $installerPath -ArgumentList $arguments -Wait -NoNewWindow

# Clean up installer
Remove-Item $installerPath -Force

# Add PostgreSQL to PATH
$env:Path += ";$installDir\bin"
[Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)

Write-Host "PostgreSQL installation completed!" -ForegroundColor Green
Write-Host "PostgreSQL installed at: $installDir" -ForegroundColor Yellow
Write-Host "Port: $port" -ForegroundColor Yellow
Write-Host "Superuser: postgres" -ForegroundColor Yellow
Write-Host "pgAdmin should be available in your Start Menu" -ForegroundColor Yellow

# Test connection (optional)
Write-Host "`nTesting PostgreSQL connection..." -ForegroundColor Green
& "$installDir\bin\psql.exe" -U postgres -c "SELECT version();"