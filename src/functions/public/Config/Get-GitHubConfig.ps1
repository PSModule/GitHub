#Requires -Modules @{ ModuleName = 'Store'; ModuleVersion = '0.3.0' }

function Get-GitHubConfig {
    <#
        .SYNOPSIS
        Get configuration value.

        .DESCRIPTION
        Get a named configuration value from the GitHub configuration file.

        .EXAMPLE
        Get-GitHubConfig -Name ApiBaseUri

        Get the current GitHub configuration for the ApiBaseUri.
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
        return Get-GitHubContext
    }

    Get-StoreConfig -Name $Name -Store $script:Config.Name
}
