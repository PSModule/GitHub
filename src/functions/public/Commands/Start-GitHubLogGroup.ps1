function Start-GitHubLogGroup {
    <#
        .SYNOPSIS
        Starts a log group in GitHub Actions

        .DESCRIPTION
        Creates an expandable group in the GitHub Actions log. Anything you print to the log between the
        `Start-GitHubLogGroup` and `Stop-GitHubLogGroup` commands will be nested inside an expandable entry in the log.
        This is useful for organizing long log outputs and making them more readable.

        This function only has an effect when running in a GitHub Actions workflow (when $env:GITHUB_ACTIONS is 'true').
        When run outside of GitHub Actions, it does nothing.

        This corresponds to the `::group::{title}` workflow command in GitHub Actions.

        .EXAMPLE
        ```pwsh
        ```pwsh
        Start-GitHubLogGroup 'MyGroup'
        ```
        ```

        Starts a new log group named 'MyGroup'. All subsequent log output will be grouped under this expandable section
        until Stop-GitHubLogGroup is called.

        .EXAMPLE
        ```pwsh
        ```pwsh
        Start-GitHubLogGroup 'Building application'
        Write-Host 'Step 1: Restoring packages'
        Write-Host 'Step 2: Compiling code'
        Write-Host 'Step 3: Running tests'
        Stop-GitHubLogGroup
        ```
        ```

        Creates a collapsible log group containing the build steps. The output will appear nested under the
        "Building application" header in the GitHub Actions log.

        .LINK
        https://psmodule.io/GitHub/Functions/Commands/Start-GitHubLogGroup

        .NOTES
        [Workflow commands](https://docs.github.com/actions/using-workflows/workflow-commands-for-github-actions#grouping-log-lines)
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
        # The title of the log group.
        # This will be displayed as the header of the expandable group in the GitHub Actions log.
        [Parameter(Mandatory)]
        [string] $Name
    )

    if ($env:GITHUB_ACTIONS -eq 'true') {
        Write-Host "::group::$Name"
    }

}
