﻿#####
Get-Module -Name GitHub -ListAvailable | Remove-Module -Force
Get-Module -Name GitHub -ListAvailable | Uninstall-Module -Force -AllVersions
Get-SecretVault | Unregister-SecretVault

Get-SecretVault
Get-SecretInfo
Get-Module -Name GitHub -ListAvailable
$VerbosePreference = 'Continue'

Install-Module -Name GitHub -Verbose -Force -AllowPrerelease
$env:PSModulePath += ';C:\Repos\GitHub\PSModule\Modules\GitHub\outputs'
Import-Module -Name 'C:\Repos\GitHub\PSModule\Modules\GitHub\src\GitHub\GitHub.psm1' -Verbose -Force

Import-Module -Name GitHub -Verbose
Clear-Host
Get-Command -Module GitHub
Get-Variable | Where-Object -Property Module -NE $null | Select-Object Name, Module, ModuleName
Connect-GitHubAccount
Get-GitHubConfig -Name AccessToken
Get-GitHubContext

Connect-GitHubAccount -Refresh -Verbose

Disconnect-GitHubAccount -Verbose
Reset-GitHubConfig -Verbose
