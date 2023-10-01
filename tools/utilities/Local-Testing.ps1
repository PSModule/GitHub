#####
Get-Module -Name GitHub* -ListAvailable | Remove-Module -Force
Get-Module -Name GitHub* -ListAvailable | Uninstall-Module -Force -AllVersions
Get-SecretVault | Unregister-SecretVault

Get-SecretVault
Get-SecretInfo
Get-Module -Name GitHub -ListAvailable
$VerbosePreference = 'Continue'

Install-Module -Name GitHub -Force -Verbose -AllowPrerelease
# $env:PSModulePath += ';C:\Repos\GitHub\PSModule\Modules\GitHub\outputs'
# Import-Module -Name 'C:\Repos\GitHub\PSModule\Modules\GitHub\src\GitHub\GitHub.psm1' -Verbose -Force

Import-Module -Name GitHub -Verbose
Get-Command -Module GitHub
Clear-Host
Connect-GitHubAccount
Connect-GitHubAccount -Owner 'MariusStorhaug' -Repo 'ResourceModules'
Connect-GitHubAccount -Mode OAuthApp
Connect-GitHubAccount -AccessToken
Get-GitHubConfig
Get-GitHubConfig -Name AccessToken
Get-GitHubConfig -Name RefreshToken
Invoke-GitHubAPI -Method Get -ApiEndpoint /user
Get-GitHubMeta
Get-GitHubOctocat -S 'Hello World'
Disconnect-GitHubAccount -Verbose
$VerbosePreference = 'SilentlyContinue'


$str = '2023-10-27 17:43:40 UTC'
$format = "yyyy-MM-dd HH:mm:ss 'UTC'"
$date = [datetime]::ParseExact($str, $format, $null)
$date


Get-GitHubOrganization
Get-GitHubOrganization -OrganizationName 'PowerShell'
Get-GitHubOrganization -OrganizationName 'PSModule'

Get-GitHubOrganizationAppInstallation -OrganizationName 'PSModule'

Set-GitHubOrganization -OrganizationName 'PSModule' -Blog 'https://www.psmodule.io'
Set-GitHubOrganization -OrganizationName 'PSModule' -Blog ''

Set-GitHubOrganization -OrganizationName 'PSModule' -Company 'PSModule123' -DefaultRepositoryPermission admin
Set-GitHubOrganization -OrganizationName 'PSModule' -Company 'PSModule' -DefaultRepositoryPermission read

Set-GitHubUser -Name 'Marius Storhaug' -Company '@DNBBank' -Email 'marstor@hotmail.com' -Blog 'https://www.github.com/MariusStorhaug' -TwitterUsername MariusStorhaug -Location 'Norway' -Hireable $false -Bio 'DevOps Engineer at DNB Bank. I ❤️ PowerShell and automation.'
Set-GitHubUser -Name 'MariusStorhaug' -Company ' '
Set-GitHubUser -Name 'MariusStorhaug' -Hireable $true
