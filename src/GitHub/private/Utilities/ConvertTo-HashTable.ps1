function ConvertTo-HashTable {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [pscustomobject]$InputObject
    )
    [hashtable]$hashtable = @{}

    foreach ($item in $InputObject.PSobject.Properties) {
        Write-Verbose "$($item.Name) : $($item.Value) : $($item.TypeNameOfValue)"
        $hashtable.$($item.Name) = $item.Value
    }
    $hashtable
}
