# PowerShell Script: CheckUnauthorizedFileChanges.ps1
# Description: Monitors specified files for unauthorized changes.

# Import necessary modules
Import-Module "${PSScriptRoot}\..\Modules\EnvLoader.psm1"
Import-Module "${PSScriptRoot}\..\Modules\ConfigLoader.psm1"
Import-Module "${PSScriptRoot}\..\Modules\Logger.psm1"
Import-Module "${PSScriptRoot}\..\Modules\FileHasher.psm1"

# Load environment variables
Import-EnvFile

# Load configuration
$config = Get-Config

# Access configuration settings directly
$MonitoredFiles = $config.MonitoredFiles
$LogDirectory = $config.LogDirectory
$Timestamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
$OutputFile = Join-Path -Path $LogDirectory -ChildPath "FileChangesCheck_$Timestamp.txt"
$HashAlgorithm = $config.FileChangeDetection.HashAlgorithm  # Access nested properties directly

# Start file integrity check
Write-Log -Message "Starting file integrity check..." -LogFilePath $OutputFile -LogLevel "INFO"

foreach ($FilePath in $MonitoredFiles) {
    try {
        Write-Log -Message "Inspecting file: $FilePath" -LogFilePath $OutputFile -LogLevel "INFO"

        if (Test-Path $FilePath) {
            # Call Get-FileHashString from FileHasher module with correct syntax for the algorithm parameter
            $FileHash = Get-FileHashString -FilePath $FilePath -Algorithm $HashAlgorithm
            Write-Log -Message "Checked $FilePath : Hash $FileHash" -LogFilePath $OutputFile -LogLevel "INFO"
        } else {
            Write-Log -Message "Monitored file $FilePath does not exist." -LogFilePath $OutputFile -LogLevel "WARNING"
        }
    } catch {
        Write-Log -Message "Error occurred while inspecting file $FilePath : $_" -LogFilePath $OutputFile -LogLevel "ERROR"
    }
}

Write-Log -Message "File integrity check completed." -LogFilePath $OutputFile -LogLevel "INFO"
