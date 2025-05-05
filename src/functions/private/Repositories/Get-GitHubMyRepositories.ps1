filter Get-GitHubMyRepositories {
    <#
        .SYNOPSIS
        List repositories for the authenticated user.

        .DESCRIPTION
        Lists repositories that the authenticated user has explicit permission (`:read`, `:write`, or `:admin`) to access.
        The authenticated user has explicit permission to access repositories they own, repositories where
        they are a collaborator, and repositories that they can access through an organization membership.

        .EXAMPLE
        Get-GitHubMyRepositories

        Gets the repositories for the authenticated user.

        .EXAMPLE
        Get-GitHubMyRepositories -Visibility 'private'

        Gets the private repositories for the authenticated user.

        .OUTPUTS
        GitHubRepository

        .LINK
        [List repositories for the authenticated user](https://docs.github.com/rest/repos/repos#list-repositories-for-the-authenticated-user)
    #>
    [OutputType([GitHubRepository])]
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseSingularNouns', '',
        Justification = 'Private function, not exposed to user.'
    )]
    param(
        # Limit the results to repositories with a visibility level.
        [ValidateSet('Internal', 'Private', 'Public')]
        [Parameter()]
        [string] $Visibility,

        # Limit the results to repositories where the user has this role.
        [ValidateSet('Owner', 'Collaborator', 'Organization_member')]
        [Parameter()]
        [string] $Affiliation = 'Owner',

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(0, 100)]
        [int] $PerPage,

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
            $inputObject = @{
                Query     = @"
query(
    `$PerPage: Int!,
    `$Cursor: String,
    `$Affiliations: [RepositoryAffiliation!],
    `$Visibility: RepositoryVisibility,
    `$IsArchived: Boolean,
    `$IsFork: Boolean
) {
  viewer {
    repositories(
        first: `$PerPage,
        after: `$Cursor,
        affiliations: `$Affiliations,
        visibility: `$Visibility,
        isArchived: `$IsArchived,
        isFork: `$IsFork
    ) {
      nodes {
        name
        owner {
          login
        }
        url
        diskUsage
        visibility
      }
      pageInfo {
        endCursor
        hasNextPage
      }
    }
  }
}
"@
                Variables = @{
                    PerPage      = $perPageSetting
                    Cursor       = $after
                    Affiliations = $Affiliation | ForEach-Object { $_.ToString().ToUpper() }
                    Visibility   = -not [string]::IsNullOrEmpty($Visibility) ? $Visibility.ToString().ToUpper() : $null
                    IsArchived   = $IsArchived
                    IsFork       = $IsFork
                }
                Context   = $Context
            }

            Invoke-GitHubGraphQLQuery @inputObject | ForEach-Object {
                $_.viewer.repositories.nodes | ForEach-Object {
                    [GitHubRepository]::new($_)
                }
                $hasNextPage = $response.pageInfo.hasNextPage
                $after = $response.pageInfo.endCursor
            }
        } while ($hasNextPage)
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
