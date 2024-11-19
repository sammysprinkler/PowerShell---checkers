function Write-Log {
    param (
        [string]$Message,
        [string]$LogLevel = "INFO",
        [string]$LogFilePath
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$LogLevel] $Message"
    Add-Content -Path $LogFilePath -Value $LogMessage
    Write-Host $LogMessage
}
Export-ModuleMember -Function Write-Log
