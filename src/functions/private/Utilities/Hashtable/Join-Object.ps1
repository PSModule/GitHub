filter Join-Object {
    <#
        .SYNOPSIS
        Merges two or more objects into a single object

        .DESCRIPTION
        Merges two or more objects into a single object.
        The first object is the main object, and the remaining objects are overrides.
        The overrides are applied in order, so the last object in the list will override any previous values.

        .EXAMPLE
        $main = [pscustomobject]@{a = 1; b = 2; c = 3}
        $overrides = [pscustomobject]@{a = 4; b = 5; d = 6}
        $overrides2 = [pscustomobject]@{a = 7; b = 8; e = 9}
        Join-Object -Main $main -Overrides $overrides, $overrides2

        a b c d e
        - - - - -
        7 8 3 6 9

        Merges the three objects into a single object.
        The values from the last object override the values from the previous objects.

        .EXAMPLE
        $main = @{a = 1;b = 2}
        $overrides = @{a = 3;c = 4}
        Merge-Object -Main $main -Overrides $overrides -AsHashtable

        Name                           Value
        ----                           -----
        a                              3
        b                              2
        c                              4

        Merges the two hashtables into a single hashtable.
        The values from the last hashtable override the values from the previous hashtables.
        Using the alias 'Merge-Object' instead of 'Join-Object'.

        .EXAMPLE
        $main = @{a = 1;b = 1;c = 1}
        $overrides = @{b = 2;d = 2}
        $overrides2 = @{c = 3;e = 3}
        $main | Join-Object -Overrides $overrides, $overrides2 | Format-Table

        a b c d e
        - - - - -
        1 2 3 2 3

        Merges the three hashtables into a single hashtable. The values from the last hashtable override the values from the previous hashtables.
        Using the pipeline to pass the main object instead of the -Main parameter.
    #>
    [OutputType([pscustomobject])]
    [OutputType(ParameterSetName = 'AsHashTable', [hashtable])]
    [Alias('Merge-Object')]
    [CmdletBinding()]
    param(
        # The main object to merge into. This object will be cloned, so the original object will not be modified.
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [object] $Main,

        # The objects to merge into the main object
        [Parameter(Mandatory)]
        [object[]] $Overrides,

        # Return the result as a hashtable instead of a pscustomobject
        [Parameter()]
        [switch] $AsHashtable
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        try {

            if ($Main -isnot [hashtable]) {
                $Main = $Main | ConvertTo-Hashtable
            }
            $hashtable = $Main.clone()

            foreach ($Override in $Overrides) {
                if ($Override -isnot [hashtable]) {
                    $Override = $Override | ConvertTo-Hashtable
                }

                $Override.Keys | ForEach-Object {
                    $hashtable[$_] = $Override[$_]
                }
            }

            if ($AsHashtable) {
                return $hashtable
            }

            $hashtable | ConvertFrom-HashTable
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
