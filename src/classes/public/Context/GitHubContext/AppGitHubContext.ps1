class AppGitHubContext : GitHubContext {
    # Client ID for GitHub Apps
    [string] $ClientID

    # Owner of the GitHub App
    [string] $OwnerName

    # Type of the owner of the GitHub App
    [string] $OwnerType

    # The permissions that the app is requesting on the target
    [string[]] $Permissions

    # The events that the app is subscribing to once installed
    [string[]] $Events

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
