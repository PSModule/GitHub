filter Assert-GitHubContext {
    <#
        .SYNOPSIS
        Check if the context meets the requirements for the command.

        .DESCRIPTION
        This function checks if the context meets the requirements for the command.
        If the context does not meet the requirements, an error is thrown.

        .EXAMPLE
        Assert-GitHubContext -Context 'github.com/Octocat' -TokenType 'App'
    #>
    [OutputType([void])]
    [CmdletBinding()]
    param(
        # The context to run the command in.
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [object] $Context,

        # The required authtypes for the command.
        [Parameter(Mandatory)]
        [string[]] $AuthType
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Verbose "[$commandName] - Start"
    }

    process {
        $command = (Get-PSCallStack)[1].Command

        if ($Context.AuthType -notin $AuthType) {
            throw "The context '$($Context.Name)' does not match the required AuthTypes [$AuthType] for [$command]."
        }
    }

    end {
        Write-Verbose "[$commandName] - End"
    }
}
