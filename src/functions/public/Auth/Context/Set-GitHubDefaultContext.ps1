function Set-GitHubDefaultContext {
    <#
        .SYNOPSIS
        Set the default context.

        .DESCRIPTION
        Set the default context for the GitHub module.

        .EXAMPLE
        Set-GitHubDefaultContext -Context 'github.com/Octocat'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(ValueFromPipeline)]
        [object] $Context = (Get-GitHubContext)
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
