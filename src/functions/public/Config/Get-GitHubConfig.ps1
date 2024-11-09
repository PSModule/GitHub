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
        [ValidateSet(
            'All',
            'AccessToken',
            'AccessTokenExpirationDate',
            'AccessTokenType',
            'ApiBaseUri',
            'ApiVersion',
            'AuthClientID',
            'AuthType',
            'ClientID',
            'DeviceFlowType',
            'HostName',
            'Owner',
            'RefreshToken',
            'RefreshTokenExpirationDate',
            'Repo',
            'Scope',
            'SecretVaultName',
            'SecretVaultType',
            'UserName'
        )]
        [string] $Name = 'All'
    )

    $prefix = $script:Config.Prefix

    switch -Regex ($Name) {
        '^AccessToken$|^RefreshToken$' {
            Get-StoreConfig -Name "$prefix$Name" -Store $script:Config.Name
        }
        '^All$' {
            Get-Store -Store $script:Config.Name
        }
        default {
            Get-StoreConfig -Name $Name -Store $script:Config.Name
        }
    }
}
