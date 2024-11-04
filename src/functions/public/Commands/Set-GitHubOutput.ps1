function Set-GitHubOutput {
    <#
        .SYNOPSIS
        Set a output variable in GitHub Actions

        .DESCRIPTION
        Set a output variable in GitHub Actions. If the variable is a SecureString, it will be converted to plain text and masked.

        .EXAMPLE
        Set-GitHubOutput -Name 'MyOutput' -Value 'Hello, World!'

        Creates a new output variable named 'MyOutput' with the value 'Hello, World!'.
    #>
    [OutputType([void])]
    [Alias('Output')]
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
        [object] $Value
    )
    if ($Value -Is [securestring]) {
        $Value = $Value | ConvertFrom-SecureString -AsPlainText -Force
        Add-Mask -Value $Value
    }
    Write-Verbose (@{ $Name = $Value } | Format-Table -Wrap -AutoSize | Out-String)
    "$Name=$Value" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
    if ([string]::IsNullOrEmpty($env:GITHUB_ACTION)) {
        Write-Warning "Cannot create output as the step has no ID."
    } else {
        Write-Verbose "Output: [$Name] avaiable as `${{ steps.$env:GITHUB_ACTION.outputs.$Name }}'"
    }
}
