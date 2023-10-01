filter ConvertFrom-HashTable {
    <#
        .SYNOPSIS
        Converts a hashtable to a pscustomobject

        .DESCRIPTION
        This function converts a hashtable to a pscustomobject.

        .EXAMPLE
        $object = @{a = 1;b = 2;c = 3}
        $object | ConvertFrom-HashTable | Format-Table

        a b c
        - - -
        1 2 3

        Converts the hashtable to a pscustomobject and displays it in a table.

        .EXAMPLE
        $object = @{a = 1;b = 2;c = 3}
        $object | ConvertFrom-Dictionary | ConvertTo-Json

        {
            "a": 1,
            "b": 2,
            "c": 3
        }

        Converts the hashtable to a pscustomobject and then to JSON.
        Using the alias 'ConvertFrom-Dictionary' instead of 'ConvertFrom-HashTable'.
    #>
    [OutputType([pscustomobject])]
    [Alias('ConvertFrom-Dictionary')]
    [CmdletBinding()]
    param (
        # The hashtable to be converted. The input takes any type of dictionary. The original dictionary is not modified.
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [object]$InputObject
    )
    $InputObject | ConvertTo-Json -Depth 100 | ConvertFrom-Json
}
