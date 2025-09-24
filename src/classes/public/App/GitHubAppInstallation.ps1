class GitHubAppInstallation {
    # The installation ID on the target.
    [System.Nullable[UInt64]] $ID

    # The app that is installed.
    [GitHubApp] $App

    # The full installation object (if available).
    [GitHubAppInstallation] $Installation

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
        $this.App = [GitHubApp]@{
            ClientID = $Object.client_id
            Slug     = $Object.app_slug
        }
        $this.Target = if ($null -ne $Object.Target) {
            [GitHubOwner]::new($Object.Target)
        } elseif ($null -ne $Object.Account) {
            [GitHubOwner]::new($Object.Account)
        } else {
            $null
        }
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
        $this.App = $AppContext.App
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
        $this.App = [GitHubApp]@{
            ClientID = $Object.client_id
            Slug     = $Object.app_slug
        }
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

        $permissionsMatch = Compare-Object -ReferenceObject $appPermissionsFiltered -DifferenceObject $this.Permissions | Measure-Object

        $this.Status = $permissionsMatch ? 'Ok' : 'Outdated'
    }
}
