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

        # Choose a custom name to set.
        [Parameter()]
        [string] $Name,

        # Choose a custom value to set.
        [Parameter()]
        [string] $Value = ''
    )

    $prefix = $script:SecretVault.Prefix

    #All timestamps return in UTC time, ISO 8601 format: YYYY-MM-DDTHH:MM:SSZ
    #Also: use Set-Secret -NAme ... -Value ... -Metadata @{Type = 'DateTime'} to set a datetime value
    # https://learn.microsoft.com/en-us/powershell/utility-modules/secretmanagement/how-to/manage-secretstore?view=ps-modules#adding-metadata

    switch ($PSBoundParameters.Keys) {
        'AccessToken' {
            Set-Secret -Name "$prefix`AccessToken" -SecureStringSecret $AccessToken -Vault $script:SecretVault.Name
        }
        'AccessTokenExpirationDate' {
            Set-Secret -Name "$prefix`AccessTokenExpirationDate" -Secret $AccessTokenExpirationDate.ToString() -Vault $script:SecretVault.Name
        }
        'AccessTokenType' {
            Set-Secret -Name "$prefix`AccessTokenType" -Secret $AccessTokenType -Vault $script:SecretVault.Name
        }
        'ApiBaseUri' {
            Set-Secret -Name "$prefix`ApiBaseUri" -Secret $ApiBaseUri -Vault $script:SecretVault.Name
        }
        'ApiVersion' {
            Set-Secret -Name "$prefix`ApiVersion" -Secret $ApiVersion -Vault $script:SecretVault.Name
        }
        'AuthType' {
            Set-Secret -Name "$prefix`AuthType" -Secret $AuthType -Vault $script:SecretVault.Name
        }
        'DeviceFlowType' {
            Set-Secret -Name "$prefix`DeviceFlowType" -Secret $DeviceFlowType -Vault $script:SecretVault.Name
        }
        'Owner' {
            Set-Secret -Name "$prefix`Owner" -Secret $Owner -Vault $script:SecretVault.Name
        }
        'RefreshToken' {
            Set-Secret -Name "$prefix`RefreshToken" -SecureStringSecret $RefreshToken -Vault $script:SecretVault.Name
        }
        'RefreshTokenExpirationDate' {
            Set-Secret -Name "$prefix`RefreshTokenExpirationDate" -Secret $RefreshTokenExpirationDate.ToString() -Vault $script:SecretVault.Name
        }
        'Repo' {
            Set-Secret -Name "$prefix`Repo" -Secret $Repo -Vault $script:SecretVault.Name
        }
        'Scope' {
            Set-Secret -Name "$prefix`Scope" -Secret $Scope -Vault $script:SecretVault.Name
        }
        'UserName' {
            Set-Secret -Name "$prefix`UserName" -Secret $UserName -Vault $script:SecretVault.Name
        }
        'Name' {
            Set-Secret -Name "$prefix$Name" -Secret $Value -Vault $script:SecretVault.Name
        }
    }
}
