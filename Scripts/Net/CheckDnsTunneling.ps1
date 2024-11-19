# CheckDnsTunneling.ps1
# Description: Script to detect DNS tunneling in network traffic.

# Import modules
Import-Module "${PSScriptRoot}\..\..\Modules\NetworkAssessment\DnsTunnelingDetector.psm1"
Import-Module "${PSScriptRoot}\..\..\Modules\NetworkAssessment\NetworkAssessmentLogger.psm1"

# Load configuration
$config = Get-Config -FilePath "${PSScriptRoot}\..\..\NetworkAssessmentConfig.json"
Write-Log -Message "Starting DNS tunneling detection..." -LogLevel "INFO"

# Check for DNS tunneling
try {
    Start-DnsTunnelingDetection -Config $config
    Write-Log -Message "DNS tunneling detection completed successfully." -LogLevel "INFO"
} catch {
    Write-Log -Message "Error during DNS tunneling detection: $_" -LogLevel "ERROR"
}
