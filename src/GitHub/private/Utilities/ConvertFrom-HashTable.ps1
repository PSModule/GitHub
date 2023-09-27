function ConvertFrom-HashTable {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [object]$InputObject
    )
    ([pscustomobject](@{} + $InputObject))
}
