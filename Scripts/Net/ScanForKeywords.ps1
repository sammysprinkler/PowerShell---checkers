# ScanForKeywords.ps1
# Description: Scans network traffic for specific keywords that may indicate suspicious activity.

# Import necessary modules
Import-Module "${PSScriptRoot}\..\..\Modules\NetworkAssessment\NetworkAssessmentLogger.psm1"
Import-Module "${PSScriptRoot}\..\..\Modules\NetworkAssessment\KeywordScanner.psm1"
Import-Module "${PSScriptRoot}\..\..\Modules\ConfigLoader.psm1"
Import-Module "${PSScriptRoot}\..\..\Modules\EnvLoader.psm1"

# Load environment variables and configuration
Import-EnvFile
$config = Get-Config -FilePath "${PSScriptRoot}\..\..\NetworkAssessmentConfig.json"

# Retrieve keywords to scan from configuration
$keywordsToScan = $config.KeywordScanning.Keywords
$logDetails = $config.KeywordScanning.LogDetails

# Start keyword scanning
Write-Log -Message "Starting keyword scan..." -LogLevel "INFO"
Write-Log -Message "Monitoring for keywords: $($keywordsToScan -join ', ')" -LogLevel "INFO"

# Run the keyword scan
try {
    $results = Start-KeywordScan -Keywords $keywordsToScan

    # Log results
    foreach ($result in $results) {
        Write-Log -Message "Detected suspicious keyword: $($result.Keyword) - Context: $($result.Context)" -LogLevel "WARNING" -IsAlert
        if ($logDetails) {
            Write-Log -Message "Packet Details: $($result.PacketDetails)" -LogLevel "INFO"
        }
    }
} catch {
    Write-Log -Message "Error during keyword scan: $_" -LogLevel "ERROR"
}

Write-Log -Message "Keyword scan completed." -LogLevel "INFO"
