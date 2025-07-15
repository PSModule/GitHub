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
    [System.Nullable[datetime]] $CreatedAt

    # Description: Timestamp when the asset was last updated
    # Example: "2025-04-11T09:03:38Z"
    [System.Nullable[datetime]] $UpdatedAt

    # Description: User who uploaded the asset, can be null
    # Example: GitHubUser object or null
    [GitHubUser] $UploadedBy

    GitHubReleaseAsset() {}

    GitHubReleaseAsset([PSCustomObject]$Object) {
        if ($null -ne $Object.node_id) {
            $this.ID = $Object.id
            $this.NodeID = $Object.node_id
            $this.Url = $Object.browser_download_url
            $this.Name = $Object.name
            $this.Label = $Object.label
            $this.State = $Object.state
            $this.ContentType = $Object.content_type
            $this.Size = $Object.size
            $this.Downloads = $Object.download_count
            $this.CreatedAt = $Object.created_at
            $this.UpdatedAt = $Object.updated_at
            $this.UploadedBy = [GitHubUser]::new($Object.uploader)
        } else {
            $this.NodeID = $Object.id
            $this.Url = $Object.downloadUrl
            $this.Name = $Object.name
            $this.ContentType = $Object.contentType
            $this.Size = $Object.size
            $this.Downloads = $Object.downloadCount
            $this.CreatedAt = $Object.createdAt
            $this.UpdatedAt = $Object.updatedAt
            $this.UploadedBy = [GitHubUser]::new($Object.uploadedBy)
        }
    }
}
