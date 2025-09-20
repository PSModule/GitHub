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
    [GitHubPermission[]] $Permissions

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

    # The status indicating if the installation permissions and events match the app's configuration.
    [string] $Status

    GitHubAppInstallation() {}

    GitHubAppInstallation([PSCustomObject] $Object) {
        $this.ID = $Object.id
        $this.App = [GitHubApp]::new()
        $this.App.ClientID = $Object.client_id
        $this.App.Slug = $Object.app_slug
        $this.Target = [GitHubOwner]::new($Object.account)
        $this.Type = $Object.target_type
        $this.RepositorySelection = $Object.repository_selection
        $this.Permissions = [GitHubPermission]::NewPermissionList($Object.permissions, $this.Type)
        $this.Events = , ($Object.events)
        $this.FilePaths = , ($Object.single_file_paths)
        $this.CreatedAt = $Object.created_at
        $this.UpdatedAt = $Object.updated_at
        $this.SuspendedAt = $Object.suspended_at
        $this.SuspendedBy = [GitHubUser]::new($Object.suspended_by)
        $this.Url = $Object.html_url
        $this.Status = 'Unknown'
    }

    GitHubAppInstallation([PSCustomObject] $Object, [GitHubAppContext] $AppContext) {
        $this.ID = $Object.id
        $this.App = [GitHubApp]::new()
        $this.App.ID = $AppContext.ID
        $this.App.ClientID = $AppContext.ClientID
        $this.App.Slug = $AppContext.Slug
        $this.App.NodeID = $AppContext.NodeID
        $this.App.DatabaseID = $AppContext.DatabaseID
        $this.App.Owner = $AppContext.Owner
        $this.App.Name = $AppContext.Name
        $this.App.Description = $AppContext.Description
        $this.App.ExternalUrl = $AppContext.ExternalUrl
        $this.App.Url = $AppContext.Url
        $this.App.CreatedAt = $AppContext.CreatedAt
        $this.App.UpdatedAt = $AppContext.UpdatedAt
        $this.App.Permissions = $AppContext.Permissions
        $this.App.Events = $AppContext.Events
        $this.App.Installations = $AppContext.Installations
        $this.Target = [GitHubOwner]::new($Object.account)
        $this.Type = $Object.target_type
        $this.RepositorySelection = $Object.repository_selection
        $this.Permissions = [GitHubPermission]::NewPermissionList($Object.permissions, $this.Type)
        $this.Events = , ($Object.events)
        $this.FilePaths = , ($Object.single_file_paths)
        $this.CreatedAt = $Object.created_at
        $this.UpdatedAt = $Object.updated_at
        $this.SuspendedAt = $Object.suspended_at
        $this.SuspendedBy = [GitHubUser]::new($Object.suspended_by)
        $this.Url = $Object.html_url
        $this.SetStatus()
    }

    GitHubAppInstallation([PSCustomObject] $Object, [string] $Target, [string] $Type, [string] $HostName) {
        $this.ID = $Object.id
        $this.App = [GitHubApp]::new()
        $this.App.ClientID = $Object.client_id
        $this.App.Slug = $Object.app_slug
        $this.Target = [GitHubOwner]@{
            Name = $Target
            Type = $Type
            Url  = "https://$HostName/$Target"
        }
        $this.Type = $Type
        $this.RepositorySelection = $Object.repository_selection
        $this.Permissions = [GitHubPermission]::NewPermissionList($Object.permissions, $this.Type)
        $this.Events = , ($Object.events)
        $this.FilePaths = $Object.single_file_paths
        $this.CreatedAt = $Object.created_at
        $this.UpdatedAt = $Object.updated_at
        $this.SuspendedAt = $Object.suspended_at
        $this.SuspendedBy = [GitHubUser]::new($Object.suspended_by)
        $this.Url = "https://$HostName/$($Type.ToLower())s/$Target/settings/installations/$($Object.id)"
        $this.Status = 'Unknown'
    }

    # Sets the Status property by comparing installation permissions with app permissions
    # filtered by the appropriate scope based on installation type
    [void] SetStatus() {
        if (-not $this.App -or -not $this.App.Permissions) {
            $this.Status = 'Unknown'
            return
        }
        if (-not $this.Permissions) {
            $this.Status = 'Unknown'
            return
        }

        # Get app permissions filtered by installation type scope
        $appPermissionsFiltered = switch ($this.Type) {
            'Enterprise' {
                $this.App.Permissions | Where-Object { $_.Scope -eq 'Enterprise' }
            }
            'Organization' {
                $this.App.Permissions | Where-Object { $_.Scope -in @('Organization', 'Repository') }
            }
            'User' {
                $this.App.Permissions | Where-Object { $_.Scope -in @('Repository') }
            }
            default {
                $this.App.Permissions
            }
        }

        $permissionsMatch = [GitHubPermission]::ComparePermissionLists($this.Permissions, $appPermissionsFiltered)

        $this.Status = $permissionsMatch ? 'Ok' : 'Outdated'
    }
}
