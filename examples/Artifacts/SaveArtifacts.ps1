$modulesPath = $env:PSModulePath -Split [IO.Path]::PathSeparator | Select-Object -First 1
Get-GitHubArtifact -Owner PSModule -Repository GitHub -Name module |
    Save-GitHubArtifact -Path $modulesPath -Extract -Force

New-GitHubRepository -Name mytest -AllowSquashMerge -AddReadme -License mit -Gitignore VisualStudio
Get-GitHubRepository -Username MariusStorhaug -Name mytest | Remove-GitHubRepository -Confirm:$false
New-GitHubRelease -Owner MariusStorhaug -Repository mytest -Name 'mytest' -Tag 'v1.0' -Body 'Initial release' -Debug

Get-GitHubOrganization -Name PSModule | Get-GitHubRepository -Name GitHub | Get-GitHubWorkflow -Name Process-PSModule | Get-gitHubWorkflowRun



Get-GitHubOrganization | Get-GitHubRepository | Get-GitHubRelease
Get-GitHubUser | Get-GitHubRepository | Get-GitHubRelease

Get-GitHubRelease -Owner PSModule -Repository GitHub

Get-GitHubUser | Get-GitHubRepository -Name mytest | New-GitHubRelease -Tag 'v1.6.3' -Latest -GenerateReleaseNotes -Notes 'Release notes' -Name 'test'
Get-GitHubUser | Get-GitHubRepository -Name mytest | Get-GitHubRelease -All


Invoke-GitHubAPI -ApiEndpoint '/repos/PSModule/Github/git/matching-refs/' | Select-Object -ExpandProperty Response | Select * | Format-Table

Invoke-GitHubAPI -ApiEndpoint '/repos/MariusStorhaug/mytest/branches' | Select-Object -ExpandProperty Response


Invoke-GitHubAPI -Method POST -ApiEndpoint '/repos/MariusStorhaug/mytest/git/refs' -Body @{
    ref = 'refs/heads/test'
    sha = 'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0'
}
