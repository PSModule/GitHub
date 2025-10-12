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
        ```powershell
        Get-GitHubRepositoryContributor -Owner 'PSModule' -Name 'GitHub'
        ```

        Gets all contributors to the GitHub repository.

        .NOTES
        [List repository contributors](https://docs.github.com/rest/repos/repos#list-repository-contributors)

        .LINK
        https://psmodule.io/GitHub/Functions/Repositories/Repositories/Get-GitHubRepositoryContributor
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

        # Wether to include anonymous contributors in results.
        [Parameter()]
        [switch] $Anon,

        # The number of results per page (max 100).
        [Parameter()]
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
        $body = @{
            anon = $Anon
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Name/contributors"
            Body        = $body
            PerPage     = $PerPage
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
