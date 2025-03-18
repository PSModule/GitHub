class GitHubOwner {
    [string]$Login
    [int]$Id
    [string]$NodeId
    [string]$Url
    [string]$HtmlUrl
    [string]$AvatarUrl
    [string]$Type
    [string]$Name
    [string]$Company
    [string]$Blog
    [string]$Location
    [string]$Email
    [string]$TwitterUsername
    [int]$PublicRepos
    [int]$PublicGists
    [int]$Followers
    [int]$Following
    [DateTime]$CreatedAt
    [DateTime]$UpdatedAt

    # Simple parameterless constructor
    GitHubOwner() {}

    # Creates a object from a hashtable of key-vaule pairs.
    GitHubOwner([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates a object from a PSCustomObject.
    GitHubOwner([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }
}
