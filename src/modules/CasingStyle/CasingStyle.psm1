[CmdletBinding()]
param()
$baseName = [System.IO.Path]::GetFileNameWithoutExtension($PSCommandPath)
$script:PSModuleInfo = Test-ModuleManifest -Path "$PSScriptRoot\$baseName.psd1"
$script:PSModuleInfo | Format-List | Out-String -Stream | ForEach-Object { Write-Debug $_ }
$scriptName = $script:PSModuleInfo.Name
Write-Debug "[$scriptName] - Importing module"
#region    [functions] - [public]
Write-Debug "[$scriptName] - [functions] - [public] - Processing folder"
#region    [functions] - [public] - [ConvertTo-CasingStyle]
Write-Debug "[$scriptName] - [functions] - [public] - [ConvertTo-CasingStyle] - Importing"
filter ConvertTo-CasingStyle {
    <#
        .SYNOPSIS
        Convert a string to a different casing style

        .DESCRIPTION
        This function converts a string to a different casing style.

        .EXAMPLE
        'thisIsCamelCase' | ConvertTo-CasingStyle -To 'snake_case'

        Convert the string 'thisIsCamelCase' to 'this_is_camel_case'

        .EXAMPLE
        'thisIsCamelCase' | ConvertTo-CasingStyle -To 'UPPER_SNAKE_CASE'

        Convert the string 'thisIsCamelCase' to 'THIS_IS_CAMEL_CASE'

        .EXAMPLE
        'thisIsCamelCase' | ConvertTo-CasingStyle -To 'kebab-case'

        .OUTPUTS
        [string] - The converted string

        .LINK
        https://psmodule.io/CasingStyle/Functions/ConvertTo-CasingStyle/
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

    $currentStyle = Get-CasingStyle -Text $Text

    $words = Split-CasingStyle -Text $Text -By $currentStyle

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
Write-Debug "[$scriptName] - [functions] - [public] - [ConvertTo-CasingStyle] - Done"
#endregion [functions] - [public] - [ConvertTo-CasingStyle]
#region    [functions] - [public] - [Get-CasingStyle]
Write-Debug "[$scriptName] - [functions] - [public] - [Get-CasingStyle] - Importing"
filter Get-CasingStyle {
    <#
        .SYNOPSIS
        Detects the casing style of a string

        .DESCRIPTION
        This function detects the casing style of a string.

        .EXAMPLE
        'testtesttest' | Get-CasingStyle

        lowercase

        .EXAMPLE
        'TESTTESTTEST' | Get-CasingStyle

        UPPERCASE

        .EXAMPLE
        'Testtesttest' | Get-CasingStyle

        Sentencecase

        .EXAMPLE
        'TestTestTest' | Get-CasingStyle

        PascalCase

        .EXAMPLE
        'testTestTest' | Get-CasingStyle

        camelCase

        .EXAMPLE
        'test-test-test' | Get-CasingStyle

        kebab-case

        .EXAMPLE
        'TEST-TEST-TEST' | Get-CasingStyle

        UPPER-KEBAB-CASE

        .EXAMPLE
        'test_test_test' | Get-CasingStyle

        snake_case

        .EXAMPLE
        'TEST_TEST_TEST' | Get-CasingStyle

        UPPER_SNAKE_CASE

        .EXAMPLE
        'Test_teSt-Test' | Get-CasingStyle

        Unknown

        .OUTPUTS
        [string] - The detected casing style of the input string

        .LINK
        https://psmodule.io/CasingStyle/Functions/Get-CasingStyle/
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param (
        # The string to check the casing style of
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [string] $Text
    )

    $style = if ([regex]::Match($Text, $script:LowerCase).Success) {
        'lowercase'
    } elseif ([regex]::Match($Text, $script:UpperCase).Success) {
        'UPPERCASE'
    } elseif ([regex]::Match($Text, $script:SentenceCase).Success) {
        'Sentencecase'
    } elseif ([regex]::Match($Text, $script:TitleCase).Success) {
        'Title Case'
    } elseif ([regex]::Match($Text, $script:PascalCase).Success) {
        'PascalCase'
    } elseif ([regex]::Match($Text, $script:CamelCase).Success) {
        'camelCase'
    } elseif ([regex]::Match($Text, $script:KebabCase).Success) {
        'kebab-case'
    } elseif ([regex]::Match($Text, $script:UpperKebabCase).Success) {
        'UPPER-KEBAB-CASE'
    } elseif ([regex]::Match($Text, $script:SnakeCase).Success) {
        'snake_case'
    } elseif ([regex]::Match($Text, $script:UpperSnakeCase).Success) {
        'UPPER_SNAKE_CASE'
    } else {
        'Unknown'
    }

    Write-Verbose "Detected casing style: [$style]"
    $style
}
Write-Debug "[$scriptName] - [functions] - [public] - [Get-CasingStyle] - Done"
#endregion [functions] - [public] - [Get-CasingStyle]
#region    [functions] - [public] - [Split-CasingStyle]
Write-Debug "[$scriptName] - [functions] - [public] - [Split-CasingStyle] - Importing"
filter Split-CasingStyle {
    <#
        .SYNOPSIS
        Splits a string based on one or more casing styles.

        .DESCRIPTION
        This function takes a string and an array of casing styles (via the -By parameter)
        and splits the string into its component words. It does this iteratively,
        applying each split to every token produced by the previous one.

        .EXAMPLE
        Split-CasingStyle -Text 'this-is-a-kebab-case-string' -By kebab-case

        this
        is
        a
        kebab
        case
        string

        .EXAMPLE
        Split-CasingStyle -Text 'this_is_a_kebab_case_string' -By 'snake_case'

        this
        is
        a
        kebab
        case
        string

        .EXAMPLE
        Split-CasingStyle -Text 'ThisIsAPascalCaseString' -By 'PascalCase'

        This
        Is
        A
        Pascal
        Case
        String

        .EXAMPLE
        Split-CasingStyle -Text 'thisIsACamelCaseString' -By 'camelCase'

        this
        Is
        A
        Camel
        Case
        String

        .EXAMPLE
        Split-CasingStyle -Text 'this_is_a-CamelCaseString' -By kebab-case | Split-CasingStyle -By snake_case

        this_is_a
        camelcasestring

        .EXAMPLE
        'this_is_a-PascalString' | Split-CasingStyle -By 'snake_case','kebab-case','PascalCase'

        .OUTPUTS
        [string[]] - An array of strings, each representing a word in the original string

        .LINK
        https://psmodule.io/CasingStyle/Functions/Split-CasingStyle/
    #>
    [CmdletBinding()]
    param(
        # The string to split
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [string]$Text,

        # The casing style(s) to split the string by.
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
        [string[]]$By
    )

    process {
        Write-Verbose "Starting with string: [$Text]"
        # Start with the original text as the only token.
        $tokens = @($Text)

        # For each casing style in the -By list, split every token accordingly.
        foreach ($style in $By) {
            Write-Verbose "Splitting by casing style: $style"
            $newTokens = @()
            foreach ($token in $tokens) {
                switch ($style) {
                    'PascalCase' {
                        # Use regex to match sequences like 'Pascal' and 'String' in 'PascalString'
                        $matchedTokens = [regex]::Matches($token, '([A-Z][a-z]*)')
                        if ($matchedTokens.Count -gt 0) {
                            $newTokens += $matchedTokens | ForEach-Object { $_.Value }
                        } else {
                            $newTokens += $token
                        }
                        break
                    }
                    'camelCase' {
                        # Match leading lowercase or uppercase letter groups
                        $matchedTokens = [regex]::Matches($token, '(^[a-z]+|[A-Z][a-z]*)')
                        if ($matchedTokens.Count -gt 0) {
                            $newTokens += $matchedTokens | ForEach-Object { $_.Value }
                        } else {
                            $newTokens += $token
                        }
                        break
                    }
                    'kebab-case' {
                        $newTokens += $token -split '-'
                        break
                    }
                    'UPPER-KEBAB-CASE' {
                        $newTokens += $token -split '-'
                        break
                    }
                    'snake_case' {
                        $newTokens += $token -split '_'
                        break
                    }
                    'UPPER_SNAKE_CASE' {
                        $newTokens += $token -split '_'
                        break
                    }
                    default {
                        # For any other case styles, you might split on whitespace
                        $newTokens += $token -split ' '
                        break
                    }
                }
            }
            # Update tokens with the newly split parts
            $tokens = $newTokens
            Write-Verbose "Tokens after splitting by $style`: [$($tokens -join ', ')]"
        }
        Write-Verbose "Final result: [$($tokens -join ', ')]"
        $tokens
    }
}
Write-Debug "[$scriptName] - [functions] - [public] - [Split-CasingStyle] - Done"
#endregion [functions] - [public] - [Split-CasingStyle]
Write-Debug "[$scriptName] - [functions] - [public] - Done"
#endregion [functions] - [public]
#region    [variables] - [private]
Write-Debug "[$scriptName] - [variables] - [private] - Processing folder"
#region    [variables] - [private] - [Cases]
Write-Debug "[$scriptName] - [variables] - [private] - [Cases] - Importing"
$script:LowerCase = '^[a-z][a-z0-9]*$'
$script:UpperCase = '^[A-Z][A-Z0-9]*$'
$script:SentenceCase = '^[A-Z][a-z0-9]*$'
$script:TitleCase = '^([A-Z][a-z]*)(\s+[A-Z][a-z]*)+$'
$script:PascalCase = '^[A-Z][a-z0-9]*([A-Z][a-z0-9]*)+$'
$script:CamelCase = '^[a-z][a-z0-9]*([A-Z][a-z0-9]*)+$'
$script:KebabCase = '^[a-z][a-z0-9]*(-[a-z0-9]+)+$'
$script:UpperKebabCase = '^[A-Z][A-Z0-9]*(-[A-Z0-9]+)+$'
$script:SnakeCase = '^[a-z][a-z0-9]*(_[a-z0-9]+)+$'
$script:UpperSnakeCase = '^[A-Z][A-Z0-9]*(_[A-Z0-9]+)+$'
Write-Debug "[$scriptName] - [variables] - [private] - [Cases] - Done"
#endregion [variables] - [private] - [Cases]
Write-Debug "[$scriptName] - [variables] - [private] - Done"
#endregion [variables] - [private]

#region    Member exporter
$exports = @{
    Alias    = '*'
    Cmdlet   = ''
    Function = @(
        'ConvertTo-CasingStyle'
        'Get-CasingStyle'
        'Split-CasingStyle'
    )
}
Export-ModuleMember @exports
#endregion Member exporter

