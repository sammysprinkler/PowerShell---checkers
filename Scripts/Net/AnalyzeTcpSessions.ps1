# AnalyzeTcpSessions.ps1
# Description: Script to analyze TCP sessions for potential hijacking or unusual flags.

# Import modules
Import-Module "${PSScriptRoot}\..\..\Modules\NetworkAssessment\TcpSessionAnalyzer.psm1"
Import-Module "${PSScriptRoot}\..\..\Modules\NetworkAssessment\NetworkAssessmentLogger.psm1"

# Load configuration
$config = Get-Config -FilePath "${PSScriptRoot}\..\..\NetworkAssessmentConfig.json"
Write-Log -Message "Starting TCP session analysis..." -LogLevel "INFO"

# Analyze TCP sessions
try {
    Start-TcpSessionAnalysis -Config $config
    Write-Log -Message "TCP session analysis completed successfully." -LogLevel "INFO"
} catch {
    Write-Log -Message "Error during TCP session analysis: $_" -LogLevel "ERROR"
}
