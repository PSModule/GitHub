class GitHubApp : GitHubNode {
    # The unique ID of the app
    [System.Nullable[UInt64]] $ID

    # The Client ID of the app
    [string] $ClientID

    # The App ID of the app
    [System.Nullable[UInt64]] $AppID

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
    [pscustomobject] $Permissions

    # The events that the app is subscribing to on its target.
    [string[]] $Events

    # The number of installations
    [System.Nullable[int]] $Installations

    GitHubApp() {}

    GitHubApp([object]$Object) {
        $this.ID = $Object.id
        $this.ClientID = $Object.client_id
        $this.AppID = $Object.app_id
        $this.Slug = $Object.app_slug ?? $Object.slug
        $this.NodeID = $Object.node_id
        $this.Owner = [GitHubOwner]::new($Object.owner)
        $this.Name = $Object.name
        $this.Description = $Object.description
        $this.ExternalUrl = $Object.external_url
        $this.Url = $Object.html_url
        $this.CreatedAt = $Object.created_at
        $this.UpdatedAt = $Object.updated_at
        $this.Permissions = $Object.permissions
        $this.Events = $Object.events
        $this.Installations = $Object.installations_count
    }
}
