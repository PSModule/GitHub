Function Get-GitHubWorkflowRun {
    <#
        .NOTES
        https://docs.github.com/en/rest/reference/actions#list-workflow-runs-for-a-repository
    #>
    [CmdletBinding()]
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
        [int] $PageSize = 100
    )

    $processedPages = 0
    $workflowRuns = @()
    do {
        $processedPages++
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repo/actions/runs?per_page=$PageSize&page=$processedPages"
        }
        $response = Invoke-GitHubAPI @inputObject
        $workflowRuns += $response.workflows | Where-Object name -Match $name | Where-Object id -Match $id
    } until ($workflowRuns.count -eq $response.total_count)
    $workflowRuns


    do {
        $WorkflowRuns = $response.workflow_runs
        $Results += $WorkflowRuns
    } while ($WorkflowRuns.count -eq 100)
    return $Results | Where-Object Name -Match $Name | Where-Object workflow_id -Match $ID
}
