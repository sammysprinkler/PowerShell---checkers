# CheckNetworkConnections.ps1
# Description: Checks for established network connections on suspicious ports.

# Import necessary modules
Import-Module "${PSScriptRoot}\..\Modules\ConfigLoader.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\..\Modules\PathLoader.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\..\Modules\EnvLoader.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\..\Modules\Logger.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\..\Modules\NetworkUtils.psm1" -ErrorAction Stop

# Check if the script is running with administrator privileges
function Test-Admin {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "This script requires administrator privileges. Please run as administrator."
        Start-Process -FilePath "powershell" -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
}

# Call Test-Admin to ensure script is running with admin privileges
Test-Admin

# Load environment variables
try {
    Import-EnvFile
    Write-Host "Environment variables loaded successfully."
} catch {
    Write-Host "Failed to load environment variables: $_"
    exit 1
}

# Load configurations and paths
try {
    $config = Get-Config -FilePath "${PSScriptRoot}\..\config.json"
    $paths = Get-Paths -FilePath "${PSScriptRoot}\..\paths.json"

    # Use expanded log directory path
    $LogDirectory = $paths.LogDirectory
    Write-Host "Configurations and paths loaded successfully."
} catch {
    Write-Host "Error loading configurations or paths: $_"
    exit 1
}

# Ensure log directory exists
try {
    if (!(Test-Path -Path $LogDirectory)) {
        New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
        Write-Host "Log directory created at $LogDirectory"
    }
} catch {
    Write-Host "Error creating log directory: $_" -ForegroundColor Red
    exit 1
}

# Generate log file path with timestamp
$Timestamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
$OutputFile = Join-Path -Path $LogDirectory -ChildPath "NetworkConnectionsCheck_$Timestamp.txt"

# Log the start of the network connection check
Write-Log -Message "Starting network connection check..." -LogFilePath $OutputFile -LogLevel "INFO" -ConsoleOutput

# Get list of suspicious ports from the config
$SuspiciousPorts = $config.SuspiciousPorts

# Perform the network connection check
try {
    Get-NetTCPConnection | ForEach-Object {
        if ($_.State -eq 'Established' -and $SuspiciousPorts -contains $_.LocalPort) {
            $message = "Suspicious connection detected: LocalPort $($_.LocalPort), RemoteAddress $($_.RemoteAddress)"
            Write-Log -Message $message -LogFilePath $OutputFile -LogLevel "WARNING" -ConsoleOutput
        }
    }
} catch {
    Write-Log -Message ("Error occurred while checking network connections: {0}" -f $_) -LogFilePath $OutputFile -LogLevel "ERROR" -ConsoleOutput
}

# Log the completion of the network connection check
Write-Log -Message "Network connection check completed." -LogFilePath $OutputFile -LogLevel "INFO" -ConsoleOutput
