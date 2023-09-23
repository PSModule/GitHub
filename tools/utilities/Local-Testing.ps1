#####
Get-Module -Name GitHub -ListAvailable | Remove-Module -Force
Get-Module -Name GitHub -ListAvailable | Uninstall-Module -Force -AllVersions
Get-SecretVault | Unregister-SecretVault

Get-SecretVault
Get-Module -Name GitHub -ListAvailable
Install-Module -Name GitHub -Verbose -Force -AllowPrerelease
Import-Module -Name GitHub -Verbose
Clear-Host
Get-Command -Module GitHub
Get-Variable | Where-Object -Property Module -ne $null | Select-Object Name, Module, ModuleName
Connect-GitHubAccount
Get-GitHubConfig | ConvertTo-Json -Depth 100
Get-GitHubContext

Connect-GitHubAccount -Refresh -Verbose

Disconnect-GitHubAccount -Verbose
