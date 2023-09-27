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

    $prefix = $script:SecretVault.Prefix

    switch($Name) {
        'AccessToken' {
            Get-Secret -Name "$prefix`AccessToken"
        }
        'RefreshToken' {
            Get-Secret -Name "$prefix`RefreshToken"
        }
        'RefreshTokenExpirationDate' {
            $RefreshTokenData = Get-SecretInfo -Name "$prefix`RefreshToken"
            $RefreshTokenData.Metadata | ConvertFrom-HashTable | ConvertTo-HashTable | Select-Object -ExpandProperty $Name
        }
        default {
            $AccessTokenData = Get-SecretInfo -Name "$prefix`AccessToken"
            $AccessTokenData.Metadata | ConvertFrom-HashTable | ConvertTo-HashTable | Select-Object -ExpandProperty $Name
        }
    }
}
