# CheckNetworkConnections.ps1
# Description: Checks for established network connections on suspicious ports.

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
    $LogFilePath = Join-Path -Path $LogDirectory -ChildPath "NetworkConnectionsCheck_$Timestamp.txt"

    if (-not $LogFilePath) {
        throw "LogFilePath cannot be null or empty."
    }
    Write-Host "Log file path set to $LogFilePath"
} catch {
    Write-Host "Error initializing log file path: $_" -ForegroundColor Red
    exit 1
}

# Header with environment and configuration info
Write-Log -Message "==== Network Connection Check Report ====" -LogLevel "INFO" -LogFilePath $LogFilePath
Write-Log -Message "Date: $(Get-Date)" -LogLevel "INFO" -LogFilePath $LogFilePath
Write-Log -Message "Environment: User - $env:USERPROFILE | Hostname - $env:COMPUTERNAME" -LogLevel "INFO" -LogFilePath $LogFilePath
Write-Log -Message "Suspicious Ports: $($config.SuspiciousPorts -join ', ')" -LogLevel "INFO" -LogFilePath $LogFilePath
Write-Log -Message "========================================" -LogLevel "INFO" -LogFilePath $LogFilePath

# Step 4: Perform the Network Connection Check
Write-Log -Message "Starting network connection check..." -LogLevel "INFO" -LogFilePath $LogFilePath

# Initialize counters and log suspicious connections separately for easy reference
$suspiciousConnections = 0
$totalConnectionsChecked = 0
$suspiciousDetails = @()

try {
    Get-NetTCPConnection | ForEach-Object {
        $totalConnectionsChecked++
        $connectionDetails = "LocalPort: $($_.LocalPort), RemoteAddress: $($_.RemoteAddress), State: $($_.State)"

        # Log each connection checked
        Write-Log -Message "Checking connection: $connectionDetails" -LogLevel "INFO" -LogFilePath $LogFilePath

        # Check if connection matches suspicious criteria
        if ($_.State -eq 'Established' -and $config.SuspiciousPorts -contains $_.LocalPort) {
            $suspiciousConnections++
            $suspiciousDetails += "Suspicious connection detected: $connectionDetails"
        }
    }

    # Summarize suspicious connections if any found
    if ($suspiciousConnections -gt 0) {
        Write-Log -Message "==== Suspicious Connections Detected ====" -LogLevel "WARNING" -LogFilePath $LogFilePath
        foreach ($detail in $suspiciousDetails) {
            Write-Log -Message $detail -LogLevel "WARNING" -LogFilePath $LogFilePath
        }
    } else {
        Write-Log -Message "No suspicious connections detected." -LogLevel "INFO" -LogFilePath $LogFilePath
    }

    # Summary of findings
    Write-Log -Message "==== Summary of Network Connection Check ====" -LogLevel "INFO" -LogFilePath $LogFilePath
    Write-Log -Message "Total Connections Checked: $totalConnectionsChecked" -LogLevel "INFO" -LogFilePath $LogFilePath
    Write-Log -Message "Total Suspicious Connections Detected: $suspiciousConnections" -LogLevel ($suspiciousConnections -gt 0 ? "WARNING" : "INFO") -LogFilePath $LogFilePath

} catch {
    Write-Log -Message "Error during network check: $_" -LogLevel "ERROR" -LogFilePath $LogFilePath
    exit 1
}

# Final log entry indicating completion
Write-Log -Message "Network connection check completed." -LogLevel "INFO" -LogFilePath $LogFilePath
