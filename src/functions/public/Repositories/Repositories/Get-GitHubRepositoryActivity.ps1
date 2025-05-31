filter Get-GitHubRepositoryActivity {
    <#
        .SYNOPSIS
        List repository activities

        .DESCRIPTION
        Lists a detailed history of changes to a repository, such as pushes, merges, force pushes, and branch changes,
        and associates these changes with commits and users.

        For more information about viewing repository activity,
        see "[Viewing activity and data for your repository](https://docs.github.com/repositories/viewing-activity-and-data-for-your-repository)."

        .EXAMPLE
        Get-GitHubRepositoryActivity -Owner 'PSModule' -Name 'GitHub'

        .EXAMPLE
        Get-GitHubRepositoryActivity -Owner 'PSModule' -Name 'GitHub' -Direction 'asc'

        .EXAMPLE
        Get-GitHubRepositoryActivity -Owner 'PSModule' -Name 'GitHub' -PerPage 100

        .EXAMPLE
        Get-GitHubRepositoryActivity -Owner 'PSModule' -Name 'GitHub' -Before '2021-01-01T00:00:00Z'

        .EXAMPLE
        Get-GitHubRepositoryActivity -Owner 'PSModule' -Name 'GitHub' -After '2021-01-01T00:00:00Z'

        .EXAMPLE
        Get-GitHubRepositoryActivity -Owner 'PSModule' -Name 'GitHub' -Ref 'refs/heads/main'

        .EXAMPLE
        Get-GitHubRepositoryActivity -Owner 'PSModule' -Name 'GitHub' -Actor 'octocat'

        .EXAMPLE
        $params = @{
            Owner       = 'PSModule'
            Repo        = 'GitHub'
            TimePeriod  = 'day'
        }
        Get-GitHubRepositoryActivity @params |
            Select-Object -Property @{n='actor';e={$_.actor.login}},activity_type,ref,timestamp

        Gets the activity for the past 24 hours and selects the actor, activity type, ref, and timestamp.

        .EXAMPLE
        Get-GitHubRepositoryActivity -Owner 'PSModule' -Name 'GitHub' -ActivityType 'push','force_push'

        .NOTES
        [List repository activities](https://docs.github.com/rest/repos/repos#list-repository-activities)

        .LINK
        https://psmodule.io/GitHub/Functions/Repositories/Repositories/Get-GitHubRepositoryActivity
    #>
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('Organization')]
        [Alias('User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Name,

        # The direction to sort the results by.
        [Parameter()]
        [ValidateSet('asc', 'desc')]
        [string] $Direction = 'desc',

        # The number of results per page (max 100).
        [Parameter()]
        [System.Nullable[int]] $PerPage,

        # A cursor, as given in the Link header. If specified, the query only searches for results before this cursor.
        [Parameter(ParameterSetName = 'BeforeAfter')]
        [string] $Before,

        # A cursor, as given in the Link header. If specified, the query only searches for results after this cursor.
        [Parameter(ParameterSetName = 'BeforeAfter')]
        [string] $After,

        # The Git reference for the activities you want to list.
        # The ref for a branch can be formatted either as refs/heads/BRANCH_NAME or BRANCH_NAME, where BRANCH_NAME is the name of your branch.
        [Parameter()]
        [string] $Ref,

        # The GitHub username to use to filter by the actor who performed the activity.
        [Parameter()]
        [string] $Actor,

        # The time period to filter by.
        # For example,day will filter for activity that occurred in the past 24 hours,
        # and week will filter for activity that occurred in the past 7 days (168 hours).
        [Parameter()]
        [ValidateSet('day', 'week', 'month', 'quarter', 'year')]
        [Alias('time_period')]
        [string] $TimePeriod,

        # The activity type to filter by.
        # For example,you can choose to filter by 'force_push', to see all force pushes to the repository.
        [Parameter()]
        [ValidateSet('push', 'force_push', 'branch_creation', 'branch_deletion', 'pr_merge', 'merge_queue_merge')]
        [Alias('activity_type')]
        [string] $ActivityType,

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
            direction     = $Direction
            before        = $Before
            after         = $After
            ref           = $Ref
            actor         = $Actor
            time_period   = $TimePeriod
            activity_type = $ActivityType
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Name/activity"
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
