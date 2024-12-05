$scriptFilePath = $MyInvocation.MyCommand.Path
Write-Verbose 'Initializing GitHub PowerShell module...'
Write-Verbose "Path: $scriptFilePath"

### This is the context for this module
# Get current module context
$context = (Get-Context -ID $script:Config.Name)
if (-not $context) {
    Write-Verbose 'No context found, creating a new context...'
    Set-Context -ID $script:Config.Name -Context @{}
}
$context = (Get-Context -ID $script:Config.Name)

if (-not $context.DefaultGitHubAppClientID) {
    Set-GitHubConfig -Name DefaultGitHubAppClientID -Value $script:Auth.GitHubApp.ClientID
}
if (-not $context.DefaultOAuthAppClientID) {
    Set-GitHubConfig -Name DefaultOAuthAppClientID -Value $script:Auth.OAuthApp.ClientID
}
if (-not $context.AccessTokenGracePeriodInHours) {
    Set-GitHubConfig -Name AccessTokenGracePeriodInHours -Value $script:Auth.AccessTokenGracePeriodInHours
}
if (-not $context.DefaultHostName) {
    $defaultHostName = $env:GITHUB_SERVER_URL ?? 'github.com'
    Set-GitHubConfig -Name DefaultHostName -Value $defaultHostName
}

if (-not $context.RunEnv) {
    $script:runEnv = if ($env:GITHUB_ACTIONS -eq 'true') {
        'GHA'
    } elseif (-not [string]::IsNullOrEmpty($env:WEBSITE_PLATFORM_VERSION)) {
        'AFA'
    } else {
        'Local'
    }
    Set-GitHubConfig -Name 'RunEnv' -Value $script:runEnv
}

if ($env:GITHUB_ACTIONS -eq 'true') {
    Write-Verbose 'Detected running on a GitHub Actions runner, preparing environment...'
    $env:GITHUB_REPOSITORY_NAME = $env:GITHUB_REPOSITORY -replace '.+/'
    Set-GitHubEnv -Name 'GITHUB_REPOSITORY_NAME' -Value $env:GITHUB_REPOSITORY_NAME
}
