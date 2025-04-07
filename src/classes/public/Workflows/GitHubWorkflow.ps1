class GitHubWorkflow {
    # The workflow's database identifier.
    [int64] $DatabaseID

    # The node identifier of the workflow.
    [string] $NodeID

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
    [datetime] $CreatedAt

    # The timestamp when the workflow was last updated.
    [datetime] $UpdatedAt

    # The timestamp when the workflow was last updated.
    [datetime] $DeletedAt

    # The GitHub URL for viewing the workflow.
    [string] $Url

    # The badge URL for this workflow's status.
    [string] $BadgeUrl

    # Simple parameterless constructor.
    GitHubWorkflow() {
    }

    # Creates an object from a hashtable of key-value pairs.
    GitHubWorkflow([hashtable] $Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates an object from a PSCustomObject.
    GitHubWorkflow([PSCustomObject] $Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }
}
