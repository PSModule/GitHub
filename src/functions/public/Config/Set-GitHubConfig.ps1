#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '2.0.0' }

function Set-GitHubConfig {
    <#
        .SYNOPSIS
        Set a GitHub module configuration.

        .DESCRIPTION
        Set a GitHub module configuration.

        .EXAMPLE
        Set-GitHubConfig -Name DefaultUser -Value 'Octocat'

        Sets the DefaultUser item in the GitHub configuration to 'Octocat'.
    #>
    [Alias('Set-GHConfig')]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Set the access token type.
        [Parameter()]
        [string] $Name,

        # Set the access token type.
        [Parameter()]
        [string] $Value
    )

    if ($PSCmdlet.ShouldProcess('ContextSetting', 'Set')) {
        Set-ContextSetting -Name $Name -Value $Value -Context $script:Config.Name
    }
}
