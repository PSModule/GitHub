#Requires -Modules Store

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
            'AccessToken',
            'AccessTokenExpirationDate',
            'AccessTokenType',
            'ApiBaseUri',
            'ApiVersion',
            'AuthType',
            'DeviceFlowType',
            'Owner',
            'RefreshToken',
            'RefreshTokenExpirationDate',
            'Repo',
            'Scope',
            'UserName'
        )]
        [string] $Name
    )

    $prefix = $script:SecretVault.Prefix

    switch ($Name) {
        'AccessToken' {
            Get-StoreConfig -Name "$prefix`AccessToken"
        }
        'RefreshToken' {
            Get-StoreConfig -Name "$prefix`RefreshToken"
        }
        default {
            Get-StoreConfig -Name $Name
        }
    }
}
