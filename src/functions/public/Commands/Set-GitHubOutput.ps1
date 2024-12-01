function Set-GitHubOutput {
    <#
        .SYNOPSIS
        Set a output variable in GitHub Actions

        .DESCRIPTION
        Supports SecureString and multiline strings.

        .EXAMPLE
        Set-GitHubOutput -Name 'MyOutput' -Value 'Hello, World!'

        Creates a new output variable named 'MyOutput' with the value 'Hello, World!'.

        .NOTES
        [Setting an output parameter](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions#setting-an-output-parameter)
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
    [Alias('Output')]
    [CmdletBinding()]
    param (
        # Name of the variable
        [Parameter(Mandatory)]
        [string] $Name,

        # Value of the variable
        [Parameter(Mandatory)]
        [AllowNull()]
        [object] $Value
    )

    if ($Value -Is [securestring]) {
        $Value = $Value | ConvertFrom-SecureString -AsPlainText -Force
        Add-Mask -Value $Value
    }

    if ([string]::IsNullOrEmpty($env:GITHUB_ACTION)) {
        Write-Warning 'Cannot create output as the step has no ID.'
    }

    Write-Verbose "Output: [$Name] = [$Value]"

    $guid = [guid]::NewGuid().Guid
    $content = @"
$Name<<$guid
$Value
$guid
"@
    $content | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append

    Write-Verbose "Output: [$Name] avaiable as `${{ steps.$env:GITHUB_ACTION.outputs.$Name }}'"
}
