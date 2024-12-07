class GitHubConfig : Context {
    # The access token grace period in hours.
    [int] $AccessTokenGracePeriodInHours

    # The default context.
    [string] $DefaultContext

    # The default GitHub App client ID.
    [string] $DefaultGitHubAppClientID

    # The default host name.
    [string] $DefaultHostName

    # The default OAuth app client ID.
    [string] $DefaultOAuthAppClientID

    # The type of run environment.
    [string] $RunEnv

    GitHubConfig() : Base([string]$ID) {}
}
