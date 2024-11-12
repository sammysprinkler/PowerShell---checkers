# PowerShell Script: CheckNetworkConnections.ps1
# Description: Checks for established network connections on suspicious ports.

# Import necessary modules
Import-Module "${PSScriptRoot}\..\Modules\EnvLoader.psm1"
Import-Module "${PSScriptRoot}\..\Modules\ConfigLoader.psm1"
Import-Module "${PSScriptRoot}\..\Modules\Logger.psm1"
Import-Module "${PSScriptRoot}\..\Modules\NetworkUtils.psm1"

# Load environment variables
Import-EnvFile

# Load configuration
$config = Get-Config

# Use configuration settings
$SuspiciousPorts = $config.SuspiciousPorts
$LogDirectory = $config.LogDirectory
$Timestamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
$OutputFile = Join-Path -Path $LogDirectory -ChildPath "NetworkConnectionsCheck_$Timestamp.txt"

# Start the network connection check
Write-Log -Message "Starting network connection check..." -LogFilePath $OutputFile -LogLevel "INFO"

try {
    Test-SuspiciousPorts -SuspiciousPorts $SuspiciousPorts | ForEach-Object {
        Write-Log -Message "Suspicious port open: $($_.LocalPort)" -LogFilePath $OutputFile -LogLevel "WARNING"
    }
} catch {
    Write-Log -Message "Error occurred while checking network connections: $_" -LogFilePath $OutputFile -LogLevel "ERROR"
}

Write-Log -Message "Network connection check completed." -LogFilePath $OutputFile -LogLevel "INFO"
