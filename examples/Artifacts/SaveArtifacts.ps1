$modulesPath = $env:PSModulePath -Split [IO.Path]::PathSeparator | Select-Object -First 1
Get-GitHubArtifact -Owner PSModule -Repository GitHub -Name module |
    Save-GitHubArtifact -Path $modulesPath -Extract -Force

New-GitHubRepository -Name mytest -AllowSquashMerge -AddReadme -License mit -Gitignore VisualStudio
Get-GitHubRepository -Username MariusStorhaug -Name mytest | Remove-GitHubRepository -Confirm:$false
New-GitHubRelease -Owner MariusStorhaug -Repository mytest -Name 'mytest' -Tag 'v1.0' -Body 'Initial release' -Debug

Get-GitHubOrganization -Name PSModule | Get-GitHubRepository -Name GitHub | Get-GitHubWorkflow -Name Process-PSModule | Get-gitHubWorkflowRun
Get-GitHubOrganization | Get-GitHubRepository -Name GitHub | Get-GitHubRelease
Get-GitHubUser | Get-GitHubRepository -Name mytest | Get-GitHubRelease

Get-GitHubRelease -Owner PSModule -Repository GitHub


Get-GitHubUser
