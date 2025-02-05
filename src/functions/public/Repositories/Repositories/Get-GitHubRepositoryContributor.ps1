filter Get-GitHubRepositoryContributor {
    <#
        .SYNOPSIS
        List repository contributors

        .DESCRIPTION
        Lists contributors to the specified repository and sorts them by the number of commits per contributor in descending order.
        This endpoint may return information that is a few hours old because the GitHub REST API caches contributor data to improve performance.

        GitHub identifies contributors by author email address. This endpoint groups contribution counts by GitHub user,
        which includes all associated email addresses. To improve performance, only the first 500 author email addresses
        in the repository link to GitHub users. The rest will appear as anonymous contributors without associated GitHub user information.

        .EXAMPLE
        Get-GitHubRepositoryContributor -Owner 'PSModule' -Repository 'GitHub'

        Gets all contributors to the GitHub repository.

        .NOTES
        [List repository contributors](https://docs.github.com/rest/repos/repos#list-repository-contributors)
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
        [string] $Repository,

        # Wether to include anonymous contributors in results.
        [Parameter()]
        [switch] $Anon,

        # The number of results per page (max 100).
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
    }

    process {
        $body = @{
            anon     = $Anon
            per_page = $PerPage
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/contributors"
            Body        = $body
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
