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

    $RefreshTokenData = Get-SecretInfo -Name "$prefix`RefreshToken" |
        Select-Object -ExpandProperty Metadata | ConvertFrom-HashTable | ConvertTo-HashTable
    $AccessTokenData = Get-SecretInfo -Name "$prefix`AccessToken" |
        Select-Object -ExpandProperty Metadata | ConvertFrom-HashTable | ConvertTo-HashTable
    $metadata = Join-Object -Main $RefreshTokenData -Overrides $AccessTokenData -AsHashtable

    switch ($Name) {
        'AccessToken' {
            Get-Secret -Name "$prefix`AccessToken"
        }
        'RefreshToken' {
            Get-Secret -Name "$prefix`RefreshToken"
        }
        default {
            if ($Name) {
                $metadata.$Name
            } else {
                $metadata.GetEnumerator() | Sort-Object -Property Name
            }
        }
    }
}
