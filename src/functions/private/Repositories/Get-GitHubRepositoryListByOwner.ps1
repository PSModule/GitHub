filter Get-GitHubRepositoryListByOwner {
    <#
        .SYNOPSIS
        List repositories for a user

        .DESCRIPTION
        Lists public repositories for the specified user.
        Note: For GitHub AE, this endpoint will list internal repositories for the specified user.

        .EXAMPLE
        Get-GitHubRepositoryListByOwner -Owner 'octocat'

        Gets the repositories for the user 'octocat'.

        .EXAMPLE
        Get-GitHubRepositoryListByOwner -Owner 'octocat' -Type 'member'

        Gets the repositories of organizations where the user 'octocat' is a member.

        .EXAMPLE
        Get-GitHubRepositoryListByOwner -Owner 'octocat' -Sort 'created' -Direction 'asc'

        Gets the repositories for the user 'octocat' sorted by creation date in ascending order.

        .OUTPUTS
        GitHubRepository

        .LINK
        [List repositories for a user](https://docs.github.com/rest/repos/repos#list-repositories-for-a-user)
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseDeclaredVarsMoreThanAssignments', 'hasNextPage', Scope = 'Function',
        Justification = 'Unknown issue with var scoping in blocks.'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseDeclaredVarsMoreThanAssignments', 'after', Scope = 'Function',
        Justification = 'Unknown issue with var scoping in blocks.'
    )]
    [OutputType([GitHubRepository])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # Limit the results to repositories with a visibility level.
        [ValidateSet('Internal', 'Private', 'Public')]
        [Parameter()]
        [string] $Visibility,

        # Limit the results to repositories where the user has this role.
        [ValidateSet('Owner', 'Collaborator', 'Organization_member')]
        [Parameter()]
        [string] $Affiliations = 'Owner',

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
        do {
            $inputObject = @{
                Query     = @"
query(
    `$Owner: String!,
    `$PerPage: Int!,
    `$Cursor: String,
    `$Affiliations: [RepositoryAffiliation!],
    `$Visibility: RepositoryVisibility,
    `$IsArchived: Boolean,
    `$IsFork: Boolean
) {
  repositoryOwner(
    login: `$Owner
  ) {
    repositories(
        first: `$PerPage,
        after: `$Cursor,
        affiliations: `$Affiliations,
        visibility: `$Visibility,
        isArchived: `$IsArchived,
        isFork: `$IsFork
    ) {
      nodes {
        id
        databaseId
        name
        owner {
          login
        }
        nameWithOwner
        url
        description
        createdAt
        updatedAt
        pushedAt
        archivedAt
        homepageUrl
        diskUsage
        primaryLanguage {
          name
          id
          color
        }
        hasIssuesEnabled
        hasProjectsEnabled
        hasWikiEnabled
        hasDiscussionsEnabled
        isArchived
        isDisabled
        isTemplate
        isFork
        licenseInfo {
          name
        }
        forkingAllowed
        webCommitSignoffRequired
        repositoryTopics(first: 100) {
          nodes {
            topic {
              name
            }
          }
        }
        visibility
        issues {
          totalCount
        }
        pullRequests {
          totalCount
        }
        stargazers {
          totalCount
        }
        watchers {
          totalCount
        }
        forks {
          totalCount
        }
        defaultBranchRef {
          name
        }
        viewerPermission
        squashMergeAllowed
        mergeCommitAllowed
        rebaseMergeAllowed
        autoMergeAllowed
        deleteBranchOnMerge
        allowUpdateBranch
        squashMergeCommitTitle
        squashMergeCommitMessage
        mergeCommitTitle
        mergeCommitMessage
        templateRepository {
          id
          databaseId
          name
          owner {
            login
          }
        }
        parent {
          name
          owner {
            login
          }
        }
        sshUrl
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
                    Owner        = $Owner
                    PerPage      = $PerPage
                    Cursor       = $after
                    Affiliations = $affiliations | ForEach-Object { $_.ToString().ToUpper() }
                    Visibility   = $visibility | ForEach-Object { $_.ToString().ToUpper() }
                    IsArchived   = $isArchived
                    IsFork       = $isFork
                }
                Context   = $Context
            }

            Invoke-GitHubGraphQLQuery @inputObject | ForEach-Object {
                foreach ($repository in $_.repositoryOwner.repositories.nodes) {
                    $repository
                }
                $hasNextPage = $_.repositoryOwner.repositories.pageInfo.hasNextPage
                $after = $_.repositoryOwner.repositories.pageInfo.endCursor
            }
        } while ($hasNextPage)
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
