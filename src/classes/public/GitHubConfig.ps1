class GitHubConfig : Context {
    [int] $AccessTokenGracePeriodInHours
    [string] $DefaultContext
    [string] $DefaultGitHubAppClientID
    [string] $DefaultHostName
    [string] $DefaultOAuthAppClientID
    [string] $RunEnv

    GitHubConfig() : Base([string]$ID) {}
}
