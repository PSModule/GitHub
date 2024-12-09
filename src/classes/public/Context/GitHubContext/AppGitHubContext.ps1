class AppGitHubContext : GitHubContext {
    # Client ID for GitHub Apps
    [string] $ClientID

    # Creates a context object from a hashtable of key-vaule pairs.
    AppGitHubContext([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates a context object from a PSCustomObject.
    AppGitHubContext([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }
}
