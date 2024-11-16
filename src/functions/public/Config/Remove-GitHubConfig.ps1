#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '2.0.1' }

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

    if ($PSCmdlet.ShouldProcess('ContextSetting', 'Remove')) {
        Set-ContextSetting -Name $Name -Value $null -Context $script:Config.Name
    }
}
