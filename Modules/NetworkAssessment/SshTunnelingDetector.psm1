# Modules/NetworkAssessment/SshTunnelingDetector.psm1

function Test-SshTunneling {
    param (
        [Parameter(Mandatory = $true)]
        [int]$Port,
        [Parameter(Mandatory = $true)]
        [string]$Protocol
    )

    $Config = Get-Config -FilePath "${PSScriptRoot}\..\NetworkAssessmentConfig.json"
    $NonStandardPortThreshold = $Config.SshTunnelingDetection.NonStandardPortThreshold

    if ($Protocol -eq "SSH" -and $Port -gt $NonStandardPortThreshold) {
        Write-Log -Message "[ALERT] SSH tunneling detected on port $Port" -LogLevel "WARNING" -IsAlert
        return $true
    }
    return $false
}

Export-ModuleMember -Function Test-SshTunneling
