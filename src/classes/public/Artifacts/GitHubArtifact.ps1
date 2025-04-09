class GitHubArtifact : GitHubNode {
    # The name of the artifact.
    [string] $Name

    # The name of the organization or user the variable is associated with.
    [string] $Owner

    # The name of the repository the variable is associated with.
    [string] $Repository

    # The size of the artifact in bytes.
    [int64] $Size

    # The API URL for accessing the artifact.
    [string] $Url

    # The URL for downloading the artifact archive.
    [string] $ArchiveDownloadUrl

    # Indicates if the artifact has expired.
    [bool] $Expired

    # The SHA256 digest of the artifact.
    [string] $Digest

    # The timestamp when the artifact was created.
    [datetime] $CreatedAt

    # The timestamp when the artifact was last updated.
    [datetime] $UpdatedAt

    # The timestamp when the artifact will expire.
    [datetime] $ExpiresAt

    # Information about the associated workflow run.
    [PSCustomObject] $WorkflowRun

    GitHubArtifact() {}

    GitHubArtifact([PSCustomObject]$Object, [string]$Owner, [string]$Repository) {
        $this.ID = $_.Response.id
        $this.NodeID = $_.Response.node_id
        $this.Name = $_.Response.name
        $this.Owner = $Owner
        $this.Repository = $Repository
        $this.Size = $_.Response.size_in_bytes
        $this.Url = $_.Response.url
        $this.ArchiveDownloadUrl = $_.Response.archive_download_url
        $this.Expired = $_.Response.expired
        $this.Digest = $_.Response.digest
        $this.CreatedAt = $_.Response.created_at
        $this.UpdatedAt = $_.Response.updated_at
        $this.ExpiresAt = $_.Response.expires_at
        $this.WorkflowRun = $_.Response.workflow_run
    }
}
