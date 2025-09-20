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

    # The type of the owner: 'User', 'Organization' or 'Enterprise'.
    # Example: User
    [string] $Type

    # The location of the account.
    # Example: San Francisco
    [string] $Location

    # The description of the organization.
    # Example: A great organization
    [string] $Description

    # The website URL of the account.
    # Example: https://github.com/blog
    [string] $Website

    # The creation date of the account.
    # Example: 2008-01-14T04:33:35Z
    [System.Nullable[datetime]] $CreatedAt

    # The last update date of the account.
    # Example: 2008-01-14T04:33:35Z
    [System.Nullable[datetime]] $UpdatedAt

    GitHubOwner() {}

    GitHubOwner([PSCustomObject]$Object) {
        # From GitHubNode
        $this.ID = $Object.id
        $this.NodeID = $Object.node_id ?? $Object.NodeID

        # From GitHubOwner
        $this.Name = $Object.slug ?? $Object.login ?? $Object.name
        $this.DisplayName = $Object.DisplayName ?? $Object.name
        $this.AvatarUrl = $Object.avatar_url ?? $Object.AvatarUrl
        $this.Url = $Object.html_url ?? $Object.url
        $this.Type = $Object.type
        $this.Location = $Object.location
        $this.Description = $Object.description ?? $Object.bio
        $this.Website = $Object.websiteUrl ?? $Object.blog ?? $Object.Website
        $this.CreatedAt = $Object.created_at ?? $Object.createdAt
        $this.UpdatedAt = $Object.updated_at ?? $Object.updatedAt
    }

    [string] ToString() {
        return $this.Name
    }
}
