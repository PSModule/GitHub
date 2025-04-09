class GitHubSecret {
    # The key ID of the public key.
    [string] $Name

    # The type of Public Key.
    [string] $Type

    # The scope of the variable, organization, repository, or environment.
    [string] $Scope

    # The name of the organization or user the Public Key is associated with.
    [string] $Owner

    # The name of the repository the Public Key is associated with.
    [string] $Repository

    # The name of the environment the Public Key is associated with.
    [string] $Environment

    # The date and time the variable was created.
    [datetime] $CreatedAt

    # The date and time the variable was last updated.
    [datetime] $UpdatedAt

    # The visibility of the variable.
    [string] $Visibility

    # The ids of the repositories that the variable is visible to.
    [GitHubRepository[]] $SelectedRepositories

    GitHubSecret() {}

    GitHubSecret([PSCustomObject]$Object, [string]$Owner, [string]$Repository, [string]$Environment) {
        $this.Name = $Object.name
        $this.Type = $Object.type
        $this.Owner = $Object.owner
        $this.Repository = $Object.repository
        $this.Environment = $Object.environment
        $this.CreatedAt = [datetime]$Object.created_at
        $this.UpdatedAt = [datetime]$Object.updated_at
        $this.Visibility = $Object.visibility
        $this.SelectedRepositories = @()
        if ($Object.visibility -eq 'selected') {
            foreach ($repo in $Object.selected_repositories) {
                $this.SelectedRepositories += [GitHubRepository]::new($repo)
            }
        }
        #Set scope based on provided values in Owner, Repository, Environment
        $this.Scope = if ($this.Owner -and $this.Repository -and $this.Environment) {
            'Environment'
        } elseif ($this.Owner -and $this.Repository) {
            'Repository'
        } elseif ($this.Owner) {
            'Organization'
        } else {
            'Unknown'
        }
    }
}
