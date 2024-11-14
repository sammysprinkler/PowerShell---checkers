# CheckRunningProcesses.ps1
# Description: Checks for running processes that match a list of suspicious processes.

# Import Main module for core initialization
Import-Module "${PSScriptRoot}\..\Modules\Main.psm1" -ErrorAction Stop

# Initialize core environment (environment variables, configurations, paths)
try {
    Initialize-CoreEnvironment
} catch {
    Write-Host "Initialization failed: $_" -ForegroundColor Red
    exit 1
}

# Ensure that LogFilePath is available
if (-not $global:LogFilePath) {
    Write-Host "Error: LogFilePath is not set. Unable to log messages." -ForegroundColor Red
    exit 1
}

# Access suspicious processes from configuration
$SuspiciousProcesses = $global:Config.SuspiciousProcesses

# Log start of process check
Write-Log -Message "Starting process check for suspicious activity..." -LogFilePath $global:LogFilePath -LogLevel "INFO" -ConsoleOutput

# Perform process check and log results
try {
    Get-Process | ForEach-Object {
        $ProcessName = $_.ProcessName.ToLower()
        if ($SuspiciousProcesses -contains $ProcessName) {
            $message = "Suspicious process found: PID $($_.Id) - $($_.ProcessName)"
            Write-Log -Message $message -LogFilePath $global:LogFilePath -LogLevel "WARNING" -ConsoleOutput
        }
    }
} catch {
    Write-Log -Message "Error occurred while checking processes: $_" -LogFilePath $global:LogFilePath -LogLevel "ERROR" -ConsoleOutput
}

# Log completion of process check
Write-Log -Message "Process check completed." -LogFilePath $global:LogFilePath -LogLevel "INFO" -ConsoleOutput
