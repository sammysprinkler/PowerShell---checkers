# PowerShell Script: CheckNetworkConnections.ps1
# Description: Checks for established network connections on suspicious ports.

$SuspiciousPorts = @(4444, 1337, 8080, 9001)
$Timestamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
$OutputFile = "C:\Users\skell\OneDrive - CloudMate, Inc\Desktop\Code\PC Checks\NetworkConnectionsCheck_$Timestamp.txt"

function Write-Log {
    param ([string]$Message)
    $Message | Tee-Object -FilePath $OutputFile -Append
    Write-Output $Message
}

Write-Log "[$Timestamp] Starting network connection check..."

try {
    Get-NetTCPConnection | ForEach-Object {
        Write-Log "Inspecting connection: $($_.LocalAddress):$($_.LocalPort) -> $($_.RemoteAddress):$($_.RemotePort) [State: $($_.State)]"

        if ($_.State -eq 'Established' -and $SuspiciousPorts -contains $_.LocalPort) {
            $Message = "Suspicious connection detected: $($_.LocalAddress):$($_.LocalPort) -> $($_.RemoteAddress):$($_.RemotePort)"
            Write-Log $Message
        }
    }
} catch {
    Write-Log "Error occurred while retrieving network connections: $_"
}

Write-Log "[$Timestamp] Network connection check completed."
