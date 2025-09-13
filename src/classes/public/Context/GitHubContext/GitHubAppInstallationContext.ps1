class GitHubAppInstallationContext : GitHubContext {
    # Client ID for GitHub Apps
    [string] $ClientID

    # The installation ID.
    [System.Nullable[uint64]] $InstallationID

    # The permissions that the app is requesting on the target
    [GitHubPermission[]] $Permissions

    # The events that the app is subscribing to once installed
    [string[]] $Events

    # The target type of the installation.
    [string] $InstallationType

    # The target login or slug of the installation.
    [string] $InstallationName

    GitHubAppInstallationContext() {}

    GitHubAppInstallationContext([pscustomobject]$Object) {
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
        $this.TokenExpiresAt = $Object.TokenExpiresAt
        $this.Enterprise = $Object.Enterprise
        $this.Owner = $Object.Owner
        $this.Repository = $Object.Repository
        $this.HttpVersion = $Object.HttpVersion
        $this.PerPage = $Object.PerPage
        $this.ClientID = $Object.ClientID
        $this.InstallationID = $Object.InstallationID
        $this.Permissions = [GitHubPermission]::newPermissionList($Object.Permissions, $Object.InstallationType)
        $this.Events = $Object.Events
        $this.InstallationType = $Object.InstallationType
        $this.InstallationName = $Object.InstallationName
    }
}
