class GitHubUser : GitHubOwner {
    [bool]$SiteAdmin
    [string]$Bio
    [string]$UserViewType
    [string]$NotificationEmail
    [array]$SocialAccounts

    # Simple parameterless constructor
    GitHubUser() {}

    # Creates a object from a hashtable of key-vaule pairs.
    GitHubUser([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates a object from a PSCustomObject.
    GitHubUser([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }
}
