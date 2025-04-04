class GitHubSecret {
    # The key ID of the public key.
    [string] $Name

    # The type of Public Key.
    [string] $Type

    # The name of the organization or user the Public Key is associated with.
    [string] $Owner

    # The name of the repository the Public Key is associated with.
    [string] $Repository

    # The name of the environment the Public Key is associated with.
    [string] $Environment

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
