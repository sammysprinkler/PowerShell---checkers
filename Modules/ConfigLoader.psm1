# Modules/ConfigLoader.psm1
# Module for loading configuration files

function Get-Config {
    param (
        [string]$FilePath = (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath "config.json")
    )

    if (Test-Path -Path $FilePath) {
        try {
            # Load JSON config file and convert it to a PowerShell object
            $config = Get-Content -Path $FilePath | ConvertFrom-Json

            # Expand any environment variables within the config if any
            $expandedConfig = [System.Collections.Hashtable]::Synchronized(@{})
            foreach ($key in $config.PSObject.Properties.Name) {
                # Check if the value is a string and contains environment variables
                if ($config.$key -is [string]) {
                    $expandedConfig[$key] = [Environment]::ExpandEnvironmentVariables($config.$key)
                } else {
                    # If it's not a string, just assign it as-is
                    $expandedConfig[$key] = $config.$key
                }
                Write-Host ("Loaded config for {0}: {1}" -f $key, $expandedConfig[$key])
            }

            return $expandedConfig
        } catch {
            throw ("Error loading configuration file at {0}: {1}" -f $FilePath, $_)
        }
    } else {
        throw ("Configuration file not found at {0}" -f $FilePath)
    }
}
