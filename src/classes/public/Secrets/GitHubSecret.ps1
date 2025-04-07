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

    # Simple parameterless constructor
    GitHubSecret() {}

    # Creates a object from a hashtable of key-vaule pairs.
    GitHubSecret([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates a object from a PSCustomObject.
    GitHubSecret([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }
}
