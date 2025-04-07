class GitHubOwner {
    # The username/login of the owner.
    # Example: octocat
    [string] $Name

    # The unique identifier of the owner.
    # Example: 42
    [System.Nullable[UInt64]] $DatabaseID

    # The node ID of the owner.
    # Example: MDQ6VXNlcjE=
    [string] $NodeID

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
