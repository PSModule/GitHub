﻿class GitHubReleaseAsset : GitHubNode {
    # Description: URL for downloading the asset
    # Example: "https://github.com/PSModule/GitHub/releases/download/v0.22.1/asset.zip"
    [string] $Url

    # Description: The file name of the asset
    # Example: "Team Environment"
    [string] $Name

    # Description: Label for the asset, can be null
    # Example: null
    [string] $Label

    # Description: State of the release asset (e.g., uploaded, open)
    # Example: "uploaded"
    [string] $State

    # Description: MIME type of the asset
    # Example: "application/zip"
    [string] $ContentType

    # Description: Size of the asset in bytes
    # Example: 1024
    [int] $Size

    # Description: Number of times the asset was downloaded
    # Example: 100
    [int] $Downloads

    # Description: Timestamp when the asset was created
    # Example: "2025-04-11T09:03:38Z"
    [datetime] $CreatedAt

    # Description: Timestamp when the asset was last updated
    # Example: "2025-04-11T09:03:38Z"
    [datetime] $UpdatedAt

    # Description: User who uploaded the asset, can be null
    # Example: GitHubUser object or null
    [GitHubUser] $Uploader

    GitHubReleaseAsset() {}

    GitHubReleaseAsset([PSCustomObject]$Object) {
        $this.Url = $Object.url
        $this.Name = $Object.name
        $this.Label = $Object.label
        $this.State = $Object.state
        $this.ContentType = $Object.content_type
        $this.Size = $Object.size
        $this.Downloads = $Object.downloads
        $this.CreatedAt = [datetime]::Parse($Object.created_at)
        $this.UpdatedAt = [datetime]::Parse($Object.updated_at)
        $this.Uploader = [GitHubUser]::new($Object.uploader)
    }
}

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
    [bool] $Latest

    # True to create a draft (unpublished) release, false to create a published one
    # Example: false
    [bool] $Draft

    # Whether to identify the release as a prerelease or a full release
    # Example: false
    [bool] $Prerelease

    # GitHub URL for the release
    # Example: "https://github.com/PSModule/GitHub/releases/tag/v0.22.1"
    [string] $Url

    # User who authored the release
    [GitHubUser] $Author

    # Timestamp when the release was created
    # Example: "2025-04-11T09:03:38Z"
    [System.Nullable[datetime]] $CreatedAt

    # Timestamp when the release was published, can be null
    # Example: "2025-04-11T13:41:34Z"
    [System.Nullable[datetime]] $PublishedAt

    # URL for the release tarball, can be null
    # Example: "https://api.github.com/repos/PSModule/GitHub/tarball/v0.22.1"
    [string] $TarballUrl

    # URL for the release zipball, can be null
    # Example: "https://api.github.com/repos/PSModule/GitHub/zipball/v0.22.1"
    [string] $ZipballUrl

    # Assets that are uploaded to the release.
    [GitHubReleaseAsset[]] $Assets

    # Number of mentions in the release notes
    # Example: 1
    [int] $Mentions

    GitHubRelease() {}

    GitHubRelease([PSCustomObject] $Object, [string] $Owner, [string] $Repository, [bool] $Latest) {
        # From GitHubNode
        $this.ID = $Object.id
        $this.NodeID = $Object.node_id

        # From GitHubRelease
        $this.Name = $Object.name
        $this.Repository = $Repository
        $this.Owner = $Owner
        $this.Notes = $Object.body
        $this.Url = $Object.html_url
        $this.Author = [GitHubUser]::new($Object.author)
        $this.Tag = $Object.tag_name
        $this.Target = $Object.target_commitish
        $this.Latest = $Latest
        $this.Draft = $Object.draft
        $this.Prerelease = $Object.prerelease
        $this.CreatedAt = $Object.created_at
        $this.PublishedAt = $Object.published_at
        $this.Assets = $Object.assets | ForEach-Object { [GitHubReleaseAsset]::new($_) }
    }
}
