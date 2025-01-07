function Start-GitHubLogGroup {
    <#
        .SYNOPSIS
        Starts a log group in GitHub Actions

        .EXAMPLE
        New-LogGroup 'MyGroup'

        Starts a new log group named 'MyGroup'

        .NOTES
        [GitHub - Grouping log lines](https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#grouping-log-lines)
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

    begin {}

    process {
        try {
            Write-Host "::group::$Name"
        } catch {
            throw $_
        }
    }

    end {}
}
