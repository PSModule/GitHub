class GitHubRepositoryPermissions {
    # Full control over the repository, including managing settings and access. Can delete the repository and change roles for others.
    [System.Nullable[bool]] $Admin

    # Has elevated permissions to manage repository settings (e.g., branches, webhooks). Cannot delete the repository or manage its access.
    [System.Nullable[bool]] $Maintain

    # Can push code and manage issues and pull requests. Cannot manage repository settings or permissions.
    # Alias "Write"
    [System.Nullable[bool]] $Push

    # Can manage issues and pull requests (label, assign, close, etc.). Cannot push code or change repository settings.
    [System.Nullable[bool]] $Triage

    # Can view and clone the repository. Cannot push code or manage issues and pull requests.
    # Alias "Read"
    [System.Nullable[bool]] $Pull

    GitHubRepositoryPermissions() {}

    GitHubRepositoryPermissions([PSCustomObject]$Object) {
        $this.Admin = $Object.admin
        $this.Maintain = $Object.maintain
        $this.Push = $Object.push
        $this.Triage = $Object.triage
        $this.Pull = $Object.pull
    }
}
