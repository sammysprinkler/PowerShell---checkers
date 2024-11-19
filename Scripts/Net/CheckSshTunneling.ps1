# CheckSshTunneling.ps1
# Description: Script to detect SSH tunneling in network traffic.

# Import modules
Import-Module "${PSScriptRoot}\..\..\Modules\NetworkAssessment\SshTunnelingDetector.psm1"
Import-Module "${PSScriptRoot}\..\..\Modules\NetworkAssessment\NetworkAssessmentLogger.psm1"

# Load configuration
$config = Get-Config -FilePath "${PSScriptRoot}\..\..\NetworkAssessmentConfig.json"
Write-Log -Message "Starting SSH tunneling detection..." -LogLevel "INFO"

# Check for SSH tunneling
try {
    Start-SshTunnelingDetection -Config $config
    Write-Log -Message "SSH tunneling detection completed successfully." -LogLevel "INFO"
} catch {
    Write-Log -Message "Error during SSH tunneling detection: $_" -LogLevel "ERROR"
}
