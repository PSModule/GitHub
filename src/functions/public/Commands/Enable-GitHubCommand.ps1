function Enable-GitHubCommand {
    <#
        .SYNOPSIS
        Resumes workflow commands

        .DESCRIPTION
        Resumes processing any workflow commands.

        To stop the processing of workflow commands, pass a unique string to the function. To resume processing workflow commands, pass the same string
        that you used to stop workflow commands to the Enable-GitHubCommand.

        .EXAMPLE
        ```powershell
        Enable-GitHubCommand "123"
        ```

        Resumes processing any workflow commands.

        .NOTES
        [Stopping and starting workflow commands](https://docs.github.com/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions#stopping-and-starting-workflow-commands)

        .LINK
        https://psmodule.io/GitHub/Functions/Commands/Enable-GitHubCommand
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
        # The unique string to resume the processing of workflow commands
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
            Write-Host "::$String::"
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
