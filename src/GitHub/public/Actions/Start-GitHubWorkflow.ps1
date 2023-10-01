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
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        [Alias('workflow_id')]
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $ID,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [Alias('branch', 'tag')]
        [string] $Ref = 'main',

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

    (Invoke-GitHubAPI @inputObject).Response

}
