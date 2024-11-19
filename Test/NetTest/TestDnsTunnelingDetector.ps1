# Test\NetTest\TestDnsTunnelingDetector.ps1
# Test script for the DnsTunnelingDetector.psm1 module

# Import the DnsTunnelingDetector and NetworkAssessmentLogger modules
Import-Module "${PSScriptRoot}\..\..\Modules\NetworkAssessment\DnsTunnelingDetector.psm1" -ErrorAction Stop
Import-Module "${PSScriptRoot}\..\..\Modules\NetworkAssessment\NetworkAssessmentLogger.psm1" -ErrorAction Stop

# Mock packet data for testing DNS tunneling detection
$testPacket = @{
    Protocol = "DNS"
    QR = 0
    Questions = @(
        @{ Name = "example.com" },
        @{ Name = "verylongsuspiciousdomainthatispossiblytunnelinginformation.example.com" }
    )
}

# Begin the test for DNS tunneling detection
Write-Host "Running DNS Tunneling Test..."

# Call the function with a threshold to trigger detection for testing purposes
$result = Test-DnsTunneling -Packet $testPacket -Threshold 30 -LogDetails

if ($result) {
    Write-Host "Test passed: DNS tunneling detected as expected." -ForegroundColor Green
} else {
    Write-Host "Test failed: DNS tunneling was not detected." -ForegroundColor Red
}

# Confirm the log file output by logging the test completion
Write-Log -Message "Completed DNS tunneling test in TestDnsTunnelingDetector.ps1" -LogLevel "INFO"
