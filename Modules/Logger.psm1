# Modules/Logger.psm1
# A robust logging module for consistent logging across scripts

function Write-Log {
    param (
        [string]$Message,
        [string]$LogFilePath,
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$LogLevel = "INFO",
        [switch]$ConsoleOutput  # Switch parameter without a default value
    )

    # Ensure LogFilePath is provided
    if ([string]::IsNullOrEmpty($LogFilePath)) {
        throw "LogFilePath cannot be null or empty."
    }

    # Format the timestamp and message
    $Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    $FormattedMessage = "[{0}] [{1}] {2}" -f $Timestamp, $LogLevel, $Message

    # Attempt to write to log file
    try {
        # Append to the log file
        $FormattedMessage | Out-File -FilePath $LogFilePath -Append -Encoding UTF8

        # Optionally output to console if $ConsoleOutput is specified
        if ($ConsoleOutput) {
            Write-Output $FormattedMessage
        }
    } catch {
        Write-Output ("Error writing to log file {0}: {1}" -f $LogFilePath, $_) -ForegroundColor Red
    }
}
