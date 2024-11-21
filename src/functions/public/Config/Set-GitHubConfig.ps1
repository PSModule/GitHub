#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '3.0.2' }

function Set-GitHubConfig {
    <#
        .SYNOPSIS
        Set a GitHub module configuration.

        .DESCRIPTION
        Set a GitHub module configuration.

        .EXAMPLE
        Set-GitHubConfig -Name DefaultUser -Value 'Octocat'

        Sets the value of DefaultUser to 'Octocat' in the GitHub module configuration.
    #>
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
        Set-ContextSetting -Name $Name -Value $Value -ID $script:Config.Name
    }
}
