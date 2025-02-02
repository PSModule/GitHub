#Requires -Modules @{ ModuleName = 'CasingStyle'; RequiredVersion = '1.0.2' }

filter ConvertTo-HashTable {
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
    param(
        # The object to be converted. The input takes any type of object. The original object is not modified.
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [object]$InputObject,

        # The casing style of the hashtable keys.
        [Parameter()]
        [ValidateSet(
            'lowercase',
            'UPPERCASE',
            'Title Case',
            'PascalCase',
            'camelCase',
            'kebab-case',
            'UPPER-KEBAB-CASE',
            'snake_case',
            'UPPER_SNAKE_CASE'
        )]
        [string]$NameCasingStyle
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        [hashtable]$hashtable = @{}
    }

    process {
        try {
            foreach ($item in $InputObject.PSObject.Properties) {
                $name = if ($NameCasingStyle) { ($item.Name | ConvertTo-CasingStyle -To $NameCasingStyle) } else { $item.Name } #FIXME: Add '#Requires -Modules' for [ConvertTo-CasingStyle] Suggestions: CasingStyle, Casing
                $hashtable[$name] = $item.Value
            }
            $hashtable
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
