# TestConfigLoader.ps1
# Script to test the ConfigLoader module with color-coded logging for debugging

# Import the ConfigLoader module
Import-Module "${PSScriptRoot}\..\Modules\ConfigLoader.psm1" -ErrorAction Stop

# Helper function to output color-coded messages for different log levels
function Write-ColorLog {
    param (
        [string]$Message,
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level
    )

    switch ($Level) {
        "INFO" { Write-Host $Message -ForegroundColor Cyan }
        "WARNING" { Write-Host $Message -ForegroundColor Yellow }
        "ERROR" { Write-Host $Message -ForegroundColor Red }
        "SUCCESS" { Write-Host $Message -ForegroundColor Green }
    }
}

# Start test
Write-ColorLog "Testing Get-Config function..." "INFO"

# Test: Locate and load the configuration
try {
    $config = Get-Config
    if ($null -ne $config) {
        Write-ColorLog "Configuration loaded successfully from config.json" "SUCCESS"

        # Loop through each key-value pair in the config and log its contents
        foreach ($key in $config.Keys) {
            $value = $config[$key]
            Write-ColorLog "Key: $key, Value: $value" "INFO"
        }
    } else {
        Write-ColorLog "Error: Configuration could not be loaded." "ERROR"
    }
} catch {
    Write-ColorLog "Exception occurred during config loading: $_" "ERROR"
}

# Test: Specific config keys to validate environment variable expansion
Write-ColorLog "Validating expanded paths and placeholders in config..." "INFO"

# Define keys to check (modify as needed based on your config structure)
$expectedKeys = @("Paths.LogDirectory", "Paths.OutputDirectory", "GitHubCredentials.Username", "SystemPaths.HostsFilePath")

foreach ($keyPath in $expectedKeys) {
    # Split the keyPath into individual keys for nested retrieval
    $keys = $keyPath -split '\.'
    $current = $config
    foreach ($key in $keys) {
        if ($current -and $current.PSObject.Properties[$key]) {
            $current = $current.$key
        } else {
            Write-ColorLog "Error: Key $keyPath not found in the config." "ERROR"
            $current = $null
            break
        }
    }

    if ($null -ne $current) {
        Write-ColorLog "Expanded ${keyPath}: $current" "SUCCESS"
    } else {
        Write-ColorLog "Error: Could not expand $keyPath." "ERROR"
    }
}

Write-ColorLog "ConfigLoader module test completed." "INFO"
