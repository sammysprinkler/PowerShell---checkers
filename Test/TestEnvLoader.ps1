# TestEnvLoader.ps1
# Description: Tests the EnvLoader module for loading environment variables.

# Import the module
Import-Module -Name "${PSScriptRoot}\..\Modules\EnvLoader.psm1" -ErrorAction Stop

# Function to print messages in color
function Write-ColorMessage {
    param (
        [string]$Message,
        [string]$Color
    )
    switch ($Color) {
        "Yellow" { Write-Host $Message -ForegroundColor Yellow }
        "Red"    { Write-Host $Message -ForegroundColor Red }
        "Blue"   { Write-Host $Message -ForegroundColor Blue }
        "Green"  { Write-Host $Message -ForegroundColor Green }
        default  { Write-Host $Message }
    }
}

# Test function to load environment variables from .env file
function Test-ImportEnvFile {
    Write-ColorMessage "Testing Import-EnvFile function..." "Yellow"

    # Clear specific environment variables for testing
    $variablesToClear = @("GITHUB_USERNAME", "GITHUB_EMAIL", "GITHUB_TOKEN", "PROJECT_ROOT", "USERPROFILE", "PUBLIC_IP")
    foreach ($var in $variablesToClear) {
        Remove-Item Env:\$var -ErrorAction SilentlyContinue
    }

    # Attempt to load environment variables
    $result = Import-EnvFile
    if ($result) {
        Write-ColorMessage "Environment variables loaded successfully." "Green"

        $variablesToCheck = @("GITHUB_USERNAME", "GITHUB_EMAIL", "GITHUB_TOKEN", "USERPROFILE", "PROJECT_ROOT", "PUBLIC_IP")
        foreach ($var in $variablesToCheck) {
            $value = [Environment]::GetEnvironmentVariable($var)
            if ($null -ne $value) {
                Write-ColorMessage "$var is set to $value" "Blue"
            } else {
                Write-ColorMessage "Error: $var failed to load" "Red"
            }
        }
    } else {
        Write-ColorMessage "Import-EnvFile failed to load variables" "Red"
    }
}

# Run the test
Test-ImportEnvFile
