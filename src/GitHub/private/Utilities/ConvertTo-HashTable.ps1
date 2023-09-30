﻿function ConvertTo-HashTable {
    <#
        .SYNOPSIS
        Converts an object to a hashtable

        .DESCRIPTION
        This function converts an object to a hashtable.

        .EXAMPLE
        $object = [pscustomobject]@{a = 1;b = 2;c = 3}
        $object | ConvertTo-HashTable | Format-Table

        Name                           Value
        ----                           -----
        a                              1
        b                              2
        c                              3

        Converts the object to a hashtable and displays it in a table.

        .EXAMPLE
        $object = [pscustomobject]@{a = 1;b = 2;c = 3}
        $object | ConvertTo-Dictionary | ConvertTo-Json

        {
            "a": 1,
            "b": 2,
            "c": 3
        }
        
        Converts the object to a hashtable and then to JSON.
        Using the alias 'ConvertTo-Dictionary' instead of 'ConvertTo-HashTable'.
    #>
    [OutputType([hashtable])]
    [Alias('ConvertTo-Dictionary')]
    [CmdletBinding()]
    param (
        # The object to be converted. The input takes any type of object. The original object is not modified.
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [object]$InputObject
    )
    $InputObject | ConvertTo-Json -Depth 100 | ConvertFrom-Json -AsHashtable
}
