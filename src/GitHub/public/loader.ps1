Initialize-SecretVault -Name $script:SecretVault.Name -Type $script:SecretVault.Type
Restore-GitHubConfig

if (-not [string]::IsNullOrEmpty($env:GH_TOKEN)) {
    Write-Verbose 'Logging on using GH_TOKEN'
    Connect-GitHubAccount -AccessToken $env:GH_TOKEN
}
if (-not [string]::IsNullOrEmpty($env:GITHUB_TOKEN)) {
    Write-Verbose 'Logging on using GITHUB_TOKEN'
    Connect-GitHubAccount -AccessToken $env:GITHUB_TOKEN
}
