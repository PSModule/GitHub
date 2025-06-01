function Start-GitHubLogGroup {
    <#
        .SYNOPSIS
        Starts a log group in GitHub Actions

        .EXAMPLE
        New-LogGroup 'MyGroup'

        Starts a new log group named 'MyGroup'

        .NOTES
        [GitHub - Grouping log lines](https://docs.github.com/actions/using-workflows/workflow-commands-for-github-actions#grouping-log-lines)

        .LINK
        https://psmodule.io/GitHub/Functions/Commands/Start-GitHubLogGroup
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '', Scope = 'Function',
        Justification = 'Does not change state'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingWriteHost', '', Scope = 'Function',
        Justification = 'Intended for logging in Github Runners which does support Write-Host'
    )]
    [CmdletBinding()]
    [Alias('Start-LogGroup')]
    param(
        # The name of the log group
        [Parameter(Mandatory)]
        [string] $Name
    )

    if ($env:GITHUB_ACTIONS -eq 'true') {
        Write-Host "::group::$Name"
    }

}
