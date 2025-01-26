class GitHubConfig {
    # The context ID.
    [string] $ID

    # The access token grace period in hours.
    [int] $AccessTokenGracePeriodInHours

    # The default context.
    [string] $DefaultContext

    # The default GitHub App client ID.
    [string] $GitHubAppClientID

    # The default host name.
    [string] $HostName

    # The default OAuth app client ID.
    [string] $OAuthAppClientID

    # The default value for the GitHub API version to use.
    [string] $ApiVersion

    # The default value for the HTTP protocol version.
    [version] $HttpVersion

    # The default value for the 'per_page' API parameter used in 'Get' functions that support paging.
    [int] $PerPage

    # Simple parameterless constructor
    GitHubConfig() {}

    # Creates a context object from a hashtable of key-vaule pairs.
    GitHubConfig([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates a context object from a PSCustomObject.
    GitHubConfig([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }
}
