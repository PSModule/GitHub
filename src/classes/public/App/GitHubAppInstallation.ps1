class GitHubAppInstallation {
    # The installation ID on the target.
    [System.Nullable[UInt64]] $ID

    # The app that is installed.
    [GitHubApp] $App

    # The target of the installation.
    [GitHubOwner] $Target

    # The type of target.
    [string] $Type

    # The type of repository selection.
    [string] $RepositorySelection

    # The permissions that the app has on the target.
    [pscustomobject] $Permissions

    # The events that the app is subscribing to.
    [string[]] $Events

    # The file paths that the app has access to.
    [string[]] $FilePaths

    # The creation date of the installation.
    # Example: 2008-01-14T04:33:35Z
    [System.Nullable[datetime]] $CreatedAt

    # The last update date of the installation.
    # Example: 2008-01-14T04:33:35Z
    [System.Nullable[datetime]] $UpdatedAt

    # The date the installation was suspended.
    # Example: 2008-01-14T04:33:35Z
    [System.Nullable[datetime]] $SuspendedAt

    # The account that suspended the installation.
    [GitHubUser] $SuspendedBy

    # The URL to the target's profile based on the target type.
    [string] $Url

    GitHubAppInstallation() {}

    GitHubAppInstallation([PSCustomObject] $Object) {
        $this.ID = $Object.id
        $this.App = [GitHubApp]::new(
            [PSCustomObject]@{
                client_id = $Object.client_id
                app_id    = $Object.app_id
                app_slug  = $Object.app_slug
            }
        )
        $this.Target = [GitHubOwner]::new($Object.account)
        $this.Type = $Object.target_type
        $this.RepositorySelection = $Object.repository_selection
        $this.Permissions = $Object.permissions
        $this.Events = , ($Object.events)
        $this.FilePaths = $Object.single_file_paths
        $this.CreatedAt = $Object.created_at
        $this.UpdatedAt = $Object.updated_at
        $this.SuspendedAt = $Object.suspended_at
        $this.SuspendedBy = [GitHubUser]::new($Object.suspended_by)
        $this.Url = $Object.html_url
    }

    GitHubAppInstallation([PSCustomObject] $Object, [string] $Target, [string] $Type, [string] $HostName) {
        $this.ID = $Object.id
        $this.App = [GitHubApp]::new(
            [PSCustomObject]@{
                client_id = $Object.client_id
                app_id    = $Object.app_id
                app_slug  = $Object.app_slug
            }
        )
        $this.Target = [GitHubOwner]@{
            Name = $Target
            Type = $Type
            Url  = "https://$HostName/$Target"
        }
        $this.Type = $Type
        $this.RepositorySelection = $Object.repository_selection
        $this.Permissions = $Object.permissions
        $this.Events = , ($Object.events)
        $this.FilePaths = $Object.single_file_paths
        $this.CreatedAt = $Object.created_at
        $this.UpdatedAt = $Object.updated_at
        $this.SuspendedAt = $Object.suspended_at
        $this.SuspendedBy = [GitHubUser]::new($Object.suspended_by)
        $this.Url = "https://$HostName/$($Type.ToLower())s/$Target/settings/installations/$($Object.id)"
    }
}
