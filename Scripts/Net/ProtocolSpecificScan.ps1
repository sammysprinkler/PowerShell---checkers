# NetworkAssessment.ps1
# Description: Main script to run all network assessment checks.

# Import logger
Import-Module "${PSScriptRoot}\..\..\Modules\NetworkAssessment\NetworkAssessmentLogger.psm1"

# Load configuration
$config = Get-Config -FilePath "${PSScriptRoot}\..\..\NetworkAssessmentConfig.json"
Write-Log -Message "Starting network assessment..." -LogLevel "INFO"

# Run each check
& "${PSScriptRoot}\AnalyzeTcpSessions.ps1"
& "${PSScriptRoot}\CheckDnsTunneling.ps1"
& "${PSScriptRoot}\CheckSshTunneling.ps1"
& "${PSScriptRoot}\DetectAttackSignatures.ps1"
& "${PSScriptRoot}\ScanForKeywords.ps1"
& "${PSScriptRoot}\ProtocolSpecificScan.ps1"

Write-Log -Message "Network assessment completed." -LogLevel "INFO"
