class GitHubVariable {
    # The name of the variable.
    [string] $Name

    # The value of the variable.
    [string] $Value

    # The scope of the variable, organization, repository, or environment.
    [string] $Scope

    # The name of the organization or user the variable is stored in.
    [string] $Owner

    # The name of the repository the variable is stored in.
    [string] $Repository

    # The name of the environment the variable is stored in.
    [string] $Environment

    # The date and time the variable was created.
    [datetime] $CreatedAt

    # The date and time the variable was last updated.
    [datetime] $UpdatedAt

    # The visibility of the variable.
    [string] $Visibility

    # The ids of the repositories that the variable is visible to.
    [GitHubRepository[]] $SelectedRepositories

    GitHubVariable() {}

    GitHubVariable([PSCustomObject]$Object, [string]$Owner, [string]$Repository, [string]$Environment, [GitHubRepository[]]$SelectedRepositories) {
        $this.Name = $Object.name
        $this.Value = $Object.value
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
