# Get all the releases for a specific repository
Get-GitHubRelease -Owner PSModule -Repository GitHub

# Get the latest release for a specific repository
Get-GitHubRelease -Owner PSModule -Repository GitHub -Latest

# Get all the releases for all repos in the organization
'PSModule' | Get-GitHubOrganization | Get-GitHubRepository | Get-GitHubRelease

# Get the latest releases for all repos in the organization
'PSModule' | Get-GitHubOrganization | Get-GitHubRepository | ForEach-Object -ThrottleLimit ([Environment]::ProcessorCount) -Parallel {
    do {
        Import-Module -Name GitHub
    } until ($? -eq $true)
    $_ | Get-GitHubRelease -Latest
}

'PSModule' | Get-GitHubOrganization | Get-GitHubRepository | Get-GitHubRelease -Latest

# Create a new release for a specific repository
$repoName = 'mytest'

$repo = Get-GitHubUser | Get-GitHubRepository -Name $repoName
$repo | Get-GitHubRelease
$repo | New-GitHubRelease -Tag 'v1.0' -Latest
$repo | New-GitHubRelease -Tag 'v1.1' -Latest -Name 'test'
$repo | New-GitHubRelease -Tag 'v1.2' -Latest -Name 'test' -Notes 'Release notes'
$repo | New-GitHubRelease -Tag 'v1.3' -Latest -Name 'test' -GenerateReleaseNotes
$repo | Get-GitHubRelease -Tag 'v1.3' | Format-List
$repo | Get-GitHubRelease -Tag 'v1.3' | Update-GithubRelease -Notes 'Release notes'
$repo | Update-GitHubRelease -Tag 'v1.3' -Name 'test123' -Debug

$repo | New-GitHubRelease -Tag 'v1.3.1' -Latest -GenerateReleaseNotes
$repo | Get-GitHubRelease -Tag 'v1.3.1' | Format-List
$repo | Set-GitHubRelease -Tag 'v1.3.1' -Latest -GenerateReleaseNotes -Debug
$repo | Set-GitHubRelease -Tag 'v1.3.1' -Latest -GenerateReleaseNotes -Notes 'Release notes'
$repo | Get-GitHubRelease -Tag 'v1.3.1' | Format-List

$repo | Set-GitHubRelease -Tag 'v1.5' -Latest -Name 'test' -Notes 'Release notes' | Select-Object *
$repo | Get-GitHubRelease -Tag 'v1.4' | Select-Object Tag, Name, Latest, Prerelease, Draft
$repo | Set-GitHubRelease -Tag 'v1.4' | Select-Object Tag, Name, Latest, Prerelease, Draft
$repo | Set-GitHubRelease -Tag 'v1.4' -Name 'test2' -Draft | Select-Object Tag, Name, Latest, Prerelease, Draft
$repo | Set-GitHubRelease -Tag 'v1.4' -Name 'test2' -Draft -Prerelease | Select-Object Tag, Name, Latest, Prerelease, Draft
$repo | Set-GitHubRelease -Tag 'v1.4' -Name 'test2' -Prerelease | Select-Object Tag, Name, Latest, Prerelease, Draft
$repo | Set-GitHubRelease -Tag 'v1.4' -Name 'test2' -Latest | Select-Object Tag, Name, Latest, Prerelease, Draft
$repo | Set-GitHubRelease -Tag 'v1.4' -Name 'test2' | Select-Object Tag, Name, Latest, Prerelease, Draft

$repo | Get-GitHubRelease -Tag 'v1.4' | Select-Object *

$repo | Set-GitHubRelease -Tag 'v1.4' -Name 'test2'


New-GitHubReleaseNote -Owner PSModule -Repository GitHub -Tag 'v0.22.0' -Target 'main' -PreviousTag 'v0.20.0' | Format-List

$repo | Get-GitHubRelease | Remove-GitHubRelease


$repo | Remove-GitHubRepository -Confirm:$false
