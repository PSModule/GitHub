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

    # The blog URL of the account.
    # Example: https://github.com/blog
    [string] $Blog

    # The location of the account.
    # Example: San Francisco
    [string] $Location

    # The email of the account.
    # Example: octocat@github.com
    [string] $Email

    # The Twitter username.
    # Example: monalisa
    [string] $TwitterUsername

    # The number of public repositories.
    # Example: 2
    [System.Nullable[uint]] $PublicRepos

    # The number of public gists.
    # Example: 1
    [System.Nullable[uint]] $PublicGists

    # The number of followers.
    # Example: 20
    [System.Nullable[uint]] $Followers

    # The number of accounts this account is following.
    # Example: 0
    [System.Nullable[uint]] $Following

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
        # From GitHubNode
        $this.ID = $Object.id
        $this.NodeID = $Object.node_id

        # From GitHubOwner
        $this.Name = $Object.login
        $this.DisplayName = $Object.name
        $this.AvatarUrl = $Object.avatar_url
        $this.Url = $Object.html_url
        $this.Type = $Object.type
        $this.Company = $Object.company
        $this.Blog = $Object.blog
        $this.Location = $Object.location
        $this.Email = $Object.email
        $this.TwitterUsername = $Object.twitter_username
        $this.PublicRepos = $Object.public_repos
        $this.PublicGists = $Object.public_gists
        $this.Followers = $Object.followers
        $this.Following = $Object.following
        $this.CreatedAt = $Object.created_at
        $this.UpdatedAt = $Object.updated_at
        $this.Plan = [GitHubPlan]::New($Object.plan)
    }

    [string] ToString() {
        return $this.Name
    }
}
