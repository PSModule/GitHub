class GitHubRepository {
    # The name of the repository.
    [string] $Name

    # The full name of the repository.
    # This is the name of the repository including the owner.
    # Example: "octocat/Hello-World".
    [string] $FullName

    # The ID of the repository.
    [string] $NodeID

    # The database ID of the repository.
    [UInt64] $DatabaseID

    # The description of the repository.
    [string] $Description

    # The owner of the repository.
    [string] $Owner

    # The URL of the repository.
    [string] $Url

    # The date and time the repository was created.
    [System.Nullable[datetime]] $CreatedAt

    # The date and time the repository was last updated.
    [System.Nullable[datetime]] $UpdatedAt

    # Simple parameterless constructor
    GitHubRepository() {}

    # Creates a object from a hashtable of key-vaule pairs.
    GitHubRepository([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates a object from a PSCustomObject.
    GitHubRepository([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }

    [string] ToString() {
        return $this.Name
    }
}
