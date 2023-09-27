function Stop-GitHubWorkflowRun {
    [CmdletBinding()]
    [alias('Cancel-GitHubWorkflowRun')]
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
        # API Reference
        # https://docs.github.com/en/rest/reference/actions#cancel-a-workflow-run
        $inputObject = @{
            Method      = 'POST'
            APIEndpoint = "/repos/$Owner/$Repo/actions/runs/$ID/cancel"
        }
        $response = Invoke-GitHubAPI @inputObject

        $response
    }

    end {}
}
