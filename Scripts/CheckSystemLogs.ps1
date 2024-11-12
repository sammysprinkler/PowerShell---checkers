# PowerShell Script: CheckSystemLogs.ps1
# Description: Analyzes the security log for suspicious entries.

$Timestamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
$OutputFile = "C:\Users\skell\OneDrive - CloudMate, Inc\Desktop\Code\PC Checks\SystemLogsCheck_$Timestamp.txt"

function Write-Log {
    param ([string]$Message)
    $Message | Tee-Object -FilePath $OutputFile -Append
    Write-Output $Message
}

Write-Log "[$Timestamp] Starting system log check..."

try {
    Write-Log "Reading the latest 100 entries from the Security log..."
    Get-EventLog -LogName Security -Newest 100 | ForEach-Object {
        Write-Log "Inspecting log entry ID $($_.InstanceId): $($_.Message)"

        if ($_.Message -match 'failed password|error') {
            $Message = "Suspicious log entry detected: $($_.Message)"
            Write-Log $Message
        }
    }
} catch {
    Write-Log "Error occurred while accessing system logs: $_"
}

Write-Log "[$Timestamp] System log check completed."
