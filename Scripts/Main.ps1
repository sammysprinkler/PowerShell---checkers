# MainScript.ps1
# Description: The main entry point script to initialize all modules and run checks.

# Import modules in the required order
Write-Host -ForegroundColor Yellow "Importing modules..."

# 1. Load EnvLoader first to set environment variables
Import-Module "${PSScriptRoot}\Modules\EnvLoader.psm1" -ErrorAction Stop

# 2. Load other modules, which may depend on the environment variables
Import-Module "${PSScriptRoot}\Modules\ConfigLoader.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\Modules\Logger.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\Modules\NetworkUtils.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\Modules\FileHasher.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\Modules\PathLoader.psm1" -ErrorAction Stop

# Step 1: Load environment variables
Write-Host -ForegroundColor Yellow "Loading environment variables..."
if (-not (Import-EnvFile)) {
    Write-Host -ForegroundColor Red "Failed to load environment variables. Exiting."
    exit 1
}

# Step 2: Load configuration, which depends on environment variables
Write-Host -ForegroundColor Yellow "Loading configuration..."
try {
    $config = Get-Config -FilePath "${PSScriptRoot}\config.json"
    Write-Host -ForegroundColor Green "Configuration loaded successfully."
} catch {
    Write-Host -ForegroundColor Red "Failed to load configuration: $_"
    exit 1
}

# Step 3: Initialize Logging Directory
$logDir = [System.Environment]::ExpandEnvironmentVariables($config.Paths.LogDirectory)
if (!(Test-Path -Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    Write-Host -ForegroundColor Green "Log directory created at $logDir"
}

# Step 4: Run the individual scripts or functions in the correct order
Write-Host -ForegroundColor Yellow "Starting individual scripts..."

# Example of running a specific script or function
& "${PSScriptRoot}\Scripts\CheckNetworkConnections.ps1"
& "${PSScriptRoot}\Scripts\CheckRunningProcesses.ps1"
& "${PSScriptRoot}\Scripts\CheckSystemLogs.ps1"
& "${PSScriptRoot}\Scripts\CheckUnauthorizedFileChanges.ps1"

Write-Host -ForegroundColor Green "All checks completed successfully."
