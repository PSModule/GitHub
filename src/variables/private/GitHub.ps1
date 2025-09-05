$script:IsGitHubActions = $env:GITHUB_ACTIONS -eq 'true'
$script:IsFunctionApp = $env:FUNCTIONS_WORKER_RUNTIME -eq 'powershell'
$script:IsLocal = -not ($script:IsGitHubActions -or $script:IsFunctionApp)
$script:GitHub = [pscustomobject]@{
    ContextVault       = 'PSModule.GitHub'
    TokenPrefixPattern = '(?<=^(ghu|gho|ghs|github_pat|ghp)).*'
    EnvironmentType    = Get-GitHubEnvironmentType
    DefaultConfig      = [GitHubConfig]@{
        ID                            = 'Module'
        HostName                      = ($env:GITHUB_SERVER_URL ?? 'github.com') -replace '^https?://'
        ApiBaseUri                    = "https://api.$(($env:GITHUB_SERVER_URL ?? 'github.com') -replace '^https?://')"
        AccessTokenGracePeriodInHours = 4.0
        GitHubAppClientID             = 'Iv1.f26b61bc99e69405'
        OAuthAppClientID              = '7204ae9b0580f2cb8288'
        DefaultContext                = ''
        ApiVersion                    = '2022-11-28'
        HttpVersion                   = '2.0'
        PerPage                       = 100
        RetryCount                    = 0
        RetryInterval                 = 1
        EnvironmentType               = Get-GitHubEnvironmentType
    }
    Config             = $null
    Event              = $null
    Runner             = $null
}
