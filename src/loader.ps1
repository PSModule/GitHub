﻿$scriptFilePath = $MyInvocation.MyCommand.Path
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

if (-not $context.GitHubAppClientID) {
    Set-GitHubConfig -Name GitHubAppClientID -Value $script:Auth.GitHubApp.ClientID
}
if (-not $context.OAuthAppClientID) {
    Set-GitHubConfig -Name OAuthAppClientID -Value $script:Auth.OAuthApp.ClientID
}
if (-not $context.AccessTokenGracePeriodInHours) {
    Set-GitHubConfig -Name AccessTokenGracePeriodInHours -Value $script:Auth.AccessTokenGracePeriodInHours
}

$script:runEnv = if ($env:GITHUB_ACTIONS -eq 'true') {
    'GHA'
} elseif (-not [string]::IsNullOrEmpty($env:WEBSITE_PLATFORM_VERSION)) {
    'AFA'
} else {
    'Local'
}

Set-GitHubConfig -Name 'RunEnv' -Value $script:runEnv

if ($env:GITHUB_ACTIONS -eq 'true') {
    Write-Verbose 'Detected running on a GitHub Actions runner, preparing environment...'
    $env:GITHUB_REPOSITORY_NAME = $env:GITHUB_REPOSITORY -replace '.+/'
    Set-GitHubEnv -Name 'GITHUB_REPOSITORY_NAME' -Value $env:GITHUB_REPOSITORY_NAME
}
