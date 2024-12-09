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
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Verbose "[$commandName] - Start"
        $Context = Resolve-GitHubContext -Context $Context
    }

    process {
        Write-Verbose 'Token splatt:'
        $Context.Token | ConvertFrom-SecureString -AsPlainText | ForEach-Object { Write-Verbose "Token: $_" }
        if ($PSCmdlet.ShouldProcess("$Context", 'Set default context')) {
            Set-GitHubConfig -Name 'DefaultContext' -Value $Context.Name
        }
    }

    end {
        Write-Verbose "[$commandName] - End"
    }
}
