$Owner = 'MariusStorhaug'
$Repo = 'ResourceModules'

$Owner = 'PSModule'
$Repo = 'GitHub'


Install-Module -Name GitHub -Force -AllowClobber
Connect-GitHubAccount -Owner $Owner -Repo $Repo -Verbose

Set-GitHubConfig -Owner $Owner -Repo $Repo -Verbose
Get-GitHubConfig
Get-GitHubWorkflow -Verbose

# Disable all workflows
Get-GitHubWorkflow | Where-Object state -EQ 'active' | Disable-GitHubWorkflow

# Enable all workflows
Get-GitHubWorkflow | Where-Object state -NE 'active' | Enable-GitHubWorkflow

# Cancel all started workflows
Get-GitHubWorkflowRun | Where-Object status -NE Completed | Stop-GitHubWorkflowRun

# Remove all completed workflows
Get-GitHubWorkflowRun | Where-Object status -EQ Completed | Remove-GitHubWorkflowRun

# Disable all workflows
Get-GitHubWorkflow | Disable-GitHubWorkflow

# Cancel all started workflows
Get-GitHubWorkflowRun | Where-Object status -NE completed | Stop-GitHubWorkflowRun

Get-GitHubRepoTeams


(Get-GitHubWorkflow).count

Get-GitHubWorkflow | Select-Object -first 1 -Property *

Get-GitHubWorkflow | Select-Object Name, state
Get-GitHubWorkflow | Where-Object state -NE disabled_manually | Disable-GitHubWorkflow
Get-GitHubWorkflow | Disable-GitHubWorkflow
Get-GitHubWorkflow | Select-Object Name, state

Get-GitHubWorkflow | Select-Object Name, state
Get-GitHubWorkflow | Where-Object name -NotLike '.*' | Enable-GitHubWorkflow
Get-GitHubWorkflow | Select-Object Name, state

Get-GitHubWorkflow | Select-Object Name, state
Get-GitHubWorkflow | Enable-GitHubWorkflow
Get-GitHubWorkflow | Select-Object Name, state

Get-GitHubWorkflow | Select-Object Name | Sort-Object Name -Unique
Get-GitHubWorkflow | Get-GitHubWorkflowUsage
(Get-GitHubWorkflow | Get-GitHubWorkflowRun).count
Get-GitHubWorkflowRun | Cancel-GitHubWorkflowRun
Get-GitHubWorkflowRun | Remove-GitHubWorkflowRun

Get-GitHubWorkflowRun | Select-Object -Property name, display_title, created_at, run_started_at, updated_at, @{name = 'duration'; expression = { $_.updated_at - $_.run_started_at } }, @{name = 'wait_duration'; expression = { $_.updated_at - $_.created_at } } | Format-Table -AutoSize

Get-GitHubWorkflowRun | Where-Object run_started_at -le (Get-Date).AddDays(-1) | Remove-GitHubWorkflowRun


Get-GitHubWorkflow | Where-Object name -NotLike '.*' | Start-GitHubWorkflow -Inputs @{
    staticValidation = $true
    deploymentValidation = $false
    removeDeployment = $true
    prerelease = $false
}
