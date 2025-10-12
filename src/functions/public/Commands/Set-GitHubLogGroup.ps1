function Set-GitHubLogGroup {
    <#
        .SYNOPSIS
        Encapsulates commands with a log group in GitHub Actions

        .DESCRIPTION
        DSL approach for GitHub Action commands.
        Allows for colapsing of code in IDE for code that belong together.

        .EXAMPLE
        ```powershell
        Set-GitHubLogGroup -Name 'MyGroup' -ScriptBlock {
            Write-Host 'Hello, World!'
        }
        ```

        Creates a new log group named 'MyGroup' and writes 'Hello, World!' to the output.

        .EXAMPLE
        ```powershell
        LogGroup 'MyGroup' {
            Write-Host 'Hello, World!'
        }
        ```

        Uses the alias 'LogGroup' to create a new log group named 'MyGroup' and writes 'Hello, World!' to the output.

        .NOTES
        [GitHub - Grouping log lines](https://docs.github.com/actions/using-workflows/workflow-commands-for-github-actions#grouping-log-lines)

        .LINK
        https://psmodule.io/GitHub/Functions/Commands/Set-GitHubLogGroup
    #>
    [Alias('LogGroup')]
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
        # The name of the log group
        [Parameter(Mandatory)]
        [string] $Name,

        # The script block to execute
        [Parameter(Mandatory)]
        [scriptblock] $ScriptBlock
    )

    Write-Host "::group::$Name"
    . $ScriptBlock
    Write-Host '::endgroup::'
}
