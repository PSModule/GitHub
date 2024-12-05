#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '4.0.0' }

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
    param(
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

        # Set the enterprise name for the context.
        [Parameter()]
        [string] $Enterprise,

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

        # The context name to set the configuration for.
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    $commandName = $MyInvocation.MyCommand.Name
    Write-Verbose "[$commandName] - Start"

    $params = @{
        ApiBaseUri                 = $ApiBaseUri                 # https://api.github.com
        ApiVersion                 = $ApiVersion                 # 2022-11-28
        AuthClientID               = $AuthClientID               # Client ID for UAT
        AuthType                   = $AuthType                   # UAT / PAT / App / IAT
        ClientID                   = $ClientID                   # Client ID for GitHub Apps
        DeviceFlowType             = $DeviceFlowType             # GitHubApp / OAuthApp
        HostName                   = $HostName                   # github.com / msx.ghe.com / github.local
        NodeID                     = $NodeID                     # User ID / app ID (GraphQL Node ID)
        DatabaseID                 = $DatabaseID                 # Database ID
        UserName                   = $UserName                   # User name
        Enterprise                 = $Enterprise                 # Enterprise name
        Owner                      = $Owner                      # Owner name
        Repo                       = $Repo                       # Repo name
        Scope                      = $Scope                      # 'gist read:org repo workflow'
        #-----------------------------------------------------------------------------------------
        TokenType                  = $TokenType                  # ghu / gho / ghp / github_pat / PEM / ghs /
        Token                      = $Token                      # Access token
        TokenExpirationDate        = $TokenExpirationDate        # 2024-01-01-00:00:00
        RefreshToken               = $RefreshToken               # Refresh token
        RefreshTokenExpirationDate = $RefreshTokenExpirationDate # 2024-01-01-00:00:00
    }

    $params | Remove-HashtableEntry -NullOrEmptyValues
    $contextID = "$($Script:Config.Name)/$Context"
    $contextObj = Get-Context -ID $contextID
    $contextHashtable = $contextObj | ConvertTo-Hashtable
    $contextHashtable = Join-Object -Main $contextHashtable -Overrides $params -AsHashtable
    if ($PSCmdlet.ShouldProcess("settings for [$Contex]", 'Update')) {
        Set-Context -ID $contextID -Context $contextHashtable
    }

    Write-Verbose "[$commandName] - End"
}
