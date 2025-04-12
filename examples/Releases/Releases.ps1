# Get the latest release for a specific repository
Get-GitHubRelease -Owner PSModule -Repository GitHub

# Get all the releases for a specific repository
Get-GitHubRelease -Owner PSModule -Repository GitHub -All

# Get the latest releases for all repos in the organization
Get-GitHubOrganization -Name GitHub | Get-GitHubRepository | Get-GitHubRelease

# Get all the releases for all repos in the organization
Get-GitHubOrganization -Name GitHub | Get-GitHubRepository | Get-GitHubRelease


$repoName = 'mytest'
New-GitHubRepository -Name $repoName -AllowSquashMerge -AddReadme -License mit -Gitignore VisualStudio

$repo = Get-GitHubUser | Get-GitHubRepository -Name $repoName
$repo | Get-GitHubRelease -All
$repo | New-GitHubRelease -Tag 'v1.0' -Latest -GenerateReleaseNotes -Notes 'Release notes' -Name 'test'
$repo | New-GitHubRelease -Tag 'v1.1' -Latest -GenerateReleaseNotes -Notes 'Release notes' -Name 'test'
$repo | New-GitHubRelease -Tag 'v1.2' -Latest -GenerateReleaseNotes -Notes 'Release notes' -Name 'test'
$repo | New-GitHubRelease -Tag 'v1.3' -Latest -GenerateReleaseNotes -Notes 'Release notes' -Name 'test'
$repo | Get-GitHubRelease -All
$repo | New-GitHubRelease -Tag 'v1.4' -Draft
$repo | Get-GitHubRelease -Tag 'v1.4'
$repo | Update-GitHubRelease -Tag 'v1.3' -Draft -Prerelease

$repo | Get-GitHubRelease -All | Remove-GitHubRelease


Get-GitHubRepository -Username MariusStorhaug -Name $repoName | Remove-GitHubRepository -Confirm:$false
