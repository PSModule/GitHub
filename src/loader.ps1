﻿$scriptFilePath = $MyInvocation.MyCommand.Path
Write-Verbose 'Initializing GitHub PowerShell module...'
Write-Verbose "Path: $scriptFilePath"

switch ($script:GitHub.EnvironmentType) {
    'GHA' {
        $PSStyle.OutputRendering = 'Ansi'
        Write-Verbose 'Detected running on a GitHub Actions runner, preparing environment...'
        $env:GITHUB_REPOSITORY_NAME = $env:GITHUB_REPOSITORY -replace '.+/'
        Set-GitHubEnvironmentVariable -Name 'GITHUB_REPOSITORY_NAME' -Value $env:GITHUB_REPOSITORY_NAME
        $env:GITHUB_HOST_NAME = ($env:GITHUB_SERVER_URL ?? 'github.com') -replace '^https?://'
        Set-GitHubEnvironmentVariable -Name 'GITHUB_HOST_NAME' -Value $env:GITHUB_HOST_NAME
        Import-GitHubEventData
        Import-GitHubRunnerData
    }
}
