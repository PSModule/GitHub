filter New-GitHubPullRequestCommentByNumber {
    <#
        .SYNOPSIS
        Create an issue comment on a pull request.

        .DESCRIPTION
        This endpoint creates a comment on a pull request using the GitHub Issues API. Pull requests are considered
        issues in the GitHub API, so comments on pull requests are created using the issues comments endpoint.
        This is for general comments on the pull request, not review comments on specific lines of code.

        .EXAMPLE
        ```powershell
        New-GitHubPullRequestCommentByNumber -Owner 'octocat' -Repository 'Hello-World' -Number 1 -Body 'Great work!'
        ```

        Adds a comment to pull request #1.

        .OUTPUTS
        PSCustomObject

        .NOTES
        [Create an issue comment](https://docs.github.com/rest/issues/comments#create-an-issue-comment)
    #>
    [OutputType([PSCustomObject])]
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

        # The contents of the comment.
        [Parameter(Mandatory)]
        [string] $Body,

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
        $requestBody = @{
            body = $Body
        }

        $apiParams = @{
            Method      = 'POST'
            APIEndpoint = "/repos/$Owner/$Repository/issues/$Number/comments"
            Body        = $requestBody
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("Pull request #$Number in $Owner/$Repository", 'Create comment')) {
            Invoke-GitHubAPI @apiParams | ForEach-Object {
                $_.Response
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
