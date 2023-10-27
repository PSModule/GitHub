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
        # API Reference
        # https://docs.github.com/free-pro-team@latest/rest/actions/workflows?apiVersion=2022-11-28#create-a-workflow-dispatch-event
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        # The ID of the workflow.
        [Alias('workflow_id')]
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
        [hashtable] $Inputs = @{}
    )

    $body = @{
        ref    = $Ref
        inputs = $Inputs
    }

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/actions/workflows/$ID/dispatches"
        Method      = 'POST'
        Body        = $body
    }

    if ($PSCmdlet.ShouldProcess("workflow with ID [$ID] in [$Owner/$Repo]", 'Start')) {
        (Invoke-GitHubAPI @inputObject).Response
    }

}
