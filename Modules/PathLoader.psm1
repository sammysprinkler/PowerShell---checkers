function Get-Paths {
    param (
        [string]$FilePath = (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath "paths.json")
    )

    if (Test-Path -Path $FilePath) {
        # Load paths.json and convert it to a PowerShell object
        $paths = Get-Content -Path $FilePath | ConvertFrom-Json

        # Expand any environment variables within the JSON file
        $expandedPaths = [System.Collections.Hashtable]::Synchronized(@{})
        foreach ($key in $paths.PSObject.Properties.Name) {
            # Expand environment variables (e.g., ${env:USERPROFILE}) in each path
            $expandedPaths[$key] = [Environment]::ExpandEnvironmentVariables($paths.$key)
            Write-Host "Loaded path for $($key): $($expandedPaths[$key])"
        }

        return $expandedPaths
    } else {
        throw "Path configuration file not found at $FilePath"
    }
}
