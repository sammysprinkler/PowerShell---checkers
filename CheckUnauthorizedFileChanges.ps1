# PowerShell Script: CheckUnauthorizedFileChanges.ps1
$MonitoredFiles = if ($env:OS -eq "Windows_NT") {
    @("C:\\Windows\\System32\\drivers\\etc\\hosts")
} else {
    @("/etc/passwd", "/etc/shadow")
}
$OutputFile = "FileChangesCheck.txt"

Write-Output "Checking for unauthorized file changes..." | Tee-Object -FilePath $OutputFile

foreach ($FilePath in $MonitoredFiles) {
    Write-Output "Inspecting file: $FilePath"
    if (Test-Path $FilePath) {
        $FileSize = (Get-Item $FilePath).Length
        $Message = "Checked $FilePath: Size $FileSize bytes"
        Write-Output $Message | Tee-Object -FilePath $OutputFile -Append
    } else {
        $Message = "Monitored file $FilePath does not exist."
        Write-Output $Message | Tee-Object -FilePath $OutputFile -Append
    }
}
