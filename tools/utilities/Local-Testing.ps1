Get-GitHubAppInstallation -Organization 'PSModule'

$user = Get-GitHubUser
$user.social_accounts
Add-GitHubUserSocials -AccountUrls 'https://www.github.com/MariusStorhaug'

Get-GitHubUserEmail
Add-GitHubUserEmail -Emails 'octocat@psmodule.io'
Remove-GitHubUserEmail -Emails 'octocat@psmodule.io'

$Release = New-GitHubRelease -Owner PSModule -Repo Demo -TagName 'v1.0.0' -Name 'v1.0.0' -Draft -TargetCommitish 'main' -Body 'test release'
Get-GitHubRelease -Owner PSModule -Repo Demo
Get-GitHubRelease -Owner PSModule -Repo Demo -ID $Release.ID
Set-GitHubRelease -Owner PSModule -Repo Demo -ID $Release.ID
Get-GitHubRelease -Owner PSModule -Repo Demo -Latest
Get-GitHubRelease -Owner PSModule -Repo Demo -Tag 'v1.0.0'
$Release = Get-GitHubRelease -Owner PSModule -Repo Demo -Latest
Add-GitHubReleaseAsset -Owner PSModule -Repo Demo -ID $Release.ID -FilePath 'C:\Repos\GitHub\PSModule\Modules\GitHub\tools\utilities\Local-Testing.ps1'

Get-GitHubReleaseAsset -Owner PSModule -Repo Demo -ReleaseID $Release.ID



Get-GitHubRepositoryTopic -Owner 'PSModule' -Repo 'GitHub'
