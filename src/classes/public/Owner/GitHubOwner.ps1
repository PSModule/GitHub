class GitHubOwner : GitHubNode {
    # The username/login of the owner.
    # Example: octocat
    [string] $Name

    # The name of the organization.
    # Example: github
    [string] $DisplayName

    # The avatar URL of the owner.
    # Example: https://github.com/images/error/octocat_happy.gif
    [string] $AvatarUrl

    # The URL to the owner's profile.
    # Example: https://github.com/octocat
    [string] $Url

    # The type of the owner: "User" or "Organization".
    # Example: User
    [string] $Type

    # The company the account is affiliated with.
    # Example: GitHub
    [string] $Company

    # The location of the account.
    # Example: San Francisco
    [string] $Location

    # The email of the account.
    # Example: octocat@github.com
    [string] $Email

    # The Twitter username.
    # Example: monalisa
    [string] $TwitterUsername

    # The blog URL of the account.
    # Example: https://github.com/blog
    [string] $Blog

    # The number of followers.
    # Example: 20
    [System.Nullable[uint]] $Followers

    # The number of accounts this account is following.
    # Example: 0
    [System.Nullable[uint]] $Following

    # The number of public repositories.
    # Example: 2
    [System.Nullable[uint]] $PublicRepos

    # The number of public gists.
    # Example: 1
    [System.Nullable[uint]] $PublicGists

    # The number of private gists.
    # Example: 81
    [System.Nullable[uint]] $PrivateGists

    # The number of total private repositories.
    # Example: 100
    [System.Nullable[uint]] $TotalPrivateRepos

    # The number of owned private repositories.
    # Example: 100
    [System.Nullable[uint]] $OwnedPrivateRepos

    # The disk usage in kilobytes.
    # Example: 10000
    [System.Nullable[uint]] $DiskUsage

    # The number of collaborators on private repositories.
    # Example: 8
    [System.Nullable[uint]] $Collaborators

    # The creation date of the account.
    # Example: 2008-01-14T04:33:35Z
    [System.Nullable[datetime]] $CreatedAt

    # The last update date of the account.
    # Example: 2008-01-14T04:33:35Z
    [System.Nullable[datetime]] $UpdatedAt

    # The user's plan.
    # Includes: Name, Collaborators, PrivateRepos, Space
    [GitHubPlan] $Plan

    # Simple parameterless constructor
    GitHubOwner() {}

    # Creates an object from a hashtable of key-value pairs.
    GitHubOwner([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates an object from a PSCustomObject.
    GitHubOwner([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }

    [string] ToString() {
        return $this.Name
    }
}
