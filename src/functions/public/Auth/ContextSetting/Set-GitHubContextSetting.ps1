#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '2.0.4' }

function Set-GitHubContextSetting {
    <#
        .SYNOPSIS
        Set the GitHub configuration.

        .DESCRIPTION
        Set the GitHub configuration. Specific scopes can be set by using the parameters.

        .EXAMPLE
        Set-GitHubContextSetting -APIBaseURI 'https://api.github.com" -APIVersion '2022-11-28'

        Sets the App.API scope of the GitHub configuration.

        .EXAMPLE
        Set-GitHubContextSetting -Name "MyFavouriteRepo" -Value 'https://github.com/PSModule/GitHub'

        Sets a item called 'MyFavouriteRepo' in the GitHub configuration.
    #>
    [Alias('Set-GHConfig')]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Set the access token type.
        [Parameter()]
        [string] $TokenType,

        # The Node ID of the context.
        [Parameter()]
        [string] $NodeID,

        # The Database ID of the context.
        [Parameter()]
        [string] $DatabaseID,

        # Set the access token.
        [Parameter()]
        [securestring] $Token,

        # Set the access token expiration date.
        [Parameter()]
        [datetime] $TokenExpirationDate,

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
        [string] $Scope
    )

    $storeName = $Script:Config.Name

    if ($PSCmdlet.ShouldProcess('Config', 'Set')) {

        if ($RefreshToken) {
            Set-Context -Name "$storeName/RefreshToken" -Token $RefreshToken -Variables @{
                RefreshTokenExpirationDate = $RefreshTokenExpirationDate
            }
        }

        $variables = @{
            ApiBaseUri          = $ApiBaseUri
            ApiVersion          = $ApiVersion
            AuthClientID        = $AuthClientID
            AuthType            = $AuthType
            ClientID            = $ClientID
            DeviceFlowType      = $DeviceFlowType
            HostName            = $HostName
            NodeID              = $NodeID
            DatabaseID          = $DatabaseID
            Owner               = $Owner
            Repo                = $Repo
            Scope               = $Scope
            Token               = $Token
            TokenExpirationDate = $TokenExpirationDate
            TokenType           = $TokenType
        }

        $variables | Remove-HashtableEntry -NullOrEmptyValues

        foreach ($key in $variables.Keys) {
            if ($PSCmdlet.ShouldProcess("Setting [$key]", "to [$($variables[$key])]")) {
                Write-Verbose "Setting [$key] to [$($variables[$key])]"
                Set-ContextSetting -Name $key -Value $variables[$key] -Context $script:Config.Name
            }
        }
    }
}
