#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '3.0.3' }

function Remove-GitHubConfig {
    <#
        .SYNOPSIS
        Remove a GitHub module configuration.

        .DESCRIPTION
        Remove a GitHub module configuration.

        .EXAMPLE
        Remove-GitHubConfig -Name DefaultUser

        Removes the 'DefaultUser' item in the GitHub module configuration.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Set the access token type.
        [Parameter()]
        [string] $Name
    )

    $commandName = $MyInvocation.MyCommand.Name
    Write-Verbose "[$commandName] - Start"

    if ($PSCmdlet.ShouldProcess('ContextSetting', 'Remove')) {
        Set-ContextSetting -Name $Name -Value $null -ID $script:Config.Name
    }

    Write-Verbose "[$commandName] - End"
}
