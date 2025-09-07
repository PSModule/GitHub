class GitHubSecret {
    # The name of the secret.
    [string] $Name

    # The scope of the secret, organization, repository, or environment.
    [string] $Scope

    # The name of the organization or user the secret is stored in.
    [string] $Owner

    # The name of the repository the secret is stored in.
    [string] $Repository

    # The name of the environment the secret is stored in.
    [string] $Environment

    # The date and time the secret was created.
    [datetime] $CreatedAt

    # The date and time the secret was last updated.
    [datetime] $UpdatedAt

    # The visibility of the secret.
    [string] $Visibility

    # The ids of the repositories that the secret is visible to.
    [GitHubRepository[]] $SelectedRepositories

    GitHubSecret() {}

    GitHubSecret([PSCustomObject]$Object, [string]$Owner, [string]$Repository, [string]$Environment, [GitHubRepository[]]$SelectedRepositories) {
        $this.Name = $Object.name
        $this.Owner = $Owner
        $this.Repository = $Repository
        $this.Environment = $Environment
        $this.CreatedAt = $Object.created_at
        $this.UpdatedAt = $Object.updated_at
        $this.Visibility = $Object.visibility
        $this.SelectedRepositories = $SelectedRepositories

        #Set scope based on provided values in Owner, Repository, Environment
        $this.Scope = if ($Owner -and $Repository -and $Environment) {
            'Environment'
        } elseif ($Owner -and $Repository) {
            'Repository'
        } elseif ($Owner) {
            'Organization'
        } else {
            'Unknown'
        }
    }
}
