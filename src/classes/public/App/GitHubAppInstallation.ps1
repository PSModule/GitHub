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
    [object] $Permissions

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
        $this.Permissions = $this.GetPermissions($Object.permissions, $this.Type)
        $this.Events = , ($Object.events)
        $this.FilePaths = $Object.single_file_paths
        $this.CreatedAt = $Object.created_at
        $this.UpdatedAt = $Object.updated_at
        $this.SuspendedAt = $Object.suspended_at
        $this.SuspendedBy = [GitHubUser]::new($Object.suspended_by)
        $this.Url = $Object.html_url
        $this.Status = 'Unknown'
    }

    GitHubAppInstallation([PSCustomObject] $Object, [GitHubApp] $App) {
        $this.ID = $Object.id
        $this.App = $App
        $this.Target = [GitHubOwner]::new($Object.account)
        $this.Type = $Object.target_type
        $this.RepositorySelection = $Object.repository_selection
        $this.Permissions = $this.GetPermissions($Object.permissions, $this.Type)
        $this.Events = , ($Object.events)
        $this.FilePaths = $Object.single_file_paths
        $this.CreatedAt = $Object.created_at
        $this.UpdatedAt = $Object.updated_at
        $this.SuspendedAt = $Object.suspended_at
        $this.SuspendedBy = [GitHubUser]::new($Object.suspended_by)
        $this.Url = $Object.html_url
        $this.UpdateStatus()
    }

    GitHubAppInstallation([PSCustomObject] $Object, [string] $Target, [string] $Type, [GitHubContext] $Context) {
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
            Url  = "https://$($Context.HostName)/$Target"
        }
        $this.Type = $Type
        $this.RepositorySelection = $Object.repository_selection
        $this.Permissions = [GitHubPermission]::NewPermissionList($Object.permissions, $Type)
        $this.Events = , ($Object.events)
        $this.FilePaths = $Object.single_file_paths
        $this.CreatedAt = $Object.created_at
        $this.UpdatedAt = $Object.updated_at
        $this.SuspendedAt = $Object.suspended_at
        $this.SuspendedBy = [GitHubUser]::new($Object.suspended_by)
        $this.Url = "https://$($Context.HostName)/$($Type.ToLower())s/$Target/settings/installations/$($Object.id)"
        $this.Status = 'Unknown'
    }

    GitHubAppInstallation([PSCustomObject] $Object, [string] $Target, [string] $Type, [GitHubContext] $Context, [GitHubApp] $App) {
        $this.ID = $Object.id
        $this.App = $App
        $this.Target = [GitHubOwner]@{
            Name = $Target
            Type = $Type
            Url  = "https://$($Context.HostName)/$Target"
        }
        $this.Type = $Type
        $this.RepositorySelection = $Object.repository_selection
        $this.Permissions = [GitHubPermission]::NewPermissionList($Object.permissions, $Type)
        $this.Events = , ($Object.events)
        $this.FilePaths = $Object.single_file_paths
        $this.CreatedAt = $Object.created_at
        $this.UpdatedAt = $Object.updated_at
        $this.SuspendedAt = $Object.suspended_at
        $this.SuspendedBy = [GitHubUser]::new($Object.suspended_by)
        $this.Url = "https://$($Context.HostName)/$($Type.ToLower())s/$Target/settings/installations/$($Object.id)"
        $this.UpdateStatus()
    }

    # Updates the Status property by comparing installation permissions with app permissions
    # filtered by the appropriate scope based on installation type
    [void] UpdateStatus() {
        if (-not $this.App -or -not $this.App.Permissions) {
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

        # Compare permissions by creating lookup dictionaries
        $appPermissionLookup = @{}
        foreach ($perm in $appPermissionsFiltered) {
            $appPermissionLookup[$perm.Name] = $perm.Value
        }

        $installationPermissionLookup = @{}
        foreach ($perm in $this.Permissions) {
            $installationPermissionLookup[$perm.Name] = $perm.Value
        }

        # Check if permissions match
        $permissionsMatch = $true

        # Check if all app permissions exist in installation with same values
        foreach ($name in $appPermissionLookup.Keys) {
            if (-not $installationPermissionLookup.ContainsKey($name) -or
                $installationPermissionLookup[$name] -ne $appPermissionLookup[$name]) {
                $permissionsMatch = $false
                break
            }
        }

        # Check if installation has any extra permissions not in the app
        if ($permissionsMatch) {
            foreach ($name in $installationPermissionLookup.Keys) {
                if (-not $appPermissionLookup.ContainsKey($name)) {
                    $permissionsMatch = $false
                    break
                }
            }
        }

        $this.Status = $permissionsMatch ? 'Ok' : 'Outdated'
    }
}
