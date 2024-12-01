function ConvertTo-GitHubOutput {
    param (
        [Parameter(Mandatory = $true)]
        [PSObject]$InputObject,

        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [string]$Delimiter = '----------',
        [string]$EOFMarker = 'EOF'
    )

    $outputLines = @()

    # Add delimiter at the top
    $outputLines += $Delimiter

    foreach ($property in $InputObject.PSObject.Properties) {
        $key = $property.Name
        $value = $property.Value

        if ($value -is [string] -and $value.Contains("`n")) {
            # Multi-line value
            $outputLines += "$key<<$EOFMarker"
            $outputLines += $value
            $outputLines += $EOFMarker
        } else {
            # Single-line value
            $outputLines += "$key=$value"
        }
    }

    # Add delimiter at the bottom
    $outputLines += $Delimiter

    # Write to file
    $outputLines | Out-File -FilePath $FilePath -Encoding UTF8
}
