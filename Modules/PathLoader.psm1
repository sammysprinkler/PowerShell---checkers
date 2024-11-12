# PathLoader.psm1
function Get-Paths {
    param (
        [string]$FilePath = "$PSScriptRoot\..\paths.json"
    )

    if (Test-Path -Path $FilePath) {
        return Get-Content -Path $FilePath | ConvertFrom-Json
    } else {
        throw "Path configuration file not found at $FilePath"
    }
}
