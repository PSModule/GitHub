$scriptFilePath = $MyInvocation.MyCommand.Path

Write-Verbose 'Showing module details:'
Write-Verbose ($MyInvocation.MyCommand | Select-Object -Property * | Out-String)

Write-Verbose "[$scriptFilePath] - Initializing GitHub PowerShell module..."

if ($env:GITHUB_ACTIONS -eq 'true') {
    Write-Verbose 'Detected running on a GitHub Actions runner, preparing environment...'
    $env:GITHUB_REPOSITORY_NAME = $env:GITHUB_REPOSITORY -replace '.+/'
    Set-GitHubEnv -Name 'GITHUB_REPOSITORY_NAME' -Value $env:GITHUB_REPOSITORY_NAME
}

### This is the store config for this module
$storeParams = @{
    Name      = $script:Config.Name
    Variables = @{}
}
Set-Store @storeParams
