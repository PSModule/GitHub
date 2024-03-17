#Requires -Modules Store

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
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Set the access token type.
        [Parameter()]
        [string] $AccessTokenType,

        # Set the access token.
        [Parameter()]
        [securestring] $AccessToken,

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
        [string] $UserName
    )

    $prefix = $script:Config.Prefix

    $Settings = @{
        "$prefix`AccessToken"      = $AccessToken
        AccessTokenExpirationDate  = $AccessTokenExpirationDate
        AccessTokenType            = $AccessTokenType
        ApiBaseUri                 = $ApiBaseUri
        ApiVersion                 = $ApiVersion
        AuthType                   = $AuthType
        DeviceFlowType             = $DeviceFlowType
        Owner                      = $Owner
        "$prefix`RefreshToken"     = $RefreshToken
        RefreshTokenExpirationDate = $RefreshTokenExpirationDate
        Repo                       = $Repo
        Scope                      = $Scope
        UserName                   = $UserName
    }

    $Settings | Remove-HashtableEntry -NullOrEmptyValues

    foreach ($key in $Settings.Keys) {
        if ($PSCmdlet.ShouldProcess("Setting $key", "Setting $key to $($Settings[$key])")) {
            Write-Verbose "Setting $key to $($Settings[$key])"
            Set-StoreConfig -Name $key -Value $Settings[$key]
        }
    }
}
