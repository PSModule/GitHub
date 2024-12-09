class InstallationGitHubContext : GitHubContext {
    # Client ID for GitHub Apps
    [string] $ClientID

    # The token expiration date.
    # 2024-01-01-00:00:00
    [datetime] $TokenExpirationDate

    # The installation ID.
    [int] $InstallationID

    # Creates a context object from a hashtable of key-vaule pairs.
    InstallationGitHubContext([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates a context object from a PSCustomObject.
    InstallationGitHubContext([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }
}
