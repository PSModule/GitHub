filter Start-GitHubWorkflowReRun {
    <#
        .SYNOPSIS
        Re-run a workflow

        .DESCRIPTION
        Re-runs your workflow run using its `run_id`. You can also specify a branch or tag name to re-run a workflow run from a branch

        .EXAMPLE
        Start-GitHubWorkflowReRun -Owner 'octocat' -Repo 'Hello-World' -ID 123456789

        .NOTES
        https://docs.github.com/rest/reference/actions#re-run-a-workflow
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        # The unique identifier of the workflow run.
        [Alias('workflow_id')]
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $ID
    )

    $inputObject = @{
        Method      = 'POST'
        APIEndpoint = "/repos/$Owner/$Repo/actions/runs/$ID/rerun"
    }

    if ($PSCmdlet.ShouldProcess("workflow with ID [$ID] in [$Owner/$Repo]", 'Re-run')) {
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

}
