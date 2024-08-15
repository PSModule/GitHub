$scriptFilePath = $MyInvocation.MyCommand.Path

Write-Verbose "[$scriptFilePath] - Initializing GitHub PowerShell module..."

Initialize-Store -Name 'GitHubPowerShell' -SecretVaultName $script:Config.Name -SecretVaultType $script:Config.Type

if ($env:GITHUB_ACTIONS -eq 'true') {
    Initialize-RunnerEnvironment
}

# Autologon if a token is present in environment variables
$envVar = Get-ChildItem -Path 'Env:' | Where-Object Name -In 'GH_TOKEN', 'GITHUB_TOKEN' | Select-Object -First 1
$envVarPresent = $envVar.count -gt 0
if ($envVarPresent) {
    Connect-GitHubAccount
}
