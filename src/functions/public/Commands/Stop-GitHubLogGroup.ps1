function Stop-GitHubLogGroup {
    <#
        .SYNOPSIS
        Stops the current log group in GitHub Actions

        .DESCRIPTION
        Ends the expandable group in the GitHub Actions log that was started with `Start-GitHubLogGroup`.
        All log output after this command will no longer be nested within the group.

        This function only has an effect when running in a GitHub Actions workflow (when $env:GITHUB_ACTIONS is 'true').
        When run outside of GitHub Actions, it does nothing.

        This corresponds to the `::endgroup::` workflow command in GitHub Actions.

        .EXAMPLE
        ```powershell
        Stop-GitHubLogGroup
        ```

        Stops the current log group in GitHub Actions.

        .EXAMPLE
        ```powershell
        Start-GitHubLogGroup 'Deployment Steps'
        Write-Host 'Deploying to staging...'
        Write-Host 'Deployment complete'
        Stop-GitHubLogGroup
        Write-Host 'This output is not in the group'
        ```

        Creates a log group for deployment steps. The final Write-Host command outputs text outside of the group
        since Stop-GitHubLogGroup was called.

        .LINK
        https://psmodule.io/GitHub/Functions/Commands/Stop-GitHubLogGroup

        .NOTES
        [Workflow commands](https://docs.github.com/actions/using-workflows/workflow-commands-for-github-actions#grouping-log-lines)
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
