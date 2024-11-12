# CheckSystemLogs.ps1
# Description: Analyzes system logs for errors or unauthorized access attempts.

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
$ErrorKeywords = $config.ErrorKeywords
$MaxLogEntries = $config.MaxLogEntries

# Initialize log file
$Timestamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
$OutputFile = Join-Path -Path $LogDirectory -ChildPath "SystemLogsCheck_$Timestamp.txt"

# Start log analysis
Write-Log -Message "Starting system log check..." -LogFilePath $OutputFile -LogLevel "INFO"

try {
    Get-EventLog -LogName Security -Newest $MaxLogEntries | ForEach-Object {
        if ($_.Message -match ($ErrorKeywords -join "|")) {
            Write-Log -Message "Suspicious log entry detected: $($_.Message)" -LogFilePath $OutputFile -LogLevel "WARNING"
        }
    }
} catch {
    Write-Log -Message "Error occurred while checking system logs: $_" -LogFilePath $OutputFile -LogLevel "ERROR"
}

Write-Log -Message "System log check completed." -LogFilePath $OutputFile -LogLevel "INFO"
