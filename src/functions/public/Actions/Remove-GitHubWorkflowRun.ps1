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
        [Delete a workflow run](https://docs.github.com/rest/actions/workflow-runs#delete-a-workflow-run)
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
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [Alias('ID', 'run_id')]
        [string] $RunID,

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
        APIEndpoint = "repos/$Owner/$Repo/actions/runs/$RunID"
        Method      = 'DELETE'
    }

    if ($PSCmdlet.ShouldProcess("workflow run with ID [$RunID] in [$Owner/$Repo]", 'Delete')) {
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

}
