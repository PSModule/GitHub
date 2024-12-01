function ConvertTo-GitHubOutput {
    param (
        [Parameter(Mandatory)]
        [PSObject]$InputObject
    )

    $outputLines = @()

    foreach ($property in $InputObject.PSObject.Properties) {
        $key = $property.Name
        $value = $property.Value

        # Convert hashtable or PSCustomObject to compressed JSON
        if ($value -is [hashtable] -or $value -is [PSCustomObject]) {
            $value = $value | ConvertTo-Json -Compress
        }

        if ($value -is [string] -and $value.Contains("`n")) {
            # Multi-line value
            $guid = [Guid]::NewGuid().ToString()
            $EOFMarker = "EOF_$guid"
            $outputLines += "$key<<$EOFMarker"
            $outputLines += $value
            $outputLines += $EOFMarker
        } else {
            # Single-line value
            $outputLines += "$key=$value"
        }
    }
    $outputLines
}
