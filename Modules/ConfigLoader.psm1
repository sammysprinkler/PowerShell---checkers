# Modules/ConfigLoader.psm1
# A module to load and parse config.json file

function Get-Config {
    param (
        [string]$ConfigFilePath = "$PSScriptRoot\..\config.json"
    )

    if (Test-Path -Path $ConfigFilePath) {
        return Get-Content -Path $ConfigFilePath | ConvertFrom-Json
    } else {
        throw "Configuration file not found at $ConfigFilePath"
    }
}
