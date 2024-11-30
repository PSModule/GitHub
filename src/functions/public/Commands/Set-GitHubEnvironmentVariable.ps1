function Set-GitHubEnvironmentVariable {
    <#
        .SYNOPSIS
        Setting an environment variable

        .DESCRIPTION
        Set a GitHub environment variable

        .EXAMPLE
        Set-GitHubEnv -Name 'MyVariable' -Value 'MyValue'

        .NOTES
        [Setting an environment variable](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions#setting-an-environment-variable)
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '', Scope = 'Function',
        Justification = 'Long doc links'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '', Scope = 'Function',
        Justification = 'Does not change system state significantly'
    )]
    [OutputType([void])]
    [Alias('Set-GitHubEnv')]
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

    Write-Verbose "Env: [$Name] = [$Value]"

    $Value = $Value.Split([System.Environment]::NewLine)
    $guid = [guid]::NewGuid().Guid
    "$Name<<$guid" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    $Value | ForEach-Object {
        $_ | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    }
    "$guid" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
}
