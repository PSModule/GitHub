class GitHubConfig : Context {
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

    # Simple constructor that initializes the context ID.
    GitHubConfig() : Base([string]$ID) {}
}
