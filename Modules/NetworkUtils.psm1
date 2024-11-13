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
        throw ("Error checking port `${Port}: $_")
    }
}

function Test-SuspiciousPorts {
    param (
        [int[]]$SuspiciousPorts,
        [string]$LogFilePath,
        [switch]$ConsoleOutput
    )

    # Expand environment variables in the LogFilePath
    if ($LogFilePath) {
        $LogFilePath = [System.Environment]::ExpandEnvironmentVariables($LogFilePath)
    }

    foreach ($Port in $SuspiciousPorts) {
        try {
            # Check if the specified port is open
            $openConnections = Test-PortOpen -Port $Port
            if ($openConnections) {
                $message = "Suspicious port open: $Port"

                # Log using Write-Log function if available
                if ($LogFilePath) {
                    Write-Log -Message $message -LogFilePath $LogFilePath -LogLevel "WARNING" -ConsoleOutput:$ConsoleOutput
                } elseif ($ConsoleOutput) {
                    Write-Output $message
                }
            }
        } catch {
            # Format the error message with ${} syntax for the $Port variable
            $errorMessage = "Error checking suspicious port `${Port}: $_"

            # Log the error using Write-Log, or fallback to direct output if not available
            if ($LogFilePath) {
                Write-Log -Message $errorMessage -LogFilePath $LogFilePath -LogLevel "ERROR" -ConsoleOutput:$ConsoleOutput
            } elseif ($ConsoleOutput) {
                Write-Output $errorMessage -ForegroundColor Red
            }
        }
    }
}
