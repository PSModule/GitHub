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
        [int] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    $Context = Resolve-GitHubContext -Context $Context

    if ([string]::IsNullOrEmpty($Owner)) {
        $Owner = $Context.Owner
    }
    Write-Debug "Owner : [$($Context.Owner)]"

    if ([string]::IsNullOrEmpty($Repo)) {
        $Repo = $Context.Repo
    }
    Write-Debug "Repo : [$($Context.Repo)]"

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
