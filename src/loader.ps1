$moduleInfo = $MyInvocation.MyCommand
$scriptFilePath = $MyInvocation.MyCommand.Path


Write-Verbose "[$scriptFilePath] - Initializing GitHub PowerShell module..."
Write-Verbose ($moduleInfo.Version | Out-String)
Write-Verbose ($moduleInfo.CommandType | Out-String)
Write-Verbose ($moduleInfo.ModuleName | Out-String)
Write-Verbose ($moduleInfo.Name | Out-String)

if ($env:GITHUB_ACTIONS -eq 'true') {
    Write-Verbose 'Detected running on a GitHub Actions runner, preparing environment...'
    $env:GITHUB_REPOSITORY_NAME = $env:GITHUB_REPOSITORY -replace '.+/'
    Set-GitHubEnv -Name 'GITHUB_REPOSITORY_NAME' -Value $env:GITHUB_REPOSITORY_NAME
}

### This is the context for this module
# Get current module context
$context = Get-Context -Name $script:Config.Name -AsPlainText

# Add values from the variables, if the values are not present in the context
$context['Name'] = $context['Name'] ?? $script:Config.Name

# Set the context using the values from the variables
Set-Context @context
