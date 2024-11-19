# NetworkAssessment.ps1
# Description: Orchestrates all network assessment checks and outputs results to logs.

# Define paths for modules and scripts
$ProjectRoot = "${PSScriptRoot}"
$ScriptsPath = Join-Path -Path $ProjectRoot -ChildPath "Scripts\Net"
$LogsDirectory = Join-Path -Path $ProjectRoot -ChildPath "Logs"
$LogFile = Join-Path -Path $LogsDirectory -ChildPath "NetworkAssessment_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"

# Ensure the logs directory exists
if (!(Test-Path -Path $LogsDirectory)) {
    New-Item -Path $LogsDirectory -ItemType Directory -Force | Out-Null
}

# Import necessary modules
Import-Module "${ProjectRoot}\Modules\NetworkAssessment\NetworkAssessmentLogger.psm1" -ErrorAction Stop
Import-Module "${ProjectRoot}\Modules\ConfigLoader.psm1" -ErrorAction Stop
Import-Module "${ProjectRoot}\Modules\EnvLoader.psm1" -ErrorAction Stop

# Load environment variables and configuration
Import-EnvFile
$config = Get-Config -FilePath "${ProjectRoot}\NetworkAssessmentConfig.json"

# Initialize logging
Write-Log -Message "Starting Network Assessment..." -LogLevel "INFO" -LogFilePath $LogFile

# Run each network assessment module
try {
    Write-Log -Message "Running DNS Tunneling Check..." -LogLevel "INFO" -LogFilePath $LogFile
    & "$ScriptsPath\CheckDnsTunneling.ps1" -LogFilePath $LogFile

    Write-Log -Message "Running SSH Tunneling Check..." -LogLevel "INFO" -LogFilePath $LogFile
    & "$ScriptsPath\CheckSshTunneling.ps1" -LogFilePath $LogFile

    Write-Log -Message "Running TCP Session Analysis..." -LogLevel "INFO" -LogFilePath $LogFile
    & "$ScriptsPath\AnalyzeTcpSessions.ps1" -LogFilePath $LogFile

    Write-Log -Message "Running Attack Signature Detection..." -LogLevel "INFO" -LogFilePath $LogFile
    & "$ScriptsPath\DetectAttackSignatures.ps1" -LogFilePath $LogFile

    Write-Log -Message "Running Protocol Specific Scan..." -LogLevel "INFO" -LogFilePath $LogFile
    & "$ScriptsPath\ProtocolSpecificScan.ps1" -LogFilePath $LogFile

    Write-Log -Message "Running Keyword Scan..." -LogLevel "INFO" -LogFilePath $LogFile
    & "$ScriptsPath\ScanForKeywords.ps1" -LogFilePath $LogFile

    Write-Log -Message "Network Assessment completed successfully." -LogLevel "INFO" -LogFilePath $LogFile

} catch {
    Write-Log -Message "An error occurred during Network Assessment: $_" -LogLevel "ERROR" -LogFilePath $LogFile
}

# Summarize and output completion
Write-Log -Message "Network Assessment finished. Logs saved to $LogFile" -LogLevel "INFO"
Write-Host "Network Assessment completed. Check the log at: $LogFile"

