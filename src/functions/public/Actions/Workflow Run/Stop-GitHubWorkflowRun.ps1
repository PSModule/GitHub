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
        [Cancel a workflow run](https://docs.github.com/rest/actions/workflow-runs#cancel-a-workflow-run)
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [alias('Cancel-GitHubWorkflowRun')]
    param(
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
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
        [Alias('DatabaseID')]
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
            APIEndpoint = "/repos/$Owner/$Repository/actions/runs/$ID/cancel"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("$Owner/$Repository/$ID", 'Cancel/Stop workflow run')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
                Write-Verbose "Cancelled workflow run [$ID] in [$Owner/$Repository]"
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
