filter Get-GitHubReleaseAll {
    <#
        .SYNOPSIS
        List releases

        .DESCRIPTION
        This returns a list of releases, which does not include regular Git tags that have not been associated with a release.
        To get a list of Git tags, use the [Repository Tags API](https://docs.github.com/rest/repos/repos#list-repository-tags).
        Information about published releases are available to everyone. Only users with push access will receive listings for draft releases.

        .EXAMPLE
        ```pwsh
        Get-GitHubReleaseAll -Owner 'octocat' -Repository 'hello-world'
        ```

        Gets all the releases for the repository 'hello-world' owned by 'octocat'.

        .INPUTS
        GitHubRepository

        .OUTPUTS
        GitHubRelease

        .NOTES
        [List releases](https://docs.github.com/rest/releases/releases#list-releases)
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseDeclaredVarsMoreThanAssignments', 'hasNextPage', Scope = 'Function',
        Justification = 'Unknown issue with var scoping in blocks.'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseDeclaredVarsMoreThanAssignments', 'after', Scope = 'Function',
        Justification = 'Unknown issue with var scoping in blocks.'
    )]
    [OutputType([GitHubRelease])]
    [CmdletBinding(SupportsPaging)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The number of results per page (max 100).
        [Parameter()]
        [System.Nullable[int]] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $hasNextPage = $true
        $after = $null
        $perPageSetting = Resolve-GitHubContextSetting -Name 'PerPage' -Value $PerPage -Context $Context

        do {
            $apiParams = @{
                Query     = @'
query($owner: String!, $repository: String!, $perPage: Int, $after: String) {
  repository(owner: $owner, name: $repository) {
    releases(first: $perPage, after: $after) {
      nodes {
        id
        databaseId
        tagName
        name
        description
        isLatest
        isDraft
        isPrerelease
        url
        createdAt
        publishedAt
        updatedAt
        author {
          login
        }
      }
      pageInfo {
        endCursor
        hasNextPage
      }
    }
  }
}
'@
                Variables = @{
                    owner      = $Owner
                    repository = $Repository
                    perPage    = $perPageSetting
                    after      = $after
                }
                Context   = $Context
            }

            Invoke-GitHubGraphQLQuery @apiParams | ForEach-Object {
                foreach ($release in $_.repository.releases.nodes) {
                    [GitHubRelease]::new($release, $Owner, $Repository, $null)
                }
                $hasNextPage = $_.repository.releases.pageInfo.hasNextPage
                $after = $_.repository.releases.pageInfo.endCursor
            }
        } while ($hasNextPage)
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
