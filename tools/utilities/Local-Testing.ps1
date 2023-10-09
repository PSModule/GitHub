#####
Get-Module -Name GitHub -ListAvailable
Get-Module -Name GitHub* -ListAvailable | Remove-Module -Force
Get-Module -Name GitHub* -ListAvailable | Uninstall-Module -Force -AllVersions
Get-Module -Name GitHub -ListAvailable

Get-SecretVault | Unregister-SecretVault

Get-SecretVault
Get-SecretInfo
Get-Module -Name GitHub -ListAvailable
$VerbosePreference = 'Continue'

Install-Module -Name GitHub -Force -Verbose -AllowPrerelease
Get-Module -Name GitHub -ListAvailable
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

Get-GitHubOrganization | Select-Object Name, login, id
Get-GitHubOrganization -OrganizationName 'PowerShell'
Get-GitHubOrganization -OrganizationName 'PSModule'

Get-GitHubOrganizationAppInstallation -OrganizationName 'PSModule'

Set-GitHubOrganization -OrganizationName 'PSModule' -Blog 'https://www.psmodule.io'
Set-GitHubOrganization -OrganizationName 'PSModule' -Blog ''

Set-GitHubOrganization -OrganizationName 'PSModule' -Company 'PSModule123' -DefaultRepositoryPermission admin | Select-Object name, company, default_repository_permission
Set-GitHubOrganization -OrganizationName 'PSModule' -Company 'PSModule' -DefaultRepositoryPermission read | Select-Object name, company, default_repository_permission

Get-GitHubUser
Get-GitHubUser | Select-Object Name, login, id, company, blog, twitter_username, location, hireable, bio

$user = Get-GitHubUser
$user.social_accounts

Set-GitHubUser -Company '@DNBBank' -Email 'marstor@hotmail.com' -Blog 'https://www.github.com/MariusStorhaug' -TwitterUsername MariusStorhaug -Location 'Norway' -Hireable $false -Bio 'DevOps Engineer at DNB Bank. I ❤️ PowerShell and automation.'
Set-GitHubUser -Company ' '
Set-GitHubUser -Hireable $true | Select-Object login, hireable
Set-GitHubUser -Hireable $false | Select-Object login, hireable

Add-GitHubUserSocials -AccountUrls 'https://www.github.com/MariusStorhaug'

Get-GitHubUserEmail
Add-GitHubUserEmail -Emails 'octocat@psmodule.io'
Remove-GitHubUserEmail -Emails 'octocat@psmodule.io'

Get-ChildItem -Path 'C:\Repos\GitHub\PSModule\Modules\GitHub\src\GitHub\private\Utilities' -File -Recurse -Force | Select-Object -ExpandProperty FullName | ForEach-Object { $null = . $_ }


$Release = New-GitHubRelease -Owner PSModule -Repo Demo -TagName 'v1.0.0' -Name 'v1.0.0' -Draft -TargetCommitish 'main' -Body 'test release'
Get-GitHubRelease -Owner PSModule -Repo Demo
Get-GitHubRelease -Owner PSModule -Repo Demo -ID $Release.id
Set-GitHubRelease -Owner PSModule -Repo Demo -ID $Release.id
Get-GitHubRelease -Owner PSModule -Repo Demo -Latest
Get-GitHubRelease -Owner PSModule -Repo Demo -Tag 'v1.0.0'
$Release = Get-GitHubRelease -Owner PSModule -Repo Demo -Latest
Add-GitHubReleaseAsset -Owner PSModule -Repo Demo -ID $Release.id -FilePath 'C:\Repos\GitHub\PSModule\Modules\GitHub\tools\utilities\Local-Testing.ps1'

Get-GitHubReleaseAsset -Owner PSModule -Repo Demo -ReleaseID $Release.id

Get-GitHubRepository | Select-Object full_name, id, visibility, created_at
Get-GitHubRepository -Type owner | Select-Object full_name, id, visibility, created_at
Get-GitHubRepository -Type private -Sort pushed | Select-Object full_name, id, visibility, created_at

Get-GitHubRepository -Owner 'PSModule' -Repo 'Demo' | Select-Object full_name, id, visibility, created_at
Get-GitHubRepository -Owner 'Azure' -Repo 'ResourceModules' | Select-Object full_name, id, visibility, created_at

Get-GitHubRepository -SinceID 702104693 -Verbose | Select-Object full_name, id, visibility, created_at

Get-GitHubRepository -Username 'octocat' -Type all | Select-Object full_name, id, visibility, created_at
Get-GitHubRepository -Username 'octocat' -Type 'member' | Select-Object full_name, id, visibility, created_at
Get-GitHubRepository -Username 'octocat' -Sort 'created' -Direction 'asc' | Select-Object full_name, id, visibility, created_at

Get-GitHubRepository -Owner 'PSModule' | Select-Object full_name, id, visibility, created_at
Get-GitHubRepository -Owner 'PSModule' -Type 'public' | Select-Object full_name, id, visibility, created_at
Get-GitHubRepository -Owner 'PSModule' -Sort 'created' -Direction 'asc' | Select-Object full_name, id, visibility, created_at

$params = @{
    Verbose                  = $true
    Owner                    = 'PSModule'
    Name                     = 'Hello-world'
    Description              = 'This is a test repo.'
    Homepage                 = 'https://github.com'
    Visibility               = 'public'
    HasIssues                = $true
    HasProjects              = $true
    HasWiki                  = $true
    HasDownloads             = $true
    IsTemplate               = $true
    # TeamID      = 12345679
    AutoInit                 = $true
    # GitignoreTemplate        = 'VisualStudio'
    # LicenseTemplate          = 'MIT'
    AllowSquashMerge         = $true
    SquashMergeCommitTitle   = 'PR_TITLE'
    SquashMergeCommitMessage = 'PR_BODY'
    AllowMergeCommit         = $true
    MergeCommitTitle         = 'PR_TITLE'
    MergeCommitMessage       = 'PR_BODY'
    AllowRebaseMerge         = $true
    AllowAutoMerge           = $true
    DeleteBranchOnMerge      = $true
}
New-GitHubRepositoryOrg @params -GitignoreTemplate Fortran -LicenseTemplate 'MIT License'

Remove-GitHubRepository -Owner PSModule -Repo 'Hello-world' -Verbose
