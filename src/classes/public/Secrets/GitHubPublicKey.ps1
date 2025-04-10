class GitHubPublicKey {
    # The key ID of the public key.
    [string] $ID

    # The public key used to encrypt secrets.
    [string] $Key

    # The type of Public Key.
    [string] $Type

    # The name of the organization or user the Public Key is associated with.
    [string] $Owner

    # The name of the repository the Public Key is associated with.
    [string] $Repository

    # The name of the environment the Public Key is associated with.
    [string] $Environment

    GitHubPublicKey() {}

    GitHubPublicKey([PSCustomObject]$Object, [string]$Type, [string]$Owner, [string]$Repository, [string]$Environment) {
        $this.ID = $Object.key_id
        $this.Key = $Object.key
        $this.Type = $Type
        $this.Owner = $Owner
        $this.Repository = $Repository
        $this.Environment = $Environment
    }
}
