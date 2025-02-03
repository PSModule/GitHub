filter Start-GitHubWorkflow {
    <#
        .SYNOPSIS
        Start a workflow run using the workflow's ID.

        .DESCRIPTION
        Start a workflow run using the workflow's ID.

        .EXAMPLE
        Get-GitHubWorkflow | Where-Object name -NotLike '.*' | Start-GitHubWorkflow -Inputs @{
            staticValidation = $true
            deploymentValidation = $false
            removeDeployment = $true
            prerelease = $false
        }

        .NOTES
        [Create a workflow dispatch event](https://docs.github.com/en/rest/actions/workflows#create-a-workflow-dispatch-event)
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

        # The ID of the workflow.
        [Alias('workflow_id', 'WorkflowID')]
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $ID,

        # The reference of the workflow run. The reference can be a branch, tag, or a commit SHA.
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Alias('branch', 'tag')]
        [string] $Ref = 'main',

        # Input parameters for the workflow run. You can use the inputs and payload keys to pass custom data to your workflow.
        [Parameter()]
        [hashtable] $Inputs = @{},

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
        $body = @{
            ref    = $Ref
            inputs = $Inputs
        }

        $inputObject = @{
            Context     = $Context
            APIEndpoint = "/repos/$Owner/$Repository/actions/workflows/$ID/dispatches"
            Method      = 'POST'
            Body        = $body
        }

        if ($PSCmdlet.ShouldProcess("$Owner/$Repo/$ID", 'Start workflow')) {
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
