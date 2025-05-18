filter Get-GitHubRepositoryRuleSuiteList {
    <#
        .SYNOPSIS
        List repository rule suites

        .DESCRIPTION
        Lists suites of rule evaluations at the repository level.
        For more information, see"[Managing rulesets for a repository](https://docs.github.com/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/managing-rulesets-for-a-repository#viewing-insights-for-rulesets)."

        .EXAMPLE
        $params = @{
            Owner           = 'octocat'
            Repo            = 'hello-world'
            Ref             = 'main'
            TimePeriod      = 'day'
            ActorName       = 'octocat'
            RuleSuiteResult = 'all'
        }
        Get-GitHubRepositoryRuleSuiteList @params

        Gets a list of rule suites for the main branch of the hello-world repository owned by octocat.

        .NOTES
        [List repository rule suites](https://docs.github.com/rest/repos/rule-suites#list-repository-rule-suites)
    #>
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Long links')]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('Organization')]
        [Alias('User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The name of the ref. Cannot contain wildcard characters.
        # When specified, only rule evaluations triggered for this ref will be returned.
        [Parameter()]
        [string] $Ref,

        # The time period to filter by.
        # For example,day will filter for rule suites that occurred in the past 24 hours,
        # and week will filter for insights that occurred in the past 7 days (168 hours).
        [Parameter()]
        [ValidateSet('hour', 'day', 'week', 'month')]
        [string] $TimePeriod = 'day',

        # The handle for the GitHub user account to filter on. When specified, only rule evaluations triggered by this actor will be returned.
        [Parameter()]
        [string] $ActorName,

        # The rule results to filter on. When specified, only suites with this result will be returned.
        [Parameter()]
        [ValidateSet('pass', 'fail', 'bypass', 'all')]
        [string] $RuleSuiteResult = 'all',

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [System.Nullable[int]] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $body = @{
            ref               = $Ref
            time_period       = $TimePeriod
            actor_name        = $ActorName
            rule_suite_result = $RuleSuiteResult
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/rulesets/rule-suites"
            Body        = $body
            PerPage     = $PerPage
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
