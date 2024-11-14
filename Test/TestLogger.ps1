# TestLogger.ps1
# Description: Tests the Logger module to ensure logs are written correctly.

# Import the module
Import-Module -Name "${PSScriptRoot}\..\Modules\Logger.psm1" -ErrorAction Stop

# Set test variables
$logFilePath = "${PSScriptRoot}\..\Logs\TestLog.txt"

# Function to test Write-Log
function Test-WriteLog {
    try {
        Write-Host "Testing Write-Log function..." -ForegroundColor Yellow

        # Test log message
        Write-Log -Message "Test log entry: INFO level" -LogFilePath $logFilePath -LogLevel "INFO" -ConsoleOutput

        if (Test-Path -Path $logFilePath) {
            Write-Host "Log file created at: $logFilePath" -ForegroundColor Green
            Write-Host "Log entry written successfully." -ForegroundColor Blue
        } else {
            Write-Host "Error: Log file was not created." -ForegroundColor Red
        }
    } catch {
        Write-Host "Error in Write-Log: $_" -ForegroundColor Red
    }
}

# Run the test
Test-WriteLog
