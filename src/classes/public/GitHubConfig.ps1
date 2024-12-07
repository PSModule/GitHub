class GitHubConfig : Context {
    [string] $DefaultHostName
    [string] $RunEnv
    [string] $DefaultGitHubAppClientID
    [string] $DefaultOAuthAppClientID
    [string] $AccessTokenGracePeriodInHours

    GitHubConfig() : Base([string]$ID) {}
}
