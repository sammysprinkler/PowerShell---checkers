# DetectAttackSignatures.ps1
# Description: Script to detect common attack signatures (SYN flood, Slowloris, etc.).

# Import modules
Import-Module "${PSScriptRoot}\..\..\Modules\NetworkAssessment\AttackSignatureDetector.psm1"
Import-Module "${PSScriptRoot}\..\..\Modules\NetworkAssessment\NetworkAssessmentLogger.psm1"

# Load configuration
$config = Get-Config -FilePath "${PSScriptRoot}\..\..\NetworkAssessmentConfig.json"
Write-Log -Message "Starting attack signature detection..." -LogLevel "INFO"

# Detect attack signatures
try {
    Start-AttackSignatureDetection -Config $config
    Write-Log -Message "Attack signature detection completed successfully." -LogLevel "INFO"
} catch {
    Write-Log -Message "Error during attack signature detection: $_" -LogLevel "ERROR"
}
