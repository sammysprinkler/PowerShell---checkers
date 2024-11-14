# CheckSystemLogs.ps1
# Description: Analyzes system logs for errors or unauthorized access attempts.

# Import necessary modules
Import-Module "${PSScriptRoot}\..\Modules\EnvLoader.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\..\Modules\ConfigLoader.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\..\Modules\Logger.psm1" -ErrorAction Stop

# Step 1: Load environment variables
try {
    if (-not (Import-EnvFile)) {
        Write-Host "Error: Failed to load environment variables." -ForegroundColor Red
        exit 1
    }
    Write-Host "Environment variables loaded successfully."
} catch {
    Write-Host "Error loading environment variables: $_" -ForegroundColor Red
    exit 1
}

# Step 2: Load configurations and paths
try {
    $config = Get-Config -FilePath "${env:PROJECT_ROOT}\config.json"
    $paths = Get-Config -FilePath "${env:PROJECT_ROOT}\paths.json"

    $LogDirectory = $paths.Paths.LogDirectory -replace '\${env:PROJECT_ROOT}', $env:PROJECT_ROOT
    $OutputDirectory = $paths.Paths.OutputDirectory -replace '\${env:PROJECT_ROOT}', $env:PROJECT_ROOT

    # Ensure directories exist
    if (-not (Test-Path -Path $LogDirectory)) { New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null }
    if (-not (Test-Path -Path $OutputDirectory)) { New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null }

    Write-Host "Log and output directories resolved and ensured to exist."
} catch {
    Write-Host "Error loading configurations or paths: $_" -ForegroundColor Red
    exit 1
}

# Step 3: Initialize Log File
try {
    $Timestamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
    $LogFilePath = Join-Path -Path $LogDirectory -ChildPath "SystemLogsCheck_$Timestamp.txt"

    if (-not $LogFilePath) {
        throw "LogFilePath cannot be null or empty."
    }
    Write-Host "Log file path set to $LogFilePath"
} catch {
    Write-Host "Error initializing log file path: $_" -ForegroundColor Red
    exit 1
}

# Header with environment and configuration info
Write-Log -Message "==== System Logs Check Report ====" -LogLevel "INFO" -LogFilePath $LogFilePath
Write-Log -Message "Date: $(Get-Date)" -LogLevel "INFO" -LogFilePath $LogFilePath
Write-Log -Message "Environment: User - $env:USERPROFILE | Hostname - $env:COMPUTERNAME" -LogLevel "INFO" -LogFilePath $LogFilePath
Write-Log -Message "Keywords for Suspicious Logs: $($config.ErrorKeywords -join ', ')" -LogLevel "INFO" -LogFilePath $LogFilePath
Write-Log -Message "Max Log Entries Checked: $config.MaxLogEntries" -LogLevel "INFO" -LogFilePath $LogFilePath
Write-Log -Message "===================================" -LogLevel "INFO" -LogFilePath $LogFilePath

# Step 4: Analyze System Logs
Write-Log -Message "Starting system log check..." -LogLevel "INFO" -LogFilePath $LogFilePath

# Initialize counters and log suspicious entries separately for easy reference
$suspiciousEntriesFound = 0
$totalEntriesChecked = 0
$suspiciousDetails = @()

try {
    Get-EventLog -LogName Security -Newest $config.MaxLogEntries | ForEach-Object {
        $totalEntriesChecked++
        $logMessage = "EventID: $($_.EventID), EntryType: $($_.EntryType), Message: $($_.Message)"

        # Log each entry checked (optional for verbosity; remove if too detailed)
        Write-Log -Message "Checking log entry: $logMessage" -LogLevel "INFO" -LogFilePath $LogFilePath

        # Check if the log entry contains any of the defined suspicious keywords
        if ($_.Message -match ($config.ErrorKeywords -join "|")) {
            $suspiciousEntriesFound++
            $suspiciousDetails += "Suspicious entry detected: $logMessage"
        }
    }

    # Summarize suspicious entries if any found
    if ($suspiciousEntriesFound -gt 0) {
        Write-Log -Message "==== Suspicious Log Entries Detected ====" -LogLevel "WARNING" -LogFilePath $LogFilePath
        foreach ($detail in $suspiciousDetails) {
            Write-Log -Message $detail -LogLevel "WARNING" -LogFilePath $LogFilePath
        }
    } else {
        Write-Log -Message "No suspicious log entries detected." -LogLevel "INFO" -LogFilePath $LogFilePath
    }

    # Summary of findings
    Write-Log -Message "==== Summary of System Log Check ====" -LogLevel "INFO" -LogFilePath $LogFilePath
    Write-Log -Message "Total Entries Checked: $totalEntriesChecked" -LogLevel "INFO" -LogFilePath $LogFilePath
    Write-Log -Message "Total Suspicious Entries Detected: $suspiciousEntriesFound" -LogLevel ($suspiciousEntriesFound -gt 0 ? "WARNING" : "INFO") -LogFilePath $LogFilePath

} catch {
    Write-Log -Message "Error occurred while checking system logs: $_" -LogLevel "ERROR" -LogFilePath $LogFilePath
    exit 1
}

# Final log entry indicating completion
Write-Log -Message "System log check completed." -LogLevel "INFO" -LogFilePath $LogFilePath
