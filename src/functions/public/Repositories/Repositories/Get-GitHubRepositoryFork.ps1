filter Get-GitHubRepositoryFork {
    <#
        .SYNOPSIS
        List forks

        .DESCRIPTION
        List forks of a named repository.

        .EXAMPLE
        Get-GitHubRepositoryFork -Owner 'octocat' -Repo 'Hello-World'

        List forks of the 'Hello-World' repository owned by 'octocat'.

        .NOTES
        [List forks](https://docs.github.com/rest/repos/forks#list-forks)
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
        [ValidateSet('newest', 'oldest', 'stargazers', 'watchers')]
        [string] $Sort = 'newest',

        # The number of results per page.
        [Parameter()]
        [ValidateRange(0, 100)]
        [int] $PerPage,

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

        if ([string]::IsNullOrEmpty($Owner)) {
            $Owner = $Context.Owner
        }
        Write-Debug "Owner: [$Owner]"

        if ([string]::IsNullOrEmpty($Repo)) {
            $Repo = $Context.Repo
        }
        Write-Debug "Repo: [$Repo]"
    }

    process {
        try {
            $body = @{
                sort     = $Sort
                per_page = $PerPage
            }
            $body | Remove-HashtableEntry -NullOrEmptyValues

            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/repos/$Owner/$Repo/forks"
                Method      = 'Get'
                Body        = $body
            }

            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
