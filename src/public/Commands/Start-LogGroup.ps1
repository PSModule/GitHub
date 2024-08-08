function Start-LogGroup {
    <#
        .SYNOPSIS
        Starts a log group in GitHub Actions

        .EXAMPLE
        New-LogGroup 'MyGroup'

        Starts a new log group named 'MyGroup'

        .NOTES
        [GitHub - Grouping log lines](https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#grouping-log-lines)
    #>
    [Alias('New-LogGroup')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '', Scope = 'Function',
        Justification = 'Does not change state'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingWriteHost', '', Scope = 'Function',
        Justification = 'Intended for logging in Github Runners which does support Write-Host'
    )]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Name
    )

    Write-Host "::group::$Name"
}
