# Modules/FileHasher.psm1
# Module for calculating file hashes for integrity checks

function Get-FileHashString {
    param (
        [string]$FilePath,
        [string]$Algorithm = "SHA256"
    )

    if (Test-Path -Path $FilePath) {
        return (Get-FileHash -Path $FilePath -Algorithm $Algorithm).Hash
    } else {
        throw "File not found: $FilePath"
    }
}
