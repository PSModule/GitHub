function Stop-GitHubLogGroup {
    <#
        .SYNOPSIS
        Stops the current log group in GitHub Actions

        .EXAMPLE
        Stop-LogGroup

        Starts a new log group named 'MyGroup'

        .NOTES
        [GitHub - Grouping log lines](https://docs.github.com/actions/using-workflows/workflow-commands-for-github-actions#grouping-log-lines)
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '', Scope = 'Function',
        Justification = 'Does not change state'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingWriteHost', '', Scope = 'Function',
        Justification = 'Intended for logging in Github Runners'
    )]
    [CmdletBinding()]
    [Alias('Stop-LogGroup')]
    param()

    if ($env:GITHUB_ACTIONS -eq 'true') {
        Write-Host '::endgroup::'
    }
}
