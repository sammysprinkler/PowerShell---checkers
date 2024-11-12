# PowerShell Script: CheckRunningProcesses.ps1
# Description: Checks for specific suspicious processes running on the system.

# Import necessary modules
Import-Module "${PSScriptRoot}\..\Modules\EnvLoader.psm1"
Import-Module "${PSScriptRoot}\..\Modules\ConfigLoader.psm1"
Import-Module "${PSScriptRoot}\..\Modules\Logger.psm1"

# Load environment variables
Import-EnvFile

# Load configuration
$config = Get-Config

# Use configuration settings
$SuspiciousProcesses = $config.SuspiciousProcesses
$LogDirectory = $config.LogDirectory
$Timestamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
$OutputFile = Join-Path -Path $LogDirectory -ChildPath "RunningProcessesCheck_$Timestamp.txt"

# Start process check
Write-Log -Message "Starting process check for suspicious activity..." -LogFilePath $OutputFile -LogLevel "INFO"

try {
    Get-Process | ForEach-Object {
        $ProcessName = $_.ProcessName.ToLower()
        if ($SuspiciousProcesses -contains $ProcessName) {
            Write-Log -Message "Suspicious process found: PID $($_.Id) - $($_.ProcessName)" -LogFilePath $OutputFile -LogLevel "WARNING"
        }
    }
} catch {
    Write-Log -Message "Error occurred while retrieving processes: $_" -LogFilePath $OutputFile -LogLevel "ERROR"
}

Write-Log -Message "Process check completed." -LogFilePath $OutputFile -LogLevel "INFO"
