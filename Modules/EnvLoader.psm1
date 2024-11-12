function Import-EnvFile {
    # Dynamically locate the .env file in the parent directory of the current script
    param (
        [string]$envFilePath = (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath ".env")
    )

    if (Test-Path -Path $envFilePath) {
        Write-Host "Loading environment variables from $envFilePath..."

        # Process each line in the .env file
        Get-Content -Path $envFilePath | ForEach-Object {
            # Match lines with 'key=value' format, ignoring comments and blank lines
            if ($_ -match '^\s*([^#].*?)\s*=\s*(.*)\s*$') {
                $name, $value = $matches[1], $matches[2]
                # Set the environment variable and confirm it was set
                [Environment]::SetEnvironmentVariable($name, $value)
                Write-Host "Set environment variable: $name=$value"
            }
        }
    } else {
        Write-Host "Warning: .env file not found at $envFilePath"
    }
}
