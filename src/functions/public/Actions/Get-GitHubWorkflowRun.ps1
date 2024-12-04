filter Get-GitHubWorkflowRun {
    <#
        .NOTES
        [List workflow runs for a workflow](https://docs.github.com/rest/actions/workflow-runs?apiVersion=2022-11-28#list-workflow-runs-for-a-workflow)
        [List workflow runs for a repository](https://docs.github.com/rest/actions/workflow-runs?apiVersion=2022-11-28#list-workflow-runs-for-a-repository)
    #>
    [CmdletBinding(DefaultParameterSetName = 'Repo')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    param(
        [Parameter()]
        [string] $Owner,

        [Parameter()]
        [string] $Repo,

        [Parameter(ParameterSetName = 'ByName')]
        [string] $Name,

        [Parameter(ParameterSetName = 'ByID')]
        [string] $ID,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage = 30,

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
        Context     = $Context
        APIEndpoint = $Uri
        Method      = 'GET'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response.workflow_runs
    }

}
