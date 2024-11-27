function Add-GitHubSystemPath {
    <#
    .SYNOPSIS
    Adds a system path to the GitHub Actions environment

    .DESCRIPTION
    Prepends a directory to the system PATH variable and automatically makes it available to all subsequent actions in the current job;
    the currently running action cannot access the updated path variable. To see the currently defined paths for your job, you can use
    echo "$env:PATH" in a step or an action.

    .EXAMPLE
    Add-GitHubSystemPath -Path '$HOME/.local/bin'

    .NOTES
    [Adding a system path](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions#adding-a-system-path)
    #>
    [CmdletBinding()]
    param (
        [string]$Path
    )

    Write-Verbose "Current PATH: $env:PATH"
    Write-Verbose "Adding system path: $Path"

    $Path | Out-File -FilePath $env:GITHUB_PATH -Append
}
