# CheckRunningProcesses.ps1
# Description: Checks for running processes that match a list of suspicious processes.

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
$SuspiciousProcesses = $config.SuspiciousProcesses

# Initialize log file
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
    Write-Log -Message "Error occurred while checking processes: $_" -LogFilePath $OutputFile -LogLevel "ERROR"
}

Write-Log -Message "Process check completed." -LogFilePath $OutputFile -LogLevel "INFO"
