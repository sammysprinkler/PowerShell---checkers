# PowerShell Script: CheckSystemLogs.ps1
# Description: Analyzes the security log for suspicious entries.

# Import necessary modules
Import-Module "${PSScriptRoot}\..\Modules\EnvLoader.psm1"
Import-Module "${PSScriptRoot}\..\Modules\ConfigLoader.psm1"
Import-Module "${PSScriptRoot}\..\Modules\Logger.psm1"

# Load environment variables
Import-EnvFile

# Load configuration
$config = Get-Config

# Use configuration settings
$LogDirectory = $config.LogDirectory
$MaxLogEntries = $config.MaxLogEntries
$ErrorKeywords = $config.ErrorKeywords
$Timestamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
$OutputFile = Join-Path -Path $LogDirectory -ChildPath "SystemLogsCheck_$Timestamp.txt"

# Start system log check
Write-Log -Message "Starting system log check..." -LogFilePath $OutputFile -LogLevel "INFO"

try {
    Write-Log -Message "Reading the latest $MaxLogEntries entries from the Security log..." -LogFilePath $OutputFile -LogLevel "INFO"

    Get-EventLog -LogName Security -Newest $MaxLogEntries | ForEach-Object {
        if ($ErrorKeywords | ForEach-Object { $_.ToLower() } -any { $_ -match $_.Message.ToLower() }) {
            Write-Log -Message "Suspicious log entry detected: $($_.Message)" -LogFilePath $OutputFile -LogLevel "WARNING"
        }
    }
} catch {
    Write-Log -Message "Error occurred while accessing system logs: $_" -LogFilePath $OutputFile -LogLevel "ERROR"
}

Write-Log -Message "System log check completed." -LogFilePath $OutputFile -LogLevel "INFO"
