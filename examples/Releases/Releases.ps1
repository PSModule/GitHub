# Get all the releases for a specific repository
Get-GitHubRelease -Owner PSModule -Repository GitHub

# Get the latest release for a specific repository
Get-GitHubRelease -Owner PSModule -Repository GitHub -Latest

# Get all the releases for all repos in the organization
'PSModule' | Get-GitHubOrganization | Get-GitHubRepository | Get-GitHubRelease

# Get the latest releases for all repos in the organization
Get-GitHubOrganization -Name PSModule | Get-GitHubRepository | Get-GitHubRelease -Latest

# Create a new release for a specific repository
$repoName = 'mytest'
New-GitHubRepository -Name $repoName -AllowSquashMerge -AddReadme -License mit -Gitignore VisualStudio

$repo = Get-GitHubUser | Get-GitHubRepository -Name $repoName
$repo | Get-GitHubRelease
$repo | New-GitHubRelease -Tag 'v1.0' -Latest
$repo | New-GitHubRelease -Tag 'v1.1' -Latest -Name 'test'
$repo | New-GitHubRelease -Tag 'v1.2' -Latest -Name 'test' -Notes 'Release notes'
$repo | Set-GitHubRelease -Tag 'v1.5' -Latest -Name 'test' -Notes 'Release notes' | Select-Object *
$repo | Get-GitHubRelease -Tag 'v1.4' | Select-Object Tag, Name, Latest, Prerelease, Draft
$repo | Set-GitHubRelease -Tag 'v1.4' | Select-Object Tag, Name, Latest, Prerelease, Draft
$repo | Set-GitHubRelease -Tag 'v1.4' -Name 'test2' | Select-Object Tag, Name, Latest, Prerelease, Draft
$repo | Set-GitHubRelease -Tag 'v1.4' -Name 'test2' -Draft | Select-Object Tag, Name, Latest, Prerelease, Draft
$repo | Set-GitHubRelease -Tag 'v1.4' -Name 'test2' -Draft -Prerelease | Select-Object Tag, Name, Latest, Prerelease, Draft
$repo | Set-GitHubRelease -Tag 'v1.4' -Name 'test2' -Prerelease | Select-Object Tag, Name, Latest, Prerelease, Draft
$repo | Set-GitHubRelease -Tag 'v1.4' -Name 'test2' -Latest | Select-Object Tag, Name, Latest, Prerelease, Draft

$repo | Get-GitHubRelease -Tag 'v1.4' | Select-Object *

$repo | Set-GitHubRelease -Tag 'v1.4' -Notes @'
## This is a test release.

This is a test release.
This is a test release.

## This is a test release.

This is a test release.
This is a test release.
This is a test release.

| Header 1 | Header 2 |
|---------|---------|
| Row 1 | Row 2 |
| Row 3 | Row 4 |
| Row 5 | Row 6 |

'@
$repo | Set-GitHubRelease -Tag 'v1.4' -Prerelease -Draft
$repo | Set-GitHubRelease -Tag 'v1.4' -Latest

$repo | Get-GitHubRelease -All | Remove-GitHubRelease


$repo | Remove-GitHubRepository -Confirm:$false
