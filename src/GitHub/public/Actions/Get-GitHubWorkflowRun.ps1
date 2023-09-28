Function Get-GitHubWorkflowRun {
    <#
        .NOTES
        https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#list-workflow-runs-for-a-workflow
        https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#list-workflow-runs-for-a-repository
    #>
    [CmdletBinding(DefaultParameterSetName = 'Repo')]
    param (
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        [Parameter(ParameterSetName = 'ByName')]
        [string] $Name,

        [Parameter(ParameterSetName = 'ByID')]
        [string] $ID,

        [Parameter()]
        [int] $PerPage = 100
    )

    begin {}

    process {

        $body = @{
            per_page = $PerPage
        }

        if ($Name) {
            $ID = (Get-GitHubWorkflow -Owner $Owner -Repo $Repo -Name $Name).id
        }

        if ($ID) {
            $Uri = "/repos/$Owner/$Repo/actions/workflows/$ID/runs"
        } else {
            $Uri = "/repos/$Owner/$Repo/actions/runs"
        }

        $inputObject = @{
            APIEndpoint = $Uri
            Method      = 'GET'
            Body        = $body
        }

        Invoke-GitHubAPI @inputObject | Select-Object -ExpandProperty workflow_runs | Write-Output

    }

    end {}

}
