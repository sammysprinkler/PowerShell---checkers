# CheckNetworkConnections.ps1
# Description: Checks for established network connections on suspicious ports.

# Import necessary modules
Import-Module "${PSScriptRoot}\..\Modules\ConfigLoader.psm1"
Import-Module "${PSScriptRoot}\..\Modules\PathLoader.psm1"
Import-Module "${PSScriptRoot}\..\Modules\EnvLoader.psm1"
Import-Module "${PSScriptRoot}\..\Modules\Logger.psm1"

# Load environment variables
Import-EnvFile

# Load configurations and paths
$config = Get-Config -FilePath "${PSScriptRoot}\..\config.json"
$paths = Get-Paths -FilePath "${PSScriptRoot}\..\paths.json"

# Access paths and configurations
$LogDirectory = $paths.LogDirectory
$SuspiciousPorts = $config.SuspiciousPorts

# Initialize log file
$Timestamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
$OutputFile = Join-Path -Path $LogDirectory -ChildPath "NetworkConnectionsCheck_$Timestamp.txt"

# Start the network connection check
Write-Log -Message "Starting network connection check..." -LogFilePath $OutputFile -LogLevel "INFO"

try {
    Get-NetTCPConnection | ForEach-Object {
        if ($_.State -eq 'Established' -and $SuspiciousPorts -contains $_.LocalPort) {
            Write-Log -Message "Suspicious connection detected: LocalPort $($_.LocalPort)" -LogFilePath $OutputFile -LogLevel "WARNING"
        }
    }
} catch {
    Write-Log -Message "Error occurred while checking network connections: $_" -LogFilePath $OutputFile -LogLevel "ERROR"
}

Write-Log -Message "Network connection check completed." -LogFilePath $OutputFile -LogLevel "INFO"
