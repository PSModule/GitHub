filter Assert-GitHubContext {
    <#
        .SYNOPSIS
        Check if the context meets the requirements for the command.

        .DESCRIPTION
        This function checks if the context meets the requirements for the command.
        If the context does not meet the requirements, an error is thrown.

        .EXAMPLE
        Assert-GitHubContext -Context 'github.com/Octocat' -AuthType 'App'
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

        # TODO: Implement permission check
        # # The required permission for the command.
        # [Parameter()]
        # [string] $Permission
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        $command = (Get-PSCallStack)[1].Command

        if ($Context.AuthType -notin $AuthType) {
            throw "The context '$($Context.Name)' does not match the required AuthTypes [$AuthType] for [$command]."
        }
        # TODO: Implement permission check
        # if ($Context.AuthType -in 'IAT' -and $Context.Permission -notin $Permission) {
        #     throw "The context '$($Context.Name)' does not match the required Permission [$Permission] for [$command]."
        # }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
