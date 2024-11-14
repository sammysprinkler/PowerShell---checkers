# RunAllTests.ps1
# Script to run all test scripts in the Test directory and log results in the main Logs directory

# Import the EnvLoader module to load environment variables from the .env file
Import-Module "${PSScriptRoot}\..\Modules\EnvLoader.psm1" -ErrorAction Stop

# Ensure environment variables are loaded, including PROJECT_ROOT
if (-not (Import-EnvFile)) {
    Write-Host "Error: Failed to load environment variables." -ForegroundColor Red
    exit 1
}

# Validate that PROJECT_ROOT is set
if (-not $env:PROJECT_ROOT) {
    Write-Host "Error: PROJECT_ROOT environment variable is not set." -ForegroundColor Red
    exit 1
}

# Set paths using the PROJECT_ROOT environment variable
$TestFolderPath = Join-Path -Path $env:PROJECT_ROOT -ChildPath "Test"
$LogDirectoryPath = Join-Path -Path $env:PROJECT_ROOT -ChildPath "Logs"

# Generate a unique log file name with timestamp
$Timestamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
$LogFilePath = Join-Path -Path $LogDirectoryPath -ChildPath "TestLog_$Timestamp.txt"

# Ensure the Logs directory exists
if (-not (Test-Path -Path $LogDirectoryPath)) {
    New-Item -ItemType Directory -Path $LogDirectoryPath -Force | Out-Null
    Write-Host "Created log directory at $LogDirectoryPath"
}

# Function to log messages to both console and log file
function Log-Message {
    param (
        [string]$Message,
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )

    # Define colors based on log level
    $colorMap = @{
        "INFO" = "Cyan"
        "WARNING" = "Yellow"
        "ERROR" = "Red"
        "SUCCESS" = "Green"
    }

    # Write to console with color
    Write-Host $Message -ForegroundColor $colorMap[$Level]

    # Write to log file with timestamp and level
    Add-Content -Path $LogFilePath -Value "[${Level}] [$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))] $Message"
}

# Start of test log
Log-Message "==== TEST RUN LOG - $(Get-Date) ====" "INFO"
Log-Message "" "INFO"

# Run each test script in the Test directory, excluding RunAllTests.ps1
try {
    # Ensure Test folder exists
    if (-not (Test-Path -Path $TestFolderPath)) {
        Log-Message "Error: Test folder not found at $TestFolderPath" "ERROR"
        exit 1
    }

    # Retrieve all test scripts, excluding RunAllTests.ps1 itself
    $TestScripts = Get-ChildItem -Path $TestFolderPath -Filter *.ps1 | Where-Object { $_.Name -ne "RunAllTests.ps1" }

    foreach ($script in $TestScripts) {
        Log-Message "==== Running test script: $($script.Name) - $(Get-Date) ====" "INFO"

        try {
            # Capture output from each test script as a single multi-line string
            $output = & "$($script.FullName)" 2>&1 | Out-String

            # Log each line of output to both console and log file
            $outputLines = $output -split "`n"
            foreach ($line in $outputLines) {
                Log-Message $line.Trim() "INFO"
            }

            # Mark the end of the script's output in the log file
            Log-Message "==== Completed test script: $($script.Name) - $(Get-Date) ====" "SUCCESS"
        } catch {
            # Log and display errors
            Log-Message "Error running script $($script.Name): $_" "ERROR"
        }
        # Blank line between script logs for readability
        Log-Message "" "INFO"
    }
} catch {
    Log-Message "Error finding test scripts in ${TestFolderPath}: $_" "ERROR"
}

# Complete log entry
Log-Message "==== All tests completed at $(Get-Date) ====" "INFO"
Log-Message "Results saved to $LogFilePath" "SUCCESS"
