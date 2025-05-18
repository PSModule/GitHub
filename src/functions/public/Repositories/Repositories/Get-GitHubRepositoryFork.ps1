filter Get-GitHubRepositoryFork {
    <#
        .SYNOPSIS
        List forks

        .DESCRIPTION
        List forks of a named repository.

        .EXAMPLE
        Get-GitHubRepositoryFork -Owner 'octocat' -Name 'Hello-World'

        List forks of the 'Hello-World' repository owned by 'octocat'.

        .NOTES
        [List forks](https://docs.github.com/rest/repos/forks#list-forks)
    #>
    [CmdletBinding()]
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
        [ValidateSet('newest', 'oldest', 'stargazers', 'watchers')]
        [string] $Sort = 'newest',

        # The number of results per page.
        [Parameter()]
        [ValidateRange(1, 100)]
        [System.Nullable[int]] $PerPage,

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
            sort     = $Sort
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Name/forks"
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
