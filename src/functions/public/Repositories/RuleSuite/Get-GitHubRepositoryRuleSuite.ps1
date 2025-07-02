filter Get-GitHubRepositoryRuleSuite {
    <#
        .SYNOPSIS
        List repository rule suites or a rule suite by ID.

        .DESCRIPTION
        Lists suites of rule evaluations at the repository level.
        If an ID is specified, gets information about a suite of rule evaluations from within a repository.
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
        Get-GitHubRepositoryRuleSuite @params

        Gets a list of rule suites for the main branch of the hello-world repository owned by octocat.

        .EXAMPLE
        Get-GitHubRepositoryRuleSuite -Owner 'octocat' -Repository 'hello-world' -RuleSuiteId 123456789

        Gets information about a suite of rule evaluations with ID 123456789 from within the octocat/hello-world repository.

        .NOTES
        [List repository rule suites](https://docs.github.com/rest/repos/rule-suites#list-repository-rule-suites)
        [Get a repository rule suite](https://docs.github.com/rest/repos/rule-suites#get-a-repository-rule-suite)

        .LINK
        https://psmodule.io/GitHub/Functions/Repositories/RuleSuite/Get-GitHubRepositoryRuleSuite
    #>
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Long links')]
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
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
        [System.Nullable[int]] $PerPage,

        # The unique identifier of the rule suite result. To get this ID, you can use GET /repos/ { owner }/ { repo }/rulesets/rule-suites for repositories and GET /orgs/ { org }/rulesets/rule-suites for organizations.
        [Parameter(
            Mandatory,
            ParameterSetName = 'ById'
        )]
        [int] $RuleSuiteId,

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
            Context    = $Context
            Owner      = $Owner
            Repository = $Repository
        }

        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                $params += @{
                    RuleSuiteId = $RuleSuiteId
                }
                Get-GitHubRepositoryRuleSuiteById @params
            }
            default {
                $params += @{
                    Ref             = $Ref
                    TimePeriod      = $TimePeriod
                    ActorName       = $ActorName
                    RuleSuiteResult = $RuleSuiteResult
                    PerPage         = $PerPage
                }
                Get-GitHubRepositoryRuleSuiteList @params
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
