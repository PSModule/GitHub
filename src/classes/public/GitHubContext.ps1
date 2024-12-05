class GitHubContext : IFormattable {
    # The API base URI.
    # https://api.github.com
    [string] $ApiBaseUri

    # The GitHub API version.
    # 2022-11-28
    [string] $ApiVersion

    # The authentication client ID.
    # Client ID for UAT
    [string] $AuthClientID

    # The authentication type.
    # UAT / PAT / App / IAT
    [string] $AuthType

    # Client ID for GitHub Apps
    [string] $ClientID

    # The device flow type.
    # GitHubApp / OAuthApp
    [string] $DeviceFlowType

    # The API hostname.
    # github.com / msx.ghe.com / github.local
    [string] $HostName

    # User ID / App ID as GraphQL Node ID
    [string] $NodeID

    # The Database ID of the context.
    [string] $DatabaseID

    # The context ID.
    # HostName/Username or HostName/AppSlug
    # Context:PSModule.Github/github.com/Octocat
    [string] $ID

    # The GitHub Context Name.
    # HostName/Username or HostName/AppSlug
    # github.com/Octocat
    [string] $Name

    # The user name.
    [string] $UserName

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

    # The access token.
    [securestring] $Token

    # The token expiration date.
    # 2024-01-01-00:00:00
    [datetime] $TokenExpirationDate

    # The refresh token.
    [securestring] $RefreshToken

    # The refresh token expiration date.
    # 2024-01-01-00:00:00
    [datetime] $RefreshTokenExpirationDate

    GitHubContext([string]$ID) {
        $this.ID = $ID
    }

    GitHubContext([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    GitHubContext([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }

    [string] ToString() {
        return $this.Name
    }
}
