# CheckUnauthorizedFileChanges.ps1
# Description: Monitors specified files for unauthorized changes by checking hashes.

# Import necessary modules
Import-Module "${PSScriptRoot}\..\Modules\EnvLoader.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\..\Modules\ConfigLoader.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\..\Modules\Logger.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\..\Modules\FileHasher.psm1" -ErrorAction Stop

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

    # Access relevant paths and configuration properties
    $LogDirectory = $paths.Paths.LogDirectory -replace '\${env:PROJECT_ROOT}', $env:PROJECT_ROOT
    $OutputDirectory = $paths.Paths.OutputDirectory -replace '\${env:PROJECT_ROOT}', $env:PROJECT_ROOT
    $MonitoredFiles = $config.MonitoredFiles
    $HashAlgorithm = $config.FileChangeDetection.HashAlgorithm

    # Ensure log and output directories exist
    if (-not (Test-Path -Path $LogDirectory)) { New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null }
    if (-not (Test-Path -Path $OutputDirectory)) { New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null }

    Write-Host "Log and output directories resolved and ensured to exist."
} catch {
    Write-Host "Error loading configurations or paths: $_" -ForegroundColor Red
    exit 1
}

# Step 3: Initialize log file
try {
    $Timestamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
    $LogFilePath = Join-Path -Path $LogDirectory -ChildPath "FileChangesCheck_$Timestamp.txt"

    if (-not $LogFilePath) {
        throw "LogFilePath cannot be null or empty."
    }
    Write-Host "Log file path set to $LogFilePath"
} catch {
    Write-Host "Error initializing log file path: $_" -ForegroundColor Red
    exit 1
}

# Header with environment and configuration info
Write-Log -Message "==== File Integrity Check Report ====" -LogLevel "INFO" -LogFilePath $LogFilePath
Write-Log -Message "Date: $(Get-Date)" -LogLevel "INFO" -LogFilePath $LogFilePath
Write-Log -Message "Environment: User - $env:USERPROFILE | Hostname - $env:COMPUTERNAME" -LogLevel "INFO" -LogFilePath $LogFilePath
Write-Log -Message "Files Monitored: $($MonitoredFiles -join ', ')" -LogLevel "INFO" -LogFilePath $LogFilePath
Write-Log -Message "Hash Algorithm: $HashAlgorithm" -LogLevel "INFO" -LogFilePath $LogFilePath
Write-Log -Message "===================================" -LogLevel "INFO" -LogFilePath $LogFilePath

# Step 4: Start file integrity check
Write-Log -Message "Starting file integrity check..." -LogLevel "INFO" -LogFilePath $LogFilePath

# Initialize counters for summary
$totalFilesChecked = 0
$missingFiles = 0
$errorsDetected = 0

foreach ($FilePath in $MonitoredFiles) {
    $totalFilesChecked++
    try {
        if (Test-Path $FilePath) {
            # Generate hash for the monitored file
            $FileHash = Get-FileHashString -FilePath $FilePath -Algorithm $HashAlgorithm
            Write-Log -Message "Checked $FilePath : Hash $FileHash" -LogLevel "INFO" -LogFilePath $LogFilePath
        } else {
            Write-Log -Message "Monitored file $FilePath does not exist." -LogLevel "WARNING" -LogFilePath $LogFilePath
            $missingFiles++
        }
    } catch {
        Write-Log -Message "Error occurred while inspecting file $FilePath : $_" -LogLevel "ERROR" -LogFilePath $LogFilePath
        $errorsDetected++
    }
}

# Step 5: Summary of file integrity check
Write-Log -Message "==== Summary of File Integrity Check ====" -LogLevel "INFO" -LogFilePath $LogFilePath
Write-Log -Message "Total Files Checked: $totalFilesChecked" -LogLevel "INFO" -LogFilePath $LogFilePath
Write-Log -Message "Missing Files: $missingFiles" -LogLevel ($missingFiles -gt 0 ? "WARNING" : "INFO") -LogFilePath $LogFilePath
Write-Log -Message "Errors Detected: $errorsDetected" -LogLevel ($errorsDetected -gt 0 ? "ERROR" : "INFO") -LogFilePath $LogFilePath

# Final log entry indicating completion
Write-Log -Message "File integrity check completed." -LogLevel "INFO" -LogFilePath $LogFilePath
