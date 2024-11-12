# PowerShell Script: CheckRunningProcesses.ps1
# Description: Checks for specific suspicious processes running on the system.

$SuspiciousProcesses = @("nc", "netcat", "ncat", "meterpreter", "powershell", "cmd.exe")
$Timestamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
$OutputFile = "C:\Users\skell\OneDrive - CloudMate, Inc\Desktop\Code\PC Checks\RunningProcessesCheck_$Timestamp.txt"

function Write-Log {
    param ([string]$Message)
    $Message | Tee-Object -FilePath $OutputFile -Append
    Write-Output $Message
}

Write-Log "[$Timestamp] Starting process check for suspicious activity..."

try {
    Get-Process | ForEach-Object {
        $ProcessName = $_.ProcessName.ToLower()
        Write-Log "Inspecting process: PID $($_.Id) - $($_.ProcessName)"

        if ($SuspiciousProcesses -contains $ProcessName) {
            $Message = "Suspicious process found: PID $($_.Id) - $($_.ProcessName)"
            Write-Log $Message
        }
    }
} catch {
    Write-Log "Error occurred while retrieving processes: $_"
}

Write-Log "[$Timestamp] Process check completed."
