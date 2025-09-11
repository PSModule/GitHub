class GitHubConfig {
    # The context ID.
    [string] $ID

    # The access token grace period in hours.
    [System.Nullable[double]] $AccessTokenGracePeriodInHours

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
    [System.Nullable[int]] $PerPage

    # The default value for retry count.
    [System.Nullable[int]] $RetryCount

    # The default value for retry interval in seconds.
    [System.Nullable[int]] $RetryInterval

    # The environment type, which is used to determine the context of the GitHub API calls.
    [string] $EnvironmentType

    # The completion mode for argument completers. Options: 'StartsWith', 'Contains'.
    [string] $CompletionMode

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
