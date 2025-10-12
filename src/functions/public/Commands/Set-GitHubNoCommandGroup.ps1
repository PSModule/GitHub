function Set-GitHubNoCommandGroup {
    <#
        .SYNOPSIS
        Disables workflow commands for a block of code.

        .DESCRIPTION
        DSL approach for GitHub Action commands.
        Allows for colapsing of code in IDE for code that belong together.

        .EXAMPLE
        ```powershell
        Set-GitHubNoCommandGroup {
            Write-Host 'Hello, World!'
            Write-GithubError 'This is an error'
        }
        ```

        Groups commands where no workflow commands are run.

        .EXAMPLE
        ```powershell
        NoLogGroup 'MyGroup' {
            Write-Host 'Hello, World!'
            Write-GithubError 'This is an error'
        }
        ```

        Groups commands where no workflow commands are run, using an alias and DSL approach.

        .NOTES
        [Stopping and starting workflow commands](https://docs.github.com/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions#stopping-and-starting-workflow-commands)

        .LINK
        https://psmodule.io/GitHub/Functions/Commands/Set-GitHubNoCommandGroup
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '', Scope = 'Function',
        Justification = 'Long doc links'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '', Scope = 'Function',
        Justification = 'Does not change state'
    )]
    [CmdletBinding()]
    [Alias('NoLogGroup')]
    param(
        # The script block to execute
        [Parameter(Mandatory)]
        [scriptblock] $ScriptBlock
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        $guid = [string][guid]::NewGuid().Guid

        Disable-GitHubCommand -String $guid
        . $ScriptBlock
        Enable-GitHubCommand -String $guid
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
