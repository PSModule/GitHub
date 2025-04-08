class GitHubUser : GitHubOwner {
    # Whether the user is hireable.
    [System.Nullable[bool]] $Hireable

    # The user's biography.
    # Example: There once was...
    [string] $Bio

    # The notification email address of the user.
    # Example: octocat@github.com
    [string] $NotificationEmail

    GitHubUser() {}

    GitHubUser([PSCustomObject]$Object) {
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

        # From GitHubUser
        $this.Hireable = $Object.hireable
        $this.Bio = $Object.bio
        $this.NotificationEmail = $Object.notification_email
    }

    [string] ToString() {
        return $this.Name
    }
}
