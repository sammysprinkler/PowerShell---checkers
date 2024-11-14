# TestNetworkUtils.ps1
# Description: Tests the NetworkUtils module for network utilities like checking open ports.

# Import the module
Import-Module -Name "${PSScriptRoot}\..\Modules\NetworkUtils.psm1" -ErrorAction Stop

# Function to test Test-PortOpen
function Test-TestPortOpen {
    param (
        [int]$Port = 8080  # Example port for testing
    )

    try {
        Write-Host "Testing Test-PortOpen function with port $Port..."

        # Check if the port is open
        $isOpen = Test-PortOpen -Port $Port

        if ($isOpen) {
            Write-Host "Port $Port is open."
        } else {
            Write-Host "Port $Port is not open."
        }
    } catch {
        Write-Host "Error in Test-PortOpen: $_" -ForegroundColor Red
    }
}

# Run the test
Test-TestPortOpen
