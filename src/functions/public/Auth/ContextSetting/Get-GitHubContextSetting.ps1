#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '2.0.0' }

function Get-GitHubConfig {
    <#
        .SYNOPSIS
        Get a module configuration value.

        .DESCRIPTION
        Get a named configuration value from the GitHub config.

        .EXAMPLE
        Get-GitHubConfig -Name DefaultUser

        Get the current GitHub configuration for the DefaultUser.
    #>
    [Alias('Get-GHConfig')]
    [Alias('GGHC')]
    [OutputType([object])]
    [CmdletBinding()]
    param (
        # Choose a configuration name to get.
        [Parameter()]
        [string] $Name
    )

    if (-not $Name) {
        Get-Context -Name $script:Config.Name -AsPlainText
    }

    Get-ContextSetting -Name $Name -Context $script:Config.Name -AsPlainText
}
