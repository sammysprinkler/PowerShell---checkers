# Modules/NetworkAssessment/TcpSessionAnalyzer.psm1

function Analyze-TcpSession {
    param (
        [Parameter(Mandatory = $true)]
        [string]$TcpFlags,
        [int]$SequenceNumber,
        [int]$AcknowledgmentNumber
    )

    if ($TcpFlags -eq "FA" -and $SequenceNumber -gt 0 -and $AcknowledgmentNumber -gt 0) {
        Write-Log -Message "[ALERT] Potential TCP session hijacking detected." -LogLevel "WARNING" -IsAlert
        return $true
    }
    return $false
}

Export-ModuleMember -Function Analyze-TcpSession
