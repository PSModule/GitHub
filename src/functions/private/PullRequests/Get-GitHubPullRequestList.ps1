filter Get-GitHubPullRequestList {
    <#
        .SYNOPSIS
        List pull requests in a repository.

        .DESCRIPTION
        Lists pull requests in a repository. You can use parameters to narrow the list of results.
        Anyone with read access to the repository can use this endpoint.

        .EXAMPLE
        ```powershell
        Get-GitHubPullRequestList -Owner 'octocat' -Repository 'Hello-World'
        ```

        Lists all pull requests in the repository.

        .EXAMPLE
        ```powershell
        Get-GitHubPullRequestList -Owner 'octocat' -Repository 'Hello-World' -State 'open' -Head 'octocat:new-feature'
        ```

        Lists all open pull requests in the repository from the specified head branch.

        .OUTPUTS
        GitHubPullRequest

        .NOTES
        [List pull requests](https://docs.github.com/rest/pulls/pulls#list-pull-requests)
    #>
    [OutputType([GitHubPullRequest])]
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # Either 'open', 'closed', or 'all' to filter by state. Default: open
        [Parameter()]
        [ValidateSet('open', 'closed', 'all')]
        [string] $State = 'open',

        # Filter pulls by head user or head organization and branch name in the format of 'user:ref-name' or 'organization:ref-name'.
        # For example: 'github:new-script-format' or 'octocat:test-branch'.
        [Parameter()]
        [string] $Head,

        # Filter pulls by base branch name. Example: 'gh-pages'.
        [Parameter()]
        [string] $Base,

        # What to sort results by. Can be either 'created', 'updated', 'popularity' (comment count) or 'long-running' (age, filtering by pulls updated in the last month). Default: created
        [Parameter()]
        [ValidateSet('created', 'updated', 'popularity', 'long-running')]
        [string] $Sort = 'created',

        # The direction of the sort. Can be either 'asc' or 'desc'. Default: desc when sort is 'created' or sort is not specified, otherwise asc.
        [Parameter()]
        [ValidateSet('asc', 'desc')]
        [string] $Direction,

        # The number of results per page (max 100).
        [Parameter()]
        [System.Nullable[int]] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $body = @{
            state     = $State
            head      = $Head
            base      = $Base
            sort      = $Sort
            direction = $Direction
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/pulls"
            Body        = $body
            PerPage     = $PerPage
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            $_.Response | ForEach-Object {
                [GitHubPullRequest]::new($_, $Owner, $Repository)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
