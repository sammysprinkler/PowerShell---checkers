# Modules/Logger.psm1
# A simple logging module for consistent logging across scripts

function Write-Log {
    param (
        [string]$Message,
        [string]$LogFilePath,
        [string]$LogLevel = "INFO"
    )

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $FormattedMessage = "[$Timestamp] [$LogLevel] $Message"

    # Append to the log file and output to console
    $FormattedMessage | Tee-Object -FilePath $LogFilePath -Append
    Write-Output $FormattedMessage
}
