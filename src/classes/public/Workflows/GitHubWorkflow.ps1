class GitHubWorkflow : GitHubNode {
    # The name of the workflow.
    [string] $Name

    # The name of the organization or user the variable is associated with.
    [string] $Owner

    # The name of the repository the variable is associated with.
    [string] $Repository

    # The path to the workflow file.
    [string] $Path

    # The current state of the workflow (e.g., active/inactive).
    [string] $State

    # The timestamp when the workflow was created.
    [System.Nullable[datetime]] $CreatedAt

    # The timestamp when the workflow was last updated.
    [System.Nullable[datetime]] $UpdatedAt

    # The timestamp when the workflow was last updated.
    [System.Nullable[datetime]] $DeletedAt

    # The GitHub URL for viewing the workflow.
    [string] $Url

    # The badge URL for this workflow's status.
    [string] $BadgeUrl

    GitHubWorkflow() {}

    GitHubWorkflow([PSCustomObject] $Object, [string] $Owner, [string] $Repository) {
        $this.ID = $Object.id
        $this.NodeID = $Object.node_id
        $this.Name = $Object.name
        $this.Owner = $Owner
        $this.Repository = $Repository
        $this.Path = $Object.path
        $this.State = $Object.state
        $this.CreatedAt = $Object.created_at
        $this.UpdatedAt = $Object.updated_at
        $this.DeletedAt = $Object.deleted_at
        $this.Url = $Object.html_url
        $this.BadgeUrl = $Object.badge_url
    }
}
