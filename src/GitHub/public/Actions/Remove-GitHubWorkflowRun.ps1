filter Remove-GitHubWorkflowRun {
    <#
        .SYNOPSIS
        Delete a workflow run

        .DESCRIPTION
        Delete a specific workflow run. Anyone with write access to the repository can use this endpoint. If the repository is
        private you must use an access token with the `repo` scope. GitHub Apps must have the `actions:write` permission to use
        this endpoint.

        .EXAMPLE
        Remove-GitHubWorkflowRun -Owner 'octocat' -Repo 'Hello-World' -ID 123456789

        Deletes the workflow run with the ID 123456789 from the 'Hello-World' repository owned by 'octocat'

        .NOTES
        https://docs.github.com/rest/actions/workflow-runs#delete-a-workflow-run
    #>
    [CmdletBinding()]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        # The unique identifier of the workflow run.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [Alias('ID', 'run_id')]
        [string] $RunID
    )

    $inputObject = @{
        APIEndpoint = "repos/$Owner/$Repo/actions/runs/$ID"
        Method      = 'DELETE'
    }

    (Invoke-GitHubAPI @inputObject).Response

}
