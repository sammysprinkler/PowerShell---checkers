# PathLoader.psm1
# This module provides functionality to load and expand paths from a configuration file (paths.json)

# Function to load paths from a JSON file and expand any environment variables
function Get-Paths {
    param (
        [string]$FilePath = (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath "paths.json")
    )

    if (Test-Path -Path $FilePath) {
        try {
            # Load paths.json and convert it to a PowerShell object
            $paths = Get-Content -Path $FilePath | ConvertFrom-Json

            # Helper function to expand %VARIABLE% syntax and remove surrounding single quotes if present
            function Expand-And-CleanPath {
                param ([string]$path)
                # Expand environment variables using %VARIABLE% syntax
                $expandedPath = [System.Environment]::ExpandEnvironmentVariables($path)
                # Remove surrounding single quotes if they are present
                return $expandedPath -replace "^'(.*)'$", '$1'
            }

            # Expand environment variables for each path entry
            $expandedPaths = [System.Collections.Hashtable]::Synchronized(@{})
            foreach ($key in $paths.PSObject.Properties.Name) {
                # Check if the value is a string and expand environment variables
                if ($paths.$key -is [string]) {
                    $expandedPaths[$key] = Expand-And-CleanPath -path $paths.$key
                } else {
                    # Non-string values are assigned as-is
                    $expandedPaths[$key] = $paths.$key
                }
                Write-Host "Loaded and expanded path for ${key}: $($expandedPaths[$key])"
            }

            return $expandedPaths
        } catch {
            throw ("Error reading or parsing paths configuration file at `$FilePath: $($_)")
        }
    } else {
        throw ("Path configuration file not found at `$FilePath")
    }
}

