# EnvLoader.psm1
function Import-EnvFile {
    param (
        [string]$envFilePath = "${PSScriptRoot}\..\github repo\.env"
    )

    if (Test-Path -Path $envFilePath) {
        Get-Content -Path $envFilePath | ForEach-Object {
            if ($_ -match '^\s*([^#].*?)\s*=\s*(.*)\s*$') {
                $name, $value = $matches[1], $matches[2]
                [Environment]::SetEnvironmentVariable($name, $value)
            }
        }
    } else {
        Write-Host "Warning: .env file not found at $envFilePath"
    }
}
