filter Update-GitHubPullRequestByNumber {
    <#
        .SYNOPSIS
        Update a pull request.

        .DESCRIPTION
        Updates a pull request in a repository. You can update the title, body, state, base branch, and maintainer_can_modify properties.
        Draft pull requests are available in public repositories with GitHub Free and GitHub Free for organizations, GitHub Pro, and legacy per-repository billing plans,
        and in public and private repositories with GitHub Team and GitHub Enterprise Cloud.

        .EXAMPLE
        ```powershell
        Update-GitHubPullRequestByNumber -Owner 'octocat' -Repository 'Hello-World' -Number 1 -State 'closed'
        ```

        Closes pull request #1 in the repository.

        .EXAMPLE
        ```powershell
        Update-GitHubPullRequestByNumber -Owner 'octocat' -Repository 'Hello-World' -Number 1 -Title 'New title' -Body 'New description'
        ```

        Updates the title and body of pull request #1.

        .OUTPUTS
        GitHubPullRequest

        .NOTES
        [Update a pull request](https://docs.github.com/rest/pulls/pulls#update-a-pull-request)
    #>
    [OutputType([GitHubPullRequest])]
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The number that identifies the pull request.
        [Parameter(Mandatory)]
        [int] $Number,

        # The title of the pull request.
        [Parameter()]
        [string] $Title,

        # The contents of the pull request body.
        [Parameter()]
        [string] $Body,

        # State of this Pull Request. Either 'open' or 'closed'.
        [Parameter()]
        [ValidateSet('open', 'closed')]
        [string] $State,

        # The name of the branch you want your changes pulled into. This should be an existing branch on the current repository.
        [Parameter()]
        [string] $Base,

        # Indicates whether maintainers can modify the pull request.
        [Parameter()]
        [System.Nullable[bool]] $MaintainerCanModify,

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
            title                 = $Title
            body                  = $Body
            state                 = $State
            base                  = $Base
            maintainer_can_modify = $MaintainerCanModify
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $apiParams = @{
            Method      = 'PATCH'
            APIEndpoint = "/repos/$Owner/$Repository/pulls/$Number"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("Pull request #$Number in $Owner/$Repository", 'Update')) {
            Invoke-GitHubAPI @apiParams | ForEach-Object {
                [GitHubPullRequest]::new($_.Response, $Owner, $Repository)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
