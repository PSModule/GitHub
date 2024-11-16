$moduleInfo = $MyInvocation.MyCommand
$scriptFilePath = $MyInvocation.MyCommand.Path


Write-Verbose "[$scriptFilePath] - Initializing GitHub PowerShell module..."

if ($env:GITHUB_ACTIONS -eq 'true') {
    Write-Verbose 'Detected running on a GitHub Actions runner, preparing environment...'
    $env:GITHUB_REPOSITORY_NAME = $env:GITHUB_REPOSITORY -replace '.+/'
    Set-GitHubEnv -Name 'GITHUB_REPOSITORY_NAME' -Value $env:GITHUB_REPOSITORY_NAME
}

### This is the context for this module
# Get current module context
$context = (Get-Context -Name $script:Config.Name -AsPlainText)
if (-not $context) {
    Write-Verbose 'No context found, creating a new context...'
    Set-Context @{
        Name = $script:Config.Name
    }
}
