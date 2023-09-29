function Start-GitHubWorkflowReRun {
    <#
        .SYNOPSIS
        Short description

        .DESCRIPTION
        Long description

        .PARAMETER Owner
        Parameter description

        .PARAMETER Repo
        Parameter description

        .PARAMETER ID
        Parameter description

        .EXAMPLE
        An example

        .NOTES
        https://docs.github.com/en/rest/reference/actions#re-run-a-workflow
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
        [string] $ID
    )

    begin {}

    process {

        $inputObject = @{
            Method      = 'POST'
            APIEndpoint = "/repos/$Owner/$Repo/actions/runs/$ID/rerun"
        }

        Invoke-GitHubAPI @inputObject

    }

    end {}
}
