class UserGitHubContext : GitHubContext {
    # The authentication client ID.
    # Client ID for UAT
    [string] $AuthClientID

    # The device flow type.
    # GitHubApp / OAuthApp
    [string] $DeviceFlowType

    # The scope when authenticating with OAuth.
    # 'gist read:org repo workflow'
    [string] $Scope

    # The token expiration date.
    # 2024-01-01-00:00:00
    [System.Nullable[datetime]] $TokenExpiresAt

    # The refresh token.
    [securestring] $RefreshToken

    # The refresh token expiration date.
    # 2024-01-01-00:00:00
    [System.Nullable[datetime]] $RefreshTokenExpiresAt

    UserGitHubContext() {}

    UserGitHubContext([PSCustomObject]$Object) {
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
        $this.AuthClientID = $Object.AuthClientID
        $this.DeviceFlowType = $Object.DeviceFlowType
        $this.Scope = $Object.Scope
        $this.TokenExpiresAt = $Object.TokenExpiresAt
        $this.RefreshToken = $Object.RefreshToken
        $this.RefreshTokenExpiresAt = $Object.RefreshTokenExpiresAt
    }
}
