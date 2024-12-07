class GitHubContext : Context {
    # The GitHub Context Name.
    # HostName/Username or HostName/AppSlug
    # github.com/Octocat
    [string] $Name

    # The API hostname.
    # github.com / msx.ghe.com / github.local
    [string] $HostName

    # The API base URI.
    # https://api.github.com
    [string] $ApiBaseUri

    # The GitHub API version.
    # 2022-11-28
    [string] $ApiVersion

    # The context type
    # User / App / Installation
    [string] $Type

    # The authentication type.
    # UAT / PAT / App / IAT
    [string] $AuthType

    # User ID / App ID as GraphQL Node ID
    [string] $NodeID

    # The Database ID of the context.
    [string] $DatabaseID


    # The user name.
    [string] $UserName

    # The access token.
    [securestring] $Token


    #--------------------------------------------------

    # The authentication client ID.
    # Client ID for UAT
    [string] $AuthClientID

    # Client ID for GitHub Apps
    [string] $ClientID

    # The device flow type.
    # GitHubApp / OAuthApp
    [string] $DeviceFlowType

    # The default value for the Enterprise parameter.
    [string] $Enterprise

    # The default value for the Owner parameter.
    [string] $Owner

    # The default value for the Repo parameter.
    [string] $Repo

    # The scope when authenticating with OAuth.
    # 'gist read:org repo workflow'
    [string] $Scope

    # The token type.
    # ghu / gho / ghp / github_pat / PEM / ghs /
    [string] $TokenType


    # The token expiration date.
    # 2024-01-01-00:00:00
    [datetime] $TokenExpirationDate

    # The installation ID.
    [int] $InstallationID

    # The refresh token.
    [securestring] $RefreshToken

    # The refresh token expiration date.
    # 2024-01-01-00:00:00
    [datetime] $RefreshTokenExpirationDate

    GitHubContext() : Base([string]$ID) {}

    [string] ToString() {
        return $this.Name
    }
}
