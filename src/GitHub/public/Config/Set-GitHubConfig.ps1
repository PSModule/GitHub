function Set-GitHubConfig {
    <#
        .SYNOPSIS
        Set the GitHub configuration.

        .DESCRIPTION
        Set the GitHub configuration. Specific scopes can be set by using the parameters.

        .EXAMPLE
        Set-GitHubConfig -APIBaseURI 'https://api.github.com" -APIVersion '2022-11-28'

        Sets the App.API scope of the GitHub configuration.

        .EXAMPLE
        Set-GitHubConfig -Name "MyFavouriteRepo" -Value 'https://github.com/PSModule/GitHub'

        Sets a item called 'MyFavouriteRepo' in the GitHub configuration.
    #>
    [Alias('Set-GHConfig')]
    [CmdletBinding()]
    param (
        # Set the access token type.
        [Parameter()]
        [string] $AccessTokenType = '',

        # Set the access token.
        [Parameter()]
        [securestring] $AccessToken = '',

        # Set the access token expiration date.
        [Parameter()]
        [datetime] $AccessTokenExpirationDate,

        # Set the API Base URI.
        [Parameter()]
        [string] $ApiBaseUri,

        # Set the GitHub API Version.
        [Parameter()]
        [string] $ApiVersion,

        # Set the authentication type.
        [Parameter()]
        [string] $AuthType,

        # Set the device flow type.
        [Parameter()]
        [string] $DeviceFlowType,

        # Set the default for the Owner parameter.
        [Parameter()]
        [string] $Owner,

        # Set the refresh token.
        [Parameter()]
        [securestring] $RefreshToken,

        # Set the refresh token expiration date.
        [Parameter()]
        [datetime] $RefreshTokenExpirationDate,

        # Set the default for the Repo parameter.
        [Parameter()]
        [string] $Repo,

        # Set the scope.
        [Parameter()]
        [string] $Scope,

        # Set the GitHub username.
        [Parameter()]
        [string] $UserName,

        # Force the setting of the configuration item.
        [Parameter()]
        [switch] $Force
    )

    $prefix = $script:SecretVault.Prefix

    #region AccessToken
    $accessTokenGetParam = @{
        Name  = "$prefix`AccessToken"
        Vault = $script:SecretVault.Name
    }
    $acessTokenSecretInfo = Get-SecretInfo @accessTokenGetParam
    $currentAccessTokenMetadata = $acessTokenSecretInfo.Metadata

    [hashtable]$accessTokenMetadata = $PSBoundParameters.Keys | ForEach-Object {
        @{
            Name  = $_
            Value = $PSBoundParameters[$_]
        }
    }
    if (-not $Force) {
        Remove-EmptyHashTableEntries -Hashtable $accessTokenMetadata
    }

    'AccessToken', 'RefreshToken', 'RefreshTokenExpirationDate', 'Force' | ForEach-Object {
        if ($accessTokenMetadata.ContainsKey($_)) {
            $accessTokenMetadata.Remove($_)
        }
    }

    Join-HashTable -Main $currentAccessTokenMetadata -Overrides $accessTokenMetadata

    $accessTokenSetParam = @{
        Name               = "$prefix`AccessToken"
        Vault              = $script:SecretVault.Name
        SecureStringSecret = $AccessToken
        Metadata           = $secretInfo.Metadata
    }
    Remove-EmptyHashTableEntries -Hashtable $accessTokenSetParam
    Set-SecretInfo @accessTokenSetParam
    #endregion AccessToken

    #region RefreshToken
    $refreshTokenGetParam = @{
        Name  = "$prefix`RefreshToken"
        Vault = $script:SecretVault.Name
    }
    $acessTokenSecretInfo = Get-SecretInfo @refreshTokenGetParam
    $currentRefreshTokenMetadata = $acessTokenSecretInfo.Metadata

    [hashtable]$refreshTokenMetadata = $PSBoundParameters.Keys | ForEach-Object {
        @{
            Name  = $_
            Value = $PSBoundParameters[$_]
        }
    }
    if (-not $Force) {
        Remove-EmptyHashTableEntries -Hashtable $refreshTokenMetadata
    }

    'AccessToken', 'RefreshToken', 'AccessTokenExpirationDate', 'Force' | ForEach-Object {
        if ($refreshTokenMetadata.ContainsKey($_)) {
            $refreshTokenMetadata.Remove($_)
        }
    }

    Join-HashTable -Main $currentRefreshTokenMetadata -DestinationHashTable $refreshTokenMetadata

    $refreshTokenSetParam = @{
        Name               = "$prefix`RefreshToken"
        Vault              = $script:SecretVault.Name
        SecureStringSecret = $RefreshToken
        Metadata           = $secretInfo.Metadata
    }
    Remove-EmptyHashTableEntries -Hashtable $refreshTokenSetParam
    Set-SecretInfo @refreshTokenSetParam
    #endregion RefreshToken
}
