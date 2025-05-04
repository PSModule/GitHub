filter Get-GitHubRepositoryByName {
    <#
        .SYNOPSIS
        Get a repository

        .DESCRIPTION
        The `parent` and `source` objects are present when the repository is a fork.
        `parent` is the repository this repository was forked from, `source` is the ultimate source for the network.
        **Note:** In order to see the `security_and_analysis` block for a repository you must have admin permissions
        for the repository or be an owner or security manager for the organization that owns the repository.
        For more information, see "[Managing security managers in your organization](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/managing-security-managers-in-your-organization)."

        .EXAMPLE
        Get-GitHubRepositoryByName -Owner 'octocat' -Name 'Hello-World'

        Gets the repository 'Hello-World' for the organization 'octocat'.

        .OUTPUTS
        GitHubRepository
    #>
    [OutputType([GitHubRepository])]
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

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
    `$Owner: String!,
    `$Name: String!
) {
  repositoryOwner(
    login: `$Owner
  ) {
    repository(
        name: `$Name
    ) {
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
  }
}
"@
            Variables = @{
                Owner = $Owner
                Name  = $Name
            }
            Context   = $Context
        }

        Invoke-GitHubGraphQLQuery @inputObject | ForEach-Object {
            [GitHubRepository]::new($_.repositoryOwner.repository)
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
