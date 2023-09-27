# API Reference
# https://docs.github.com/en/rest/reference/actions#re-run-a-workflow
function Start-GitHubWorkflowReRun {
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
        $response = Invoke-GitHubAPI @inputObject

        return $response
    }

    end {}
}
