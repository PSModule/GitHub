class GitHubReleaseAsset : GitHubNode {
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
