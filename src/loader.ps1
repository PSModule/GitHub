$moduleInfo = $MyInvocation.MyCommand
$scriptFilePath = $MyInvocation.MyCommand.Path


Write-Verbose "[$scriptFilePath] - Initializing GitHub PowerShell module..."
Write-Verbose ($moduleInfo.Module | Out-String)

if ($env:GITHUB_ACTIONS -eq 'true') {
    Write-Verbose 'Detected running on a GitHub Actions runner, preparing environment...'
    $env:GITHUB_REPOSITORY_NAME = $env:GITHUB_REPOSITORY -replace '.+/'
    Set-GitHubEnv -Name 'GITHUB_REPOSITORY_NAME' -Value $env:GITHUB_REPOSITORY_NAME
}

### This is the context for this module
$contextParams = @{
    Name           = $script:Config.Name
    DefaultContext = 'null'
}
Set-Context @contextParams
