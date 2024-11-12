# CheckNetworkConnections.ps1
# Description: Checks for established network connections on suspicious ports.

# Import necessary modules
Import-Module "${PSScriptRoot}\..\Modules\ConfigLoader.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\..\Modules\PathLoader.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\..\Modules\EnvLoader.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\..\Modules\Logger.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\..\Modules\NetworkUtils.psm1" -ErrorAction Stop

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
    Write-Host "Configurations and paths loaded successfully."
} catch {
    Write-Host "Error loading configurations or paths: $_"
    exit 1
}

# Set up log file
$LogDirectory = $paths.LogDirectory
if (!(Test-Path -Path $LogDirectory)) {
    New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
}

$Timestamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
$OutputFile = Join-Path -Path $LogDirectory -ChildPath "NetworkConnectionsCheck_$Timestamp.txt"
Write-Log -Message "Starting network connection check..." -LogFilePath $OutputFile -LogLevel "INFO"

# Get list of suspicious ports from the config
$SuspiciousPorts = $config.SuspiciousPorts

# Perform the network connection check
try {
    Get-NetTCPConnection | ForEach-Object {
        if ($_.State -eq 'Established' -and $SuspiciousPorts -contains $_.LocalPort) {
            $message = "Suspicious connection detected: LocalPort $($_.LocalPort), RemoteAddress $($_.RemoteAddress)"
            Write-Log -Message $message -LogFilePath $OutputFile -LogLevel "WARNING"
        }
    }
} catch {
    Write-Log -Message ("Error occurred while checking network connections: {0}" -f $_) -LogFilePath $OutputFile -LogLevel "ERROR"
}

Write-Log -Message "Network connection check completed." -LogFilePath $OutputFile -LogLevel "INFO"
