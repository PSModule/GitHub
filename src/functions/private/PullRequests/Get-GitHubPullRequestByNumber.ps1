filter Get-GitHubPullRequestByNumber {
    <#
        .SYNOPSIS
        Get a pull request by number.

        .DESCRIPTION
        Gets a specific pull request in a repository by its pull request number.
        Anyone with read access to the repository can use this endpoint.

        .EXAMPLE
        ```powershell
        Get-GitHubPullRequestByNumber -Owner 'octocat' -Repository 'Hello-World' -Number 1
        ```

        Gets pull request #1 from the repository.

        .OUTPUTS
        GitHubPullRequest

        .NOTES
        [Get a pull request](https://docs.github.com/rest/pulls/pulls#get-a-pull-request)
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

        # The number that identifies the pull request.
        [Parameter(Mandatory)]
        [int] $Number,

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
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/pulls/$Number"
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            [GitHubPullRequest]::new($_.Response, $Owner, $Repository)
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
