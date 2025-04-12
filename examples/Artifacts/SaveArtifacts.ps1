$modulesPath = $env:PSModulePath -Split [IO.Path]::PathSeparator | Select-Object -First 1
Get-GitHubArtifact -Owner PSModule -Repository GitHub -Name module |
    Save-GitHubArtifact -Path $modulesPath -Extract -Force

New-GitHubRepository -Name mytest -AllowSquashMerge -AddReadme -License mit -Gitignore VisualStudio
Get-GitHubRepository -Username MariusStorhaug -Name mytest | Remove-GitHubRepository -Confirm:$false
New-GitHubRelease -Owner MariusStorhaug -Repository mytest -Name 'mytest' -Tag 'v1.0' -Body 'Initial release' -Debug

Get-GitHubOrganization -Name PSModule | Get-GitHubRepository -Name GitHub | Get-GitHubWorkflow -Name Process-PSModule | Get-GitHubWorkflowRun



Get-GitHubOrganization | Get-GitHubRepository | Get-GitHubRelease
Get-GitHubUser | Get-GitHubRepository | Get-GitHubRelease

Get-GitHubRelease -Owner PSModule -Repository GitHub

$repo = Get-GitHubUser | Get-GitHubRepository -Name mytest
$repo | Get-GitHubRelease -All
$repo | New-GitHubRelease -Tag 'v1.0' -Latest -GenerateReleaseNotes -Notes 'Release notes' -Name 'test'
$repo | New-GitHubRelease -Tag 'v1.1' -Latest -GenerateReleaseNotes -Notes 'Release notes' -Name 'test'
$repo | New-GitHubRelease -Tag 'v1.2' -Latest -GenerateReleaseNotes -Notes 'Release notes' -Name 'test'
$repo | New-GitHubRelease -Tag 'v1.3' -Latest -GenerateReleaseNotes -Notes 'Release notes' -Name 'test'
$repo | Get-GitHubRelease -All
$repo | Update-GitHubRelease -Tag 'v1.3' -Draft -PreRelease

$repo | Get-GitHubRelease -All | Remove-GitHubRelease

