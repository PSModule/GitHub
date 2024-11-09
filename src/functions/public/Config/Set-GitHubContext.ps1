function Set-GitHubContext {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The name of the context.
        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter()]
        [string] $ID,

        # Set the access token type.
        [Parameter()]
        [string] $AccessTokenType,

        # Set the access token.
        [Parameter()]
        [securestring] $Secret,

        # Set the access token expiration date.
        [Parameter()]
        [datetime] $AccessTokenExpirationDate,

        # Set the API Base URI.
        [Parameter()]
        [string] $ApiBaseUri,

        # Set the GitHub API Version.
        [Parameter()]
        [string] $ApiVersion,

        # Set the authentication client ID.
        [Parameter()]
        [string] $ClientID,

        # Set the authentication type.
        [Parameter()]
        [string] $AuthType,

        # Set the device flow type.
        [Parameter()]
        [string] $DeviceFlowType,

        # Set the API hostname.
        [Parameter(Mandatory)]
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
        [string] $Scope
    )

    $storeName = $Script:Config.Name
    # $storeName = $Script:Config.Name, $HostName, $Name -join '/'

    if ($PSCmdlet.ShouldProcess('Context', 'Set')) {

        if ($RefreshToken) {
            Set-Store -Name "$storeName/RefreshName" -Secret $RefreshToken -Variables @{
                RefreshTokenExpirationDate = $RefreshTokenExpirationDate
            }
        }

        Set-Store -Name $storeName -Secret $Secret -Variables @{
            Name                       = $Name
            ID                         = $ID
            HostName                   = $HostName
            AccessTokenExpirationDate  = $AccessTokenExpirationDate
            AccessTokenType            = $AccessTokenType
            ApiBaseUri                 = $ApiBaseUri
            ApiVersion                 = $ApiVersion
            AuthClientID               = $AuthClientID
            AuthType                   = $AuthType
            ClientID                   = $ClientID
            DeviceFlowType             = $DeviceFlowType
            Owner                      = $Owner
            "$prefix`RefreshToken"     = $RefreshToken
            RefreshTokenExpirationDate = $RefreshTokenExpirationDate
            Repo                       = $Repo
            Scope                      = $Scope
            SecretVaultName            = $SecretVaultName
            SecretVaultType            = $SecretVaultType
            UserName                   = $UserName
        }
    }
}
