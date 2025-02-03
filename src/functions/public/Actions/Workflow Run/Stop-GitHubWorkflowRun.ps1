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
        [Cancel a workflow run](https://docs.github.com/en/rest/actions/workflow-runs#cancel-a-workflow-run)
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [alias('Cancel-GitHubWorkflowRun')]
    param(
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [Alias('Organization')]
        [Alias('User')]
        [string] $Owner,

        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Repository,

        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [Alias('workflow_id', 'WorkflowID')]
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
            Method      = 'Post'
            APIEndpoint = "/repos/$Owner/$Repository/actions/runs/$ID/cancel"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("$Owner/$Repo/$ID", 'Cancel/Stop workflow run')) {
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
