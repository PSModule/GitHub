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
        Get-GitHubRepositoryContributor -Owner 'PSModule' -Repo 'GitHub'

        Gets all contributors to the GitHub repository.

        .NOTES
        [List repository contributors](https://docs.github.com/rest/repos/repos#list-repository-contributors)

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
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT

        if ([string]::IsNullOrEmpty($Owner)) {
            $Owner = $Context.Owner
        }
        Write-Debug "Owner : [$($Context.Owner)]"

        if ([string]::IsNullOrEmpty($Repo)) {
            $Repo = $Context.Repo
        }
        Write-Debug "Repo : [$($Context.Repo)]"
    }

    process {
        try {
            $body = @{
                anon     = $Anon
                per_page = $PerPage
            } | Remove-HashtableEntry -NullOrEmptyValues

            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/repos/$Owner/$Repo/contributors"
                Method      = 'GET'
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
        Write-Debug "[$commandName] - End"
    }
}
