function Switch-GitHubContext {
    <#
        .SYNOPSIS
        Set the default context.

        .DESCRIPTION
        Set the default context for the GitHub module.

        .EXAMPLE
        Switch-GitHubContext -Context 'github.com/Octocat'

        .LINK
        https://psmodule.io/GitHub/Functions/Auth/Context/Switch-GitHubContext
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(ValueFromPipeline)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        Write-Debug "Setting default context to [$Context]"
        $Context = Resolve-GitHubContext -Context $Context
        if ($PSCmdlet.ShouldProcess("$Context", 'Set default context')) {
            Set-GitHubConfig -Name 'DefaultContext' -Value $Context.Name
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
