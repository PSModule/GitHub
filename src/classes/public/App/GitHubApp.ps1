class GitHubApp : GitHubNode {
    # The unique ID of the app
    [System.Nullable[UInt64]] $ID

    # The Client ID of the app
    [string] $ClientID

    # The Slug of the app
    [string] $Slug

    # The node_id of the app
    [string] $NodeID

    # The owner of the app.
    [GitHubOwner] $Owner

    # The name of the app
    [string] $Name

    # The description of the app
    [string] $Description

    # The external URL of the app
    [string] $ExternalUrl

    # The HTML URL of the app
    [string] $Url

    # The creation date of the app
    [System.Nullable[datetime]] $CreatedAt

    # The last update date of the app
    [System.Nullable[datetime]] $UpdatedAt

    # The permissions that the app is requesting.
    [GitHubPermission[]] $Permissions

    # The events that the app is subscribing to on its target.
    [string[]] $Events

    # The number of installations
    [System.Nullable[int]] $Installations

    GitHubApp() {}

    GitHubApp([object]$Object) {
        $this.ID = $Object.id
        $this.ClientID = $Object.client_id ?? $Object.ClientID
        $this.Slug = $Object.app_slug ?? $Object.slug
        $this.NodeID = $Object.node_id ?? $Object.NodeID
        $this.Owner = [GitHubOwner]::new($Object.owner)
        $this.Name = $Object.name
        $this.Description = $Object.description
        $this.ExternalUrl = $Object.external_url ?? $Object.ExternalUrl
        $this.Url = $Object.html_url ?? $Object.Url
        $this.CreatedAt = $Object.created_at ?? $Object.createdAt
        $this.UpdatedAt = $Object.updated_at ?? $Object.updatedAt
        $this.Permissions = [GitHubPermission]::NewPermissionList($Object.permissions)
        $this.Events = , ($Object.events)
        $this.Installations = $Object.installations_count ?? $Object.Installations
    }

    [string] ToString() {
        return $this.Slug
    }
}
