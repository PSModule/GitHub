function Remove-GitHubWorkflowRun {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $ID
    )

    begin {}

    process {

        $inputObject = @{
            APIEndpoint = "repos/$Owner/$Repo/actions/runs/$ID"
            Method      = 'DELETE'
        }

        (Invoke-GitHubAPI @inputObject).Response

    }

    end {}
}
