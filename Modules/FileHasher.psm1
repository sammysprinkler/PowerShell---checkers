# Modules/FileHasher.psm1
# Module for calculating file hashes for integrity checks

function Get-FileHashString {
    param (
        [string]$FilePath,
        [ValidateSet("SHA1", "SHA256", "MD5")]
        [string]$Algorithm = "SHA256"
    )

    # Check if the file exists
    if (!(Test-Path -Path $FilePath)) {
        throw "File not found: $($FilePath)"
    }

    try {
        # Calculate the file hash
        $fileHash = (Get-FileHash -Path $FilePath -Algorithm $Algorithm).Hash
        Write-Host ("Calculated {0} hash for {1}: {2}" -f $Algorithm, $FilePath, $fileHash)
        return $fileHash
    } catch {
        throw ("Error calculating hash for {0} with algorithm {1}: {2}" -f $FilePath, $Algorithm, $_)
    }
}
