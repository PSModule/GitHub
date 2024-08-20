filter Convert-StringCasingStyle {
    <#
    .SYNOPSIS
    Convert a string to a different casing style

    .DESCRIPTION
    This function converts a string to a different casing style.

    .EXAMPLE
    'thisIsCamelCase' | Convert-StringCasingStyle -To 'snake_case'

    Convert the string 'thisIsCamelCase' to 'this_is_camel_case'

    .EXAMPLE
    'thisIsCamelCase' | Convert-StringCasingStyle -To 'UPPER_SNAKE_CASE'

    Convert the string 'thisIsCamelCase' to 'THIS_IS_CAMEL_CASE'

    .EXAMPLE
    'thisIsCamelCase' | Convert-StringCasingStyle -To 'kebab-case'

    .NOTES
    General notes
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param (
        # The string to convert
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [string] $Text,

        # The casing style to convert the string to
        [Parameter(Mandatory)]
        [ValidateSet(
            'lowercase',
            'UPPERCASE',
            'Title Case',
            'Sentencecase',
            'PascalCase',
            'camelCase',
            'kebab-case',
            'UPPER-KEBAB-CASE',
            'snake_case',
            'UPPER_SNAKE_CASE'
        )]
        [string] $To
    )

    $currentStyle = Get-StringCasingStyle -Text $Text

    $words = Split-StringByCasingStyle -Text $Text -By $currentStyle

    # Convert the words into the target style
    switch ($To) {
        'lowercase' { ($words -join '').toLower() }
        'UPPERCASE' { ($words -join '').toUpper() }
        'Title Case' { ($words | ForEach-Object { $_.Substring(0, 1).ToUpper() + $_.Substring(1).ToLower() }) -join ' ' }
        'Sentencecase' { $words -join '' | ForEach-Object { $_.Substring(0, 1).ToUpper() + $_.Substring(1).ToLower() } }
        'kebab-case' { ($words -join '-').ToLower() }
        'snake_case' { ($words -join '_').ToLower() }
        'PascalCase' { ($words | ForEach-Object { $_.Substring(0, 1).ToUpper() + $_.Substring(1).ToLower() }) -join '' }
        'camelCase' {
            $words[0].toLower() + (($words | Select-Object -Skip 1 | ForEach-Object { $_.Substring(0, 1).ToUpper() + $_.Substring(1) }) -join '')
        }
        'UPPER_SNAKE_CASE' { ($words -join '_').toUpper() }
        'UPPER-KEBAB-CASE' { ($words -join '-').toUpper() }
    }
}
