filter Stop-GitHubWorkflowRun {
    <#
        .SYNOPSIS
        Cancel a workflow run

        .DESCRIPTION
        Cancels a workflow run using its `run_id`. You can use this endpoint to cancel a workflow run that is in progress or waiting

        .EXAMPLE
        Stop-GitHubWorkflowRun -Owner 'octocat' -Repo 'Hello-World' -ID 123456789

        Cancels the workflow run with the ID 123456789 from the 'Hello-World' repository owned by 'octocat'

        .NOTES
        https://docs.github.com/rest/reference/actions#cancel-a-workflow-run
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [alias('Cancel-GitHubWorkflowRun')]
    param (
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        [Alias('workflow_id')]
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $ID
    )


    $inputObject = @{
        Method      = 'POST'
        APIEndpoint = "/repos/$Owner/$Repo/actions/runs/$ID/cancel"
    }

    if ($PSCmdlet.ShouldProcess("workflow run with ID [$ID] in [$Owner/$Repo]", 'Cancel/Stop')) {
        (Invoke-GitHubAPI @inputObject).Response
    }

}
