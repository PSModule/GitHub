$script:GitHub = [pscustomobject]@{
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
        HostName                      = ($env:GITHUB_SERVER_URL ?? 'github.com') -replace '^https?://'
        AccessTokenGracePeriodInHours = 4
        GitHubAppClientID             = 'Iv1.f26b61bc99e69405'
        OAuthAppClientID              = '7204ae9b0580f2cb8288'
        DefaultContext                = ''
        ApiVersion                    = '2022-11-28'
        HttpVersion                   = '2.0'
        PerPage                       = 100
        RetryCount                    = 0
        RetryInterval                 = 1
    }
    Config             = $null
    Event              = $null
    Runner             = $null
}
