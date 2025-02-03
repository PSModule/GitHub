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
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [Alias('Organization')]
        [Alias('User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Repository,

        # The unique identifier of the workflow run.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [Alias('run_id', 'RunID')]
        [string] $ID,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $inputObject = @{
            Method      = 'DELETE'
            APIEndpoint = "repos/$Owner/$Repository/actions/runs/$ID"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("$Owner/$Repo/$ID", 'Delete workflow run')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
