$script:GitHub = [pscustomobject]@{
    Initialized        = $false
    TokenPrefixPattern = '(?<=^(ghu|gho|ghs|github_pat|ghp)).*'
    EnvironmentType    = if ($env:GITHUB_ACTIONS -eq 'true') {
        'GHA'
    } elseif (-not [string]::IsNullOrEmpty($env:WEBSITE_PLATFORM_VERSION)) {
        'AFA'
    } else {
        'Local'
    }
    DefaultConfig      = [GitHubConfig]@{
        ID                            = 'PSModule.GitHub'
        HostName                      = $env:GITHUB_SERVER_URL ?? 'github.com'
        AccessTokenGracePeriodInHours = 4
        GitHubAppClientID             = 'Iv1.f26b61bc99e69405'
        OAuthAppClientID              = '7204ae9b0580f2cb8288'
        DefaultContext                = ''
    }
    Config             = [GitHubConfig]::new()
}
