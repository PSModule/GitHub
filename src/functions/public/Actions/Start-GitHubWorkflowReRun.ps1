filter Start-GitHubWorkflowReRun {
    <#
        .SYNOPSIS
        Re-run a workflow

        .DESCRIPTION
        Re-runs your workflow run using its `run_id`. You can also specify a branch or tag name to re-run a workflow run from a branch

        .EXAMPLE
        Start-GitHubWorkflowReRun -Owner 'octocat' -Repo 'Hello-World' -ID 123456789

        .NOTES
        [Re-run a workflow](https://docs.github.com/en/rest/actions/workflow-runs#re-run-a-workflow)
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo,

        # The unique identifier of the workflow run.
        [Alias('workflow_id')]
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $ID,

        # The context to run the command in.
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    $contextObj = Get-GitHubContext -Context $Context
    if (-not $contextObj) {
        throw 'Log in using Connect-GitHub before running this command.'
    }
    Write-Debug "Context: [$Context]"

    if ([string]::IsNullOrEmpty($Owner)) {
        $Owner = $contextObj.Owner
    }
    Write-Debug "Owner : [$($contextObj.Owner)]"

    if ([string]::IsNullOrEmpty($Repo)) {
        $Repo = $contextObj.Repo
    }
    Write-Debug "Repo : [$($contextObj.Repo)]"

    $inputObject = @{
        Context     = $Context
        Method      = 'POST'
        APIEndpoint = "/repos/$Owner/$Repo/actions/runs/$ID/rerun"
    }

    if ($PSCmdlet.ShouldProcess("workflow with ID [$ID] in [$Owner/$Repo]", 'Re-run')) {
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

}
