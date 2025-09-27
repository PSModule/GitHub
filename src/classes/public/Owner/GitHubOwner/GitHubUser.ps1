class GitHubUser : GitHubOwner {
    # The email of the account.
    # Example: octocat@github.com
    [string] $Email

    # Whether the user is hireable.
    [System.Nullable[bool]] $Hireable

    # The company the account is affiliated with.
    # Example: GitHub
    [string] $Company

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

    # The notification email address of the user.
    # Example: octocat@github.com
    [string] $NotificationEmail

    # The user's plan.
    # Includes: Name, Collaborators, PrivateRepos, Space
    [GitHubPlan] $Plan

    GitHubUser() {}

    GitHubUser([PSCustomObject]$Object) {
        # From GitHubNode
        $this.ID = $Object.databaseId ?? $Object.id
        $this.NodeID = $Object.node_id ?? $Object.NodeID ?? $Object.id

        # From GitHubOwner
        $this.Name = $Object.login ?? $Object.Name
        $this.DisplayName = $Object.name ?? $Object.DisplayName
        $this.AvatarUrl = $Object.avatar_url ?? $Object.AvatarUrl
        $this.Url = $Object.html_url ?? $Object.Url
        $this.Type = $Object.type
        $this.Location = $Object.location
        $this.Description = $Object.bio ?? $Object.Description
        $this.Website = $Object.blog ?? $Object.Website
        $this.CreatedAt = $Object.created_at ?? $Object.CreatedAt
        $this.UpdatedAt = $Object.updated_at ?? $Object.UpdatedAt

        # From GitHubUser
        $this.Email = $Object.email
        $this.Hireable = $Object.hireable
        $this.Company = $Object.company
        $this.TwitterUsername = $Object.twitter_username ?? $Object.TwitterUsername
        $this.PublicRepos = $Object.public_repos ?? $Object.PublicRepos
        $this.PublicGists = $Object.public_gists ?? $Object.PublicGists
        $this.Followers = $Object.followers
        $this.Following = $Object.following
        $this.NotificationEmail = $Object.notification_email ?? $Object.NotificationEmail
        $this.Plan = [GitHubPlan]::New($Object.plan)
    }

    [string] ToString() {
        return $this.Name
    }
}
