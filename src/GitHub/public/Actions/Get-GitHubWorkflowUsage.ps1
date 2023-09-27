Function Get-GitHubWorkflowUsage {
    [CmdletBinding(
        DefaultParameterSetName = 'ByName'
    )]
    param (
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string[]] $ID
    )

    begin {}

    process {
        # API Reference
        # https://docs.github.com/en/rest/reference/actions#get-workflow-usage


        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repo/actions/workflows/$ID/timing"
        }
        $response = Invoke-GitHubAPI @inputObject

        $response #billable?
    }

    end {}
}
