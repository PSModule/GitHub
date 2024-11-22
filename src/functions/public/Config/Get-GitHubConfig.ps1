#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '3.0.3' }

function Get-GitHubConfig {
    <#
        .SYNOPSIS
        Get a GitHub module configuration.

        .DESCRIPTION
        Get a GitHub module configuration.

        .EXAMPLE
        Get-GitHubConfig -Name DefaultUser

        Get the DefaultUser value from the GitHub module configuration.
    #>
    [OutputType([void])]
    [CmdletBinding()]
    param (
        # The name of the configuration to get.
        [Parameter()]
        [string] $Name
    )

    if (-not $Name) {
        return Get-Context -Name $script:Config.Name
    }

    Get-ContextSetting -Name $Name -ID $script:Config.Name
}
