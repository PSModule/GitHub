function Set-GitHubEnvironmentVariable {
    <#
        .SYNOPSIS
        Set a GitHub environment variable

        .DESCRIPTION
        Set a GitHub environment variable

        .EXAMPLE
        Set-GitHubEnv -Name 'MyVariable' -Value 'MyValue'
    #>
    [OutputType([void])]
    [Alias('Set-GitHubEnv')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '', Scope = 'Function',
        Justification = 'Does not change system state significantly'
    )]
    [CmdletBinding()]
    param (
        # Name of the variable
        [Parameter(Mandatory)]
        [string] $Name,

        # Value of the variable
        [Parameter(Mandatory)]
        [AllowNull()]
        [string] $Value
    )
    Write-Verbose (@{ $Name = $Value } | Format-Table -Wrap -AutoSize | Out-String)
    "$Name=$Value" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
}
