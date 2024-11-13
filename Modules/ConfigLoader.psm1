# Modules/ConfigLoader.psm1
# Module for loading and expanding configuration files

function Get-Config {
    param (
        [string]$FilePath = (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath "config.json")
    )

    if (Test-Path -Path $FilePath) {
        try {
            # Load JSON config file and convert it to a PowerShell object
            $config = Get-Content -Path $FilePath -Raw | ConvertFrom-Json

            # Recursive function to expand environment variables
            function Expand-VariablesInConfig($item) {
                if ($item -is [string]) {
                    # If the item is a string, expand any environment variables
                    return [Environment]::ExpandEnvironmentVariables($item)
                } elseif ($item -is [System.Collections.Hashtable] -or $item -is [PSCustomObject]) {
                    # If the item is a hashtable or custom object, iterate through its properties
                    $expandedObject = [System.Collections.Hashtable]::Synchronized(@{})
                    foreach ($property in $item.PSObject.Properties) {
                        $expandedObject[$property.Name] = Expand-VariablesInConfig($property.Value)
                    }
                    return $expandedObject
                } elseif ($item -is [System.Collections.IEnumerable]) {
                    # If the item is an array or list, iterate through its elements
                    $expandedArray = @()
                    foreach ($element in $item) {
                        $expandedArray += Expand-VariablesInConfig($element)
                    }
                    return $expandedArray
                } else {
                    # Return the item as-is if it does not match any specific type
                    return $item
                }
            }

            # Expand environment variables in the config
            $expandedConfig = Expand-VariablesInConfig($config)

            # Output expanded config for debug purposes
            foreach ($key in $expandedConfig.Keys) {
                Write-Host ("Loaded and expanded config for {0}: {1}" -f $key, $expandedConfig[$key])
            }

            return $expandedConfig
        } catch {
            throw ("Error loading configuration file at {0}: {1}" -f $FilePath, $_)
        }
    } else {
        throw ("Configuration file not found at {0}" -f $FilePath)
    }
}
