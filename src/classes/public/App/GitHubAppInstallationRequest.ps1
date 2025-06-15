class GitHubAppInstallationRequest : GitHubNode {
    # The user who requested the installation.
    [GitHubUser] $RequestedBy

    # The target of the installation.
    [GitHubOwner] $Target

    # The creation date of the installation.
    # Example: 2008-01-14T04:33:35Z
    [System.Nullable[datetime]] $CreatedAt

    GitHubAppInstallationRequest() {}

    GitHubAppInstallationRequest([PSCustomObject]$Object) {
        $this.ID = $Object.id
        $this.NodeID = $Object.node_id
        $this.RequestedBy = [GitHubUser]::new($Object.requester)
        $this.Target = [GitHubOwner]::new($Object.account)
        $this.CreatedAt = $Object.created_at
    }
}
