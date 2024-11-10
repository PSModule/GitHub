#Requires -Modules @{ ModuleName = 'Store'; ModuleVersion = '0.3.1' }

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
        [string] $SecretType,

        # The ID of the context.
        [Parameter()]
        [string] $ID,

        # Set the access token.
        [Parameter()]
        [securestring] $Secret,

        # Set the access token expiration date.
        [Parameter()]
        [datetime] $SecretExpirationDate,

        # Set the API Base URI.
        [Parameter()]
        [string] $ApiBaseUri,

        # Set the GitHub API Version.
        [Parameter()]
        [string] $ApiVersion,

        # Set the authentication client ID.
        [Parameter()]
        [string] $AuthClientID,

        # Set the authentication type.
        [Parameter()]
        [string] $AuthType,

        # Set the client ID.
        [Parameter()]
        [string] $ClientID,

        # Set the device flow type.
        [Parameter()]
        [string] $DeviceFlowType,

        # Set the API hostname.
        [Parameter()]
        [string] $HostName,

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
        [string] $Name
    )

    $storeName = $Script:Config.Name

    if ($PSCmdlet.ShouldProcess('Config', 'Set')) {

        if ($RefreshToken) {
            Set-Store -Name "$storeName/RefreshToken" -Secret $RefreshToken -Variables @{
                RefreshTokenExpirationDate = $RefreshTokenExpirationDate
            }
        }

        $variables = @{
            ApiBaseUri           = $ApiBaseUri
            ApiVersion           = $ApiVersion
            AuthClientID         = $AuthClientID
            AuthType             = $AuthType
            ClientID             = $ClientID
            DeviceFlowType       = $DeviceFlowType
            HostName             = $HostName
            ID                   = $ID
            Name                 = $Name
            Owner                = $Owner
            Repo                 = $Repo
            Scope                = $Scope
            Secret               = $Secret
            SecretExpirationDate = $SecretExpirationDate
            SecretType           = $SecretType
        }

        $variables | Remove-HashtableEntry -NullOrEmptyValues

        foreach ($key in $variables.Keys) {
            if ($PSCmdlet.ShouldProcess("Setting [$key]", "to [$($variables[$key])]")) {
                Write-Verbose "Setting [$key] to [$($variables[$key])]"
                Set-StoreConfig -Name $key -Value $variables[$key] -Store $script:Config.Name
            }
        }
    }
}
