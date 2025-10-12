function Disable-GitHubCommand {
    <#
        .SYNOPSIS
        Stops workflow commands

        .DESCRIPTION
        Stops processing any workflow commands. This special command allows you to log anything without accidentally running a workflow command.
        For example, you could stop logging to output an entire script that has comments.

        To stop the processing of workflow commands, pass a unique string to the function. To resume processing workflow commands, pass the same string
        that you used to stop workflow commands to the Enable-GitHubCommand.

        .EXAMPLE
        ```pwsh
        Disable-GitHubCommand "123"
        ```

        Stops processing any workflow commands.

        .NOTES
        [Stopping and starting workflow commands](https://docs.github.com/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions#stopping-and-starting-workflow-commands)

        .LINK
        https://psmodule.io/GitHub/Functions/Commands/Disable-GitHubCommand
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '', Scope = 'Function',
        Justification = 'Long doc links'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingWriteHost', '', Scope = 'Function',
        Justification = 'Intended for logging in Github Runners which does support Write-Host'
    )]
    [OutputType([void])]
    [CmdletBinding()]
    param(
        # The unique string to stop the processing of workflow commands
        [Parameter(Mandatory)]
        [string] $String
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        $String = $String.ToLower()

        if ($env:GITHUB_ACTIONS -eq 'true') {
            Write-Host "::stop-commands::$String"
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
