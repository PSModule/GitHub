class GitHubEnvironment : GitHubNode {
    # The name of the environment.
    [string] $Name

    # The repository where the environment is.
    [string] $Repository

    # The owner of the environment.
    [string] $Owner

    # URL of the environment.
    [string] $Url

    # The date and time the environment was created.
    [System.Nullable[datetime]] $CreatedAt

    # The date and time the environment was last updated.
    [System.Nullable[datetime]] $UpdatedAt

    # Whether admins can bypass protection rules.
    [System.Nullable[bool]] $AdminsCanBypass

    # Protection rules associated with the environment.
    [object[]] $ProtectionRules

    # Deployment branch policy details.
    [object] $DeploymentBranchPolicy

    GitHubEnvironment() {}

    GitHubEnvironment([PSCustomObject]$Object, [string]$Owner, [string]$Repository) {
        $this.ID = $Object.id
        $this.NodeID = $Object.node_id
        $this.Name = $Object.name
        $this.Owner = $Owner
        $this.Repository = $Repository
        $this.CreatedAt = $Object.created_at
        $this.UpdatedAt = $Object.updated_at
        $this.AdminsCanBypass = $Object.can_admins_bypass
        $this.ProtectionRules = $Object.protection_rules
        $this.DeploymentBranchPolicy = $Object.deployment_branch_policy
    }
}
