$scriptFilePath = $MyInvocation.MyCommand.Path

Write-Verbose "[$scriptFilePath] - Initializing GitHub PowerShell module..."

Initialize-Store -Name 'GitHubPowerShell' -SecretVaultName $script:Config.Name -SecretVaultType $script:Config.Type

if ($env:GITHUB_ACTIONS -eq 'true') {
    Initialize-RunnerEnvironment
}
