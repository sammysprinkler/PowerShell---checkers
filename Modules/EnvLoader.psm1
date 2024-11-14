# EnvLoader.psm1
# Module to load environment variables from a .env file with dynamic path handling

# Function to locate the .env file relative to the script location
function Get-EnvFilePath {
    param (
        [string]$fileName = ".env"
    )

    # Determine the directory of the currently executing script
    $scriptRoot = $PSScriptRoot
    if (-not $scriptRoot) {
        $scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
    }

    # Construct the full path to the .env file based on the script root
    $envFilePath = Join-Path -Path $scriptRoot -ChildPath "..\$fileName"

    # Validate the .env file path
    if (Test-Path -Path $envFilePath) {
        Write-Host "Located .env file at $envFilePath" -ForegroundColor Green
        return $envFilePath
    } else {
        Write-Host "Warning: .env file not found at expected path $envFilePath" -ForegroundColor Yellow
        return $null
    }
}

# Function to extract key-value pairs from the .env file
function ExtractEnvVariables {
    param (
        [string]$FilePath
    )

    $envVariables = @{}

    if (Test-Path -Path $FilePath) {
        Write-Host "Loading environment variables from $FilePath..." -ForegroundColor Yellow
        Get-Content -Path $FilePath | ForEach-Object {
            # Skip comments and empty lines
            if ($_ -match '^\s*([^#\s].*?)\s*=\s*\"?(.*?)\"?\s*$') {
                $name, $value = $matches[1], $matches[2]
                $envVariables[$name] = $value
                Write-Host "Parsed variable: $name = $value" -ForegroundColor Blue
            }
        }
    } else {
        Write-Host "Error: .env file not found at $FilePath" -ForegroundColor Red
    }

    return $envVariables
}

# Function to set parsed environment variables
function Set-EnvVariables {
    param (
        [hashtable]$Variables
    )

    $loadedVariables = @()
    foreach ($name in $Variables.Keys) {
        [Environment]::SetEnvironmentVariable($name, $Variables[$name])
        $loadedVariables += $name
        Write-Host "Set environment variable: $name=${Variables[$name]}" -ForegroundColor Green
    }

    return $loadedVariables
}

# Main function to load .env variables
function Import-EnvFile {
    # Locate the .env file
    $envFilePath = Get-EnvFilePath
    if ($null -eq $envFilePath) {
        Write-Host "Error: .env file path not found. Make sure the .env file is located at the project root." -ForegroundColor Red
        return $false
    }

    # Extract environment variables
    $variables = ExtractEnvVariables -FilePath $envFilePath
    if ($variables.Count -eq 0) {
        Write-Host "Error: No environment variables loaded from $envFilePath" -ForegroundColor Red
        return $false
    }

    # Set the environment variables
    $loadedVars = Set-EnvVariables -Variables $variables
    if ($loadedVars.Count -eq 0) {
        Write-Host "Error: Failed to set environment variables" -ForegroundColor Red
        return $false
    }

    Write-Host "Environment variables loaded successfully: $loadedVars" -ForegroundColor Green
    return $true
}
