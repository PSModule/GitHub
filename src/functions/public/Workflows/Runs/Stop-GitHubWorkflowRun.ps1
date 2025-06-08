filter Stop-GitHubWorkflowRun {
    <#
        .SYNOPSIS
        Cancel a workflow run

        .DESCRIPTION
        Cancels a workflow run using its `run_id`. You can use this endpoint to cancel a workflow run that is in progress or waiting

        .EXAMPLE
        Stop-GitHubWorkflowRun -Owner 'octocat' -Repository 'Hello-World' -ID 123456789

        Cancels the workflow run with the ID 123456789 from the 'Hello-World' repository owned by 'octocat'.

        .INPUTS
        GitHubWorkflowRun

        .LINK
        https://psmodule.io/GitHub/Functions/Workflows/Runs/Stop-GitHubWorkflowRun/

        .NOTES
        [Cancel a workflow run](https://docs.github.com/rest/actions/workflow-runs#cancel-a-workflow-run)
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [alias('Cancel-GitHubWorkflowRun')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # The unique identifier of the workflow run.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $ID,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context -Anonymous $Anonymous
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $inputObject = @{
            Method      = 'POST'
            APIEndpoint = "/repos/$Owner/$Repository/actions/runs/$ID/cancel"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("$Owner/$Repository/$ID", 'Cancel/Stop workflow run')) {
            Write-Verbose "Cancelled workflow run [$ID] in [$Owner/$Repository]"
            $null = Invoke-GitHubAPI @inputObject
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
