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
        [Parameter()]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo,

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
        [hashtable] $Inputs = @{},

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

    $body = @{
        ref    = $Ref
        inputs = $Inputs
    }

    $inputObject = @{
        Context     = $Context
        APIEndpoint = "/repos/$Owner/$Repo/actions/workflows/$ID/dispatches"
        Method      = 'POST'
        Body        = $body
    }

    if ($PSCmdlet.ShouldProcess("workflow with ID [$ID] in [$Owner/$Repo]", 'Start')) {
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

}
