$scriptFilePath = $MyInvocation.MyCommand.Path
$moduleName = $MyInvocation.MyCommand.Module.Name
$moduleVersion = $MyInvocation.MyCommand.Module.Version
Write-Verbose "Initializing GitHub PowerShell module..."
Write-Verbose "Name:      $moduleName"
Write-Verbose "Version:   $moduleVersion"
Write-Verbose "Path:      $scriptFilePath"

if ($env:GITHUB_ACTIONS -eq 'true') {
    Write-Verbose 'Detected running on a GitHub Actions runner, preparing environment...'
    $env:GITHUB_REPOSITORY_NAME = $env:GITHUB_REPOSITORY -replace '.+/'
    Set-GitHubEnv -Name 'GITHUB_REPOSITORY_NAME' -Value $env:GITHUB_REPOSITORY_NAME
}

### This is the context for this module
# Get current module context
$context = (Get-Context -ID $script:Config.Name)
if (-not $context) {
    Write-Verbose 'No context found, creating a new context...'
    Set-Context -ID $script:Config.Name -Context @{ ContextID = 'GitHub' }
}
