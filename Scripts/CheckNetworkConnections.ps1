# CheckNetworkConnections.ps1
# Description: Checks for established network connections on suspicious ports.

# Import necessary modules
Import-Module "${PSScriptRoot}\..\Modules\ConfigLoader.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\..\Modules\EnvLoader.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\..\Modules\Logger.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\..\Modules\NetworkUtils.psm1" -ErrorAction Stop

# Ensure admin privileges
function Test-Admin {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "This script requires administrator privileges. Restarting with elevated permissions..."
        Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -Wait
        exit
    }
}
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
    $LogDirectory = $config.Paths.LogDirectory
    $OutputDirectory = $config.Paths.OutputDirectory

    Write-Host "Resolved LogDirectory: $LogDirectory"
    Write-Log -Message "Configurations and paths loaded successfully." -LogFilePath "$LogDirectory\execution.log" -LogLevel "INFO" -ConsoleOutput
} catch {
    Write-Host "Error loading configurations or paths: $_"
    exit 1
}

# Ensure log directory exists
try {
    if (!(Test-Path -Path $LogDirectory)) {
        New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
        Write-Host "Log directory created at $LogDirectory"
        Write-Log -Message "Log directory created at $LogDirectory" -LogFilePath "$LogDirectory\execution.log" -LogLevel "INFO" -ConsoleOutput
    }
} catch {
    Write-Host "Error creating log directory: $_" -ForegroundColor Red
    exit 1
}

# Generate log file path with timestamp
$Timestamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
$OutputFile = Join-Path -Path $LogDirectory -ChildPath "NetworkConnectionsCheck_$Timestamp.txt"

# Start network connection check
Write-Log -Message "Starting network connection check..." -LogFilePath $OutputFile -LogLevel "INFO" -ConsoleOutput
$SuspiciousPorts = $config.SuspiciousPorts

# Perform network connection check
try {
    Get-NetTCPConnection | ForEach-Object {
        if ($_.State -eq 'Established' -and $SuspiciousPorts -contains $_.LocalPort) {
            $message = "Suspicious connection detected: LocalPort $($_.LocalPort), RemoteAddress $($_.RemoteAddress)"
            Write-Log -Message $message -LogFilePath $OutputFile -LogLevel "WARNING" -ConsoleOutput
        }
    }
} catch {
    Write-Log -Message ("Error checking network connections: {0}" -f $_) -LogFilePath $OutputFile -LogLevel "ERROR" -ConsoleOutput
}

Write-Log -Message "Network connection check completed." -LogFilePath $OutputFile -LogLevel "INFO" -ConsoleOutput
