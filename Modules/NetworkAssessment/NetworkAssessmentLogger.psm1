# NetworkAssessmentLogger.psm1
# Extends the main Logger module with network-specific logging functionality

# Import core logging functionality
Import-Module "${PSScriptRoot}\..\Logger.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\..\EnvLoader.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\..\ConfigLoader.psm1" -ErrorAction Stop

# Load environment variables
Import-EnvFile

# Load network assessment configuration
$ConfigPath = "${PSScriptRoot}\..\NetworkAssessmentConfig.json"
try {
    $config = Get-Config -FilePath $ConfigPath
} catch {
    Write-Output "Error loading configuration from $($ConfigPath): $($_)"
    return
}

# Ensure PROJECT_ROOT is set in the environment variables, else use default
if (-not $env:PROJECT_ROOT) {
    $env:PROJECT_ROOT = (Get-Item -Path "${PSScriptRoot}\..").FullName
}

# Resolve the Log Directory path
$LogDirectory = $config.LogDirectory -replace '\${env:PROJECT_ROOT}', $($env:PROJECT_ROOT)

# Validate the Log Directory path and create it if it doesn't exist
if ([string]::IsNullOrWhiteSpace($LogDirectory)) {
    Write-Output "Error: LogDirectory path is not defined in NetworkAssessmentConfig.json."
    return
} elseif (!(Test-Path -Path $LogDirectory)) {
    try {
        New-Item -Path $LogDirectory -ItemType Directory -Force | Out-Null
    } catch {
        Write-Output "Error creating log directory at $($LogDirectory): $($_)"
        return
    }
}

# Define the NetworkAssessment log file path
$LogFilePath = Join-Path -Path $LogDirectory -ChildPath "NetworkAssessment.log"

# Wrapper for network-specific logging, using the main logger
function Write-NetworkLog {
    param (
        [string]$Message,
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$LogLevel = "INFO",
        [switch]$IsAlert  # Use this switch to highlight important log entries
    )

    # Use the core Write-Log function from Logger.psm1
    Write-Log -Message $Message -LogFilePath $LogFilePath -LogLevel $LogLevel -ConsoleOutput -IsAlert:$IsAlert
}

# Export Write-NetworkLog for external use
Export-ModuleMember -Function Write-NetworkLog
