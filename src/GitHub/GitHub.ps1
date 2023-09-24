$scriptFilePath = $MyInvocation.MyCommand.Path

Write-Verbose "[$scriptFilePath] - Initializing GitHub module..." -Verbose

Initialize-SecretVault -Name $script:SecretVault.Name -Type $script:SecretVault.Type

# Autoload settings if present
$script:Config = $script:ConfigTemplate | ConvertTo-Json -Depth 100 | ConvertFrom-Json -AsHashtable # Essentially a deep clone of the AppConfig template
Restore-GitHubConfig
Save-GitHubConfig

# Autologon if a token is present in environment variables
$envVar = Get-ChildItem -Path 'Env:' | Where-Object Name -In 'GH_TOKEN', 'GITHUB_TOKEN' | Select-Object -First 1
$envVarPresent = $envVar.count -gt 0
if ($envVarPresent) {
    Connect-GitHubAccount
}
