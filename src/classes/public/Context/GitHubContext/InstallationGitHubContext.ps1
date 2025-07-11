class InstallationGitHubContext : GitHubContext {
    # Client ID for GitHub Apps
    [string] $ClientID

    # The token expiration date.
    # 2024-01-01-00:00:00
    [System.Nullable[datetime]] $TokenExpiresAt

    # The installation ID.
    [System.Nullable[uint64]] $InstallationID

    # The permissions that the app is requesting on the target
    [pscustomobject] $Permissions

    # The events that the app is subscribing to once installed
    [string[]] $Events

    # The target type of the installation.
    [string] $InstallationType

    # The target login or slug of the installation.
    [string] $InstallationName

    InstallationGitHubContext() {}

    InstallationGitHubContext([pscustomobject]$Object) {
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
        $this.ClientID = $Object.ClientID
        $this.TokenExpiresAt = $Object.TokenExpiresAt
        $this.InstallationID = $Object.InstallationID
        $this.Permissions = $Object.Permissions
        $this.Events = $Object.Events
        $this.InstallationType = $Object.InstallationType
        $this.InstallationName = $Object.InstallationName
    }
}
