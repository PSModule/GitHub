class GitHubAppContext : GitHubContext {
    # Client ID for GitHub Apps
    [string] $ClientID

    # The private key for the app.
    [securestring] $PrivateKey

    # Azure Key Vault key reference for JWT signing (alternative to PrivateKey).
    [string] $KeyVaultKeyReference

    # Owner of the GitHub App
    [string] $OwnerName

    # Type of the owner of the GitHub App
    [string] $OwnerType

    # The permissions that the app is requesting on the target
    [GitHubPermission[]] $Permissions

    # The events that the app is subscribing to once installed
    [string[]] $Events

    GitHubAppContext() {}

    GitHubAppContext([pscustomobject]$Object) {
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
        $this.PrivateKey = $Object.PrivateKey
        $this.KeyVaultKeyReference = $Object.KeyVaultKeyReference
        $this.OwnerName = $Object.OwnerName
        $this.OwnerType = $Object.OwnerType
        if ($Object.Permissions) {
            $this.Permissions = [GitHubPermission]::NewPermissionList($Object.Permissions)
        }
        $this.Events = , ($Object.Events)
    }
}
