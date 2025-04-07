class GitHubUser : GitHubOwner {
    # The user's biography.
    # Example: There once was...
    [string] $Bio

    # The type of user view.
    [string] $UserViewType

    # The notification email address of the user.
    # Example: octocat@github.com
    [string] $NotificationEmail

    # Whether the user is hireable.
    [System.Nullable[bool]] $Hireable

    # Number of public repositories.
    # Example: 2
    [System.Nullable[uint]] $PublicRepos

    # Number of public gists.
    # Example: 1
    [System.Nullable[uint]] $PublicGists

    # Number of followers.
    # Example: 20
    [System.Nullable[uint]] $Followers

    # Number of users this user is following.
    # Example: 0
    [System.Nullable[uint]] $Following

    # Number of private gists.
    # Example: 81
    [System.Nullable[uint]] $PrivateGists

    # Total number of private repositories.
    # Example: 100
    [System.Nullable[uint]] $TotalPrivateRepos

    # Number of owned private repositories.
    # Example: 100
    [System.Nullable[uint]] $OwnedPrivateRepos

    # Disk usage in kilobytes.
    # Example: 10000
    [System.Nullable[uint]] $DiskUsage

    # Number of collaborators.
    # Example: 8
    [System.Nullable[uint]] $Collaborators

    # Whether two-factor authentication is enabled.
    # Example: true
    [System.Nullable[bool]]  $TwoFactorAuthentication

    # Simple parameterless constructor
    GitHubUser() {}

    # Creates an object from a hashtable of key-value pairs.
    GitHubUser([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates an object from a PSCustomObject.
    GitHubUser([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }

    [string] ToString() {
        return $this.Login
    }
}
