#####
Get-Module -Name GitHub -ListAvailable | Remove-Module -Force
Get-Module -Name GitHub -ListAvailable | Uninstall-Module -Force -AllVersions
Get-SecretVault | Unregister-SecretVault

Get-SecretVault
Get-Module -Name GitHub -ListAvailable
Install-Module -Name GitHub -Verbose -Force -AllowPrerelease
Clear-Host
Get-Command -Module GitHub
Get-Variable | Select-Object Name, Module, ModuleName
Connect-GitHubAccount
Get-GitHubConfig
Get-GitHubContext

Connect-GitHubAccount -Refresh -Verbose

Disconnect-GitHubAccount -Verbose
