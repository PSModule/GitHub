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
        Get-GitHubRepositoryActivity -Owner 'PSModule' -Repo 'GitHub'

        .EXAMPLE
        Get-GitHubRepositoryActivity -Owner 'PSModule' -Repo 'GitHub' -Direction 'asc'

        .EXAMPLE
        Get-GitHubRepositoryActivity -Owner 'PSModule' -Repo 'GitHub' -PerPage 100

        .EXAMPLE
        Get-GitHubRepositoryActivity -Owner 'PSModule' -Repo 'GitHub' -Before '2021-01-01T00:00:00Z'

        .EXAMPLE
        Get-GitHubRepositoryActivity -Owner 'PSModule' -Repo 'GitHub' -After '2021-01-01T00:00:00Z'

        .EXAMPLE
        Get-GitHubRepositoryActivity -Owner 'PSModule' -Repo 'GitHub' -Ref 'refs/heads/main'

        .EXAMPLE
        Get-GitHubRepositoryActivity -Owner 'PSModule' -Repo 'GitHub' -Actor 'octocat'

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
        Get-GitHubRepositoryActivity -Owner 'PSModule' -Repo 'GitHub' -ActivityType 'push','force_push'

        .NOTES
        [List repository activities](https://docs.github.com/rest/repos/repos#list-repository-activities)

    #>
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo,

        # The direction to sort the results by.
        [Parameter()]
        [ValidateSet('asc', 'desc')]
        [string] $Direction = 'desc',

        # The number of results per page (max 100).
        # Default: 30
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage,

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

    $Context = Resolve-GitHubContext -Context $Context

    if ([string]::IsNullOrEmpty($Owner)) {
        $Owner = $Context.Owner
    }
    Write-Debug "Owner : [$($Context.Owner)]"

    if ([string]::IsNullOrEmpty($Repo)) {
        $Repo = $Context.Repo
    }
    Write-Debug "Repo : [$($Context.Repo)]"

    $PSCmdlet.MyInvocation.MyCommand.Parameters.GetEnumerator() | ForEach-Object {
        $paramName = $_.Key
        $paramDefaultValue = Get-Variable -Name $paramName -ValueOnly -ErrorAction SilentlyContinue
        $providedValue = $PSBoundParameters[$paramName]
        Write-Verbose "[$paramName]"
        Write-Verbose "  - Default:  [$paramDefaultValue]"
        Write-Verbose "  - Provided: [$providedValue]"
        if (-not $PSBoundParameters.ContainsKey($paramName) -and ($null -ne $paramDefaultValue)) {
            Write-Verbose '  - Using default value'
            $PSBoundParameters[$paramName] = $paramDefaultValue
        } else {
            Write-Verbose '  - Using provided value'
        }
    }

    $body = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable -NameCasingStyle snake_case
    Remove-HashtableEntry -Hashtable $body -RemoveNames 'Owner', 'Repo' -RemoveTypes 'SwitchParameter'

    $inputObject = @{
        Context     = $Context
        APIEndpoint = "/repos/$Owner/$Repo/activity"
        Method      = 'GET'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
