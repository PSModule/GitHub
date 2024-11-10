#Requires -Modules @{ ModuleName = 'Store'; ModuleVersion = '0.3.1' }

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

        # Set the client ID.
        [Parameter()]
        [string] $ClientID,

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
            Name                 = $Name                 # Username / app slug
            ID                   = $ID                   # User ID / app ID
            HostName             = $HostName             # github.com / msx.ghe.com / github.local
            SecretExpirationDate = $SecretExpirationDate # 2024-01-01-00:00:00
            SecretType           = $SecretType           # ghu / gho / ghp / github_pat / JWT / ghs /
            AuthType             = $AuthType             # UAT / PAT / App / IAT
            ApiBaseUri           = $ApiBaseUri           # https://api.github.com
            ApiVersion           = $ApiVersion           # 2022-11-28
            AuthClientID         = $AuthClientID         # Client ID for UAT
            ClientID             = $ClientID             # Client ID for GitHub Apps
            DeviceFlowType       = $DeviceFlowType       # GitHubApp / OAuthApp
            Owner                = $Owner                # Owner name
            Repo                 = $Repo                 # Repo name
            Scope                = $Scope                # 'gist read:org repo workflow'
        }

        $variables | Remove-HashtableEntry -NullOrEmptyValues

        Set-Store -Name $storeName -Secret $Secret -Variables $variables
    }
}
