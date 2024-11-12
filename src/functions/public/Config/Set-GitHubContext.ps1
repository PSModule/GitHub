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

        # The Node ID of the context.
        [Parameter()]
        [string] $NodeID,

        # The Database ID of the context.
        [Parameter()]
        [string] $DatabaseID,

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

    # Set a temporary context.
    $variables = @{
        ApiBaseUri           = $ApiBaseUri           # https://api.github.com
        ApiVersion           = $ApiVersion           # 2022-11-28
        AuthClientID         = $AuthClientID         # Client ID for UAT
        AuthType             = $AuthType             # UAT / PAT / App / IAT
        ClientID             = $ClientID             # Client ID for GitHub Apps
        DeviceFlowType       = $DeviceFlowType       # GitHubApp / OAuthApp
        HostName             = $HostName             # github.com / msx.ghe.com / github.local
        NodeID               = $NodeID               # User ID / app ID (GraphQL Node ID)
        DatabaseID           = $DatabaseID           # Database ID
        Name                 = $Name                 # Username / app slug
        Owner                = $Owner                # Owner name
        Repo                 = $Repo                 # Repo name
        Scope                = $Scope                # 'gist read:org repo workflow'
        SecretExpirationDate = $SecretExpirationDate # 2024-01-01-00:00:00
        SecretType           = $SecretType           # ghu / gho / ghp / github_pat / PEM / ghs /
    }

    $variables | Remove-HashtableEntry -NullOrEmptyValues

    Set-Store -Name "$($Script:Config.Name)/tempContext" -Secret $Secret -Variables $variables

    # Run functions to get info on the temporary context.
    try {
        switch -Regex ($variables['AuthType']) {
            'PAT|UAT|IAT' {
                $viewer = Get-GitHubViewer -Context 'tempContext'
                $variables['Name'] = $viewer.login
                $variables['NodeID'] = $viewer.id
                $variables['DatabaseID'] = $viewer.databaseId
            }
            'App' {
                $app = Get-GitHubApp -Context 'tempContext'
                $variables['Name'] = $app.slug
                $variables['NodeID'] = $app.node_id
                $variables['DatabaseID'] = $app.id
            }
            default {
                $variables['Name'] = 'unknown'
                $variables['ID'] = 'unknown'
            }
        }
    } catch {
        Write-Error 'Failed to get info on the context.'
        throw ($_ | Out-String)
    }

    # Set the context to named context.
    Set-Store -Name "$($Script:Config.Name)/$HostName/$Name" -Secret $Secret -Variables $variables


    # Remove the temporary context.
    Remove-Store -Name "$($Script:Config.Name)/tempContext"

    # IF FIRST, set the context to the default context.
    # IF DEFAULT is defined, set the context to the default context.









    Write-Verbose ($context | Format-Table | Out-String)










    $storeName = "$($Script:Config.Name)/$NodeID"

    if ($PSCmdlet.ShouldProcess('Context', 'Set')) {

        if ($RefreshToken) {
            Set-Store -Name "$storeName/RefreshToken" -Secret $RefreshToken -Variables @{
                RefreshTokenExpirationDate = $RefreshTokenExpirationDate
            }
        }
        $variables = @{
            ApiBaseUri           = $ApiBaseUri           # https://api.github.com
            ApiVersion           = $ApiVersion           # 2022-11-28
            AuthClientID         = $AuthClientID         # Client ID for UAT
            AuthType             = $AuthType             # UAT / PAT / App / IAT
            ClientID             = $ClientID             # Client ID for GitHub Apps
            DeviceFlowType       = $DeviceFlowType       # GitHubApp / OAuthApp
            HostName             = $HostName             # github.com / msx.ghe.com / github.local
            NodeID               = $NodeID               # User ID / app ID (GraphQL Node ID)
            DatabaseID           = $DatabaseID           # Database ID
            Name                 = $Name                 # Username / app slug
            Owner                = $Owner                # Owner name
            Repo                 = $Repo                 # Repo name
            Scope                = $Scope                # 'gist read:org repo workflow'
            SecretExpirationDate = $SecretExpirationDate # 2024-01-01-00:00:00
            SecretType           = $SecretType           # ghu / gho / ghp / github_pat / PEM / ghs /
        }

        $variables | Remove-HashtableEntry -NullOrEmptyValues

        Set-Store -Name $storeName -Secret $Secret -Variables $variables
    }
}
