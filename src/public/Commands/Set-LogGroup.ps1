function Set-LogGroup {
    <#
        .SYNOPSIS
        Encapsulates commands with a log group in GitHub Actions

        .DESCRIPTION
        DSL approach for GitHub Action commands.
        Allows for colapsing of code in IDE for code that belong together.

        .EXAMPLE
        Set-LogGroup -Name 'MyGroup' -ScriptBlock {
            Write-Host 'Hello, World!'
        }

        Creates a new log group named 'MyGroup' and writes 'Hello, World!' to the output.

        .EXAMPLE
        LogGroup 'MyGroup' {
            Write-Host 'Hello, World!'
        }

        Uses the alias 'LogGroup' to create a new log group named 'MyGroup' and writes 'Hello, World!' to the output.

        .NOTES
        [GitHub - Grouping log lines](https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#grouping-log-lines)
    #>
    [Alias('LogGroup')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '', Scope = 'Function',
        Justification = 'Does not change state'
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

    Start-LogGroup $Name
    Write-Output $ScriptBlock.Invoke()
    Stop-LogGroup
}
