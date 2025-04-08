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

    GitHubOwner() {}

    GitHubOwner([PSCustomObject]$Object) {
        $this.ID = $Object.id
        $this.NodeID = $Object.node_id
        $this.Name = $Object.login
        $this.DisplayName = $Object.name
        $this.AvatarUrl = $Object.avatar_url
        $this.Url = $Object.html_url
        $this.Type = $Object.type
        $this.Company = $Object.company
        $this.Location = $Object.location
        $this.Email = $Object.email
        $this.TwitterUsername = $Object.twitter_username
        $this.Blog = $Object.blog
        $this.Followers = $Object.followers
        $this.Following = $Object.following
        $this.PublicRepos = $Object.public_repos
        $this.PublicGists = $Object.public_gists
        $this.PrivateGists = $Object.total_private_gists
        $this.TotalPrivateRepos = $Object.total_private_repos
        $this.OwnedPrivateRepos = $Object.owned_private_repos
        $this.DiskUsage = $Object.disk_usage
        $this.Collaborators = $Object.collaborators
        $this.CreatedAt = $Object.created_at
        $this.UpdatedAt = $Object.updated_at
        $this.Plan = [GitHubPlan]::New($Object.plan)
    }

    [string] ToString() {
        return $this.Name
    }
}
