# Main.psm1
# Main module for initializing environment variables, configuration, and paths

# Import core modules
Import-Module "${PSScriptRoot}\EnvLoader.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\ConfigLoader.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\Logger.psm1" -ErrorAction Stop

# Core initialization function
function Initialize-CoreEnvironment {
    # Step 1: Load environment variables
    try {
        if (-not (Import-EnvFile)) {
            throw "Failed to load environment variables."
        }
        Write-Host "Environment variables loaded successfully."
    } catch {
        Write-Host "Error loading environment variables: $_" -ForegroundColor Red
        throw $_
    }

    # Step 2: Load configuration
    try {
        # Load configurations
        $global:Config = Get-Config -FilePath "${env:PROJECT_ROOT}\config.json"
        $global:Paths = Get-Config -FilePath "${env:PROJECT_ROOT}\paths.json"

        # Resolve log and output directories from config, replacing placeholders with actual values
        $global:LogDirectory = $Paths.Paths.LogDirectory -replace '\${env:PROJECT_ROOT}', $env:PROJECT_ROOT
        $global:OutputDirectory = $Paths.Paths.OutputDirectory -replace '\${env:PROJECT_ROOT}', $env:PROJECT_ROOT

        # Ensure directories exist
        if (-not (Test-Path -Path $global:LogDirectory)) {
            New-Item -ItemType Directory -Path $global:LogDirectory -Force | Out-Null
        }
        if (-not (Test-Path -Path $global:OutputDirectory)) {
            New-Item -ItemType Directory -Path $global:OutputDirectory -Force | Out-Null
        }

        # Set a unique LogFilePath for the current session
        $Timestamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
        $global:LogFilePath = Join-Path -Path $global:LogDirectory -ChildPath "ExecutionLog_$Timestamp.txt"

        Write-Host "LogFilePath set to $global:LogFilePath"
    } catch {
        Write-Host "Error loading configurations or setting paths: $_" -ForegroundColor Red
        throw $_
    }
}

# Ensure LogFilePath is not empty before proceeding
if (-not $global:LogFilePath) {
    throw "LogFilePath cannot be null or empty."
}

# Export the initialization function
Export-ModuleMember -Function Initialize-CoreEnvironment
