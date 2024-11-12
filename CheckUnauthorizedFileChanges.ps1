# PowerShell Script: CheckUnauthorizedFileChanges.ps1
# Description: Monitors specified files for unauthorized changes.

$MonitoredFiles = if ($env:OS -eq "Windows_NT") {
    @("C:\Windows\System32\drivers\etc\hosts")
} else {
    @("/etc/passwd", "/etc/shadow")
}
$Timestamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
$OutputFile = "C:\Users\skell\OneDrive - CloudMate, Inc\Desktop\Code\PC Checks\FileChangesCheck_$Timestamp.txt"

function Write-Log {
    param ([string]$Message)
    $Message | Tee-Object -FilePath $OutputFile -Append
    Write-Output $Message
}

function Get-FileHashString {
    param ([string]$FilePath)
    return (Get-FileHash -Path $FilePath -Algorithm SHA256).Hash
}

Write-Log "[$Timestamp] Starting file integrity check..."

foreach ($FilePath in $MonitoredFiles) {
    try {
        Write-Log "Inspecting file: $FilePath"

        if (Test-Path $FilePath) {
            $FileHash = Get-FileHashString -FilePath $FilePath
            $Message = "Checked $FilePath: Hash $FileHash"
            Write-Log $Message
        } else {
            $Message = "Monitored file $FilePath does not exist."
            Write-Log $Message
        }
    } catch {
        Write-Log "Error occurred while inspecting file $FilePath: $_"
    }
}

Write-Log "[$Timestamp] File integrity check completed."
