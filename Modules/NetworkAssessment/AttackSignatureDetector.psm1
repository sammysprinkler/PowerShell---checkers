# Modules/NetworkAssessment/AttackSignatureDetector.psm1

function Detect-SynFlood {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourceIP,
        [string]$TcpFlags
    )

    if ($TcpFlags -eq "SYN") {
        $Global:synCounter[$SourceIP]++
        if ($Global:synCounter[$SourceIP] -gt 100) {
            Write-Log -Message "[ALERT] SYN flood detected from $SourceIP" -LogLevel "WARNING" -IsAlert
            return $true
        }
    }
    return $false
}

Export-ModuleMember -Function Detect-SynFlood
