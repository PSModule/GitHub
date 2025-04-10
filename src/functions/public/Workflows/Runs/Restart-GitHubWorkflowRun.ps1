filter Restart-GitHubWorkflowRun {
    <#
        .SYNOPSIS
        Re-run a workflow

        .DESCRIPTION
        Re-runs your workflow run using its `run_id`. You can also specify a branch or tag name to re-run a workflow run from a branch

        .EXAMPLE
        Start-GitHubWorkflowReRun -Owner 'octocat' -Repository 'Hello-World' -ID 123456789

        .INPUTS
        GitHubWorkflowRun

        .LINK
        https://psmodule.io/GitHub/Functions/Actions/Workflows/Runs/Restart-GitHubWorkflowRun/

        .LINK
        [Re-run a workflow](https://docs.github.com/rest/actions/workflow-runs#re-run-a-workflow)
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
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
            Method      = 'POST'
            APIEndpoint = "/repos/$Owner/$Repository/actions/runs/$ID/rerun"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("workflow with ID [$ID] in [$Owner/$Repository]", 'Re-run')) {
            Write-Verbose "Re-run workflow [$ID] in [$Owner/$Repository]"
            $null = Invoke-GitHubAPI @inputObject
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
