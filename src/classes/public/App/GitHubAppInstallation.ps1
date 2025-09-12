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

    # The status indicating if the installation permissions and events match the app's configuration.
    [string] $Status

    GitHubAppInstallation() {}

    # Helper method to compare installation permissions and events with app configuration
    hidden [string] CompareWithAppConfiguration([pscustomobject] $AppPermissions, [string[]] $AppEvents) {
        if ($null -eq $AppPermissions -or $null -eq $AppEvents) {
            return 'Unknown'
        }

        # Compare permissions - check if installation has all the permissions that the app requires
        $permissionsMatch = $true
        if ($AppPermissions.PSObject.Properties) {
            foreach ($permission in $AppPermissions.PSObject.Properties) {
                $appPermissionLevel = $permission.Value
                $installationPermissionLevel = $this.Permissions.PSObject.Properties[$permission.Name]?.Value

                # If app requires a permission but installation doesn't have it, or has lower level
                if ($appPermissionLevel -ne 'none' -and $installationPermissionLevel -ne $appPermissionLevel) {
                    $permissionsMatch = $false
                    break
                }
            }
        }

        # Compare events - check if installation subscribes to all events that the app wants
        $eventsMatch = $true
        if ($AppEvents -and $AppEvents.Count -gt 0) {
            foreach ($appEvent in $AppEvents) {
                if ($appEvent -notin $this.Events) {
                    $eventsMatch = $false
                    break
                }
            }
        }

        if ($permissionsMatch -and $eventsMatch) {
            return 'UpToDate'
        } elseif (-not $permissionsMatch -and -not $eventsMatch) {
            return 'PermissionsAndEventsOutdated'
        } elseif (-not $permissionsMatch) {
            return 'PermissionsOutdated'
        } else {
            return 'EventsOutdated'
        }
    }

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
        $this.Status = 'Unknown'
    }

    GitHubAppInstallation([PSCustomObject] $Object, [GitHubApp] $App) {
        $this.ID = $Object.id
        $this.App = $App
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
        $this.Status = $this.CompareWithAppConfiguration($App.Permissions, $App.Events)
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
        $this.Permissions = $Object.permissions
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
        $this.Permissions = $Object.permissions
        $this.Events = , ($Object.events)
        $this.FilePaths = $Object.single_file_paths
        $this.CreatedAt = $Object.created_at
        $this.UpdatedAt = $Object.updated_at
        $this.SuspendedAt = $Object.suspended_at
        $this.SuspendedBy = [GitHubUser]::new($Object.suspended_by)
        $this.Url = "https://$($Context.HostName)/$($Type.ToLower())s/$Target/settings/installations/$($Object.id)"
        $this.Status = $this.CompareWithAppConfiguration($App.Permissions, $App.Events)
    }
}
