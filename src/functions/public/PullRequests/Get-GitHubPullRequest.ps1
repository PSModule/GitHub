filter Get-GitHubPullRequest {
    <#
        .SYNOPSIS
        Gets pull requests from a repository.

        .DESCRIPTION
        Gets pull requests from a repository. You can list all pull requests, filter by state, head branch, base branch,
        or get a specific pull request by number.

        .EXAMPLE
        ```powershell
        Get-GitHubPullRequest -Owner 'octocat' -Repository 'Hello-World'
        ```

        Gets all open pull requests in the repository.

        .EXAMPLE
        ```powershell
        Get-GitHubPullRequest -Owner 'octocat' -Repository 'Hello-World' -Number 1
        ```

        Gets pull request #1 from the repository.

        .EXAMPLE
        ```powershell
        Get-GitHubPullRequest -Owner 'octocat' -Repository 'Hello-World' -State 'closed'
        ```

        Gets all closed pull requests in the repository.

        .EXAMPLE
        ```powershell
        Get-GitHubPullRequest -Owner 'octocat' -Repository 'Hello-World' -Head 'octocat:new-feature'
        ```

        Gets all pull requests from the 'new-feature' branch of the 'octocat' user.

        .EXAMPLE
        ```powershell
        Get-GitHubPullRequest -Owner 'octocat' -Repository 'Hello-World' -Base 'main' -State 'open'
        ```

        Gets all open pull requests targeting the 'main' branch.

        .INPUTS
        None

        .OUTPUTS
        GitHubPullRequest

        .LINK
        https://docs.github.com/rest/pulls/pulls
    #>
    [OutputType([GitHubPullRequest])]
    [CmdletBinding(DefaultParameterSetName = 'List')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'List')]
        [Parameter(Mandatory, ParameterSetName = 'ByNumber')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'List')]
        [Parameter(Mandatory, ParameterSetName = 'ByNumber')]
        [string] $Repository,

        # The number that identifies the pull request.
        [Parameter(Mandatory, ParameterSetName = 'ByNumber')]
        [int] $Number,

        # Either 'open', 'closed', or 'all' to filter by state. Default: open
        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('open', 'closed', 'all')]
        [string] $State = 'open',

        # Filter pulls by head user or head organization and branch name in the format of 'user:ref-name' or 'organization:ref-name'.
        # For example: 'github:new-script-format' or 'octocat:test-branch'.
        [Parameter(ParameterSetName = 'List')]
        [string] $Head,

        # Filter pulls by base branch name. Example: 'gh-pages'.
        [Parameter(ParameterSetName = 'List')]
        [string] $Base,

        # What to sort results by. Can be either 'created', 'updated', 'popularity' (comment count) or 'long-running' (age, filtering by pulls updated in the last month). Default: created
        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('created', 'updated', 'popularity', 'long-running')]
        [string] $Sort = 'created',

        # The direction of the sort. Can be either 'asc' or 'desc'. Default: desc when sort is 'created' or sort is not specified, otherwise asc.
        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('asc', 'desc')]
        [string] $Direction,

        # The number of results per page (max 100).
        [Parameter(ParameterSetName = 'List')]
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
        switch ($PSCmdlet.ParameterSetName) {
            'List' {
                $params = @{
                    Owner      = $Owner
                    Repository = $Repository
                    State      = $State
                    Head       = $Head
                    Base       = $Base
                    Sort       = $Sort
                    Direction  = $Direction
                    PerPage    = $PerPage
                    Context    = $Context
                }
                $params | Remove-HashtableEntry -NullOrEmptyValues
                Get-GitHubPullRequestList @params
            }
            'ByNumber' {
                $params = @{
                    Owner      = $Owner
                    Repository = $Repository
                    Number     = $Number
                    Context    = $Context
                }
                try {
                    Get-GitHubPullRequestByNumber @params
                } catch {
                    Write-Error $_
                    return
                }
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
