# Modules/ConfigLoader.psm1
# Module for loading and expanding configuration files

function Get-Config {
    param (
        [string]$FilePath = (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath "config.json")
    )

    if (Test-Path -Path $FilePath) {
        try {
            # Load JSON config file
            Write-Host "Loading configuration from $FilePath..."
            $config = Get-Content -Path $FilePath -Raw | ConvertFrom-Json

            # Recursive function to expand environment variables
            function Expand-Placeholders {
                param ([object]$item)

                if ($item -is [string]) {
                    return $item -replace '\$\{env:(\w+)\}', { param($m) [Environment]::GetEnvironmentVariable($m.Groups[1].Value) }
                } elseif ($item -is [System.Collections.IDictionary]) {
                    $expandedObject = @{}
                    foreach ($key in $item.Keys) {
                        $expandedObject[$key] = Expand-Placeholders -item $item[$key]
                    }
                    return $expandedObject
                } elseif ($item -is [System.Collections.IEnumerable] -and -not ($item -is [string])) {
                    return $item | ForEach-Object { Expand-Placeholders -item $_ }
                } else {
                    return $item
                }
            }

            # Expand environment variables in the config
            $expandedConfig = Expand-Placeholders -item $config

            # Output expanded config for debug purposes
            Write-Host "Configuration loaded successfully."
            foreach ($key in $expandedConfig.Keys) {
                Write-Host ("Expanded config for {0}: {1}" -f $key, $expandedConfig[$key]) -ForegroundColor Green
            }

            return $expandedConfig
        } catch {
            Write-Host ("Error loading configuration file at {0}: {1}" -f $FilePath, $_) -ForegroundColor Red
        }
    } else {
        Write-Host ("Configuration file not found at {0}" -f $FilePath) -ForegroundColor Red
    }
}
