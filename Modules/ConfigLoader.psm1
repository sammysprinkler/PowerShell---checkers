# ConfigLoader.psm1
function Get-Config {
    param (
        [string]$FilePath = "$PSScriptRoot\..\config.json"
    )

    if (Test-Path -Path $FilePath) {
        return Get-Content -Path $FilePath | ConvertFrom-Json
    } else {
        throw "Configuration file not found at $FilePath"
    }
}
