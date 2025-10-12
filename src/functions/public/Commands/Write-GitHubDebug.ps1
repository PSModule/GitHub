function Write-GitHubDebug {
    <#
        .SYNOPSIS
        Write a debug message in GitHub Actions

        .DESCRIPTION
        Write a debug message in GitHub Actions. The message will only be displayed if the action is running in debug mode.
        To run in debug mode, you must create a secret or variable named ACTIONS_STEP_DEBUG with the value `true` to see the debug messages set by
        this command in the log. For more information, see [Enabling debug logging](https://docs.github.com/actions/monitoring-and-troubleshooting-workflows/troubleshooting-workflows/enabling-debug-logging).

        If both the secret and variable are set, the value of the secret takes precedence over the variable.

        .EXAMPLE
        ```pwsh
        Write-GitHubDebug -Message 'Hello, World!'
        ```

        Writes a debug message 'Hello, World!'.

        .NOTES
        [Enabling debug logging](https://docs.github.com/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions#setting-a-debug-message)

        .LINK
        https://psmodule.io/GitHub/Functions/Commands/Write-GitHubDebug
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '', Scope = 'Function',
        Justification = 'Long doc links'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingWriteHost', '', Scope = 'Function',
        Justification = 'Intended for logging in Github Runners'
    )]
    [OutputType([void])]
    [Alias('Debug')]
    [CmdletBinding()]
    param(
        # Message to write
        [Parameter(Mandatory)]
        [string] $Message
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        if ($env:GITHUB_ACTIONS -eq 'true') {
            Write-Host "::debug::$Message"
            return
        }
        Write-Debug "$Message"
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
