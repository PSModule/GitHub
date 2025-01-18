$scriptFilePath = $MyInvocation.MyCommand.Path
Write-Verbose 'Initializing GitHub PowerShell module...'
Write-Verbose "Path: $scriptFilePath"

switch ($script:GitHub.EnvironmentType) {
    'GHA' {
        Write-Verbose 'Detected running on a GitHub Actions runner, preparing environment...'
        $env:GITHUB_REPOSITORY_NAME = $env:GITHUB_REPOSITORY -replace '.+/'
        Set-GitHubEnv -Name 'GITHUB_REPOSITORY_NAME' -Value $env:GITHUB_REPOSITORY_NAME
        Import-GitHubEventData
        Import-GitHubRunnerData
    }
}
