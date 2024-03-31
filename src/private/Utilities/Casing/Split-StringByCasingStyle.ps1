filter Split-StringByCasingStyle {
    <#
        .SYNOPSIS
        Splits a kebab-case string into an array of words

        .DESCRIPTION
        This function splits a kebab-case string into an array of words.

        .EXAMPLE
        Split-StringByCasingStyle -Text 'this-is-a-kebab-case-string' -By kebab-case

        this
        is
        a
        kebab
        case
        string

        .EXAMPLE
        Split-StringByCasingStyle -Text 'this_is_a_kebab_case_string' -By 'snake_case'

        this
        is
        a
        kebab
        case
        string

        .EXAMPLE
        Split-StringByCasingStyle -Text 'ThisIsAPascalCaseString' -By 'PascalCase'

        This
        Is
        A
        Pascal
        Case
        String

        .EXAMPLE
        Split-StringByCasingStyle -Text 'thisIsACamelCaseString' -By 'camelCase'

        this
        Is
        A
        Camel
        Case
        String

        .EXAMPLE
        Split-StringByCasingStyle -Text 'this_is_a-CamelCaseString' -By kebab-case | Split-StringByCasingStyle -By snake_case

        this_is_a
        camelcasestring


    #>
    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        # The string to split
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [string] $Text,

        # The casing style to split the string by
        [Parameter()]
        [ValidateSet(
            'lowercase',
            'UPPERCASE',
            'Sentencecase',
            'Title Case',
            'PascalCase',
            'camelCase',
            'kebab-case',
            'UPPER-KEBAB-CASE',
            'snake_case',
            'UPPER_SNAKE_CASE'
        )]
        [string] $By
    )

    $styles = $PSBoundParameters | Where-Object { $_.Value -eq $true } | Select-Object -ExpandProperty Name

    Write-Verbose "Splitting string [$Text] by casing style [$($styles -join ', ' )]"
    $splitText = switch ($By) {
        'PascalCase' { [regex]::Matches($Text, '([A-Z][a-z]*)').Value; break }
        'camelCase' { [regex]::Matches($Text, '([A-Z][a-z]*)|^[a-z]+').Value; break }
        'kebab-case' { $Text -split '-'; break }
        'UPPER-KEBAB-CASE' { $Text -split '-'; break }
        'snake_case' { $Text -split '_'; break }
        'UPPER_SNAKE_CASE' { $Text -split '_'; break }
        default {
            $Text -split ' '
        }
    }

    Write-Verbose "Result: [$($splitText -join ', ')]"
    $splitText
}
