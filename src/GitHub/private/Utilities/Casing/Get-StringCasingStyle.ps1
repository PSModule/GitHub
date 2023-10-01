filter Get-StringCasingStyle {
    <#
        .SYNOPSIS
        Detects the casing style of a string

        .DESCRIPTION
        This function detects the casing style of a string.

        .EXAMPLE
        'testtesttest' | Get-StringCasingStyle

        lowercase

        .EXAMPLE
        'TESTTESTTEST' | Get-StringCasingStyle

        UPPERCASE

        .EXAMPLE
        'Testtesttest' | Get-StringCasingStyle

        Sentencecase

        .EXAMPLE
        'TestTestTest' | Get-StringCasingStyle

        PascalCase

        .EXAMPLE
        'testTestTest' | Get-StringCasingStyle

        camelCase

        .EXAMPLE
        'test-test-test' | Get-StringCasingStyle

        kebab-case

        .EXAMPLE
        'TEST-TEST-TEST' | Get-StringCasingStyle

        UPPER-KEBAB-CASE

        .EXAMPLE
        'test_test_test' | Get-StringCasingStyle

        snake_case

        .EXAMPLE
        'TEST_TEST_TEST' | Get-StringCasingStyle

        UPPER_SNAKE_CASE

        .EXAMPLE
        'Test_teSt-Test' | Get-StringCasingStyle

        Unknown
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param (
        # The string to check the casing style of
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Text
    )

    $style = if ([regex]::Match($Text, '^[a-z][a-z0-9]*$').Success) {
        'lowercase'
    } elseif ([regex]::Match($Text, '^[A-Z][A-Z0-9]*$').Success) {
        'UPPERCASE'
    } elseif ([regex]::Match($Text, '^[A-Z][a-z0-9]*$').Success) {
        'Sentencecase'
    } elseif ([regex]::Match($Text, '^([A-Z][a-z]*)(\s+[A-Z][a-z]*)+$').Success) {
        'Title Case'
    } elseif ([regex]::Match($Text, '^[A-Z][a-z0-9]*([A-Z][a-z0-9]*)+$').Success) {
        'PascalCase'
    } elseif ([regex]::Match($Text, '^[a-z][a-z0-9]*([A-Z][a-z0-9]*)+$').Success) {
        'camelCase'
    } elseif ([regex]::Match($Text, '^[a-z][a-z0-9]*(-[a-z0-9]+)+$').Success) {
        'kebab-case'
    } elseif ([regex]::Match($Text, '^[A-Z][A-Z0-9]*(-[A-Z0-9]+)+$').Success) {
        'UPPER-KEBAB-CASE'
    } elseif ([regex]::Match($Text, '^[a-z][a-z0-9]*(_[a-z0-9]+)+$').Success) {
        'snake_case'
    } elseif ([regex]::Match($Text, '^[A-Z][A-Z0-9]*(_[A-Z0-9]+)+$').Success) {
        'UPPER_SNAKE_CASE'
    } else {
        'Unknown'
    }

    Write-Verbose "Detected casing style: [$style]"
    $style

}
