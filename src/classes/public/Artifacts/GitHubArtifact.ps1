class GitHubArtifact {
    # The artifact's database identifier.
    [int64] $DatabaseID

    # The node identifier of the artifact.
    [string] $NodeID

    # The name of the artifact.
    [string] $Name

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

    # Simple parameterless constructor.
    GitHubArtifact() {}

    # Creates an object from a hashtable of key-value pairs.
    GitHubArtifact([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates an object from a PSCustomObject.
    GitHubArtifact([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }
}
