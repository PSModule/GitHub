# Gets all workflows in the PSModule organization and starts the 'Nightly Run' workflow
'PSModule' | Get-GitHubOrganization | Get-GitHubRepository | Get-GitHubWorkflow -Name 'Nightly Run'
'PSModule' | Get-GitHubOrganization | Get-GitHubRepository | Get-GitHubWorkflow -Name 'Nightly Run' | Start-GitHubWorkflow


'PSModule' | Get-GitHubOrganization | Get-GitHubRepository | Get-GitHubWorkflow -Name 'Nightly Run' | ForEach-Object {
    $_ | Get-GitHubWorkflowRun | Select-Object -First 1
}
