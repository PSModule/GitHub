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
        # The context to set as the default.
        [Parameter(Mandatory)]
        [Alias('Name')]
        [string] $Context
    )

    $commandName = $MyInvocation.MyCommand.Name
    Write-Verbose "[$commandName] - Start"

    if ($PSCmdlet.ShouldProcess("$Context", 'Set default context')) {
        Set-GitHubConfig -Name 'DefaultContext' -Value $Context
    }

    Write-Verbose "[$commandName] - End"
}
