# CheckUnauthorizedFileChanges.ps1
# Description: Monitors specified files for unauthorized changes by checking hashes.

# Import necessary modules
Import-Module "${PSScriptRoot}\..\Modules\ConfigLoader.psm1"
Import-Module "${PSScriptRoot}\..\Modules\PathLoader.psm1"
Import-Module "${PSScriptRoot}\..\Modules\EnvLoader.psm1"
Import-Module "${PSScriptRoot}\..\Modules\Logger.psm1"
Import-Module "${PSScriptRoot}\..\Modules\FileHasher.psm1"

# Load environment variables
Import-EnvFile

# Load configurations and paths
$config = Get-Config -FilePath "${PSScriptRoot}\..\config.json"
$paths = Get-Paths -FilePath "${PSScriptRoot}\..\paths.json"

# Access paths and configurations
$LogDirectory = $paths.LogDirectory
$MonitoredFiles = $config.MonitoredFiles
$HashAlgorithm = $config.FileChangeDetection.HashAlgorithm

# Initialize log file
$Timestamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
$OutputFile = Join-Path -Path $LogDirectory -ChildPath "FileChangesCheck_$Timestamp.txt"

# Start file integrity check
Write-Log -Message "Starting file integrity check..." -LogFilePath $OutputFile -LogLevel "INFO"

foreach ($FilePath in $MonitoredFiles) {
    try {
        if (Test-Path $FilePath) {
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
