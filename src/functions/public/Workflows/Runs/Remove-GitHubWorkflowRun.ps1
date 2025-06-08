filter Remove-GitHubWorkflowRun {
    <#
        .SYNOPSIS
        Delete a workflow run

        .DESCRIPTION
        Delete a specific workflow run. Anyone with write access to the repository can use this endpoint. If the repository is
        private you must use an access token with the `repo` scope. GitHub Apps must have the `actions:write` permission to use
        this endpoint.

        .EXAMPLE
        Remove-GitHubWorkflowRun -Owner 'octocat' -Repository 'Hello-World' -ID 123456789

        Deletes the workflow run with the ID 123456789 from the 'Hello-World' repository owned by 'octocat'

        .INPUTS
        GitHubWorkflowRun

        .LINK
        https://psmodule.io/GitHub/Functions/Workflows/Runs/Remove-GitHubWorkflowRun/

        .NOTES
        [Delete a workflow run](https://docs.github.com/rest/actions/workflow-runs#delete-a-workflow-run)
    #>
    [CmdletBinding(SupportsShouldProcess)]
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
            Method      = 'DELETE'
            APIEndpoint = "repos/$Owner/$Repository/actions/runs/$ID"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("$Owner/$Repository/$ID", 'Delete workflow run')) {
            Write-Verbose "Deleted workflow run [$ID] in [$Owner/$Repository]"
            $null = Invoke-GitHubAPI @inputObject
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
