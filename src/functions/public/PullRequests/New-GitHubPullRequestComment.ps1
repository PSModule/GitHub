filter New-GitHubPullRequestComment {
    <#
        .SYNOPSIS
        Create a comment on a pull request.

        .DESCRIPTION
        Creates a comment on a pull request. This uses the GitHub Issues API since pull requests are considered
        issues in the GitHub API. This is for general comments on the pull request, not review comments on
        specific lines of code.

        .EXAMPLE
        ```powershell
        New-GitHubPullRequestComment -Owner 'octocat' -Repository 'Hello-World' -Number 1 -Body 'Great work!'
        ```

        Adds a comment to pull request #1.

        .EXAMPLE
        ```powershell
        New-GitHubPullRequestComment -Owner 'octocat' -Repository 'Hello-World' -Number 1 -Body 'This PR is superseded by #123'
        ```

        Adds a comment to pull request #1 indicating it's been superseded.

        .EXAMPLE
        ```powershell
        Get-GitHubPullRequest -Owner 'octocat' -Repository 'Hello-World' -Head 'octocat:old-feature' | New-GitHubPullRequestComment -Body 'Closing due to inactivity'
        ```

        Adds a comment to all pull requests from the 'old-feature' branch using pipeline input.

        .INPUTS
        GitHubPullRequest

        .OUTPUTS
        PSCustomObject

        .LINK
        https://docs.github.com/rest/issues/comments#create-an-issue-comment
    #>
    [OutputType([PSCustomObject])]
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # The number that identifies the pull request.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int] $Number,

        # The contents of the comment.
        [Parameter(Mandatory)]
        [string] $Body,

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
            Owner      = $Owner
            Repository = $Repository
            Number     = $Number
            Body       = $Body
            Context    = $Context
        }

        if ($DebugPreference -eq 'Continue') {
            Write-Debug "Creating comment on pull request #$Number in $Owner/$Repository"
            [pscustomobject]$params | Format-List | Out-String -Stream | ForEach-Object { Write-Debug $_ }
        }

        New-GitHubPullRequestCommentByNumber @params
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
