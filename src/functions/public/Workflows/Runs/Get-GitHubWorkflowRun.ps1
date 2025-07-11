﻿filter Get-GitHubWorkflowRun {
    <#
        .SYNOPSIS
        List workflow runs for a repository or a workflow

        .DESCRIPTION
        Lists all workflow runs for a repository or a workflow. You can use parameters to narrow the list of results. For more information about using
        parameters, see [Parameters](https://docs.github.com/rest/guides/getting-started-with-the-rest-api#parameters).
        Anyone with read access to the repository can use this endpoint.
        OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint with a private repository.
        This endpoint will return up to 1,000 results for each search when using the following parameters: `actor`, `branch`, `check_suite_id`, `created`,
        `event`, `head_sha`, `status`.

        .EXAMPLE
        Get-GitHubWorkflowRun -Owner 'owner' -Repository 'repo'

        Lists all workflow runs for a repository.

        .EXAMPLE
        Get-GitHubWorkflowRun -Owner 'owner' -Repository 'repo' -Actor 'octocat' -Branch 'main' -Event 'push' -Status 'success'

        Lists all workflow runs for a repository with the specified actor, branch, event, and status.

        .EXAMPLE
        Get-GitHubWorkflowRun -Owner 'octocat' -Repository 'Hello-World' -ID '42'

        Gets all workflow runs for the workflow with the ID `42` in the repository `Hello-World` owned by `octocat`.

        .EXAMPLE
        Get-GitHubWorkflowRun -Owner 'octocat' -Repository 'Hello-World' -Name 'nightly.yml' -Actor 'octocat' -Branch 'main' -Event 'push' -Status 'success'

        Gets all workflow runs for the workflow with the name `nightly.yml` in the repository `Hello-World` owned by `octocat` that were triggered by
        the user `octocat` on the branch `main` and have the status `success`.

        .INPUTS
        GitHubWorkflow

        .OUTPUTS
        GitHubWorkflowRun

        .LINK
        https://psmodule.io/GitHub/Functions/Workflows/Runs/Get-GitHubWorkflowRun/

        .NOTES
        [List workflow runs for a workflow](https://docs.github.com/rest/actions/workflow-runs#list-workflow-runs-for-a-workflow)
        [List workflow runs for a repository](https://docs.github.com/rest/actions/workflow-runs#list-workflow-runs-for-a-repository)
    #>
    [OutputType([GitHubWorkflowRun])]
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidAssignmentToAutomaticVariable', 'Event',
        Justification = 'A parameter that is used in the api call.')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Owner,

        # The name of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # The ID of the workflow. You can also pass the workflow filename as a string.
        [Parameter(Mandatory, ParameterSetName = 'ByID', ValueFromPipelineByPropertyName)]
        [string] $ID,

        # The name of the workflow.
        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string] $Name,

        # Returns someone's workflow runs. Use the login for the user who created the push associated with the check suite or workflow run.
        [Parameter()]
        [string] $Actor,

        # Returns workflow runs associated with a branch. Use the name of the branch of the `push`.
        [Parameter()]
        [string] $Branch,

        # Returns workflow run triggered by the event you specify. For example, `push`, `pull_request` or `issue`. For more information, see
        # "[Events that trigger workflows](https://docs.github.com/actions/automating-your-workflow-with-github-actions/events-that-trigger-workflows)."
        [Parameter()]
        [string] $Event,

        # Returns workflow runs with the check run status or conclusion that you specify. For example, a conclusion can be success or a status can be
        # `in_progress`. Only GitHub Actions can set a status of `waiting`, `pending`, or `requested`.
        # Can be one of: `completed`, `action_required`, `cancelled`, `failure`, `neutral`, `skipped`, `stale`, `success`, `timed_out`, `in_progress`,
        # `queued`, `requested`, `waiting`, `pending`.
        [Parameter()]
        # [ValidateSet('completed', 'action_required', 'cancelled', 'failure', 'neutral', 'skipped', 'stale', 'success', 'timed_out', 'in_progress',
        #     'queued', 'requested', 'waiting', 'pending')]
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
        [System.Nullable[UInt64]] $CheckSuiteID,

        # Only returns workflow runs that are associated with the specified head_sha.
        [Parameter()]
        [string] $HeadSHA,

        # The number of results per page (max 100).
        [Parameter()]
        [System.Nullable[int]] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $params = @{
            Owner               = $Owner
            Repository          = $Repository
            Actor               = $Actor
            Branch              = $Branch
            Event               = $Event
            Status              = $Status
            Created             = $Created
            ExcludePullRequests = [bool] $ExcludePullRequests
            CheckSuiteID        = $CheckSuiteID
            HeadSHA             = $HeadSHA
            PerPage             = $PerPage
            Context             = $Context
        }
        $params | Remove-HashtableEntry -NullOrEmptyValues

        Write-Debug "ParameterSet: $($PSCmdlet.ParameterSetName)"
        switch ($PSCmdlet.ParameterSetName) {
            'ByID' {
                $params['ID'] = $ID
                Get-GitHubWorkflowRunByWorkflow @params
            }

            'ByName' {
                $params['ID'] = (Get-GitHubWorkflow -Owner $Owner -Repository $Repository -Name $Name -Context $Context).ID
                Get-GitHubWorkflowRunByWorkflow @params
            }

            default {
                Get-GitHubWorkflowRunByRepo @params
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
