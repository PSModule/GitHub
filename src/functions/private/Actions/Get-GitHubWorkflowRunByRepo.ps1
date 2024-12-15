filter Get-GitHubWorkflowRunByRepo {
    <#
        .SYNOPSIS
        List workflow runs for a repository

        .DESCRIPTION
        Lists all workflow runs for a repository. You can use parameters to narrow the list of results. For more information about using parameters,
        see [Parameters](https://docs.github.com/rest/guides/getting-started-with-the-rest-api#parameters).
        Anyone with read access to the repository can use this endpoint.
        OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint with a private repository.
        This endpoint will return up to 1,000 results for each search when using the following parameters: `actor`, `branch`, `check_suite_id`,
        `created`, `event`, `head_sha`, `status`.

        .EXAMPLE
        Get-GitHubWorkflowRunByRepo -Owner 'owner' -Repo 'repo'

        Lists all workflow runs for a repository.

        .EXAMPLE
        Get-GitHubWorkflowRunByRepo -Owner 'owner' -Repo 'repo' -Actor 'octocat' -Branch 'main' -Event 'push' -Status 'success'

        Lists all workflow runs for a repository with the specified actor, branch, event, and status.

        .NOTES
        [List workflow runs for a repository](https://docs.github.com/rest/actions/workflow-runs?apiVersion=2022-11-28#list-workflow-runs-for-a-repository)
    #>
    [CmdletBinding(DefaultParameterSetName = 'Repo')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidAssignmentToAutomaticVariable', 'Event',
        Justification = 'A parameter that is used in the api call.')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repo,

        # Returns someone's workflow runs. Use the login for the user who created the push associated with the check suite or workflow run.
        [Parameter()]
        [string] $Actor,

        # Returns workflow runs associated with a branch. Use the name of the branch of the `push`.
        [Parameter()]
        [string] $Branch,

        # Returns workflow run triggered by the event you specify. For example, `push`, `pull_request` or `issue`. For more information, see
        # "[Events that trigger workflows])(https://docs.github.com/actions/automating-your-workflow-with-github-actions/events-that-trigger-workflows)."
        [Parameter()]
        [string] $Event,

        # Returns workflow runs with the check run status or conclusion that you specify. For example, a conclusion can be success or a status can be
        # `in_progress`. Only GitHub Actions can set a status of `waiting`, `pending`, or `requested`.
        # Can be one of: `completed`, `action_required`, `cancelled`, `failure`, `neutral`, `skipped`, `stale`, `success`, `timed_out`, `in_progress`,
        # `queued`, `requested`, `waiting`, `pending`.
        [Parameter()]
        [ValidateSet('completed', 'action_required', 'cancelled', 'failure', 'neutral', 'skipped', 'stale', 'success', 'timed_out', 'in_progress',
            'queued', 'requested', 'waiting', 'pending')]
        [string] $Status,

        # Returns workflow runs created within the given date-time range. For more information on the syntax, see
        # "[Understanding the search syntax](https://docs.github.com/search-github/getting-started-with-searching-on-github/understanding-the-search-syntax#query-for-dates)."
        [Parameter()]
        [datetime] $Created,

        # If `true` pull requests are omitted from the response (empty array).
        [Parameter()]
        [switch] $ExcludePullRequests,

        # Returns workflow runs with the check_suite_id that you specify.
        [Parameter()]
        [int] $CheckSuiteID,

        # Only returns workflow runs that are associated with the specified head_sha.
        [Parameter()]
        [string] $HeadSHA,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(0, 100)]
        [int] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
        if ([string]::IsNullOrEmpty($Owner)) {
            $Owner = $Context.Owner
        }
        Write-Debug "Owner : [$($Context.Owner)]"

        if ([string]::IsNullOrEmpty($Repo)) {
            $Repo = $Context.Repo
        }
        Write-Debug "Repo : [$($Context.Repo)]"
    }

    process {
        try {
            $body = @{
                actor                 = $Actor
                branch                = $Branch
                event                 = $Event
                status                = $Status
                created               = $Created
                exclude_pull_requests = $ExcludePullRequests
                check_suite_id        = $CheckSuiteID
                head_sha              = $HeadSHA
                per_page              = $PerPage
            }

            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/repos/$Owner/$Repo/actions/runs"
                Method      = 'GET'
                Body        = $body
            }

            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response.workflow_runs
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}
