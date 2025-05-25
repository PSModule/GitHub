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

        # Properties to include in the returned object.
        [Parameter()]
        [string[]] $Property = @(
            'ID',
            'NodeID'
            'Name',
            'Owner',
            'FullName',
            'Url',
            'Description',
            'CreatedAt',
            'UpdatedAt',
            'PushedAt',
            'ArchivedAt',
            'Homepage',
            'Size',
            'Language',
            'HasIssues',
            'HasProjects',
            'HasWiki',
            'HasDiscussions',
            'IsArchived',
            'IsTemplate',
            'IsFork',
            'License',
            'AllowForking',
            'RequireWebCommitSignoff',
            'Topics',
            'Visibility',
            'OpenIssues',
            'OpenPullRequests',
            'Stargazers',
            'Watchers',
            'Forks',
            'DefaultBranch',
            'Permissions',
            'AllowSquashMerge',
            'AllowMergeCommit',
            'AllowRebaseMerge',
            'AllowAutoMerge',
            'DeleteBranchOnMerge',
            'SuggestUpdateBranch',
            'SquashMergeCommitTitle',
            'SquashMergeCommitMessage',
            'MergeCommitTitle',
            'MergeCommitMessage',
            'TemplateRepository',
            'ForkRepository',
            'CustomProperties',
            'CloneUrl',
            'SshUrl',
            'GitUrl'
        ),

        # Additional properties to include in the returned object.
        [Parameter()]
        [string[]] $AdditionalProperty,

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
        $graphParams = @{
            PropertyList         = $Property + $AdditionalProperty
            PropertyToGraphQLMap = [GitHubRepository]::PropertyToGraphQLMap
        }
        $graphQLFields = ConvertTo-GitHubGraphQLField @graphParams

        $inputObject = @{
            Query     = @"
query(
    `$Name: String!
) {
  viewer {
    repository(
      name: `$Name
    ) {
$graphQLFields
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
