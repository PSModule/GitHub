class GitHubRelease : GitHubNode {
    # Name of the release, can be null
    # Example: "v0.22.1"
    [string] $Name

    # The repository where the environment is.
    [string] $Repository

    # The owner of the environment.
    [string] $Owner

    # The name of the tag
    # Example: "v0.22.1"
    [string] $Tag

    # Release notes or changelog, can be null
    # Example: "## What's Changed\n### Other Changes\n* Fix: Enhance repository deletion feedback and fix typo..."
    [string] $Notes

    # Specifies the commitish value that determines where the Git tag is created from
    # Example: "main"
    [string] $Target

    # True if the release is the latest release on the repo.
    # Example: true
    [bool] $IsLatest

    # True to create a draft (unpublished) release, false to create a published one
    # Example: false
    [bool] $IsDraft

    # Whether to identify the release as a prerelease or a full release
    # Example: false
    [bool] $IsPrerelease

    # GitHub URL for the release
    # Example: "https://github.com/PSModule/GitHub/releases/tag/v0.22.1"
    [string] $Url

    # User who authored the release
    [GitHubUser] $Author

    # Timestamp when the release was created
    # Example: "2025-04-11T09:03:38Z"
    [System.Nullable[datetime]] $CreatedAt

    # Timestamp when the release was published
    # Example: "2025-04-11T13:41:34Z"
    [System.Nullable[datetime]] $PublishedAt

    # Timestamp when the release was updated
    # Example: "2025-04-11T13:41:34Z"
    [System.Nullable[datetime]] $UpdatedAt

    GitHubRelease() {}

    GitHubRelease([PSCustomObject] $Object, [string] $Owner, [string] $Repository, [System.Nullable[bool]] $Latest) {
        if ($null -ne $Object.node_id) {
            $this.ID = $Object.id
            $this.NodeID = $Object.node_id
            $this.Tag = $Object.tag_name
            $this.Name = $Object.name
            $this.Notes = $Object.body
            $this.IsLatest = $Latest
            $this.IsDraft = $Object.draft
            $this.IsPrerelease = $Object.prerelease
            $this.Url = $Object.html_url
            $this.Owner = $Owner
            $this.Repository = $Repository
            $this.Target = $Object.target_commitish
            $this.CreatedAt = $Object.created_at
            $this.PublishedAt = $Object.published_at
            $this.Author = [GitHubUser]::new($Object.author)
        } else {
            $this.ID = $Object.databaseId
            $this.NodeID = $Object.id
            $this.Tag = $Object.tagName
            $this.Name = $Object.name
            $this.Notes = $Object.description
            $this.IsLatest = $Object.isLatest
            $this.IsDraft = $Object.isDraft
            $this.IsPrerelease = $Object.isPrerelease
            $this.Url = $Object.url
            $this.Owner = $Owner
            $this.Repository = $Repository
            # $this.Target = $Object.target_commitish
            $this.CreatedAt = $Object.createdAt
            $this.PublishedAt = $Object.publishedAt
            $this.UpdatedAt = $Object.updatedAt
            $this.Author = [GitHubUser]::new($Object.author)
        }
    }
}
