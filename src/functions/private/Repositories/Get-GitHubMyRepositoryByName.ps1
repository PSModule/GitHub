filter Get-GitHubMyRepositoryByName {
    <#
        .SYNOPSIS
        List repositories for the authenticated user.

        .DESCRIPTION
        Lists repositories that the authenticated user has explicit permission (`:read`, `:write`, or `:admin`) to access.
        The authenticated user has explicit permission to access repositories they own, repositories where
        they are a collaborator, and repositories that they can access through an organization membership.

        .EXAMPLE
        Get-GitHubMyRepositoryByName

        Gets the repositories for the authenticated user.

        .OUTPUTS
        GitHubRepository
    #>
    [OutputType([GitHubRepository])]
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseSingularNouns', '',
        Justification = 'Private function, not exposed to user.'
    )]
    param(
        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Name,

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
        $inputObject = @{
            Query     = @"
query(
    `$Name: String!
) {
  viewer {
    repository(
      name: `$Name
    ) {
      id
      databaseId
      name
      owner {
        login
      }
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
      repositoryTopics(first: 20) {
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
  }
}
"@
            Variables = @{
                Name = $Name
            }
            Context   = $Context
        }

        Invoke-GitHubGraphQLQuery @inputObject | ForEach-Object {
            [GitHubRepository]::new($_.viewer.repository)
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
