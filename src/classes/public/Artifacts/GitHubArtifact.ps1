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

    GitHubArtifact([PSCustomObject]$Object, [string]$Owner, [string]$Repository, [string]$HostName) {
        $this.ID = $Object.id
        $this.NodeID = $Object.node_id
        $this.Name = $Object.name
        $this.Owner = $Owner
        $this.Repository = $Repository
        $this.Size = $Object.size_in_bytes
        $this.Url = "https://$($HostName)/$Owner/$Repository/actions/runs/$($Object.workflow_run.id)/artifacts/$($Object.id)"
        $this.ArchiveDownloadUrl = $Object.archive_download_url
        $this.Expired = $Object.expired
        $this.Digest = $Object.digest
        $this.CreatedAt = $Object.created_at
        $this.UpdatedAt = $Object.updated_at
        $this.ExpiresAt = $Object.expires_at
        $this.WorkflowRun = $Object.workflow_run
    }
}
