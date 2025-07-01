class GitHubContext {
    # The context ID.
    [string] $ID

    # The GitHub Context Name.
    # HostName/Username or HostName/AppSlug
    # github.com/Octocat
    [string] $Name

    # The display name of the context.
    # Octocat
    [string] $DisplayName

    # The context type
    # User / App / Installation
    [string] $Type

    # The API hostname.
    # github.com / msx.ghe.com / github.local
    [string] $HostName

    # The API base URI.
    # https://api.github.com
    [string] $ApiBaseUri

    # The GitHub API version.
    # 2022-11-28
    [string] $ApiVersion

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

    # The token type.
    # ghu / gho / ghp / github_pat / PEM / ghs /
    [string] $TokenType

    # The default value for the Enterprise parameter.
    [string] $Enterprise

    # The default value for the Owner parameter.
    [string] $Owner

    # The default value for the Repository parameter.
    [string] $Repository

    # The default value for the HTTP protocol version.
    [string] $HttpVersion

    # The default value for the 'per_page' API parameter used in 'GET' functions that support paging.
    [int] $PerPage

    GitHubContext() {}

    GitHubContext([pscustomobject]$Object) {
        $this.ID = $Object.ID
        $this.Name = $Object.Name
        $this.DisplayName = $Object.DisplayName
        $this.Type = $Object.Type
        $this.HostName = $Object.HostName
        $this.ApiBaseUri = $Object.ApiBaseUri
        $this.ApiVersion = $Object.ApiVersion
        $this.AuthType = $Object.AuthType
        $this.NodeID = $Object.NodeID
        $this.DatabaseID = $Object.DatabaseID
        $this.UserName = $Object.UserName
        $this.Token = $Object.Token
        $this.TokenType = $Object.TokenType
        $this.Enterprise = $Object.Enterprise
        $this.Owner = $Object.Owner
        $this.Repository = $Object.Repository
        $this.HttpVersion = $Object.HttpVersion
        $this.PerPage = $Object.PerPage
    }

    [string] ToString() {
        return $this.Name
    }
}
