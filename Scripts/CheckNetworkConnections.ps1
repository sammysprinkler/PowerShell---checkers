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
    # Load configurations from config.json
    $config = Get-Config -FilePath "${env:PROJECT_ROOT}\config.json"
    # Load paths from paths.json
    $paths = Get-Config -FilePath "${env:PROJECT_ROOT}\paths.json"

    # Resolve LogDirectory and OutputDirectory paths, expanding any environment variables
    $LogDirectory = $paths.Paths.LogDirectory -replace '\${env:PROJECT_ROOT}', $env:PROJECT_ROOT
    $OutputDirectory = $paths.Paths.OutputDirectory -replace '\${env:PROJECT_ROOT}', $env:PROJECT_ROOT

    # Ensure directories exist
    if (-not (Test-Path -Path $LogDirectory)) {
        New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
    }
    if (-not (Test-Path -Path $OutputDirectory)) {
        New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
    }

    Write-Host "Log and output directories resolved and ensured to exist."
} catch {
    Write-Host "Error loading configurations or paths: $_" -ForegroundColor Red
    exit 1
}

# Step 3: Initialize Log File
try {
    $Timestamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
    $LogFilePath = Join-Path -Path $LogDirectory -ChildPath "NetworkConnectionsCheck_$Timestamp.txt"

    # Check if LogFilePath is set correctly
    if (-not $LogFilePath) {
        throw "LogFilePath cannot be null or empty."
    }

    Write-Host "Log file path set to $LogFilePath"
} catch {
    Write-Host "Error initializing log file path: $_" -ForegroundColor Red
    exit 1
}

# Step 4: Perform the Network Connection Check
Write-Log -Message "Starting network connection check..." -LogFilePath $LogFilePath -LogLevel "INFO" -ConsoleOutput

# Access suspicious ports from configuration
$SuspiciousPorts = $config.SuspiciousPorts
Write-Log -Message "Checking for connections on suspicious ports: $($SuspiciousPorts -join ', ')" -LogFilePath $LogFilePath -LogLevel "INFO" -ConsoleOutput

# Check for established connections on suspicious ports
try {
    $connectionsChecked = 0
    $suspiciousConnections = 0

    Get-NetTCPConnection | ForEach-Object {
        $connectionsChecked++
        $connectionDetails = "LocalPort: $($_.LocalPort), RemoteAddress: $($_.RemoteAddress), State: $($_.State)"

        # Log each connection
        Write-Log -Message "Checking connection: $connectionDetails" -LogFilePath $LogFilePath -LogLevel "INFO" -ConsoleOutput

        # If connection matches suspicious criteria, log as warning
        if ($_.State -eq 'Established' -and $SuspiciousPorts -contains $_.LocalPort) {
            $suspiciousConnections++
            Write-Log -Message "Suspicious connection detected: $connectionDetails" -LogFilePath $LogFilePath -LogLevel "WARNING" -ConsoleOutput
        }
    }

    Write-Log -Message "Total connections checked: $connectionsChecked" -LogFilePath $LogFilePath -LogLevel "INFO" -ConsoleOutput
    Write-Log -Message "Total suspicious connections detected: $suspiciousConnections" -LogFilePath $LogFilePath -LogLevel "INFO" -ConsoleOutput
} catch {
    Write-Log -Message "Error during network check: $_" -LogFilePath $LogFilePath -LogLevel "ERROR" -ConsoleOutput
    exit 1
}

# Final log entry indicating completion
Write-Log -Message "Network connection check completed." -LogFilePath $LogFilePath -LogLevel "INFO" -ConsoleOutput
