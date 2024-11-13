# Modules/Logger.psm1
# A robust logging module for consistent logging across scripts

function Write-Log {
    param (
        [string]$Message,
        [string]$LogFilePath,
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$LogLevel = "INFO",
        [switch]$ConsoleOutput,     # Optional: Output to console
        [switch]$DebugMode          # Optional: Output debug information for troubleshooting
    )

    # Ensure LogFilePath is provided and expand any environment variables
    if ([string]::IsNullOrEmpty($LogFilePath)) {
        throw "LogFilePath cannot be null or empty."
    }
    $LogFilePath = [System.Environment]::ExpandEnvironmentVariables($LogFilePath)

    # Ensure the directory for the log file exists, create if it does not
    $LogDirectory = Split-Path -Path $LogFilePath
    if (!(Test-Path -Path $LogDirectory)) {
        try {
            New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
            if ($DebugMode) { Write-Output ("Created log directory: {0}" -f $LogDirectory) }
        } catch {
            Write-Output ("Error creating log directory at `{0}`: {1}" -f $LogDirectory, $_) -ForegroundColor Red
            return
        }
    }

    # Format the timestamp and log message
    $Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    $FormattedMessage = "[{0}] [{1}] {2}" -f $Timestamp, $LogLevel, $Message

    # Attempt to write to the log file
    try {
        # Append to the log file with UTF-8 encoding
        $FormattedMessage | Out-File -FilePath $LogFilePath -Append -Encoding UTF8
        if ($DebugMode) { Write-Output ("Log entry written to {0}: {1}" -f $LogFilePath, $FormattedMessage) }

        # Optionally output to console if ConsoleOutput is specified
        if ($ConsoleOutput) {
            Write-Output $FormattedMessage
        }
    } catch {
        # Display error message if unable to write to log file
        Write-Output ("Error writing to log file at `{0}`: {1}" -f $LogFilePath, $_) -ForegroundColor Red
    }
}
