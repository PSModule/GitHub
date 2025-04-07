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
    [datetime] $CreatedAt

    # The date and time the environment was last updated.
    [datetime] $UpdatedAt

    # Whether admins can bypass protection rules.
    [bool] $CanAdminsBypass

    # Protection rules associated with the environment.
    [object[]] $ProtectionRules

    # Deployment branch policy details.
    [object] $DeploymentBranchPolicy

    # Simple parameterless constructor
    GitHubEnvironment() {}

    # Constructor that initializes the class from a hashtable
    GitHubEnvironment([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Constructor that initializes the class from a PSCustomObject
    GitHubEnvironment([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }
}
