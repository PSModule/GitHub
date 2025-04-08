class GitHubUser : GitHubOwner {
    # The user's biography.
    # Example: There once was...
    [string] $Bio

    # The notification email address of the user.
    # Example: octocat@github.com
    [string] $NotificationEmail

    # Whether the user is hireable.
    [System.Nullable[bool]] $Hireable

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
