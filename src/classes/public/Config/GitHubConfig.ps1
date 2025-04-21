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

    # The default base URI for the GitHub API, which is used to make API calls.
    [string] $ApiBaseUri

    # The default OAuth app client ID.
    [string] $OAuthAppClientID

    # The default value for the GitHub API version to use.
    [string] $ApiVersion

    # The default value for the HTTP protocol version.
    [string] $HttpVersion

    # The default value for the 'per_page' API parameter used in 'GET' functions that support paging.
    [int] $PerPage

    # The default value for retry count.
    [int] $RetryCount

    # The default value for retry interval in seconds.
    [int] $RetryInterval

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
