# CheckRunningProcesses.ps1
# Description: Checks for running processes that match a list of suspicious processes.

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
    $LogFilePath = Join-Path -Path $LogDirectory -ChildPath "RunningProcessesCheck_$Timestamp.txt"

    if (-not $LogFilePath) {
        throw "LogFilePath cannot be null or empty."
    }
    Write-Host "Log file path set to $LogFilePath"
} catch {
    Write-Host "Error initializing log file path: $_" -ForegroundColor Red
    exit 1
}

# Header with environment and configuration info
Write-Log -Message "==== Running Processes Check Report ====" -LogLevel "INFO" -LogFilePath $LogFilePath
Write-Log -Message "Date: $(Get-Date)" -LogLevel "INFO" -LogFilePath $LogFilePath
Write-Log -Message "Environment: User - $env:USERPROFILE | Hostname - $env:COMPUTERNAME" -LogLevel "INFO" -LogFilePath $LogFilePath
Write-Log -Message "Suspicious Processes: $($config.SuspiciousProcesses -join ', ')" -LogLevel "INFO" -LogFilePath $LogFilePath
Write-Log -Message "========================================" -LogLevel "INFO" -LogFilePath $LogFilePath

# Step 4: Perform Process Check
Write-Log -Message "Starting process check for suspicious activity..." -LogLevel "INFO" -LogFilePath $LogFilePath

# Initialize counters and log suspicious processes separately for easy reference
$suspiciousProcessesFound = 0
$totalProcessesChecked = 0
$suspiciousDetails = @()

try {
    Get-Process | ForEach-Object {
        $totalProcessesChecked++
        $processName = $_.ProcessName.ToLower()
        $processDetails = "ProcessName: $($processName), PID: $($_.Id), CPU: $($_.CPU), Memory: $([math]::Round($_.WS / 1MB, 2)) MB"

        # Log each process checked
        Write-Log -Message "Checking process: $processDetails" -LogLevel "INFO" -LogFilePath $LogFilePath

        # Check if process matches any suspicious process names
        if ($config.SuspiciousProcesses -contains $processName) {
            $suspiciousProcessesFound++
            $suspiciousDetails += "Suspicious process detected: $processDetails"
        }
    }

    # Summarize suspicious processes if any found
    if ($suspiciousProcessesFound -gt 0) {
        Write-Log -Message "==== Suspicious Processes Detected ====" -LogLevel "WARNING" -LogFilePath $LogFilePath
        foreach ($detail in $suspiciousDetails) {
            Write-Log -Message $detail -LogLevel "WARNING" -LogFilePath $LogFilePath
        }
    } else {
        Write-Log -Message "No suspicious processes detected." -LogLevel "INFO" -LogFilePath $LogFilePath
    }

    # Summary of findings
    Write-Log -Message "==== Summary of Process Check ====" -LogLevel "INFO" -LogFilePath $LogFilePath
    Write-Log -Message "Total Processes Checked: $totalProcessesChecked" -LogLevel "INFO" -LogFilePath $LogFilePath
    Write-Log -Message "Total Suspicious Processes Detected: $suspiciousProcessesFound" -LogLevel ($suspiciousProcessesFound -gt 0 ? "WARNING" : "INFO") -LogFilePath $LogFilePath

} catch {
    Write-Log -Message "Error occurred while checking processes: $_" -LogLevel "ERROR" -LogFilePath $LogFilePath
    exit 1
}

# Final log entry indicating completion
Write-Log -Message "Process check completed." -LogLevel "INFO" -LogFilePath $LogFilePath
