# TestConfigAndEnvLoader.ps1

# Import necessary modules
Import-Module "${PSScriptRoot}\..\Modules\EnvLoader.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\..\Modules\ConfigLoader.psm1" -ErrorAction Stop

# Set up log file
$Timestamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
$LogDirectory = "${PSScriptRoot}\..\Logs"
$LogFile = Join-Path -Path $LogDirectory -ChildPath "TestConfigAndEnvLoader_$Timestamp.txt"

# Ensure log directory exists
if (!(Test-Path -Path $LogDirectory)) {
    New-Item -ItemType Directory -Path $LogDirectory | Out-Null
}

# Function to log both to console and file
function Log-Output {
    param (
        [string]$Message,
        [string]$Color = "White"
    )
    # Write to console
    Write-Host $Message -ForegroundColor $Color
    # Write to log file
    Add-Content -Path $LogFile -Value $Message
}

# Step 1: Load environment variables
Log-Output "Testing Import-EnvFile function..." -Color Yellow
if (-not (Import-EnvFile)) {
    Log-Output "Import-EnvFile failed to load variables. Exiting test." -Color Red
    exit 1
}

# Display loaded environment variables with explanations
Log-Output "`nLoaded Environment Variables:" -Color Cyan
Get-ChildItem Env: | Where-Object { $_.Name -match "GITHUB|PUBLIC_IP|LAN_NETWORK|PROJECT_ROOT" } | ForEach-Object {
    $Explanation = switch ($_.Name) {
        "GITHUB_USERNAME" { "GitHub username for authentication" }
        "GITHUB_EMAIL" { "GitHub email address associated with the user" }
        "GITHUB_TOKEN" { "GitHub Personal Access Token for API access" }
        "LAN_NETWORK" { "Local Area Network (LAN) CIDR notation for IP range" }
        "PROJECT_ROOT" { "Root directory of the project where logs and configurations are stored" }
        "PUBLIC_IP" { "Public IP address used in network monitoring" }
        default { "No description available for this variable" }
    }
    $Message = "$($_.Name) = $($_.Value)  # $Explanation"
    Log-Output $Message
}

# Step 2: Load main configuration
Log-Output "`nTesting Get-Config function for Main Config (config.json)..." -Color Yellow
try {
    $configMain = Get-Config -FilePath "${PSScriptRoot}\..\config.json"
    Log-Output "Configuration loaded successfully from config.json:`n" -Color Green
    $configMain | Format-List | ForEach-Object { Log-Output $_ }
} catch {
    Log-Output "Error loading main configuration: $_" -Color Red
}

# Step 3: Load network assessment configuration
Log-Output "`nTesting Get-Config function for Network Assessment Config (NetworkAssessmentConfig.json)..." -Color Yellow
try {
    $configNetwork = Get-Config -FilePath "${PSScriptRoot}\..\NetworkAssessmentConfig.json"
    Log-Output "Configuration loaded successfully from NetworkAssessmentConfig.json:`n" -Color Green
    $configNetwork | Format-List | ForEach-Object { Log-Output $_ }
} catch {
    Log-Output "Error loading network assessment configuration: $_" -Color Red
}

# Step 4: Load paths configuration
Log-Output "`nTesting Get-Config function for Paths Config (paths.json)..." -Color Yellow
try {
    $configPaths = Get-Config -FilePath "${PSScriptRoot}\..\paths.json"
    Log-Output "Configuration loaded successfully from paths.json:`n" -Color Green
    $configPaths | Format-List | ForEach-Object { Log-Output $_ }
} catch {
    Log-Output "Error loading paths configuration: $_" -Color Red
}

# Final message
Log-Output "`nAll configurations and environment variables loaded successfully." -Color Green
