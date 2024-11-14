# TestFileHasher.ps1
# Description: Tests the FileHasher module to ensure file hashes are computed correctly.

# Import the module
Import-Module -Name "${PSScriptRoot}\..\Modules\FileHasher.psm1" -ErrorAction Stop

# Set test variables
$testFilePath = "${PSScriptRoot}\..\README.md"  # Replace with an actual file path
$hashAlgorithm = "SHA256"

# Function to test Get-FileHashString
function Test-GetFileHashString {
    try {
        Write-Host "Testing Get-FileHashString function on file: $testFilePath"

        # Calculate the hash
        $fileHash = Get-FileHashString -FilePath $testFilePath -Algorithm $hashAlgorithm

        if ($fileHash) {
            Write-Host "File hash computed successfully."
            Write-Host "$hashAlgorithm hash for ${testFilePath}: $fileHash"
        } else {
            Write-Host "Error: Hash could not be computed." -ForegroundColor Red
        }
    } catch {
        Write-Host "Error in Get-FileHashString: $_" -ForegroundColor Red
    }
}

# Run the test
Test-GetFileHashString
