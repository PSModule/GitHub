class GitHubApp {
    # The Client ID of the app
    [string] $ClientID

    # The App ID of the app
    [System.Nullable[UInt64]] $AppID

    # The Slug of the app
    [string] $Slug

    GitHubApp() {}

    GitHubApp([object]$Object) {
        $this.ClientID = $Object.client_id
        $this.AppID = $Object.app_id
        $this.Slug = $Object.app_slug ?? $Object.slug
    }
}
