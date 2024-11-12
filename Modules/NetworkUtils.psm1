# Modules/NetworkUtils.psm1
# Module for network utility functions, such as checking open ports

function Test-PortOpen {
    param (
        [int]$Port
    )

    $connections = Get-NetTCPConnection | Where-Object { $_.LocalPort -eq $Port -and $_.State -eq 'Listen' }
    return $connections
}

function Test-SuspiciousPorts {
    param (
        [array]$SuspiciousPorts
    )

    foreach ($Port in $SuspiciousPorts) {
        $openConnections = Test-PortOpen -Port $Port
        if ($openConnections) {
            Write-Output "Suspicious port open: $Port"
        }
    }
}
