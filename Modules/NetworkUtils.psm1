# Modules/NetworkUtils.psm1
# Module for network utility functions, such as checking open ports

function Test-PortOpen {
    param (
        [int]$Port
    )

    try {
        # Get active TCP connections on the specified port in "Listen" state
        $connections = Get-NetTCPConnection | Where-Object { $_.LocalPort -eq $Port -and $_.State -eq 'Listen' }
        return $connections
    } catch {
        throw ("Error checking port {0}: {1}" -f $Port, $_)
    }
}

function Test-SuspiciousPorts {
    param (
        [int[]]$SuspiciousPorts,
        [string]$LogFilePath,
        [switch]$ConsoleOutput
    )

    foreach ($Port in $SuspiciousPorts) {
        try {
            # Check if the specified port is open
            $openConnections = Test-PortOpen -Port $Port
            if ($openConnections) {
                $message = "Suspicious port open: $Port"

                # Log to file if LogFilePath is specified
                if ($LogFilePath) {
                    $Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                    $FormattedMessage = "[{0}] [WARNING] {1}" -f $Timestamp, $message
                    $FormattedMessage | Out-File -FilePath $LogFilePath -Append -Encoding UTF8
                }

                # Optionally output to console
                if ($ConsoleOutput) {
                    Write-Output $message
                }
            }
        } catch {
            # Log and output any error encountered during port checking
            $errorMessage = ("Error checking suspicious port {0}: {1}" -f $Port, $_)
            if ($ConsoleOutput) {
                Write-Output $errorMessage -ForegroundColor Red
            }
            if ($LogFilePath) {
                $Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                $ErrorLogMessage = "[{0}] [ERROR] {1}" -f $Timestamp, $errorMessage
                $ErrorLogMessage | Out-File -FilePath $LogFilePath -Append -Encoding UTF8
            }
        }
    }
}
