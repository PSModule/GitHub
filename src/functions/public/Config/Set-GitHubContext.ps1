function Set-GitHubContext {
    <#
        .SYNOPSIS
        Short description

        .DESCRIPTION
        Long description

        .EXAMPLE
        An example

        .NOTES
        General notes
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The name of the context.
        [Parameter(Mandatory)]
        [string] $Name,

        # The ID of the context.
        [Parameter()]
        [string] $ID,

        # Set the access token type.
        [Parameter(Mandatory)]
        [string] $SecretType,

        # Set the access token.
        [Parameter(Mandatory)]
        [securestring] $Secret,

        # Set the expiration date of the contexts secret.
        [Parameter()]
        [datetime] $SecretExpirationDate,

        # Set the API Base URI.
        [Parameter(Mandatory)]
        [string] $ApiBaseUri,

        # Set the GitHub API Version.
        [Parameter(Mandatory)]
        [string] $ApiVersion,

        # Set the authentication client ID.
        [Parameter()]
        [string] $AuthClientID,

        # Set the authentication type.
        [Parameter(Mandatory)]
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
            Set-Store -Name "$storeName/RefreshToken" -Secret $RefreshToken -Variables @{
                RefreshTokenExpirationDate = $RefreshTokenExpirationDate
            }
        }
        $variables = @{
            Name                 = $Name
            ID                   = $ID
            HostName             = $HostName
            SecretExpirationDate = $SecretExpirationDate
            SecretType           = $SecretType
            ApiBaseUri           = $ApiBaseUri
            ApiVersion           = $ApiVersion
            AuthClientID         = $AuthClientID
            AuthType             = $AuthType
            ClientID             = $ClientID
            DeviceFlowType       = $DeviceFlowType
            Owner                = $Owner
            Repo                 = $Repo
            Scope                = $Scope
        }

        $variables | Remove-HashtableEntry -NullOrEmptyValues

        Set-Store -Name $storeName -Secret $Secret -Variables $variables
    }
}
