# TestConfigAndEnvLoader.ps1

# Import EnvLoader and ConfigLoader
Import-Module "${PSScriptRoot}\..\Modules\EnvLoader.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\..\Modules\ConfigLoader.psm1" -ErrorAction Stop

# Step 1: Load environment variables
Write-Host -ForegroundColor Yellow "Testing Import-EnvFile function..."
if (-not (Import-EnvFile)) {
    Write-Host -ForegroundColor Red "Import-EnvFile failed to load variables. Exiting test."
    exit 1
}

# Step 2: Load configuration
Write-Host -ForegroundColor Yellow "Testing Get-Config function..."
try {
    $config = Get-Config -FilePath "${PSScriptRoot}\..\config.json"
    Write-Host -ForegroundColor Green "Configuration loaded successfully: "
    $config | Format-List
} catch {
    Write-Host -ForegroundColor Red "Error loading configuration: $_"
}
